#!/usr/bin/env python3
"""Audit-method benchmark — combine per-scenario k6 + DB metrics into one table.

Reads benchmark/results/<scenario>/{k6-summary.json,storage.csv,lag.csv,
storage_compressed.csv,sse_lag.csv,integrity.csv} and writes comparison.csv +
comparison.md + comparison.html alongside them. Pure stdlib.

sse_lag.csv (cdc / cdc-failover, written by sse_probe.py) holds the end-to-end
latency from COMMIT in mainDb to an external SSE client; integrity.csv
(cdc-failover) the exact count of lost / duplicated events against the trigger
ground truth. cdc-idle / cdc-slot are overhead-decomposition controls that
produce only k6 metrics.

When the benchmark was run for several VU levels (VU_LEVELS in run-all.sh),
results live in benchmark/results/vus-<n>/<scenario>/...; pointing this script
at benchmark/results then summarises every level and writes
comparison-by-vus.md with the write-path latency of each scenario per level.

storage_compressed.csv (cdc only) holds the TimescaleDB hypertable sizes after
compress_chunk() on every chunk; it is optional — older result sets without it
simply show "—" for the compressed rows.

When a scenario was run several times (REPEATS>1 in run-all.sh), its results
live in benchmark/results/<scenario>/run-<k>/; every metric is then reported
as the MEDIAN across runs and a second table gives the min–max spread, so the
comparison is not hostage to one lucky or unlucky run. With ≥ 2 runs a third
section tests every scenario against baseline: difference of the medians, a
bootstrap 95 % confidence interval of that difference (runs resampled with
replacement, fixed seed) and the exact two-sided Mann–Whitney U p-value. With
5 runs per side the smallest attainable p is 2/252 ≈ 0.008; a CI that contains
0 or p > 0.05 means the difference is not distinguishable from run-to-run noise.

history.csv (history scenario) is reported in its own section: time, size and
peak memory of the History API when streaming the whole audit table as JSON and
as Parquet.
"""
import csv
import glob
import itertools
import json
import math
import os
import random
import statistics
import sys

