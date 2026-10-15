#!/usr/bin/env python3
"""Audit-method benchmark — sanity checks over a results directory.

run-all.sh calls this at the end of every run (SMOKE=1 makes a failure fail the
whole run). It walks <results>/<scenario>/ (and run-<k>/, vus-<n>/ layouts) and
checks that each scenario produced the outputs the thesis relies on and that the
numbers are plausible, e.g.:

  * k6 ran the planned workload: iterations, one mutation attempt per iteration,
    most mutations succeeded, no login failures, few 5xx;
  * sessions were reused (re-logins are reported — a WARN, not a failure);
  * every audited scenario stored at least ~one audit row per successful mutation;
  * CDC: lag measured, the SSE probe received the events, the bridge sends the
    commit time (changedAt) and the Debezium time (capturedAt), no negative lag;
  * cdc-failover: no missing event against the trigger ground truth, the faults
    were injected and fell inside the workload;
  * history: every History API check passed.

Usage: python3 benchmark/smoke_check.py [results_dir]   (exit code 1 on any FAIL)
Pure stdlib.
"""
import csv
import glob
import json
import os
import sys

SCENARIOS = ["baseline", "cdc", "triggers", "envers", "cdc-idle", "cdc-slot", "cdc-failover", "history"]
AUDITED = {"cdc", "triggers", "envers", "cdc-failover"}
CORE = {"company_audit", "person_audit", "legal_entity_audit", "member_audit", "company_stocks_audit",
        "company_capital_audit"}

results = []   # (where, check, status, detail)


def add(where, check, ok, detail="", warn_only=False):
    status = "PASS" if ok else ("WARN" if warn_only else "FAIL")
    results.append((where, check, status, detail))


