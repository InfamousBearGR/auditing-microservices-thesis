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


def main():
    results_dir = sys.argv[1] if len(sys.argv) > 1 else "benchmark/results"
    found = [s for s in SCENARIO_ORDER if os.path.isdir(os.path.join(results_dir, s))]
    if not found:
        print(f"no scenario dirs under {results_dir}", file=sys.stderr)
        return 1

    rows = {s: load_scenario(os.path.join(results_dir, s)) for s in found}

    # baseline reference for overhead %
    base_c = rows.get("baseline", {}).get("create_p50_ms")

    metrics = [
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
            "—" if base_c in (None, 0) or r.get("create_p50_ms") is None
            else f"{(r['create_p50_ms'] - base_c) / base_c * 100:+.1f}%")),
        ("Audit rows captured", lambda r: fmt(r.get("audit_rows"))),
        ("Audit storage", lambda r: mb(r.get("audit_bytes"))),
        ("Bytes / audit row", lambda r: (
            "—" if not r.get("audit_rows") else fmt(r["audit_bytes"] / r["audit_rows"], " B"))),
        ("Audit lag p50 (ms)", lambda r: fmt(r.get("lag_p50_ms"))),
        ("Audit lag p95 (ms)", lambda r: fmt(r.get("lag_p95_ms"))),
        ("Audit lag p99 (ms)", lambda r: fmt(r.get("lag_p99_ms"))),
    ]

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

    print("\n".join(md))
    print(f"\nwrote {md_path}\nwrote {csv_path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
