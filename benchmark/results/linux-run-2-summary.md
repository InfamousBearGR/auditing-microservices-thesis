# Linux benchmark run 2 — 2026-10-15

Extended audit-method benchmark: six scenarios (baseline | cdc | cdc-idle | cdc-slot | triggers | envers)
at two concurrency levels (8 and 64 VUs), a CDC compression series and a failure-injection series,
5 round-robin repeats each. Same host as the 2026-10-14 run (`linux-run-summary.md`); that series is
kept unchanged in the top-level `results/{baseline,cdc,triggers,envers}/` (a local, uncommitted copy of the
whole pre-run `results/` was made at `benchmark/results-2026-10-14/`).

## Host

| | |
|---|---|
| Date | 2026-10-15 (EEST, +03:00) |
| `uname -a` | `Linux InfamousBearArch 7.2.9-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 03 Oct 2026 11:43:28 +0000 x86_64 GNU/Linux` |
| CPU | AMD Ryzen 7 5700X3D, 8 cores / 16 threads |
| RAM | 31 GiB (≈27 GiB available at start) |
| Disk | Docker root `/var/lib/docker` on `/dev/sdd2` (ext4) — Samsung SSD 860 EVO 250 GB, SATA SSD; 7.6 GB free at start, 7.3–7.6 GB during the run |
| Docker | Engine 27.2.1 (overlayfs, cgroup v2), Compose 5.6.0 (`docker --version`: `Docker version 27.2.1, build 9e34c9b`; `docker compose version`: `Docker Compose version 5.6.0`) |
| Python | 3.14.8 |
| Images | same local images as 2026-10-14 (not re-pulled): `timescale/timescaledb:latest-pg15` b26180320dea (TimescaleDB 2.25.2), `postgres:15-alpine` fceb6f86328c, `quay.io/debezium/connect:latest` 7c0e311be6ff, `apache/kafka:latest` 9516fb7634ba, `grafana/k6:latest` 632ddbc81a4a, probe `python:3.12-alpine` 1b668429b351; app images rebuilt from `f4dfa46` before the run |
| Kafka | 3 brokers (KRaft); `docker compose config` shows `KAFKA_DEFAULT_REPLICATION_FACTOR=3`, `KAFKA_MIN_INSYNC_REPLICAS=2` on kafka-1/2/3; `audit-consumer` `restart: unless-stopped` |
| Background load | none; no containers running at start (load avg 0.86 four minutes after boot) |

## Commands and timestamps

```bash
git pull                                                      # already up to date (f4dfa46)
docker compose build business-registry-api audit-consumer sse-bridge
cp -r benchmark/results benchmark/results-2026-10-14

# 3. main series                                   2026-10-15T10:03:57+03:00 → 15:17:03 (rc=0)
SCENARIOS="baseline cdc cdc-idle cdc-slot triggers envers" VU_LEVELS="8 64" TOTAL_OPS=10000 REPEATS=5 CDC_DRAIN_S=120 ./benchmark/run-all.sh 2>&1 | tee benchmark/results/run-vus.log
# 4. compression series (CDC_DRAIN_S not set → default 20 s)   15:17:03 → 15:50:58 (rc=0)
SCENARIOS=cdc VUS=64 TOTAL_OPS=10000 REPEATS=5 COMPRESS_SEGMENTBY="" RESULTS_DIR="$PWD/benchmark/results/cdc-segmentby-none" ./benchmark/run-all.sh 2>&1 | tee benchmark/results/run-compress.log
# 5. failure injection                                         15:50:58 → 16:25:03 (rc=0)
SCENARIOS=cdc-failover VUS=64 TOTAL_OPS=10000 REPEATS=5 CDC_DRAIN_S=180 RESULTS_DIR="$PWD/benchmark/results/failover" ./benchmark/run-all.sh 2>&1 | tee benchmark/results/run-failover.log

# after step 3: run-all.sh's final summarise of results/ hit the old 2026-10-14 scenario dirs and
# took the single-dir path, so comparison-by-vus.md was not written; it was produced with:
python3 -c "import sys; sys.path.insert(0,'benchmark'); import summarize; sys.exit(summarize.summarize_levels('benchmark/results',[8,64]))"
# and the top-level comparison.{md,csv,html} it had regenerated (same 2026-10-14 numbers, extra empty rows)
# were restored byte-for-byte from that copy (identical to the committed 2026-10-14 files).
```

Timestamps also in `results/run-2-timestamps.txt`.

## Verification

- `vus-8/` and `vus-64/`: all 6 scenarios × run-1..5 have `k6-summary.json` + `storage.csv`; every `cdc/run-k`
  also has `lag.csv`, `sse_lag.csv`, `sse_lag_tables.csv`, `sse_lag_samples.csv`, `storage_compressed.csv`.