SCENARIO_ORDER = ["baseline", "cdc", "triggers", "envers", "cdc-idle", "cdc-slot", "cdc-failover", "history"]


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
        # Counters that never fired are absent from the k6 summary: in a result set
        # written by the current load.js (it always counts mutation_attempts) that
        # means 0; in older result sets the metric simply did not exist (None).
        new_style = "mutation_attempts" in m

        def counter(name):
            v = trend(m, name, "count")
            return v if v is not None else (0 if new_style else None)
        row["attempts"] = counter("mutation_attempts")
        row["err_4xx"] = counter("mutations_err_4xx")
        row["err_5xx"] = counter("mutations_err_5xx")
        row["logins"] = counter("vu_logins")
        row["relogins"] = counter("vu_relogins")
        row["login_failures"] = counter("vu_login_failures")
        row["login_p50_ms"] = trend(m, "login_ms", "med")
        row["dropped_iterations"] = counter("dropped_iterations")
        row["fallbacks"] = counter("op_fallback_to_create")
        bench = data.get("bench") or {}
        if bench:
            row["executor"] = bench.get("executor")
            row["rate"] = bench.get("rate")

    storage = os.path.join(rdir, "storage.csv")
    if os.path.exists(storage):
        with open(storage) as f:
            for r in csv.DictReader(f):
                row["audit_rows"] += int(fnum(r["row_count"]) or 0)
                row["audit_bytes"] += int(fnum(r["total_bytes"]) or 0)
                # newer collect.sh: heap/toast/index split, tuple stats, size after VACUUM FULL
                for key, col in (("audit_bytes_compact", "compact_bytes"), ("audit_dead_tuples", "dead_tuples"),
                                 ("audit_index_bytes", "index_bytes"), ("audit_inserted_tuples", "inserted_tuples")):
                    v = fnum(r.get(col))
                    if v is not None:
                        row[key] = row.get(key, 0) + int(v)

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
                row["lag_max_ms"] = fnum(r.get("lag_max_ms"))

    sse = os.path.join(rdir, "sse_lag.csv")
    if os.path.exists(sse):
        with open(sse) as f:
            for r in csv.DictReader(f):
                row["sse_events"] = int(fnum(r.get("sample_events")) or 0)
                row["sse_p50_ms"] = fnum(r.get("lag_p50_ms"))
                row["sse_p95_ms"] = fnum(r.get("lag_p95_ms"))
                row["sse_p99_ms"] = fnum(r.get("lag_p99_ms"))
                row["sse_max_ms"] = fnum(r.get("lag_max_ms"))
                row["sse_reconnects"] = int(fnum(r.get("reconnects")) or 0)
                row["sse_capture_p50_ms"] = fnum(r.get("capture_p50_ms"))
                row["sse_deliver_p50_ms"] = fnum(r.get("deliver_p50_ms"))
                row["sse_stale"] = fnum(r.get("stale_skipped"))
                row["sse_duplicates"] = fnum(r.get("duplicates"))

    integ = os.path.join(rdir, "integrity.csv")
    if os.path.exists(integ):
        row.update({"int_trigger_rows": 0, "int_cdc_rows": 0, "int_duplicates": 0, "int_missing": 0})
        with open(integ) as f:
            for r in csv.DictReader(f):
                row["int_trigger_rows"] += int(fnum(r.get("trigger_rows")) or 0)
                row["int_cdc_rows"] += int(fnum(r.get("cdc_rows")) or 0)
                row["int_duplicates"] += int(fnum(r.get("duplicates")) or 0)
                row["int_missing"] += int(fnum(r.get("missing")) or 0)

    hist = os.path.join(rdir, "history.csv")
    if os.path.exists(hist):
        with open(hist) as f:
            recs = list(csv.DictReader(f))
        row["hist_checks"] = len(recs)
        row["hist_valid"] = sum(1 for r in recs if r.get("valid") == "1")
        for r in recs:
            req = r.get("request")
            if req in ("json_full", "parquet_full"):
                k = req.split("_")[0]
                row[f"hist_{k}_bytes"] = fnum(r.get("bytes"))
                row[f"hist_{k}_s"] = fnum(r.get("seconds"))
                row[f"hist_{k}_ttfb_s"] = fnum(r.get("ttfb_seconds"))
                row[f"hist_{k}_rss_kb"] = fnum(r.get("rss_peak_kb"))
                row[f"hist_{k}_rss0_kb"] = fnum(r.get("rss_start_kb"))
                row["hist_rows"] = fnum(r.get("db_rows"))
                row["hist_db_bytes"] = fnum(r.get("db_bytes"))
    return row


