#!/usr/bin/env python3
"""Audit-method benchmark — combine per-scenario k6 + DB metrics into one table.

Reads benchmark/results/<scenario>/{k6-summary.json,storage.csv,lag.csv,
storage_compressed.csv} and writes comparison.csv + comparison.md +
comparison.html alongside them. Pure stdlib.

storage_compressed.csv (cdc only) holds the TimescaleDB hypertable sizes after
compress_chunk() on every chunk; it is optional — older result sets without it
simply show "—" for the compressed rows.

When a scenario was run several times (REPEATS>1 in run-all.sh), its results
live in benchmark/results/<scenario>/run-<k>/; every metric is then reported
as the MEDIAN across runs and a second table gives the min–max spread, so the
comparison is not hostage to one lucky or unlucky run.
"""
import csv
import glob
import json
import os
import statistics
import sys

SCENARIO_ORDER = ["baseline", "cdc", "triggers", "envers"]


def fnum(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


def trend(metrics, name, stat):
    m = metrics.get(name)
    if not m:
        return None
    return m.get("values", {}).get(stat)


def load_scenario(rdir):
    row = {"audit_rows": 0, "audit_bytes": 0}

    k6_path = os.path.join(rdir, "k6-summary.json")
    if os.path.exists(k6_path):
        with open(k6_path) as f:
            data = json.load(f)
        m = data.get("metrics", {})
        row["ops"] = trend(m, "iterations", "count")
        row["throughput_ops_s"] = trend(m, "iterations", "rate")
        row["mut_ok"] = trend(m, "mutations_ok", "count")
        row["mut_err"] = trend(m, "mutations_err", "count")
        row["req_p95_ms"] = trend(m, "http_req_duration", "p(95)")
        for op in ("create", "update", "delete"):
            row[f"{op}_p50_ms"] = trend(m, f"op_{op}_ms", "med")
            row[f"{op}_p95_ms"] = trend(m, f"op_{op}_ms", "p(95)")
            row[f"{op}_p99_ms"] = trend(m, f"op_{op}_ms", "p(99)")

    storage = os.path.join(rdir, "storage.csv")
    if os.path.exists(storage):
        with open(storage) as f:
            for r in csv.DictReader(f):
                row["audit_rows"] += int(fnum(r["row_count"]) or 0)
                row["audit_bytes"] += int(fnum(r["total_bytes"]) or 0)

    comp = os.path.join(rdir, "storage_compressed.csv")
    if os.path.exists(comp):
        unc_sum = comp_sum = 0
        with open(comp) as f:
            for r in csv.DictReader(f):
                unc_sum += int(fnum(r["uncompressed_bytes"]) or 0)
                comp_sum += int(fnum(r["compressed_bytes"]) or 0)
        if comp_sum:
            row["audit_bytes_comp"] = comp_sum
            row["comp_ratio"] = unc_sum / comp_sum

    lag = os.path.join(rdir, "lag.csv")
    if os.path.exists(lag):
        with open(lag) as f:
            for r in csv.DictReader(f):
                row["lag_p50_ms"] = fnum(r.get("lag_p50_ms"))
                row["lag_p95_ms"] = fnum(r.get("lag_p95_ms"))
                row["lag_p99_ms"] = fnum(r.get("lag_p99_ms"))
    return row


NUMERIC_KEYS = [
    "ops", "throughput_ops_s", "mut_ok", "mut_err", "req_p95_ms",
    "create_p50_ms", "create_p95_ms", "create_p99_ms",
    "update_p50_ms", "update_p95_ms", "update_p99_ms",
    "delete_p50_ms", "delete_p95_ms", "delete_p99_ms",
    "audit_rows", "audit_bytes", "audit_bytes_comp", "comp_ratio",
    "lag_p50_ms", "lag_p95_ms", "lag_p99_ms",
]
INT_KEYS = ("ops", "mut_ok", "mut_err", "audit_rows", "audit_bytes", "audit_bytes_comp")


def load_scenario_runs(sdir):
    """Load one scenario: either a single run in sdir or several run-<k>/ dirs.

    Returns (aggregated_row, runs) where runs is the list of per-run rows
    (length 1 for a single run). Aggregation = median per metric; integers
    (ops, counts, rows, bytes) are rounded back to int.
    """
    run_dirs = sorted(glob.glob(os.path.join(sdir, "run-*")),
                      key=lambda d: int(d.rsplit("-", 1)[-1]))
    if not run_dirs:
        row = load_scenario(sdir)
        row["n_runs"] = 1
        return row, [row]
    runs = [load_scenario(d) for d in run_dirs]
    agg = {"n_runs": len(runs)}
    for k in NUMERIC_KEYS:
        vals = [r[k] for r in runs if r.get(k) is not None]
        if not vals:
            continue
        med = statistics.median(vals)
        agg[k] = int(round(med)) if k in INT_KEYS else med
        agg[k + "_min"] = min(vals)
        agg[k + "_max"] = max(vals)
    return agg, runs


def compression_settings(results_dir):
    """segmentby/orderby used by collect.sh (compression_settings.txt in any cdc
    run dir); falls back to the collect.sh defaults for older result sets."""
    settings = {"segmentby": "", "orderby": "changed_at DESC"}
    paths = sorted(glob.glob(os.path.join(results_dir, "cdc", "compression_settings.txt")) +
                   glob.glob(os.path.join(results_dir, "cdc", "run-*", "compression_settings.txt")))
    if paths:
        with open(paths[0]) as f:
            for line in f:
                k, _, v = line.rstrip("\n").partition("=")
                if k in settings:
                    settings[k] = v
    return settings


def fmt(v, suffix=""):
    if v is None:
        return "—"
    if isinstance(v, float):
        return f"{v:,.1f}{suffix}"
    return f"{v:,}{suffix}"


def mb(bytes_):
    if not bytes_:
        return "—"
    return f"{bytes_ / 1_048_576:.2f} MB"


SCENARIO_COLORS = {
    "baseline": "#9e9e9e",
    "cdc": "#1976d2",
    "triggers": "#e64a19",
    "envers": "#388e3c",
}


def overhead_pct(r, base_c):
    c = r.get("create_p50_ms")
    if base_c in (None, 0) or c is None:
        return None
    return (c - base_c) / base_c * 100.0


def write_html(results_dir, found, rows, base_c, has_comp=True):
    """Self-contained HTML report: grouped bar charts + comparison table.

    Pulls RAW numeric values from `rows` (not the formatted md strings) so
    Chart.js can plot them. Chart.js is loaded from CDN — needs network to
    render the charts; the table renders offline regardless.
    """
    colors = [SCENARIO_COLORS.get(s, "#607d8b") for s in found]

    def series(key):
        return [rows[s].get(key) for s in found]

    # chart specs: (canvas id, title, y-axis label, {dataset-label: [values per scenario]})
    charts = [
        ("lat50", "Latency p50 by operation (ms)", "ms", {
            "create": series("create_p50_ms"),
            "update": series("update_p50_ms"),
            "delete": series("delete_p50_ms"),
        }),
        ("lat95", "Latency p95 by operation (ms)", "ms", {
            "create": series("create_p95_ms"),
            "update": series("update_p95_ms"),
        }),
        ("overhead", "Write-path overhead vs baseline (create p50, %)", "%", {
            "overhead %": [overhead_pct(rows[s], base_c) for s in found],
        }),
        ("rows", "Audit rows captured", "rows", {
            "rows": series("audit_rows"),
        }),
        ("storage", "Audit storage (MB)", "MB", {
            "uncompressed": [(b / 1_048_576 if b else None) for b in series("audit_bytes")],
            **({"compressed (cdc)": [(b / 1_048_576 if b else None) for b in series("audit_bytes_comp")]}
               if has_comp else {}),
        }),
        ("bpr", "Bytes per audit row", "B", {
            "B/row": [(rows[s]["audit_bytes"] / rows[s]["audit_rows"]
                       if rows[s].get("audit_rows") else None) for s in found],
        }),
        ("lag", "CDC audit lag (ms)", "ms", {
            "p50": series("lag_p50_ms"),
            "p95": series("lag_p95_ms"),
            "p99": series("lag_p99_ms"),
        }),
    ]

    # one chart config per spec. Single-dataset charts color bars per-scenario;
    # multi-dataset charts color by dataset and group on the scenario axis.
    palette = ["#1976d2", "#e64a19", "#388e3c", "#fbc02d", "#7b1fa2"]
    blocks = []
    for cid, title, ylab, datasets in charts:
        if len(datasets) == 1:
            (dlabel, vals), = datasets.items()
            ds = [{"label": dlabel, "data": vals, "backgroundColor": colors}]
        else:
            ds = [{"label": dl, "data": v, "backgroundColor": palette[i % len(palette)]}
                  for i, (dl, v) in enumerate(datasets.items())]
        cfg = {
            "type": "bar",
            "data": {"labels": found, "datasets": ds},
            "options": {
                "responsive": True,
                "plugins": {
                    "title": {"display": True, "text": title},
                    "legend": {"display": len(datasets) > 1},
                },
                "scales": {"y": {"title": {"display": True, "text": ylab},
                                 "beginAtZero": True}},
            },
        }
        blocks.append((cid, json.dumps(cfg)))

    # comparison table (reuse the same metric formatting as markdown)
    table_rows = "".join(
        "<tr><th>" + label + "</th>" +
        "".join("<td>" + fn(rows[s]) + "</td>" for s in found) + "</tr>"
        for label, fn in METRICS(base_c, has_comp)
    )
    header = "".join("<th>" + s + "</th>" for s in found)
    canvases = "".join(
        f'<div class="card"><canvas id="{cid}"></canvas></div>' for cid, _ in blocks
    )
    scripts = "".join(
        f'new Chart(document.getElementById("{cid}"),{cfg});' for cid, cfg in blocks
    )

    comp_html = (" Compressed storage (cdc) is hypertable_size() after compress_chunk() on all chunks."
                 if has_comp else "")
    html = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>Audit-method comparison</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
<style>
 body{{font-family:system-ui,sans-serif;margin:2rem;background:#fafafa;color:#222}}
 h1{{font-size:1.5rem}}
 .grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(380px,1fr));gap:1rem}}
 .card{{background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:1rem}}
 table{{border-collapse:collapse;margin-top:2rem;background:#fff;width:100%}}
 th,td{{border:1px solid #e0e0e0;padding:.4rem .7rem;text-align:right;font-variant-numeric:tabular-nums}}
 th:first-child,td:first-child{{text-align:left}}
 thead th{{background:#f5f5f5}}
 .note{{color:#666;font-size:.85rem;margin-top:1rem}}
</style></head>
<body>
<h1>Audit-method comparison — results</h1>
<div class="grid">{canvases}</div>
<table><thead><tr><th>Metric</th>{header}</tr></thead><tbody>{table_rows}</tbody></table>
<p class="note">Synchronous methods (triggers, envers) commit audit rows inside the
 mutation transaction, so audit lag is ~0 and not measured; CDC lag is
 ingested_at − changed_at across all *_audit rows.{comp_html} Charts need network access
 (Chart.js CDN); the table renders offline.</p>
<script>{scripts}</script>
</body></html>"""

    html_path = os.path.join(results_dir, "comparison.html")
    with open(html_path, "w") as f:
        f.write(html)
    return html_path


COMP_LABELS = ("Audit storage (compressed)", "Compression ratio")


def METRICS(base_c, has_comp=True):
    """Metric rows shared by md / csv / html. (label, row->formatted str).
    The compressed-storage rows are dropped when no run has storage_compressed.csv."""
    rows = [
        ("Total ops", lambda r: fmt(r.get("ops"))),
        ("Throughput (ops/s)", lambda r: fmt(r.get("throughput_ops_s"))),
        ("Mutations ok / err", lambda r: f"{fmt(r.get('mut_ok'))} / {fmt(r.get('mut_err'))}"),
        ("Create p50 (ms)", lambda r: fmt(r.get("create_p50_ms"))),
        ("Create p95 (ms)", lambda r: fmt(r.get("create_p95_ms"))),
        ("Create p99 (ms)", lambda r: fmt(r.get("create_p99_ms"))),
        ("Update p50 (ms)", lambda r: fmt(r.get("update_p50_ms"))),
        ("Update p95 (ms)", lambda r: fmt(r.get("update_p95_ms"))),
        ("Delete p50 (ms)", lambda r: fmt(r.get("delete_p50_ms"))),
        ("Overhead vs baseline (create p50)", lambda r: (
            "—" if overhead_pct(r, base_c) is None
            else f"{overhead_pct(r, base_c):+.1f}%")),
        ("Audit rows captured", lambda r: fmt(r.get("audit_rows"))),
        ("Audit storage", lambda r: mb(r.get("audit_bytes"))),
        ("Audit storage (compressed)", lambda r: mb(r.get("audit_bytes_comp"))),
        ("Compression ratio", lambda r: (
            "—" if r.get("comp_ratio") is None else f"{r['comp_ratio']:.2f}×")),
        ("Bytes / audit row", lambda r: (
            "—" if not r.get("audit_rows") else fmt(r["audit_bytes"] / r["audit_rows"], " B"))),
        ("Audit lag p50 (ms)", lambda r: fmt(r.get("lag_p50_ms"))),
        ("Audit lag p95 (ms)", lambda r: fmt(r.get("lag_p95_ms"))),
        ("Audit lag p99 (ms)", lambda r: fmt(r.get("lag_p99_ms"))),
    ]
    return rows if has_comp else [m for m in rows if m[0] not in COMP_LABELS]


def main():
    results_dir = sys.argv[1] if len(sys.argv) > 1 else "benchmark/results"
    found = [s for s in SCENARIO_ORDER if os.path.isdir(os.path.join(results_dir, s))]
    if not found:
        print(f"no scenario dirs under {results_dir}", file=sys.stderr)
        return 1

    loaded = {s: load_scenario_runs(os.path.join(results_dir, s)) for s in found}
    rows = {s: loaded[s][0] for s in found}
    runs = {s: loaded[s][1] for s in found}
    n_runs = max(r.get("n_runs", 1) for r in rows.values())

    # baseline reference for overhead %
    base_c = rows.get("baseline", {}).get("create_p50_ms")
    has_comp = any(r.get("audit_bytes_comp") for rs in runs.values() for r in rs)
    metrics = METRICS(base_c, has_comp)

    # markdown
    title = "# Audit-method comparison — results"
    if n_runs > 1:
        title += f" (median of {n_runs} runs per scenario)"
    md = [title + "\n",
          "| Metric | " + " | ".join(found) + " |",
          "|" + "---|" * (len(found) + 1)]
    for label, fn in metrics:
        md.append("| " + label + " | " + " | ".join(fn(rows[s]) for s in found) + " |")
    cs = compression_settings(results_dir)
    seg = f"segmentby {cs['segmentby']}" if cs["segmentby"] else "no segmentby"
    comp_note = (" Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression "
                 f"({seg}, orderby {cs['orderby']}) and running compress_chunk() on all "
                 "chunks; compression ratio = uncompressed / compressed bytes, summed over all "
                 "*_audit hypertables." if has_comp else "")
    md.append("\n_Synchronous methods (triggers, envers) commit audit rows inside "
              "the mutation transaction, so audit lag is ~0 and not measured; CDC lag "
              "is ingested_at − changed_at across all *_audit rows. Audit storage of "
              "TimescaleDB hypertables is measured with hypertable_size() (parent + chunks)." + comp_note + "_\n")
    if n_runs > 1:
        spread_keys = [("Create p50 (ms)", "create_p50_ms"), ("Create p95 (ms)", "create_p95_ms"),
                       ("Create p99 (ms)", "create_p99_ms"), ("Update p50 (ms)", "update_p50_ms"),
                       ("Throughput (ops/s)", "throughput_ops_s"), ("Audit rows captured", "audit_rows"),
                       ("Audit storage (MB)", "audit_bytes"),
                       ("Audit storage compressed (MB)", "audit_bytes_comp"),
                       ("Compression ratio", "comp_ratio"), ("Audit lag p50 (ms)", "lag_p50_ms"),
                       ("Audit lag p99 (ms)", "lag_p99_ms")]
        if not has_comp:
            spread_keys = [k for k in spread_keys if k[1] not in ("audit_bytes_comp", "comp_ratio")]
        md.append(f"\n## Run-to-run spread (min – max over {n_runs} runs)\n")
        md.append("| Metric | " + " | ".join(found) + " |")
        md.append("|" + "---|" * (len(found) + 1))
        for label, key in spread_keys:
            cells = []
            for s in found:
                lo, hi = rows[s].get(key + "_min"), rows[s].get(key + "_max")
                if lo is None:
                    cells.append("—")
                elif key in ("audit_bytes", "audit_bytes_comp"):
                    cells.append(f"{lo / 1_048_576:.2f} – {hi / 1_048_576:.2f}")
                elif key == "comp_ratio":
                    cells.append(f"{lo:.2f} – {hi:.2f}")
                else:
                    cells.append(f"{fmt(lo)} – {fmt(hi)}")
            md.append("| " + label + " | " + " | ".join(cells) + " |")
        md.append("\n## Per-run values\n")
        cols = ["Scenario", "Run", "Create p50", "Create p95", "Create p99", "Update p50",
                "ops/s", "Audit rows", "Audit MB"] + (["Audit MB (compressed)"] if has_comp else []) + \
               ["Lag p50", "Lag p99"]
        md.append("| " + " | ".join(cols) + " |")
        md.append("|" + "---|" * len(cols))
        for s in found:
            for i, r in enumerate(runs[s], 1):
                cells = [s, str(i), fmt(r.get("create_p50_ms")), fmt(r.get("create_p95_ms")),
                         fmt(r.get("create_p99_ms")), fmt(r.get("update_p50_ms")),
                         fmt(r.get("throughput_ops_s")), fmt(r.get("audit_rows")), mb(r.get("audit_bytes"))]
                if has_comp:
                    cells.append(mb(r.get("audit_bytes_comp")))
                cells += [fmt(r.get("lag_p50_ms")), fmt(r.get("lag_p99_ms"))]
                md.append("| " + " | ".join(cells) + " |")
    md_path = os.path.join(results_dir, "comparison.md")
    with open(md_path, "w") as f:
        f.write("\n".join(md))

    # csv
    csv_path = os.path.join(results_dir, "comparison.csv")
    with open(csv_path, "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["metric"] + found)
        for label, fn in metrics:
            w.writerow([label] + [fn(rows[s]) for s in found])

    html_path = write_html(results_dir, found, rows, base_c, has_comp)

    print("\n".join(md))
    print(f"\nwrote {md_path}\nwrote {csv_path}\nwrote {html_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