- `cdc-segmentby-none/cdc/run-1..5` have `storage_compressed.csv` (+ k6/storage/lag/SSE files).
- `failover/cdc-failover/run-1..5` have `integrity.csv`, `faults.log`, `sse_lag*.csv`, `k6-summary.json`, `storage.csv`, `lag.csv`.
- Every `sse_lag.csv` (15 cdc runs + 5 failover runs): `sample_events` > 0, `errors` = 0, `reconnects` = 0.
- Every `faults.log` shows both faults (audit-consumer SIGKILL at +60 s, kafka-1 SIGKILL at +120 s) and their restarts.
  Docker's restart policy did **not** revive the consumer in any run (`exited (restarts=0)` 5 s after the kill); the
  harness restarted it at +80 s.
- Integrity: 0 missing and 0 duplicates in every table of every failover run (23,890 row changes in total).
- Every post-workload drain logged `consumer caught up` (no `still has lag`), including the 20 s-max drains of the
  compression series. No errors, tracebacks or `No space` in any of the three logs.
- Expected latency ranges: 64 VUs create p50 median 486.8–510.4 ms across scenarios (≈500 ms range ✔).
  8 VUs create p50 median 7.3–8.0 ms (run 1 of baseline/cdc: 5.2 / 5.6 ms) — a little below the "~10 ms" expectation.
- 8 VUs: `mutations_ok + mutations_err` ≈ 6,100–6,250 of 10,000 iterations (64 VUs: = 10,000). In `load.js` each VU
  keeps its own copy of the seeded id lists and removes deleted ids; with 1,250 iterations per VU the lists empty, after
  which update/delete/member/capital iterations perform only the login and record no mutation. Throughput below is
  k6 `iterations` rate (includes those iterations).

All numbers below are taken from the raw run files (`k6-summary.json`, `storage.csv`, `lag.csv`, `sse_lag*.csv`,
`storage_compressed.csv`, `integrity.csv`, `faults.log`); medians/min–max over the 5 runs, computed the same way as
`summarize.py` (they match `vus-*/comparison.md`). MB = 1,048,576 bytes.

## (a) Results per concurrency level (median of 5 runs)

### 8 VUs

| Metric | baseline | cdc | cdc-idle | cdc-slot | triggers | envers |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 7.5 | 7.3 | 7.5 | 7.5 | 7.8 | 8.0 |
| Create p95 (ms) | 31.0 | 26.0 | 26.2 | 32.1 | 35.3 | 33.5 |
| Create p99 (ms) | 48.9 | 51.8 | 49.6 | 50.4 | 50.3 | 51.5 |
| Update p50 (ms) | 4.2 | 4.2 | 4.2 | 4.4 | 4.4 | 4.3 |
| Throughput (iterations/s) | 39.6 | 37.4 | 37.9 | 38.0 | 39.7 | 39.7 |
| Mutations ok / err | 4,101 / 2,145 | 4,080 / 2,169 | 4,061 / 2,044 | 4,154 / 1,988 | 4,130 / 1,973 | 4,081 / 2,015 |
| Overhead vs baseline (create p50) | +0.0% | -2.4% | -0.4% | -0.3% | +3.8% | +6.6% |
| Audit rows | 0 | 4,613 | 0 | 0 | 4,717 | 8,509 |
| Audit MB | — | 5.60 | — | — | 4.17 | 2.10 |
| Audit lag p50 (ms) | — | 560.1 | — | — | — | — |
| Audit lag p95 (ms) | — | 904.5 | — | — | — | — |
| Audit lag p99 (ms) | — | 981.5 | — | — | — | — |

### 64 VUs

| Metric | baseline | cdc | cdc-idle | cdc-slot | triggers | envers |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 489.6 | 510.4 | 505.0 | 505.6 | 486.8 | 490.3 |
| Create p95 (ms) | 1,056.4 | 1,154.9 | 1,123.0 | 1,117.9 | 1,046.2 | 1,052.4 |
| Create p99 (ms) | 1,426.8 | 1,567.9 | 1,533.7 | 1,519.5 | 1,419.7 | 1,433.8 |
| Update p50 (ms) | 494.5 | 516.2 | 513.7 | 512.5 | 495.3 | 494.6 |
| Throughput (iterations/s) | 35.8 | 33.9 | 34.3 | 34.3 | 35.8 | 35.6 |
| Mutations ok / err | 4,083 / 5,917 | 4,108 / 5,892 | 4,092 / 5,908 | 4,085 / 5,915 | 4,144 / 5,856 | 4,064 / 5,936 |
| Overhead vs baseline (create p50) | +0.0% | +4.2% | +3.1% | +3.3% | -0.6% | +0.2% |
| Audit rows | 0 | 4,754 | 0 | 0 | 4,772 | 8,449 |
| Audit MB | — | 5.68 | — | — | 5.54 | 3.74 |
| Audit lag p50 (ms) | — | 585.7 | — | — | — | — |
| Audit lag p95 (ms) | — | 938.5 | — | — | — | — |
| Audit lag p99 (ms) | — | 1,087.6 | — | — | — | — |