NUMERIC_KEYS = [
    "ops", "throughput_ops_s", "mut_ok", "mut_err", "req_p95_ms",
    "create_p50_ms", "create_p95_ms", "create_p99_ms",
    "update_p50_ms", "update_p95_ms", "update_p99_ms",
    "delete_p50_ms", "delete_p95_ms", "delete_p99_ms",
    "audit_rows", "audit_bytes", "audit_bytes_comp", "comp_ratio",
    "lag_p50_ms", "lag_p95_ms", "lag_p99_ms", "lag_max_ms",
    "sse_events", "sse_p50_ms", "sse_p95_ms", "sse_p99_ms", "sse_max_ms", "sse_reconnects",
    "int_trigger_rows", "int_cdc_rows", "int_duplicates", "int_missing",
    "attempts", "err_4xx", "err_5xx", "logins", "relogins", "login_failures", "login_p50_ms",
    "dropped_iterations", "fallbacks",
    "audit_bytes_compact", "audit_dead_tuples", "audit_index_bytes", "audit_inserted_tuples",
    "sse_capture_p50_ms", "sse_deliver_p50_ms", "sse_stale", "sse_duplicates",
    "hist_rows", "hist_db_bytes", "hist_json_bytes", "hist_json_s", "hist_json_ttfb_s", "hist_json_rss_kb",
    "hist_json_rss0_kb", "hist_parquet_bytes", "hist_parquet_s", "hist_parquet_ttfb_s", "hist_parquet_rss_kb",
    "hist_parquet_rss0_kb", "hist_checks", "hist_valid",
]
INT_KEYS = ("ops", "mut_ok", "mut_err", "audit_rows", "audit_bytes", "audit_bytes_comp",
            "sse_events", "sse_reconnects", "int_trigger_rows", "int_cdc_rows", "int_duplicates", "int_missing",
            "attempts", "err_4xx", "err_5xx", "logins", "relogins", "login_failures", "dropped_iterations",
            "fallbacks", "audit_bytes_compact", "audit_dead_tuples", "audit_index_bytes", "audit_inserted_tuples",
            "sse_stale", "sse_duplicates", "hist_rows", "hist_db_bytes", "hist_json_bytes", "hist_parquet_bytes",
            "hist_checks", "hist_valid")


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
    for k in ("executor", "rate"):
        if runs and runs[0].get(k) is not None:
            agg[k] = runs[0][k]
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
        ("Load model", lambda r: ("—" if not r.get("executor") else
                                  ("closed (shared-iterations)" if r["executor"] == "shared-iterations"
                                   else f"open, {fmt(r.get('rate'))} ops/s"))),
        ("Throughput (ops/s)", lambda r: fmt(r.get("throughput_ops_s"))),
        ("Mutations ok / err", lambda r: f"{fmt(r.get('mut_ok'))} / {fmt(r.get('mut_err'))}"),
        ("Errors 4xx / 5xx", lambda r: (
            "—" if r.get("err_4xx") is None else f"{fmt(r.get('err_4xx'))} / {fmt(r.get('err_5xx'))}")),
        ("Logins / re-logins", lambda r: (
            "—" if r.get("logins") is None else f"{fmt(r.get('logins'))} / {fmt(r.get('relogins'))}")),
        ("Login p50 (ms)", lambda r: fmt(r.get("login_p50_ms"))),
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
        ("Audit storage after VACUUM FULL", lambda r: mb(r.get("audit_bytes_compact"))),
        ("Dead tuples in audit tables", lambda r: fmt(r.get("audit_dead_tuples"))),
        ("Audit storage (compressed)", lambda r: mb(r.get("audit_bytes_comp"))),
        ("Compression ratio", lambda r: (
            "—" if r.get("comp_ratio") is None else f"{r['comp_ratio']:.2f}×")),
        ("Bytes / audit row", lambda r: (
            "—" if not r.get("audit_rows") else fmt(r["audit_bytes"] / r["audit_rows"], " B"))),
        ("Audit lag p50 (ms)", lambda r: fmt(r.get("lag_p50_ms"))),
        ("Audit lag p95 (ms)", lambda r: fmt(r.get("lag_p95_ms"))),
        ("Audit lag p99 (ms)", lambda r: fmt(r.get("lag_p99_ms"))),
        ("Audit lag max (ms)", lambda r: fmt(r.get("lag_max_ms"))),
        ("SSE events received", lambda r: fmt(r.get("sse_events"))),
        ("SSE lag p50 (ms)", lambda r: fmt(r.get("sse_p50_ms"))),
        ("SSE lag p95 (ms)", lambda r: fmt(r.get("sse_p95_ms"))),
        ("SSE lag p99 (ms)", lambda r: fmt(r.get("sse_p99_ms"))),
        ("SSE lag max (ms)", lambda r: fmt(r.get("sse_max_ms"))),
        ("SSE commit→Debezium p50 (ms)", lambda r: fmt(r.get("sse_capture_p50_ms"))),
        ("SSE Debezium→client p50 (ms)", lambda r: fmt(r.get("sse_deliver_p50_ms"))),
        ("SSE duplicate / stale events", lambda r: (
            "—" if r.get("sse_duplicates") is None else f"{fmt(r.get('sse_duplicates'))} / {fmt(r.get('sse_stale'))}")),
        ("Integrity: trigger rows (ground truth)", lambda r: fmt(r.get("int_trigger_rows"))),
        ("Integrity: CDC rows", lambda r: fmt(r.get("int_cdc_rows"))),
        ("Integrity: missing events", lambda r: fmt(r.get("int_missing"))),
        ("Integrity: duplicate events", lambda r: fmt(r.get("int_duplicates"))),
    ]
    return rows if has_comp else [m for m in rows if m[0] not in COMP_LABELS]


