#!/usr/bin/env python3
"""Audit-method benchmark — SSE end-to-end latency probe.

Subscribes to the SSE Bridge (/stream/<table>) for every table in TABLES and,
for every change event received, measures

    lag_ms     = arrival at the client − changedAt
                 (changedAt = Debezium payload.source.ts_ms = COMMIT time in mainDb,
                  the same reference the audit consumer stores as changed_at)
    capture_ms = capturedAt − changedAt
                 (capturedAt = Debezium envelope payload.ts_ms = when Debezium
                  processed the change: WAL decoding + connector queueing)
    deliver_ms = arrival − capturedAt   (Kafka + bridge + HTTP)

so lag_ms = capture_ms + deliver_ms: the time from COMMIT in the source database
until an external party holding an open SSE connection has the event in hand.
Heartbeat events are ignored, and so are events committed before the probe
started (backlog, e.g. replayed after a bridge restart — they are counted as
stale_skipped, not as latency samples). A change_id seen twice on the same
table is counted as a duplicate delivery. The clocks of mainDb, Debezium and
this probe are the same host clock when everything runs on one Docker host,
which is the benchmark's setup.

Runs until SIGTERM/SIGINT (run-all.sh starts it as a container before k6 and
`docker stop`s it after the pipeline has drained), then writes

    <OUT_DIR>/sse_lag.csv          one summary row: percentiles over all events
    <OUT_DIR>/sse_lag_tables.csv   per-table event counts and percentiles
    <OUT_DIR>/sse_lag_samples.csv  every sample (table, received_ms, lag_ms, capture_ms)

Pure stdlib (runs in the python:3.12-alpine image). Env knobs:
    SSE_URL      default http://sse-bridge:8080
    API_KEY      default bench_api_key   (seeded by run-all.sh with access to all tables)
    TABLES       default "company person legal_entity member company_stocks company_capital"
    OUT_DIR      default /out
    SCENARIO     label written into the CSVs (default cdc)
    STALE_GRACE_MS  default 2000  (events committed earlier than probe start − grace are stale)
"""
import csv
import json
import os
import signal
import sys
import threading
import time
import urllib.error
import urllib.request
from datetime import datetime, timezone

SSE_URL = os.environ.get("SSE_URL", "http://sse-bridge:8080").rstrip("/")
API_KEY = os.environ.get("API_KEY", "bench_api_key")
TABLES = os.environ.get("TABLES", "company person legal_entity member company_stocks company_capital").split()
OUT_DIR = os.environ.get("OUT_DIR", "/out")
SCENARIO = os.environ.get("SCENARIO", "cdc")
STALE_GRACE_MS = float(os.environ.get("STALE_GRACE_MS", "2000"))

stop = threading.Event()
lock = threading.Lock()
samples = []            # (table, received_epoch_ms, lag_ms, capture_ms or None)
reconnects = {t: 0 for t in TABLES}
errors = {t: 0 for t in TABLES}
stale = {t: 0 for t in TABLES}
duplicates = {t: 0 for t in TABLES}
seen = {t: set() for t in TABLES}
START_MS = None


def now_ms():
    return time.time() * 1000.0


def parse_instant(value):
    """An ISO-8601 instant (e.g. 2026-10-14T17:04:31.113Z) or epoch ms → epoch ms."""
    if value is None:
        return None
    if isinstance(value, (int, float)):
        return float(value)
    s = str(value)
    if s.endswith("Z"):
        s = s[:-1] + "+00:00"
    try:
        return datetime.fromisoformat(s).astimezone(timezone.utc).timestamp() * 1000.0
    except ValueError:
        return None


# Backwards-compatible name used by earlier versions / tests.
parse_changed_at = parse_instant


def handle_event(table, payload):
    received = now_ms()
    try:
        ev = json.loads(payload)
    except json.JSONDecodeError:
        return
    if not isinstance(ev, dict) or ev.get("eventType") == "HEARTBEAT":
        return
    changed = parse_instant(ev.get("changedAt"))
    if changed is None:
        return
    captured = parse_instant(ev.get("capturedAt"))
    with lock:
        if START_MS is not None and changed < START_MS - STALE_GRACE_MS:
            stale[table] += 1
            return
        cid = ev.get("changeId")
        if cid is not None:
            if cid in seen[table]:
                duplicates[table] += 1
                return
            seen[table].add(cid)
        samples.append((table, received, received - changed,
                        (captured - changed) if captured is not None else None))