## (b) Run-to-run spread (min – max over 5 runs)

### 8 VUs

| Metric | baseline | cdc | cdc-idle | cdc-slot | triggers | envers |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 5.2 – 7.7 | 5.6 – 7.4 | 7.4 – 7.6 | 7.4 – 8.0 | 7.7 – 8.0 | 7.9 – 8.7 |
| Create p95 (ms) | 13.7 – 35.0 | 15.5 – 33.0 | 20.3 – 32.6 | 19.0 – 40.3 | 21.5 – 37.0 | 32.1 – 38.8 |
| Create p99 (ms) | 46.6 – 50.1 | 47.1 – 53.1 | 49.3 – 50.7 | 49.9 – 51.7 | 48.7 – 52.3 | 50.7 – 53.2 |
| Update p50 (ms) | 4.1 – 5.1 | 4.1 – 4.7 | 4.1 – 4.8 | 3.8 – 5.1 | 3.9 – 4.6 | 3.9 – 4.8 |
| Throughput (iterations/s) | 39.1 – 39.8 | 37.4 – 37.5 | 37.4 – 38.0 | 37.2 – 38.3 | 39.4 – 40.3 | 39.5 – 40.1 |
| Audit rows | — | 4,533 – 4,845 | — | — | 4,650 – 4,805 | 8,371 – 8,836 |
| Audit MB | — | 5.53 – 5.67 | — | — | 4.00 – 4.27 | 1.82 – 2.17 |
| Audit lag p50 (ms) | — | 558.6 – 570.4 | — | — | — | — |
| Audit lag p99 (ms) | — | 975.7 – 1,008.4 | — | — | — | — |

### 64 VUs

| Metric | baseline | cdc | cdc-idle | cdc-slot | triggers | envers |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 481.5 – 491.8 | 501.3 – 513.1 | 502.1 – 507.0 | 503.2 – 506.8 | 486.2 – 493.6 | 488.9 – 492.1 |
| Create p95 (ms) | 1,047.6 – 1,058.2 | 1,129.3 – 1,159.1 | 1,099.8 – 1,134.7 | 1,111.6 – 1,125.7 | 1,041.2 – 1,057.9 | 1,052.0 – 1,057.2 |
| Create p99 (ms) | 1,404.8 – 1,437.7 | 1,528.8 – 1,612.2 | 1,503.4 – 1,547.6 | 1,513.8 – 1,540.4 | 1,404.1 – 1,447.6 | 1,408.8 – 1,457.9 |
| Update p50 (ms) | 491.0 – 497.2 | 511.0 – 519.7 | 511.1 – 516.8 | 508.1 – 517.4 | 491.1 – 498.4 | 493.8 – 501.1 |
| Throughput (iterations/s) | 35.7 – 36.0 | 33.9 – 34.0 | 34.2 – 34.3 | 34.2 – 34.4 | 35.6 – 35.8 | 35.5 – 35.8 |
| Audit rows | — | 4,660 – 4,848 | — | — | 4,569 – 4,907 | 8,345 – 9,139 |
| Audit MB | — | 5.63 – 5.73 | — | — | 5.37 – 5.67 | 3.54 – 3.78 |
| Audit lag p50 (ms) | — | 563.0 – 602.2 | — | — | — | — |
| Audit lag p99 (ms) | — | 1,027.9 – 1,205.9 | — | — | — | — |

## (c) Overhead decomposition at 64 VUs (create latency, median of 5 runs)

| Step | Create p50 (ms) | Δ p50 vs previous step | Create p99 (ms) | Δ p99 vs previous step | Δ p50 vs baseline | Δ p99 vs baseline |
|---|---:|---:|---:|---:|---:|---:|
| baseline | 489.6 | — | 1,426.8 | — | +0.0 (+0.0%) | +0.0 (+0.0%) |
| cdc-idle | 505.0 | +15.4 | 1,533.7 | +107.0 | +15.4 (+3.1%) | +107.0 (+7.5%) |
| cdc-slot | 505.6 | +0.6 | 1,519.5 | -14.3 | +16.0 (+3.3%) | +92.7 (+6.5%) |
| cdc | 510.4 | +4.8 | 1,567.9 | +48.4 | +20.8 (+4.2%) | +141.2 (+9.9%) |

## (d) SSE latency (commit → external SSE client, ms)