# ── statistics (pure stdlib) ─────────────────────────────────────────────────
def _ranks(values):
    """1-based ranks, ties get the average rank."""
    order = sorted(range(len(values)), key=lambda i: values[i])
    ranks = [0.0] * len(values)
    i = 0
    while i < len(order):
        j = i
        while j + 1 < len(order) and values[order[j + 1]] == values[order[i]]:
            j += 1
        r = (i + j) / 2.0 + 1.0
        for k in range(i, j + 1):
            ranks[order[k]] = r
        i = j + 1
    return ranks


def mann_whitney_p(a, b):
    """Two-sided Mann–Whitney U p-value: exact (all relabellings of the pooled
    ranks, so ties are handled) when C(n1+n2, n1) ≤ 200 000, else the normal
    approximation with continuity correction. None if a group has < 2 values."""
    n1, n2 = len(a), len(b)
    if n1 < 2 or n2 < 2:
        return None
    ranks = _ranks(list(a) + list(b))
    mu = n1 * n2 / 2.0
    u_obs = sum(ranks[:n1]) - n1 * (n1 + 1) / 2.0
    dev = abs(u_obs - mu)
    total = math.comb(n1 + n2, n1)
    if total <= 200_000:
        hits = 0
        for idx in itertools.combinations(range(n1 + n2), n1):
            u = sum(ranks[k] for k in idx) - n1 * (n1 + 1) / 2.0
            if abs(u - mu) >= dev - 1e-9:
                hits += 1
        return hits / total
    sd = math.sqrt(n1 * n2 * (n1 + n2 + 1) / 12.0)
    if sd == 0:
        return 1.0
    z = max(0.0, dev - 0.5) / sd
    return math.erfc(z / math.sqrt(2.0))


def bootstrap_ci_median_diff(a, b, n_boot=10_000, seed=20261015):
    """95 % percentile-bootstrap CI of median(a) − median(b), resampling the runs
    of each group with replacement (fixed seed → reproducible)."""
    if len(a) < 2 or len(b) < 2:
        return None
    rng = random.Random(seed)
    diffs = sorted(statistics.median(rng.choices(a, k=len(a))) - statistics.median(rng.choices(b, k=len(b)))
                   for _ in range(n_boot))
    return diffs[int(0.025 * n_boot)], diffs[int(0.975 * n_boot) - 1]


STAT_KEYS = [("Create p50 (ms)", "create_p50_ms"), ("Create p95 (ms)", "create_p95_ms"),
             ("Create p99 (ms)", "create_p99_ms"), ("Update p50 (ms)", "update_p50_ms"),
             ("Delete p50 (ms)", "delete_p50_ms"), ("Throughput (ops/s)", "throughput_ops_s")]