def fnum(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return None


def read_csv(path):
    if not os.path.exists(path):
        return None
    with open(path, newline="") as f:
        return list(csv.DictReader(f))


def k6_metric(m, name, stat="count"):
    v = m.get(name, {}).get("values", {}).get(stat)
    return v


def check_k6(where, rdir):
    path = os.path.join(rdir, "k6-summary.json")
    if not os.path.exists(path):
        add(where, "k6 summary written", False, "k6-summary.json missing")
        return None
    with open(path) as f:
        data = json.load(f)
    m = data.get("metrics", {})
    bench = data.get("bench", {})
    iters = k6_metric(m, "iterations") or 0
    planned = bench.get("totalOps")
    if planned:
        if bench.get("executor") == "constant-arrival-rate":
            dropped = k6_metric(m, "dropped_iterations") or 0
            add(where, "open-model workload kept up", dropped <= 0.05 * planned,
                f"{iters:.0f} iterations, {dropped:.0f} dropped of {planned}", warn_only=True)
        else:
            add(where, "planned iterations ran", iters == planned, f"{iters:.0f} / {planned}")
    attempts = k6_metric(m, "mutation_attempts")
    if attempts is None:
        add(where, "load.js version", False, "no mutation_attempts metric — old load.js?")
        return None
    add(where, "one mutation per iteration", attempts == iters, f"{attempts:.0f} attempts / {iters:.0f} iterations")
    ok = k6_metric(m, "mutations_ok") or 0
    err = k6_metric(m, "mutations_err") or 0
    ratio = ok / attempts if attempts else 0
    add(where, "mutations succeed", ratio >= 0.5, f"{ok:.0f} ok / {err:.0f} err ({ratio:.0%})")
    if ratio >= 0.5:
        add(where, "mutations mostly succeed (≥ 90 %)", ratio >= 0.9, f"{ratio:.1%}", warn_only=True)
    e5 = k6_metric(m, "mutations_err_5xx") or 0
    add(where, "few server errors (5xx ≤ 2 %)", e5 <= 0.02 * max(attempts, 1), f"{e5:.0f} × 5xx")
    lf = k6_metric(m, "vu_login_failures") or 0
    add(where, "no login failures", lf == 0, f"{lf:.0f} failed logins")
    logins = k6_metric(m, "vu_logins") or 0
    relog = k6_metric(m, "vu_relogins") or 0
    if not bench.get("loginEveryIteration"):
        how = ", ".join(f"{k.replace('session_rejected_', '')}={k6_metric(m, k):.0f}"
                        for k in ("session_rejected_403", "session_rejected_401", "session_rejected_expired_page")
                        if k6_metric(m, k))
        add(where, "sessions reused (re-logins ≤ 5 % of mutations)", relog <= 0.05 * max(attempts, 1),
            f"{logins:.0f} logins, {relog:.0f} re-logins{f' (rejected: {how})' if how else ''} — the API drops "
            "the session after each mutation; results stay valid (each rejected mutation is retried once after a "
            "cheap login and only the retry is timed) but every mutation then costs a login + a rejected request",
            warn_only=True)
    for op in ("create", "update"):
        if k6_metric(m, f"op_{op}_ms", "med") is None:
            add(where, f"{op} latency recorded", False, f"op_{op}_ms missing")
    return {"ok": ok, "attempts": attempts}


def check_storage(where, sc, rdir, k6):
    rows = read_csv(os.path.join(rdir, "storage.csv"))
    if rows is None:
        add(where, "storage.csv written", False, "missing")
        return None
    total = sum(int(fnum(r.get("row_count")) or 0) for r in rows)
    core = sum(int(fnum(r.get("row_count")) or 0) for r in rows if r.get("audit_table") in CORE)
    add(where, "audit rows stored", total > 0, f"{total} rows in {len(rows)} tables")
    if k6 and k6["ok"]:
        # every successful mutation writes ≥ 1 audited row change (deletes write 2);
        # Envers merges changes of one entity per transaction, so allow some slack.
        need = 0.9 * k6["ok"]
        add(where, "≥ ~1 audit row per successful mutation", total >= need,
            f"{total} audit rows for {k6['ok']:.0f} successful mutations")
    has_compact = any((r.get("compact_bytes") or "") != "" for r in rows)
    add(where, "storage breakdown + VACUUM FULL size measured", has_compact and "dead_tuples" in rows[0],
        "compact_bytes / dead_tuples columns" if has_compact else "old collect.sh?")
    return {"total": total, "core": core}


def check_cdc(where, sc, rdir, storage):
    lag = read_csv(os.path.join(rdir, "lag.csv"))
    if not lag:
        add(where, "audit lag measured", False, "lag.csv missing or empty")
    else:
        n = int(fnum(lag[0].get("sample_rows")) or 0)
        p50 = fnum(lag[0].get("lag_p50_ms"))
        add(where, "audit lag measured", n > 0 and p50 is not None, f"{n} rows, p50 {p50} ms")
        if p50 is not None:
            add(where, "audit lag non-negative", p50 >= 0, f"p50 {p50} ms")
    add(where, "lag time series written", os.path.exists(os.path.join(rdir, "lag_timeseries.csv")), "")
    sse = read_csv(os.path.join(rdir, "sse_lag.csv"))
    if sse is None:
        add(where, "SSE probe ran", False, "sse_lag.csv missing (SSE_PROBE=0?)", warn_only=True)
        return
    r = sse[0]
    n = int(fnum(r.get("sample_events")) or 0)
    p50 = fnum(r.get("lag_p50_ms"))
    cap = fnum(r.get("capture_p50_ms"))
    add(where, "SSE events received", n > 0, f"{n} events")
    if storage and storage["core"]:
        add(where, "SSE received ≥ 90 % of the audited changes", n >= 0.9 * storage["core"],
            f"{n} SSE events vs {storage['core']} audit rows of the 6 core tables")
    add(where, "bridge sends capturedAt (new sse-bridge image)", cap is not None,
        f"commit→Debezium p50 {cap} ms" if cap is not None else "capture_p50_ms empty → rebuild sse-bridge")
    if p50 is not None:
        add(where, "SSE lag measured from commit (non-negative)", p50 >= 0, f"p50 {p50} ms")
        if cap is not None:
            add(where, "SSE lag ≥ commit→Debezium part", p50 + 1 >= cap, f"{p50} ≥ {cap}")
    dup = int(fnum(r.get("duplicates")) or 0)
    add(where, "no duplicate SSE deliveries", dup == 0, f"{dup} duplicates", warn_only=(sc == "cdc-failover"))


def check_failover(where, rdir):
    integ = read_csv(os.path.join(rdir, "integrity.csv"))
    if not integ:
        add(where, "integrity.csv written", False, "missing")
    else:
        miss = sum(int(fnum(r.get("missing")) or 0) for r in integ)
        dup = sum(int(fnum(r.get("duplicates")) or 0) for r in integ)
        trig = sum(int(fnum(r.get("trigger_rows")) or 0) for r in integ)
        add(where, "ground truth captured (trigger rows > 0)", trig > 0, f"{trig} trigger rows")
        add(where, "no event lost under faults", miss == 0, f"missing {miss}")
        add(where, "duplicates (at-least-once) reported", True, f"duplicates {dup}")
    flog = os.path.join(rdir, "faults.log")
    if not os.path.exists(flog):
        add(where, "faults injected", False, "faults.log missing")
    else:
        text = open(flog).read()
        add(where, "consumer killed and restarted", "KILL audit-consumer" in text and "START audit-consumer" in text, "")
        add(where, "broker killed and restarted", "KILL kafka-" in text and "START kafka-" in text, "")
        add(where, "fault schedule completed", "fault schedule complete" in text, "")
    for f in ("cluster_before.txt", "cluster_after.txt"):
        add(where, f"{f} recorded", os.path.exists(os.path.join(rdir, f)), "", warn_only=True)


def check_history(where, rdir):
    rows = read_csv(os.path.join(rdir, "history.csv"))
    if not rows:
        add(where, "history.csv written", False, "missing or empty")
        return
    for r in rows:
        add(where, f"history {r.get('request')}", r.get("valid") == "1",
            f"HTTP {r.get('http_code')}, rows {r.get('rows')}, {r.get('bytes')} B, {r.get('seconds')} s, "
            f"peak RSS {r.get('rss_peak_kb')} kB")


def check_run(where, sc, rdir):
    failed = os.path.join(rdir, "FAILED")
    if os.path.exists(failed):
        add(where, "scenario completed", False, "aborted: " + open(failed).read().strip() + " — see run.log")
        return
    add(where, "versions.txt recorded", os.path.exists(os.path.join(rdir, "versions.txt")), "", warn_only=True)
    if sc == "history":
        check_history(where, rdir)
        return
    k6 = check_k6(where, rdir)
    storage = None
    if sc in AUDITED:
        storage = check_storage(where, sc, rdir, k6)
    if sc in ("cdc", "cdc-failover"):
        check_cdc(where, sc, rdir, storage)
    if sc == "cdc":
        comp = read_csv(os.path.join(rdir, "storage_compressed.csv"))
        add(where, "compressed size measured", bool(comp) and any(fnum(r.get("compressed_bytes")) for r in comp),
            "storage_compressed.csv")
    if sc == "cdc-failover":
        check_failover(where, rdir)


def scan(results_dir, prefix=""):
    found = False
    for sc in SCENARIOS:
        sdir = os.path.join(results_dir, sc)
        if not os.path.isdir(sdir):
            continue
        found = True
        runs = sorted(glob.glob(os.path.join(sdir, "run-*")), key=lambda d: int(d.rsplit("-", 1)[-1]))
        for rdir in (runs or [sdir]):
            where = prefix + sc + (f"/{os.path.basename(rdir)}" if runs else "")
            check_run(where, sc, rdir)
    return found


def main():
    results_dir = sys.argv[1] if len(sys.argv) > 1 else "benchmark/results"
    found = scan(results_dir)
    for lvl in sorted(glob.glob(os.path.join(results_dir, "vus-*"))):
        found |= scan(lvl, os.path.basename(lvl) + "/")
    if not found:
        print(f"no scenario results under {results_dir}", file=sys.stderr)
        return 1
    width = max(len(w) for w, *_ in results)
    cwidth = max(len(c) for _, c, *_ in results)
    for where, check, status, detail in results:
        mark = {"PASS": "  ok ", "WARN": " WARN", "FAIL": " FAIL"}[status]
        print(f"{mark}  {where:<{width}}  {check:<{cwidth}}  {detail}")
    fails = sum(1 for r in results if r[2] == "FAIL")
    warns = sum(1 for r in results if r[2] == "WARN")
    print(f"\n{len(results)} checks: {len(results) - fails - warns} passed, {warns} warnings, {fails} failed")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