| Set | Run | Events | p50 | p95 | p99 | max | reconnects | errors |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| cdc, 8 VUs | 1 | 4,845 | 258.35 | 485.04 | 510.74 | 551.77 | 0 | 0 |
| cdc, 8 VUs | 2 | 4,613 | 234.47 | 489.50 | 515.40 | 527.05 | 0 | 0 |
| cdc, 8 VUs | 3 | 4,683 | 270.26 | 487.62 | 514.28 | 542.05 | 0 | 0 |
| cdc, 8 VUs | 4 | 4,580 | 251.35 | 486.16 | 509.71 | 531.78 | 0 | 0 |
| cdc, 8 VUs | 5 | 4,533 | 251.58 | 495.28 | 515.05 | 536.48 | 0 | 0 |
| **cdc, 8 VUs** | **median** | 4,613 | 251.58 | 487.62 | 514.28 | 536.48 | 0 | 0 |
| cdc, 64 VUs | 1 | 4,848 | 285.45 | 510.03 | 532.37 | 570.07 | 0 | 0 |
| cdc, 64 VUs | 2 | 4,718 | 266.91 | 506.99 | 587.85 | 591.80 | 0 | 0 |
| cdc, 64 VUs | 3 | 4,660 | 265.81 | 501.05 | 543.25 | 558.27 | 0 | 0 |
| cdc, 64 VUs | 4 | 4,803 | 260.82 | 499.78 | 532.44 | 549.81 | 0 | 0 |
| cdc, 64 VUs | 5 | 4,754 | 264.71 | 502.55 | 545.14 | 578.06 | 0 | 0 |
| **cdc, 64 VUs** | **median** | 4,754 | 265.81 | 502.55 | 543.25 | 570.07 | 0 | 0 |
| cdc-failover, 64 VUs | 1 | 4,855 | 276.34 | 519.87 | 10607.29 | 15682.17 | 0 | 0 |
| cdc-failover, 64 VUs | 2 | 4,887 | 272.73 | 3418.11 | 11101.71 | 14567.39 | 0 | 0 |
| cdc-failover, 64 VUs | 3 | 4,749 | 269.83 | 4305.86 | 11977.51 | 13968.83 | 0 | 0 |
| cdc-failover, 64 VUs | 4 | 4,639 | 286.48 | 4308.57 | 12926.36 | 18989.83 | 0 | 0 |
| cdc-failover, 64 VUs | 5 | 4,760 | 286.76 | 515.06 | 11094.42 | 15413.56 | 0 | 0 |
| **cdc-failover, 64 VUs** | **median** | 4,760 | 276.34 | 3418.11 | 11101.71 | 15413.56 | 0 | 0 |

Per table (median of 5 runs; p50 min–max in brackets):

| Set | Table | Events | p50 | p95 | p99 | max | reconnects | errors |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| cdc, 8 VUs | company | 1,280 | 250.20 (235.95–277.55) | 485.05 | 510.66 | 527.91 | 0 | 0 |
| cdc, 8 VUs | person | 1,394 | 259.08 (253.59–263.63) | 486.33 | 510.41 | 525.37 | 0 | 0 |
| cdc, 8 VUs | legal_entity | 1,417 | 267.30 (240.45–271.56) | 487.54 | 511.61 | 531.78 | 0 | 0 |
| cdc, 8 VUs | member | 188 | 234.42 (210.58–245.11) | 484.71 | 498.74 | 525.60 | 0 | 0 |
| cdc, 8 VUs | company_stocks | 300 | 242.84 (211.68–273.60) | 490.11 | 499.92 | 514.24 | 0 | 0 |
| cdc, 8 VUs | company_capital | 77 | 249.01 (200.88–335.14) | 480.57 | 486.10 | 514.02 | 0 | 0 |
| cdc, 64 VUs | company | 1,308 | 258.33 (251.81–283.49) | 491.77 | 515.07 | 552.60 | 0 | 0 |
| cdc, 64 VUs | person | 1,389 | 264.71 (258.12–275.32) | 494.47 | 517.69 | 547.69 | 0 | 0 |
| cdc, 64 VUs | legal_entity | 1,362 | 261.57 (259.44–280.55) | 491.04 | 514.46 | 545.14 | 0 | 0 |
| cdc, 64 VUs | member | 188 | 245.53 (222.86–274.87) | 523.04 | 551.35 | 553.96 | 0 | 0 |
| cdc, 64 VUs | company_stocks | 435 | 333.73 (258.26–353.07) | 552.77 | 564.23 | 567.51 | 0 | 0 |
| cdc, 64 VUs | company_capital | 98 | 295.25 (237.04–314.99) | 497.86 | 528.88 | 529.48 | 0 | 0 |
| cdc-failover, 64 VUs | company | 1,335 | 287.22 (267.73–297.52) | 5444.77 | 12970.45 | 14567.39 | 0 | 0 |
| cdc-failover, 64 VUs | person | 1,366 | 277.79 (260.09–290.19) | 4312.36 | 11473.77 | 13961.58 | 0 | 0 |
| cdc-failover, 64 VUs | legal_entity | 1,390 | 276.13 (268.44–293.57) | 3805.64 | 10981.74 | 13632.80 | 0 | 0 |
| cdc-failover, 64 VUs | member | 221 | 259.43 (178.50–348.83) | 489.16 | 517.96 | 525.30 | 0 | 0 |
| cdc-failover, 64 VUs | company_stocks | 405 | 248.67 (185.96–333.21) | 510.25 | 537.06 | 540.55 | 0 | 0 |
| cdc-failover, 64 VUs | company_capital | 89 | 326.04 (184.64–364.92) | 504.19 | 508.37 | 514.18 | 0 | 0 |