def stream(table):
    url = f"{SSE_URL}/stream/{table}"
    first = True
    while not stop.is_set():
        if not first:
            reconnects[table] += 1
            time.sleep(1.0)
        first = False
        req = urllib.request.Request(url, headers={"X-API-Key": API_KEY, "Accept": "text/event-stream"})
        try:
            with urllib.request.urlopen(req, timeout=60) as resp:
                data_lines = []
                for raw in resp:
                    if stop.is_set():
                        break
                    line = raw.decode("utf-8", "replace").rstrip("\r\n")
                    if line == "":
                        if data_lines:
                            handle_event(table, "\n".join(data_lines))
                            data_lines = []
                        continue
                    if line.startswith(":"):
                        continue                      # SSE comment
                    field, _, value = line.partition(":")
                    if value.startswith(" "):
                        value = value[1:]
                    if field == "data":
                        data_lines.append(value)
                if data_lines:
                    handle_event(table, "\n".join(data_lines))
        except urllib.error.HTTPError as e:
            errors[table] += 1
            print(f"[sse_probe] {table}: HTTP {e.code} — check API key/access", file=sys.stderr)
            if e.code in (401, 403):
                time.sleep(5.0)
        except Exception as e:                        # connection refused / reset / timeout
            errors[table] += 1
            if not stop.is_set():
                print(f"[sse_probe] {table}: {e.__class__.__name__}: {e}", file=sys.stderr)


def pct(sorted_vals, p):
    if not sorted_vals:
        return None
    k = max(0, min(len(sorted_vals) - 1, int(round(p * (len(sorted_vals) - 1)))))
    return sorted_vals[k]


def summarize(vals):
    vals = sorted(v for v in vals if v is not None)
    return {
        "n": len(vals),
        "p50": pct(vals, 0.50), "p95": pct(vals, 0.95), "p99": pct(vals, 0.99),
        "max": vals[-1] if vals else None,
    }


def fmt(v):
    return "" if v is None else f"{v:.2f}"


def write_results():
    os.makedirs(OUT_DIR, exist_ok=True)
    with lock:
        rows = list(samples)
    s = summarize([r[2] for r in rows])
    cap = summarize([r[3] for r in rows])
    dlv = summarize([r[2] - r[3] for r in rows if r[3] is not None])
    with open(os.path.join(OUT_DIR, "sse_lag.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["scenario", "sample_events", "lag_p50_ms", "lag_p95_ms", "lag_p99_ms", "lag_max_ms",
                    "reconnects", "errors",
                    "capture_p50_ms", "capture_p95_ms", "capture_p99_ms",
                    "deliver_p50_ms", "deliver_p95_ms", "deliver_p99_ms",
                    "stale_skipped", "duplicates"])
        w.writerow([SCENARIO, s["n"], fmt(s["p50"]), fmt(s["p95"]), fmt(s["p99"]), fmt(s["max"]),
                    sum(reconnects.values()), sum(errors.values()),
                    fmt(cap["p50"]), fmt(cap["p95"]), fmt(cap["p99"]),
                    fmt(dlv["p50"]), fmt(dlv["p95"]), fmt(dlv["p99"]),
                    sum(stale.values()), sum(duplicates.values())])
    with open(os.path.join(OUT_DIR, "sse_lag_tables.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["scenario", "table", "sample_events", "lag_p50_ms", "lag_p95_ms", "lag_p99_ms", "lag_max_ms",
                    "reconnects", "errors", "stale_skipped", "duplicates"])
        for t in TABLES:
            st = summarize([r[2] for r in rows if r[0] == t])
            w.writerow([SCENARIO, t, st["n"], fmt(st["p50"]), fmt(st["p95"]), fmt(st["p99"]), fmt(st["max"]),
                        reconnects[t], errors[t], stale[t], duplicates[t]])
    with open(os.path.join(OUT_DIR, "sse_lag_samples.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["table", "received_epoch_ms", "lag_ms", "capture_ms"])
        for t, rec, lag, capture in rows:
            w.writerow([t, f"{rec:.0f}", f"{lag:.2f}", fmt(capture)])
    print(f"[sse_probe] {s['n']} events, commit→client p50={fmt(s['p50'])} p95={fmt(s['p95'])} "
          f"p99={fmt(s['p99'])} max={fmt(s['max'])} ms (commit→Debezium p50={fmt(cap['p50'])}, "
          f"Debezium→client p50={fmt(dlv['p50'])}); stale={sum(stale.values())} "
          f"dup={sum(duplicates.values())}; wrote {OUT_DIR}/sse_lag.csv", flush=True)


def main():
    global START_MS

    def on_signal(signum, frame):
        stop.set()
    signal.signal(signal.SIGTERM, on_signal)
    signal.signal(signal.SIGINT, on_signal)

    START_MS = now_ms()
    threads = [threading.Thread(target=stream, args=(t,), daemon=True, name=f"sse-{t}") for t in TABLES]
    for th in threads:
        th.start()
    print(f"[sse_probe] subscribed to {len(TABLES)} streams at {SSE_URL}", flush=True)
    try:
        while not stop.wait(1.0):
            pass
    finally:
        write_results()


if __name__ == "__main__":
    main()
