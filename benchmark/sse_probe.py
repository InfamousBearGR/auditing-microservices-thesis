#!/usr/bin/env python3
"""Audit-method benchmark — SSE end-to-end latency probe.

Subscribes to the SSE Bridge (/stream/<table>) for every table in TABLES and,
for every change event received, measures

    lag_ms = (wall-clock time the event arrived at the client)
           - (changedAt in the event = Debezium source.ts_ms = commit time in mainDb)

i.e. the time from COMMIT in the source database until an external party holding
an open SSE connection has the event in hand (WAL decoding + Debezium + Kafka +
bridge + HTTP). Heartbeat events are ignored. The clocks of mainDb and of this
probe are the same host clock when everything runs on one Docker host, which is
the benchmark's setup.

Runs until SIGTERM/SIGINT (run-all.sh starts it as a container before k6 and
`docker stop`s it after the pipeline has drained), then writes

    <OUT_DIR>/sse_lag.csv          one summary row: percentiles over all events
    <OUT_DIR>/sse_lag_tables.csv   per-table event counts and percentiles
    <OUT_DIR>/sse_lag_samples.csv  every sample (table, received_ms, lag_ms)

Pure stdlib (runs in the python:3.12-alpine image). Env knobs:
    SSE_URL      default http://sse-bridge:8080
    API_KEY      default bench_api_key   (seeded by run-all.sh with access to all tables)
    TABLES       default "company person legal_entity member company_stocks company_capital"
    OUT_DIR      default /out
    SCENARIO     label written into the CSVs (default cdc)
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

stop = threading.Event()
lock = threading.Lock()
samples = []            # (table, received_epoch_ms, lag_ms)
reconnects = {t: 0 for t in TABLES}
errors = {t: 0 for t in TABLES}


def now_ms():
    return time.time() * 1000.0


def parse_changed_at(value):
    """changedAt is an ISO-8601 instant (e.g. 2026-10-14T17:04:31.113Z) or epoch ms."""
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


def handle_event(table, payload):
    received = now_ms()
    try:
        ev = json.loads(payload)
    except json.JSONDecodeError:
        return
    if not isinstance(ev, dict) or ev.get("eventType") == "HEARTBEAT":
        return
    changed = parse_changed_at(ev.get("changedAt"))
    if changed is None:
        return
    with lock:
        samples.append((table, received, received - changed))


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
    vals = sorted(vals)
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
    all_lags = [r[2] for r in rows]
    s = summarize(all_lags)
    with open(os.path.join(OUT_DIR, "sse_lag.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["scenario", "sample_events", "lag_p50_ms", "lag_p95_ms", "lag_p99_ms", "lag_max_ms",
                    "reconnects", "errors"])
        w.writerow([SCENARIO, s["n"], fmt(s["p50"]), fmt(s["p95"]), fmt(s["p99"]), fmt(s["max"]),
                    sum(reconnects.values()), sum(errors.values())])
    with open(os.path.join(OUT_DIR, "sse_lag_tables.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["scenario", "table", "sample_events", "lag_p50_ms", "lag_p95_ms", "lag_p99_ms", "lag_max_ms",
                    "reconnects", "errors"])
        for t in TABLES:
            st = summarize([r[2] for r in rows if r[0] == t])
            w.writerow([SCENARIO, t, st["n"], fmt(st["p50"]), fmt(st["p95"]), fmt(st["p99"]), fmt(st["max"]),
                        reconnects[t], errors[t]])
    with open(os.path.join(OUT_DIR, "sse_lag_samples.csv"), "w", newline="") as f:
        w = csv.writer(f, lineterminator="\n")
        w.writerow(["table", "received_epoch_ms", "lag_ms"])
        for t, rec, lag in rows:
            w.writerow([t, f"{rec:.0f}", f"{lag:.2f}"])
    print(f"[sse_probe] {s['n']} events, p50={fmt(s['p50'])} p95={fmt(s['p95'])} "
          f"p99={fmt(s['p99'])} max={fmt(s['max'])} ms; wrote {OUT_DIR}/sse_lag.csv")


def main():
    def on_signal(signum, frame):
        stop.set()
    signal.signal(signal.SIGTERM, on_signal)
    signal.signal(signal.SIGINT, on_signal)

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