## (e) CDC compression series (`cdc-segmentby-none/`, 64 VUs, no segmentby)

| Run | Table | Rows | Uncompressed (bytes) | Compressed (bytes) | Ratio | TSDB stats before → after (bytes) |
|---|---|---:|---:|---:|---:|---:|
| 1 | company_audit | 1,318 | 1,228,800 | 663,552 | 1.85 | 1,187,840 → 491,520 |
| 1 | company_capital_audit | 115 | 434,176 | 434,176 | 1.00 | 393,216 → 262,144 |
| 1 | company_stocks_audit | 525 | 548,864 | 434,176 | 1.26 | 507,904 → 262,144 |
| 1 | legal_entity_audit | 1,353 | 1,163,264 | 663,552 | 1.75 | 1,122,304 → 491,520 |
| 1 | member_audit | 218 | 516,096 | 434,176 | 1.19 | 475,136 → 262,144 |
| 1 | person_audit | 1,409 | 1,335,296 | 712,704 | 1.87 | 1,294,336 → 540,672 |
| 1 | **6 data tables** | 4,938 | 5,226,496 | 3,342,336 | 1.56 | — |
| 1 | **all 27 hypertables** | 4,938 | 6,086,656 | 4,202,496 | 1.45 | — |
| 2 | company_audit | 1,340 | 1,245,184 | 679,936 | 1.83 | 1,204,224 → 507,904 |
| 2 | company_capital_audit | 84 | 335,872 | 434,176 | 0.77 | 294,912 → 262,144 |
| 2 | company_stocks_audit | 366 | 491,520 | 434,176 | 1.13 | 450,560 → 262,144 |
| 2 | legal_entity_audit | 1,362 | 1,163,264 | 663,552 | 1.75 | 1,122,304 → 491,520 |
| 2 | member_audit | 188 | 507,904 | 434,176 | 1.17 | 466,944 → 262,144 |
| 2 | person_audit | 1,381 | 1,310,720 | 696,320 | 1.88 | 1,269,760 → 524,288 |
| 2 | **6 data tables** | 4,721 | 5,054,464 | 3,342,336 | 1.51 | — |
| 2 | **all 27 hypertables** | 4,721 | 5,914,624 | 4,202,496 | 1.41 | — |
| 3 | company_audit | 1,328 | 1,236,992 | 663,552 | 1.86 | 1,196,032 → 491,520 |
| 3 | company_capital_audit | 82 | 303,104 | 434,176 | 0.70 | 262,144 → 262,144 |
| 3 | company_stocks_audit | 330 | 491,520 | 434,176 | 1.13 | 450,560 → 262,144 |
| 3 | legal_entity_audit | 1,373 | 1,171,456 | 663,552 | 1.77 | 1,130,496 → 491,520 |
| 3 | member_audit | 215 | 516,096 | 434,176 | 1.19 | 475,136 → 262,144 |
| 3 | person_audit | 1,425 | 1,327,104 | 712,704 | 1.86 | 1,286,144 → 540,672 |
| 3 | **6 data tables** | 4,753 | 5,046,272 | 3,342,336 | 1.51 | — |
| 3 | **all 27 hypertables** | 4,753 | 5,906,432 | 4,202,496 | 1.41 | — |
| 4 | company_audit | 1,276 | 1,204,224 | 663,552 | 1.81 | 1,163,264 → 491,520 |
| 4 | company_capital_audit | 65 | 303,104 | 434,176 | 0.70 | 262,144 → 262,144 |
| 4 | company_stocks_audit | 225 | 458,752 | 434,176 | 1.06 | 417,792 → 262,144 |
| 4 | legal_entity_audit | 1,408 | 1,187,840 | 671,744 | 1.77 | 1,146,880 → 499,712 |
| 4 | member_audit | 104 | 450,560 | 434,176 | 1.04 | 409,600 → 262,144 |
| 4 | person_audit | 1,403 | 1,327,104 | 712,704 | 1.86 | 1,286,144 → 540,672 |
| 4 | **6 data tables** | 4,481 | 4,931,584 | 3,350,528 | 1.47 | — |
| 4 | **all 27 hypertables** | 4,481 | 5,791,744 | 4,210,688 | 1.38 | — |
| 5 | company_audit | 1,310 | 1,236,992 | 671,744 | 1.84 | 1,196,032 → 499,712 |
| 5 | company_capital_audit | 105 | 368,640 | 434,176 | 0.85 | 327,680 → 262,144 |
| 5 | company_stocks_audit | 444 | 524,288 | 434,176 | 1.21 | 483,328 → 262,144 |
| 5 | legal_entity_audit | 1,322 | 1,138,688 | 663,552 | 1.72 | 1,097,728 → 491,520 |
| 5 | member_audit | 239 | 532,480 | 434,176 | 1.23 | 491,520 → 262,144 |
| 5 | person_audit | 1,505 | 1,409,024 | 729,088 | 1.93 | 1,368,064 → 557,056 |
| 5 | **6 data tables** | 4,925 | 5,210,112 | 3,366,912 | 1.55 | — |
| 5 | **all 27 hypertables** | 4,925 | 6,070,272 | 4,227,072 | 1.44 | — |