def stats_section(found, runs):
    """Markdown lines: every scenario vs baseline, per metric."""
    if "baseline" not in runs:
        return []
    base_runs = runs["baseline"]
    lines = ["\n## Statistical comparison with baseline\n",
             "Δ = median(scenario) − median(baseline) over the runs; CI = 95 % bootstrap interval of Δ "
             "(10 000 resamples of the runs); p = exact two-sided Mann–Whitney U. A CI that contains 0 "
             "or p > 0.05 means the difference is within run-to-run noise.\n",
             "| Scenario | Metric | baseline | scenario | Δ | Δ % | 95 % CI of Δ | p |",
             "|---|---|---|---|---|---|---|---|"]
    rows_written = 0
    for s in found:
        if s == "baseline" or s == "history":
            continue
        for label, key in STAT_KEYS:
            a = [r[key] for r in runs[s] if r.get(key) is not None]
            b = [r[key] for r in base_runs if r.get(key) is not None]
            if len(a) < 2 or len(b) < 2:
                continue
            ma, mb_ = statistics.median(a), statistics.median(b)
            d = ma - mb_
            pct = (d / mb_ * 100.0) if mb_ else None
            ci = bootstrap_ci_median_diff(a, b)
            p = mann_whitney_p(a, b)
            lines.append(f"| {s} | {label} | {fmt(mb_)} | {fmt(ma)} | {d:+,.1f} | "
                         f"{'—' if pct is None else f'{pct:+.1f}%'} | "
                         f"{'—' if ci is None else f'[{ci[0]:+,.1f}, {ci[1]:+,.1f}]'} | "
                         f"{'—' if p is None else f'{p:.3f}'} |")
            rows_written += 1
    return lines if rows_written else []


def history_section(rows):
    """Markdown lines for the history scenario (History API, JSON vs Parquet)."""
    r = rows.get("history")
    if not r:
        return []
    def kb_mb(v):
        return "—" if v is None else f"{v / 1024:.1f} MB"
    lines = ["\n## History API — streaming the whole audit table\n",
             f"{fmt(r.get('hist_rows'))} synthetic rows in company_audit ({mb(r.get('hist_db_bytes'))} in TimescaleDB); "
             f"checks passed: {fmt(r.get('hist_valid'))} / {fmt(r.get('hist_checks'))}. "
             "Peak memory = VmHWM of the service process (restarted before each request).\n",
             "| Format | Response size | Time (s) | Time to first byte (s) | Peak RSS | RSS at start | Bytes / row |",
             "|---|---|---|---|---|---|---|"]
    for k, label in (("json", "JSON stream"), ("parquet", "Parquet export")):
        size = r.get(f"hist_{k}_bytes")
        rows_n = r.get("hist_rows")
        lines.append(f"| {label} | {mb(size)} | {fmt(r.get(f'hist_{k}_s'))} | {fmt(r.get(f'hist_{k}_ttfb_s'))} | "
                     f"{kb_mb(r.get(f'hist_{k}_rss_kb'))} | {kb_mb(r.get(f'hist_{k}_rss0_kb'))} | "
                     f"{'—' if not size or not rows_n else fmt(size / rows_n, ' B')} |")
    return lines


def summarize_levels(results_dir, levels):
    """results/vus-<n>/ per VU level: summarise each level, then one table with the
    write-path latency and throughput of every scenario per level (thesis §5.3:
    does the CDC overhead grow with concurrency?)."""
    per_level = {}
    for lvl in levels:
        d = os.path.join(results_dir, f"vus-{lvl}")
        found = [s for s in SCENARIO_ORDER if os.path.isdir(os.path.join(d, s))]
        if not found:
            continue
        summarize_dir(d)
        per_level[lvl] = {s: load_scenario_runs(os.path.join(d, s))[0] for s in found}
    if not per_level:
        return 1
    scen = [s for s in SCENARIO_ORDER if s != "history" and any(s in r for r in per_level.values())]
    md = ["# Audit-method comparison — by concurrency level (VUs)\n",
          "Median per scenario (and run, when REPEATS>1). Overhead = create p50 relative to baseline at the same level.\n"]
    for key, label in (("create_p50_ms", "Create p50 (ms)"), ("create_p95_ms", "Create p95 (ms)"),
                       ("create_p99_ms", "Create p99 (ms)"), ("throughput_ops_s", "Throughput (ops/s)"),
                       ("lag_p50_ms", "Audit lag p50 (ms)"), ("lag_p99_ms", "Audit lag p99 (ms)"),
                       ("sse_p50_ms", "SSE lag p50 (ms)"), ("sse_p99_ms", "SSE lag p99 (ms)")):
        md.append(f"\n## {label}\n")
        md.append("| VUs | " + " | ".join(scen) + " |")
        md.append("|" + "---|" * (len(scen) + 1))
        for lvl in levels:
            rows = per_level.get(lvl, {})
            cells = []
            for s in scen:
                v = rows.get(s, {}).get(key)
                cell = fmt(v)
                if key == "create_p50_ms" and v is not None and s != "baseline":
                    b = rows.get("baseline", {}).get("create_p50_ms")
                    if b:
                        cell += f" ({(v - b) / b * 100:+.1f}%)"
                cells.append(cell)
            md.append(f"| {lvl} | " + " | ".join(cells) + " |")
    out = os.path.join(results_dir, "comparison-by-vus.md")
    with open(out, "w") as f:
        f.write("\n".join(md) + "\n")
    print("\n".join(md))
    print(f"\nwrote {out}")
    return 0


