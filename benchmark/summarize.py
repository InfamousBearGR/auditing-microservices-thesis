#!/usr/bin/env python3
"""Audit-method benchmark — combine per-scenario k6 + DB metrics into one table.

Reads benchmark/results/<scenario>/{k6-summary.json,storage.csv,lag.csv} and
writes comparison.csv + comparison.md alongside them. Pure stdlib.
"""
import csv
import json
import os
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

    lag = os.path.join(rdir, "lag.csv")
    if os.path.exists(lag):
        with open(lag) as f:
            for r in csv.DictReader(f):
                row["lag_p50_ms"] = fnum(r.get("lag_p50_ms"))
                row["lag_p95_ms"] = fnum(r.get("lag_p95_ms"))
                row["lag_p99_ms"] = fnum(r.get("lag_p99_ms"))
    return row


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


def write_html(results_dir, found, rows, base_c):
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
            "MB": [(b / 1_048_576 if b else None) for b in series("audit_bytes")],
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
        for label, fn in METRICS(base_c)
    )
    header = "".join("<th>" + s + "</th>" for s in found)
    canvases = "".join(
        f'<div class="card"><canvas id="{cid}"></canvas></div>' for cid, _ in blocks
    )
    scripts = "".join(
        f'new Chart(document.getElementById("{cid}"),{cfg});' for cid, cfg in blocks
    )

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
 ingested_at − changed_at across all *_audit rows. Charts need network access
 (Chart.js CDN); the table renders offline.</p>
<script>{scripts}</script>
</body></html>"""

    html_path = os.path.join(results_dir, "comparison.html")
    with open(html_path, "w") as f:
        f.write(html)
    return html_path


def METRICS(base_c):
    """Metric rows shared by md / csv / html. (label, row->formatted str)."""
    return [
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
        ("Bytes / audit row", lambda r: (
            "—" if not r.get("audit_rows") else fmt(r["audit_bytes"] / r["audit_rows"], " B"))),
        ("Audit lag p50 (ms)", lambda r: fmt(r.get("lag_p50_ms"))),
        ("Audit lag p95 (ms)", lambda r: fmt(r.get("lag_p95_ms"))),
        ("Audit lag p99 (ms)", lambda r: fmt(r.get("lag_p99_ms"))),
    ]


def main():
    results_dir = sys.argv[1] if len(sys.argv) > 1 else "benchmark/results"
    found = [s for s in SCENARIO_ORDER if os.path.isdir(os.path.join(results_dir, s))]
    if not found:
        print(f"no scenario dirs under {results_dir}", file=sys.stderr)
        return 1

    rows = {s: load_scenario(os.path.join(results_dir, s)) for s in found}

    # baseline reference for overhead %
    base_c = rows.get("baseline", {}).get("create_p50_ms")
    metrics = METRICS(base_c)

    # markdown
    md = ["# Audit-method comparison — results\n",
          "| Metric | " + " | ".join(found) + " |",
          "|" + "---|" * (len(found) + 1)]
    for label, fn in metrics:
        md.append("| " + label + " | " + " | ".join(fn(rows[s]) for s in found) + " |")
    md.append("\n_Synchronous methods (triggers, envers) commit audit rows inside "
              "the mutation transaction, so audit lag is ~0 and not measured; CDC lag "
              "is ingested_at − changed_at across all *_audit rows._\n")
    md_path = os.path.join(results_dir, "comparison.md")
    with open(md_path, "w") as f:
        f.write("\n".join(md))

    # csv
    csv_path = os.path.join(results_dir, "comparison.csv")
    with open(csv_path, "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["metric"] + found)
        for label, fn in metrics:
            w.writerow([label] + [fn(rows[s]) for s in found])

    html_path = write_html(results_dir, found, rows, base_c)

    print("\n".join(md))
    print(f"\nwrote {md_path}\nwrote {csv_path}\nwrote {html_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