Median of 5 runs:

| Table | Rows | Uncompressed (bytes) | Compressed (bytes) | Ratio |
|---|---:|---:|---:|---:|
| company_audit | 1,318 | 1,236,992 | 663,552 | 1.84 |
| person_audit | 1,409 | 1,327,104 | 712,704 | 1.87 |
| legal_entity_audit | 1,362 | 1,163,264 | 663,552 | 1.75 |
| member_audit | 215 | 516,096 | 434,176 | 1.19 |
| company_stocks_audit | 366 | 491,520 | 434,176 | 1.13 |
| company_capital_audit | 84 | 335,872 | 434,176 | 0.77 |
| **6 data tables** (n tables = 6) | 4,753 | 5,054,464 | 3,342,336 | 1.51 (range 1.47–1.56) |
| **all hypertables** (n tables = 27) | 4,753 | 5,914,624 | 4,202,496 | 1.41 (range 1.38–1.45) |

## (f) Failure injection (`failover/cdc-failover/`, 64 VUs)

### Run 1

```
2026-10-15T15:53:03+0300 +60s KILL audit-consumer (SIGKILL — crash, no shutdown hook)
2026-10-15T15:53:08+0300 +65s audit-consumer state: exited (restarts=0)
2026-10-15T15:53:23+0300 +80s START audit-consumer
2026-10-15T15:54:03+0300 +120s KILL kafka-1 (SIGKILL — broker crash)
2026-10-15T15:54:33+0300 +150s START kafka-1
2026-10-15T15:54:34+0300 +151s fault schedule complete
```
Docker restart policy after SIGKILL: `exited (restarts=0)`

| Table | trigger_rows | cdc_rows | distinct change_id | duplicates | missing |
|---|---:|---:|---:|---:|---:|
| company | 1,335 | 1,335 | 1,335 | 0 | 0 |
| person | 1,357 | 1,357 | 1,357 | 0 | 0 |
| legal_entity | 1,392 | 1,392 | 1,392 | 0 | 0 |
| member | 224 | 224 | 224 | 0 | 0 |
| company_stocks | 450 | 450 | 450 | 0 | 0 |
| company_capital | 97 | 97 | 97 | 0 | 0 |
| **total** | **4,855** | **4,855** | **4,855** | **0** | **0** |

Derived from `sse_lag_samples.csv` (SSE bridge path, not the audit-consumer; windows end 30 s after restart so they do not overlap; reference = SSE p99 of samples received before the first fault = 536.78 ms):

| Fault | down window | samples kill→restart+30 s | max SSE lag kill→restart+30 s (ms) | samples > reference | last sample > reference (s after restart) |
|---|---|---:|---:|---:|---:|
| KILL audit-consumer | +60s → +80s | 689 | 517.56 | 0 | none |
| KILL kafka-1 | +120s → +150s | 735 | 15,682.17 | 166 | -14.0 |

SSE: 4,855 events, reconnects = 0, errors = 0; audit lag (lag.csv): sample_rows 4855, lag_p50_ms 659.40, lag_p95_ms 30070.07, lag_p99_ms 43454.07, lag_max_ms 47154.07

### Run 2

```
2026-10-15T15:59:50+0300 +60s KILL audit-consumer (SIGKILL — crash, no shutdown hook)
2026-10-15T15:59:56+0300 +66s audit-consumer state: exited (restarts=0)
2026-10-15T16:00:10+0300 +80s START audit-consumer
2026-10-15T16:00:50+0300 +120s KILL kafka-1 (SIGKILL — broker crash)
2026-10-15T16:01:20+0300 +150s START kafka-1
2026-10-15T16:01:20+0300 +150s fault schedule complete
```
Docker restart policy after SIGKILL: `exited (restarts=0)`