def main():
    results_dir = sys.argv[1] if len(sys.argv) > 1 else "benchmark/results"
    found = [s for s in SCENARIO_ORDER if os.path.isdir(os.path.join(results_dir, s))]
    levels = sorted((int(os.path.basename(d).split("-", 1)[1]) for d in glob.glob(os.path.join(results_dir, "vus-*"))
                     if os.path.basename(d).split("-", 1)[1].isdigit()))
    if not found and levels:
        return summarize_levels(results_dir, levels)
    if not found:
        print(f"no scenario dirs under {results_dir}", file=sys.stderr)
        return 1
    return summarize_dir(results_dir)


def summarize_dir(results_dir):
    all_found = [s for s in SCENARIO_ORDER if os.path.isdir(os.path.join(results_dir, s))]

    loaded = {s: load_scenario_runs(os.path.join(results_dir, s)) for s in all_found}
    rows = {s: loaded[s][0] for s in all_found}
    runs = {s: loaded[s][1] for s in all_found}
    # history is not a write-path scenario → its own section, not a table column
    found = [s for s in all_found if s != "history"]
    if not found:
        md = ["# Audit-method comparison — results\n"] + history_section(rows)
        md_path = os.path.join(results_dir, "comparison.md")
        with open(md_path, "w") as f:
            f.write("\n".join(md) + "\n")
        print("\n".join(md))
        print(f"\nwrote {md_path}")
        return 0
    n_runs = max(rows[s].get("n_runs", 1) for s in found)

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
              "TimescaleDB hypertables is measured with hypertable_size() (parent + chunks)." + comp_note +
              " SSE lag = arrival at an external SSE client − commit time (Debezium source.ts_ms, the same reference as "
              "the audit store's changed_at), split into commit→Debezium (envelope ts_ms) and Debezium→client "
              "(sse_probe.py). Audit storage = on-disk size including dead tuples of rolled-back transactions; "
              "'after VACUUM FULL' = size of the live rows only. "
              "cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector "
              "streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the "
              "run, with triggers as ground truth for the missing/duplicate counts._\n")
    if n_runs > 1:
        spread_keys = [("Create p50 (ms)", "create_p50_ms"), ("Create p95 (ms)", "create_p95_ms"),
                       ("Create p99 (ms)", "create_p99_ms"), ("Update p50 (ms)", "update_p50_ms"),
                       ("Throughput (ops/s)", "throughput_ops_s"), ("Audit rows captured", "audit_rows"),
                       ("Audit storage (MB)", "audit_bytes"),
                       ("Audit storage compressed (MB)", "audit_bytes_comp"),
                       ("Compression ratio", "comp_ratio"), ("Audit lag p50 (ms)", "lag_p50_ms"),
                       ("Audit lag p99 (ms)", "lag_p99_ms"), ("SSE lag p50 (ms)", "sse_p50_ms"),
                       ("SSE lag p99 (ms)", "sse_p99_ms"), ("Integrity: missing events", "int_missing"),
                       ("Integrity: duplicate events", "int_duplicates")]
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
    if n_runs > 1:
        md += stats_section(found, runs)
    md += history_section(rows)
    md_path = os.path.join(results_dir, "comparison.md")
    with open(md_path, "w") as f:
        f.write("\n".join(md) + "\n")

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