| Table | trigger_rows | cdc_rows | distinct change_id | duplicates | missing |
|---|---:|---:|---:|---:|---:|
| company | 1,340 | 1,340 | 1,340 | 0 | 0 |
| person | 1,411 | 1,411 | 1,411 | 0 | 0 |
| legal_entity | 1,371 | 1,371 | 1,371 | 0 | 0 |
| member | 221 | 221 | 221 | 0 | 0 |
| company_stocks | 450 | 450 | 450 | 0 | 0 |
| company_capital | 94 | 94 | 94 | 0 | 0 |
| **total** | **4,887** | **4,887** | **4,887** | **0** | **0** |

Derived from `sse_lag_samples.csv` (SSE bridge path, not the audit-consumer; windows end 30 s after restart so they do not overlap; reference = SSE p99 of samples received before the first fault = 504.08 ms):

| Fault | down window | samples kill→restart+30 s | max SSE lag kill→restart+30 s (ms) | samples > reference | last sample > reference (s after restart) |
|---|---|---:|---:|---:|---:|
| KILL audit-consumer | +60s → +80s | 692 | 525.67 | 14 | +0.5 |
| KILL kafka-1 | +120s → +150s | 764 | 14,567.39 | 313 | +7.7 |

SSE: 4,887 events, reconnects = 0, errors = 0; audit lag (lag.csv): sample_rows 4887, lag_p50_ms 643.53, lag_p95_ms 29149.04, lag_p99_ms 42817.04, lag_max_ms 46313.04

### Run 3

```
2026-10-15T16:06:39+0300 +60s KILL audit-consumer (SIGKILL — crash, no shutdown hook)
2026-10-15T16:06:45+0300 +66s audit-consumer state: exited (restarts=0)
2026-10-15T16:06:59+0300 +80s START audit-consumer
2026-10-15T16:07:39+0300 +120s KILL kafka-1 (SIGKILL — broker crash)
2026-10-15T16:08:09+0300 +150s START kafka-1
2026-10-15T16:08:09+0300 +150s fault schedule complete
```
Docker restart policy after SIGKILL: `exited (restarts=0)`

| Table | trigger_rows | cdc_rows | distinct change_id | duplicates | missing |
|---|---:|---:|---:|---:|---:|
| company | 1,326 | 1,326 | 1,326 | 0 | 0 |
| person | 1,366 | 1,366 | 1,366 | 0 | 0 |
| legal_entity | 1,390 | 1,390 | 1,390 | 0 | 0 |
| member | 173 | 173 | 173 | 0 | 0 |
| company_stocks | 405 | 405 | 405 | 0 | 0 |
| company_capital | 89 | 89 | 89 | 0 | 0 |
| **total** | **4,749** | **4,749** | **4,749** | **0** | **0** |

Derived from `sse_lag_samples.csv` (SSE bridge path, not the audit-consumer; windows end 30 s after restart so they do not overlap; reference = SSE p99 of samples received before the first fault = 508.45 ms):

| Fault | down window | samples kill→restart+30 s | max SSE lag kill→restart+30 s (ms) | samples > reference | last sample > reference (s after restart) |
|---|---|---:|---:|---:|---:|
| KILL audit-consumer | +60s → +80s | 696 | 514.63 | 14 | +27.9 |
| KILL kafka-1 | +120s → +150s | 767 | 13,968.83 | 337 | +24.5 |

SSE: 4,749 events, reconnects = 0, errors = 0; audit lag (lag.csv): sample_rows 4749, lag_p50_ms 644.04, lag_p95_ms 31042.31, lag_p99_ms 43871.31, lag_max_ms 46446.54

### Run 4

```
2026-10-15T16:13:27+0300 +60s KILL audit-consumer (SIGKILL — crash, no shutdown hook)
2026-10-15T16:13:33+0300 +66s audit-consumer state: exited (restarts=0)
2026-10-15T16:13:47+0300 +80s START audit-consumer
2026-10-15T16:14:27+0300 +120s KILL kafka-1 (SIGKILL — broker crash)
2026-10-15T16:14:57+0300 +150s START kafka-1
2026-10-15T16:14:58+0300 +151s fault schedule complete
```
Docker restart policy after SIGKILL: `exited (restarts=0)`

| Table | trigger_rows | cdc_rows | distinct change_id | duplicates | missing |
|---|---:|---:|---:|---:|---:|
| company | 1,351 | 1,351 | 1,351 | 0 | 0 |
| person | 1,364 | 1,364 | 1,364 | 0 | 0 |
| legal_entity | 1,316 | 1,316 | 1,316 | 0 | 0 |
| member | 188 | 188 | 188 | 0 | 0 |
| company_stocks | 342 | 342 | 342 | 0 | 0 |
| company_capital | 78 | 78 | 78 | 0 | 0 |
| **total** | **4,639** | **4,639** | **4,639** | **0** | **0** |

Derived from `sse_lag_samples.csv` (SSE bridge path, not the audit-consumer; windows end 30 s after restart so they do not overlap; reference = SSE p99 of samples received before the first fault = 573.29 ms):

| Fault | down window | samples kill→restart+30 s | max SSE lag kill→restart+30 s (ms) | samples > reference | last sample > reference (s after restart) |
|---|---|---:|---:|---:|---:|
| KILL audit-consumer | +60s → +80s | 648 | 515.06 | 0 | none |
| KILL kafka-1 | +120s → +150s | 784 | 18,989.83 | 336 | +8.2 |

SSE: 4,639 events, reconnects = 0, errors = 0; audit lag (lag.csv): sample_rows 4639, lag_p50_ms 667.93, lag_p95_ms 30335.14, lag_p99_ms 43981.14, lag_max_ms 47040.14

### Run 5

```
2026-10-15T16:20:15+0300 +60s KILL audit-consumer (SIGKILL — crash, no shutdown hook)
2026-10-15T16:20:21+0300 +66s audit-consumer state: exited (restarts=0)
2026-10-15T16:20:35+0300 +80s START audit-consumer
2026-10-15T16:21:15+0300 +120s KILL kafka-1 (SIGKILL — broker crash)
2026-10-15T16:21:45+0300 +150s START kafka-1
2026-10-15T16:21:45+0300 +150s fault schedule complete
```
Docker restart policy after SIGKILL: `exited (restarts=0)`

| Table | trigger_rows | cdc_rows | distinct change_id | duplicates | missing |
|---|---:|---:|---:|---:|---:|
| company | 1,292 | 1,292 | 1,292 | 0 | 0 |
| person | 1,401 | 1,401 | 1,401 | 0 | 0 |
| legal_entity | 1,410 | 1,410 | 1,410 | 0 | 0 |
| member | 233 | 233 | 233 | 0 | 0 |
| company_stocks | 342 | 342 | 342 | 0 | 0 |
| company_capital | 82 | 82 | 82 | 0 | 0 |
| **total** | **4,760** | **4,760** | **4,760** | **0** | **0** |

Derived from `sse_lag_samples.csv` (SSE bridge path, not the audit-consumer; windows end 30 s after restart so they do not overlap; reference = SSE p99 of samples received before the first fault = 546.77 ms):

| Fault | down window | samples kill→restart+30 s | max SSE lag kill→restart+30 s (ms) | samples > reference | last sample > reference (s after restart) |
|---|---|---:|---:|---:|---:|
| KILL audit-consumer | +60s → +80s | 699 | 524.92 | 0 | none |
| KILL kafka-1 | +120s → +150s | 814 | 15,413.56 | 202 | +9.2 |

SSE: 4,760 events, reconnects = 0, errors = 0; audit lag (lag.csv): sample_rows 4760, lag_p50_ms 655.22, lag_p95_ms 30646.25, lag_p99_ms 42872.00, lag_max_ms 46243.00

### Integrity summary over 5 runs (sum / per-run min–max)

| Table | trigger_rows Σ | cdc_rows Σ | distinct Σ | duplicates Σ (min–max) | missing Σ (min–max) |
|---|---:|---:|---:|---:|---:|
| company | 6,644 | 6,644 | 6,644 | 0 (0–0) | 0 (0–0) |
| person | 6,899 | 6,899 | 6,899 | 0 (0–0) | 0 (0–0) |
| legal_entity | 6,879 | 6,879 | 6,879 | 0 (0–0) | 0 (0–0) |
| member | 1,039 | 1,039 | 1,039 | 0 (0–0) | 0 (0–0) |
| company_stocks | 1,989 | 1,989 | 1,989 | 0 (0–0) | 0 (0–0) |
| company_capital | 440 | 440 | 440 | 0 (0–0) | 0 (0–0) |
| **total** | 23,890 | 23,890 | 23,890 | 0 (0–0) | 0 (0–0) |



## Notes

- Consumer-lag recovery time after each fault is **not recorded** by the harness: there is no consumer-group lag time
  series, `lag.csv` holds only percentiles over all rows, and the per-row audit data is removed by `down -v` before the
  next run. The fault tables above use `sse_lag_samples.csv` instead, which measures the SSE bridge's own Kafka consumer,
  not `audit-consumer`. The audit-consumer impact is visible only in each failover run's `lag.csv` (p95 ≈29–31 s,
  max ≈46–47 s vs ≈1.1 s p99 without faults).
- `cdc-segmentby-none/run.log` is the 2026-10-14 log (run-all.sh only wipes the scenario dir); this run's log is
  `results/run-compress.log`. The 2026-10-14 compression runs were overwritten in the working tree and remain in git history (commit `06b6c72`) and in the local copy `benchmark/results-2026-10-14/cdc-segmentby-none/`.
- Per-level tables: `vus-8/comparison.md`, `vus-64/comparison.md`, `comparison-by-vus.md`, `cdc-segmentby-none/comparison.md`,
  `failover/comparison.md`.
