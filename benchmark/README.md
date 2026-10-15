# Audit-method benchmark

Compares three auditing strategies for the Business Registry against a no-audit
baseline, under one fixed, reproducible CRUD workload. Built for the thesis.

| Scenario | Method | Where audit lives | When it commits |
|----------|--------|-------------------|-----------------|
| `baseline` | none | — | — |
| `cdc` | Debezium CDC → Kafka → audit-consumer | `auditDb` (TimescaleDB hypertables) | **async**, out-of-band |
| `triggers` | PostgreSQL `AFTER` row triggers | `mainDb` (`<t>_trigger_audit`) | **sync**, same txn |
| `envers` | Hibernate Envers | `mainDb` (`<t>_AUD` + `REVINFO`) | **sync**, same txn |
| `cdc-idle` | *control*: full CDC stack running, **no connector registered** (no slot, no decoding) | — | — |
| `cdc-slot` | *control*: connector streaming into Kafka, **no audit-consumer / auditDb** | — | — |
| `cdc-failover` | `cdc` + fault injection (consumer SIGKILL, broker crash) + triggers enabled as ground truth | `auditDb` + `mainDb` (`<t>_trigger_audit`) | async |
| `history` | History API only: streams `HISTORY_ROWS` synthetic audit rows as JSON and as Parquet | `auditDb` | — |

`cdc-idle` and `cdc-slot` decompose the write-path overhead of `cdc` measured on a single
host: baseline → `cdc-idle` isolates the resource contention of the extra processes,
`cdc-slot` adds logical decoding + Debezium + Kafka traffic, `cdc` adds the consumer and the
second database. `cdc-failover` answers "is anything lost?" with numbers: the triggers write
exactly one row per row-level change into `mainDb`, the CDC rows carry the WAL LSN as
`change_id`, so `integrity.csv` reports `missing = trigger_rows − distinct(change_id)` and
`duplicates = rows − distinct(change_id)` per table (at-least-once ⇒ duplicates ≥ 0, missing = 0
is the claim under test). `cdc` and `cdc-failover` also start the SSE bridge and
`sse_probe.py`, which holds one SSE connection per table and records
`arrival − changedAt` for every event (commit → external client latency; `changedAt` is
Debezium's `source.ts_ms`, the same commit timestamp the audit store keeps as `changed_at`),
split into commit → Debezium (`capturedAt` = envelope `ts_ms`) and Debezium → client.

Scope: the 6 core mutable entities — `company`, `person`, `legal_entity`,
`member`, `company_stocks`, `company_capital`.

## Run

**First, a smoke run** — every scenario once with a small load (≈ 30 min, mostly container
start-up), results in `benchmark/results-smoke/`, and `smoke_check.py` verifies every output
(the script exits non-zero if a check fails):

```bash
SMOKE=1 ./benchmark/run-all.sh
```

Then the thesis series, e.g.:

```bash
# write path at two concurrency levels, with the overhead-decomposition controls (5 runs, round-robin)
SCENARIOS="baseline cdc cdc-idle cdc-slot triggers envers" VU_LEVELS="8 64" TOTAL_OPS=10000 REPEATS=5 CDC_DRAIN_S=120 ./benchmark/run-all.sh
# the same at a FIXED arrival rate (open model: latency at a given load instead of at saturation)
SCENARIOS="baseline cdc triggers envers" VUS=64 RATE=200 TOTAL_OPS=20000 REPEATS=5 CDC_DRAIN_S=120 \
  RESULTS_DIR="$PWD/benchmark/results/rate-200" ./benchmark/run-all.sh
# cdc-only compression run into its own dir (main results untouched)
SCENARIOS=cdc VUS=64 TOTAL_OPS=10000 REPEATS=5 RESULTS_DIR="$PWD/benchmark/results/cdc-segmentby-none" ./benchmark/run-all.sh
# failure injection: 10,000 ops at 50 ops/s (200 s); consumer killed at +60 s for 20 s, kafka-1 at +120 s for 30 s
SCENARIOS=cdc-failover VUS=64 TOTAL_OPS=10000 REPEATS=5 CDC_DRAIN_S=180 RESULTS_DIR="$PWD/benchmark/results/failover" ./benchmark/run-all.sh
# …and a LONG broker outage of the SSE bridge's group coordinator: does delivery resume while the broker is still down?
SCENARIOS=cdc-failover VUS=64 TOTAL_OPS=20000 FAILOVER_RATE=50 FAULT_BROKER=coordinator FAULT_BROKER_AT=120 FAULT_BROKER_DOWN_S=180 \
  REPEATS=3 CDC_DRAIN_S=240 RESULTS_DIR="$PWD/benchmark/results/failover-long" ./benchmark/run-all.sh
# History API: JSON vs Parquet over 500,000 rows
SCENARIOS=history HISTORY_ROWS=500000 RESULTS_DIR="$PWD/benchmark/results/history" ./benchmark/run-all.sh
```

Knobs (environment variables of `run-all.sh`):

| Knob | Default | Meaning |
|------|---------|---------|
| `SMOKE` | `0` | `1` = quick correctness run (see above); any knob below still overrides its presets |
| `SCENARIOS` | `baseline cdc triggers envers` | scenarios to run, in order |
| `VUS` / `VU_LEVELS` | `10` / — | concurrent virtual users (≤ 64); `VU_LEVELS="8 64"` runs the whole set per level into `vus-<n>/` and writes `comparison-by-vus.md` |
| `TOTAL_OPS` | `2000` | iterations per run = mutation attempts (exactly one per iteration) |
| `RATE` | — | empty = **closed** model (VUs loop flat out → latency at saturation); a number = **open** model, constant arrival rate in ops/s for `TOTAL_OPS/RATE` s (`dropped_iterations` reported if the API cannot keep up) |
| `FAILOVER_RATE` | `50` | ops/s used by `cdc-failover` when `RATE` is empty — the run must last longer than the fault schedule (the script warns if not) |
| `BENCH_SEED_ROWS` | `2000` | extra companies / persons / legal entities bulk-inserted before every scenario (`sql/seed.sql`) |
| `PARTITION_IDS` | `1` | each VU updates/deletes only its own disjoint share of the ids |
| `LOGIN_EVERY_ITERATION` | `0` | `1` = the old load model (log in before every mutation) |
| `REPEATS` | `1` | runs per scenario (round-robin) → median, spread and the statistical comparison |
| `CDC_DRAIN_S` | `20` | max wait for the audit consumer to catch up after the load |
| `SSE_PROBE` | `1` | cdc / cdc-failover also start the SSE bridge + `sse_probe.py` |
| `FAULT_CONSUMER_AT` / `_DOWN_S` | `60` / `20` | consumer SIGKILL time / outage (s after the k6 start) |
| `FAULT_BROKER_AT` / `_DOWN_S` | `120` / `30` | broker SIGKILL time / outage |
| `FAULT_BROKER` | `kafka-1` | `kafka-N`, `coordinator` (the SSE bridge's consumer-group coordinator) or `controller` (the active KRaft controller) |
| `HISTORY_ROWS` | `500000` | synthetic audit rows for the `history` scenario |
| `COMPRESS_SEGMENTBY` | — | optional `segmentby` column for the cdc compressed-size measurement |
| `RESULTS_DIR` | `benchmark/results` | output directory (`run-all.sh` wipes `<RESULTS_DIR>/<scenario>/` first) |
| `K6_IMAGE` / `PROBE_IMAGE` | `grafana/k6` / `python:3.12-alpine` | container images of the load generator / SSE probe |
| `STATS_SETTLE_S`, `COMPACT` (collect.sh) | `12`, `1` | wait for table statistics; `0` skips the VACUUM FULL size |

Requirements: Docker + Docker Compose. k6 runs as the `grafana/k6` container on
the compose network (no host install). `python3` for the summary and the checks
(optional — raw CSV/JSON are written regardless).

### Load model

- **Seeding.** Before every scenario `run-all.sh` starts `mainDb` alone, disables the audit
  triggers and bulk-inserts `BENCH_SEED_ROWS` companies, persons and legal entities
  (`sql/seed.sql`: copies of the sample rows with unique names/ΑΦΜ/Γ.Ε.ΜΗ. numbers), then
  exports all ids to `<run>/seed_ids.json` for k6. Only then are the scenario's services
  started, so the seed rows are part of Debezium's initial snapshot, which is drained and
  truncated before the measurement. (The 15/30/30 sample rows alone made most updates and
  deletes of 64 concurrent VUs fail with 404 because another VU had already deleted the row.)
- **One mutation per iteration.** Entity mix company/person/legal entity 3 : 3 : 3,
  member 2, capital 2; operation mix create 6 : update 3 : delete 2. With `PARTITION_IDS=1`
  VU *k* updates/deletes only the ids at positions *i* with *i* mod VUS = *k*−1, so VUs never
  race on the same row; an update/delete with no id left falls back to a create. Failed
  mutations are therefore genuine validation/constraint failures (`Errors 4xx / 5xx`).
- **Authentication.** Each VU logs in **once** as its own user `bench<__VU>` (the API allows
  one session per user) and keeps the session; it logs in again and retries the mutation once
  only if the API rejects the session (`vu_relogins`). Logins are timed separately
  (`login_ms`) and never included in the `op_*` latencies. The bench users carry a cheap
  Argon2id hash (`m=1 MiB, t=1`, parameters stored with the hash, see `PasswordService`):
  with the default cost (`m=64 MiB, t=2`, ≈ 160–260 ms CPU and 64 MB per login) the old
  load model — one login per mutation — saturated the host's CPU with password hashing, so
  at 64 VUs the measured write latency (≈ 490 ms) was mostly queueing behind logins, not the
  audited write path (8 VUs: ≈ 7 ms). `LOGIN_EVERY_ITERATION=1` reproduces the old model.
- **Closed vs open model.** Without `RATE`, VUs issue the next mutation as soon as the previous
  one returns (latency at saturation; throughput = capacity). With `RATE`, k6 starts a fixed
  number of iterations per second (latency at a given load).

The orchestrator, per scenario: `down -v` → bring up only the services that
method needs → toggle triggers / Envers profile → run the k6 workload →
(`cdc` only) wait for the async pipeline to drain → snapshot DB metrics.

## Outputs (`benchmark/results/`)

- `<scenario>/k6-summary.json` — full k6 metrics (latency trends, throughput).
- `<scenario>/storage.csv` — per audit table: rows, on-disk size (`total_bytes`, split into `heap_bytes` / `toast_bytes` / `index_bytes`), `live_tuples` / `dead_tuples` / `inserted_tuples` (pg_stat), and `compact_bytes` = the size after `VACUUM FULL`. TimescaleDB hypertables are measured with `hypertable_detailed_size()` / `hypertable_size()` (parent + chunks + indexes); `pg_total_relation_size()` on a hypertable parent reports only the empty parent relation (~40 kB), which is why older runs under-reported the CDC audit volume. Dead tuples matter for the synchronous methods: their audit row is written inside the user's transaction, so a mutation that rolls back leaves a dead audit tuple behind that keeps occupying space (VACUUM marks it reusable but never shrinks the table) — their on-disk size grows with the number of *failed* mutations. CDC only sees committed changes. `total_bytes` is the real cost on disk; `compact_bytes` isolates the size of the stored representation.
- `<scenario>/versions.txt` — host, Docker, image ids and component versions (PostgreSQL, TimescaleDB, Debezium, Kafka, k6) and the load-model knobs of that run.
- `<scenario>/seed_ids.json` — the ids handed to k6.
- `<scenario>/run-<k>/…` — the same files per run when `REPEATS>1`; `comparison.md` then shows the median across runs, a min–max spread table and the per-run values.
- `cdc/lag.csv` — end-to-end CDC lag percentiles (`ingested_at − changed_at`, ms); `lag_timeseries.csv` the same per 1-second bucket of commit time (when did the audit store fall behind, how fast did it catch up), with the absolute start in `lag_timeseries_t0.txt`.
- `cdc/storage_compressed.csv` — CDC audit storage **after TimescaleDB native compression**, measured by `collect.sh` *after* `storage.csv`/`lag.csv` are written. For every public `*_audit` hypertable it runs
  `ALTER TABLE … SET (timescaledb.compress, timescaledb.compress_orderby = 'changed_at DESC', timescaledb.compress_segmentby = '')` (no segmentby) and
  `SELECT compress_chunk(c, if_not_compressed => true) FROM show_chunks(…) c`, then re-measures `hypertable_size()`.
  Columns: `scenario,method,audit_table,row_count,uncompressed_bytes,compressed_bytes,ratio,stats_before_bytes,stats_after_bytes` —
  `ratio = uncompressed_bytes / compressed_bytes` (both `hypertable_size()`, so indexes and the fixed per-chunk overhead are included);
  `stats_*` are TimescaleDB's own `before/after_compression_total_bytes` from `hypertable_compression_stats()` (chunks only, 0 when a table has no chunks).
  0-row tables are kept. A compression failure is logged as a warning and never aborts the run.
  The segmentby/orderby actually used are written to `cdc/compression_settings.txt`.
  On the 2026-10-14 run this compresses the CDC audit store ≈1.46× overall (≈1.8–1.9× on the large tables) — see `results/linux-run-summary.md`.
- `cdc/sse_lag.csv` — commit → external SSE client latency (p50/p95/p99/max over all events received by `sse_probe.py`), its two parts commit → Debezium (`capture_*`) and Debezium → client (`deliver_*`), reconnect/error counts, `stale_skipped` (events committed before the probe started, e.g. a backlog) and `duplicates` (same change id delivered twice); `sse_lag_tables.csv` per table, `sse_lag_samples.csv` every sample (`table,received_epoch_ms,lag_ms,capture_ms`) so the lag can be plotted over time.
- `cdc-failover/integrity.csv` — per table: `trigger_rows, cdc_rows, cdc_distinct_changes, duplicates, missing`; `cdc-failover/faults.log` — timestamped fault events (incl. which broker was killed and whether Docker's restart policy revived the consumer on its own); `cluster_before.txt` / `cluster_after.txt` — KRaft controller, consumer-group coordinators and partition leaders before the faults and after healing (to explain recovery times: losing the group coordinator or a partition leader is not the same as losing a follower).
- `history/history.csv` — History API: for `json_full` (whole table as a JSON stream, `X-API-Key` header) and `parquet_full` (Parquet export, `Authorization: Bearer`): HTTP code, rows, bytes, total time, time to first byte, the service's RSS at start and its peak RSS (`VmHWM`, service restarted before every request), plus checks `json_small` (exactly 10 rows), `json_stocks_topic` (the `company_stocks` topic is served) and `auth_missing` (401 without a key).
- `comparison-by-vus.md` — with `VU_LEVELS`: create p50/p95/p99, throughput and lags of each scenario per concurrency level (overhead % vs the baseline of the same level).
- `linux-run-summary.md` — host specs, exact commands, tables and notes for the 2026-10-14 Linux run (5 repeats + the 3-run cdc compression measurement in `cdc-segmentby-none/`).
- `comparison.md` / `comparison.csv` / `comparison.html` — combined table across scenarios (incl. `Audit storage (compressed)` and `Compression ratio` for cdc when `storage_compressed.csv` exists). With `REPEATS>1`, `comparison.md` also has a **statistical comparison with baseline**: Δ of the medians, a 95 % bootstrap CI of Δ (runs resampled, fixed seed) and the exact two-sided Mann–Whitney U p-value (with 5 vs 5 runs the smallest possible p is 0.008). The History API results get their own section.
- `smoke_check.py <results>` — sanity checks over a results directory (run automatically at the end of `run-all.sh`): planned iterations ran, one mutation per iteration, mutations mostly succeed, no login failures, sessions reused, ≥ ~1 audit row per successful mutation, lag and SSE measured from the commit time, no event lost in `cdc-failover`, every History API check passed.

### Changes on 2026-10-15 that affect comparability with earlier result sets

- **SSE latency reference.** The SSE bridge used Debezium's *envelope* `ts_ms` (when Debezium processed the event) as `changedAt`, while the audit consumer used `source.ts_ms` (the commit time). SSE latencies of earlier runs therefore left out commit → Debezium and are not comparable with the audit-store lag. `changedAt` is now the commit time; the envelope time is sent as `capturedAt`.
- **Load model.** One login per VU instead of one per mutation, cheap hash for the bench users, bulk seeding and per-VU id partitioning (see *Load model*). Write latencies at 64 VUs are no longer dominated by password hashing, and far fewer mutations fail.
- **SSE bridge.** `publish()` instead of an unbounded `replay()` (every new or reconnecting client used to receive the whole history since start-up, and it was all kept in memory); consumer offsets are committed; the Kafka client timeouts are the Apache Kafka defaults (the previous `reconnect.backoff.max.ms = 30 s` and `retry.backoff.ms = 2 s` slowed recovery after a broker crash); event payloads are no longer logged at INFO.
- **Audit consumer.** DELETE rows now keep the change reason (taken from the before-image).
- **History API.** Serves `company_stocks` and `company_capital` too; both the SSE bridge and the History API accept `X-API-Key: <key>` and `Authorization: Bearer <key>`.

## How each method is toggled

- **Triggers** — created `ENABLE`d in `mainDb/init.sql`; `run-all.sh` does
  `ALTER TABLE … DISABLE/ENABLE TRIGGER …` per scenario.
- **Envers** — off by default (`hibernate.integration.envers.enabled=false`);
  the `envers` scenario boots the API with `BR_API_PROFILES=prod,envers`, which
  enables the integrator and lets `ddl-auto=update` create the `_AUD` tables.
  `REVINFO` is pre-created in `mainDb/init.sql` (it is a mapped `@Entity`, so it
  must satisfy `validate` on every boot). Attribution: `AuditRevisionListener`
  stamps `changed_by_user_id` from the per-request `AuditContext`; `change_reason`
  + `last_user_id` also survive as audited entity columns in each `_AUD` row.
- **Event topics** are auto-created on first publish with the brokers' `default.replication.factor = 3`
  / `min.insync.replicas = 2` (compose env), so a single broker crash in `cdc-failover` must cost
  neither availability nor data.
- **CDC** — only the `cdc`-family scenarios start Kafka + Debezium + `audit-consumer`.
  `ingested_at DEFAULT now()` on the `*_audit` tables marks consumer write time;
  `changed_at` is Debezium's source commit time.

## Qualitative comparison (for the write-up)

| Dimension | CDC (Debezium) | DB triggers | Hibernate Envers |
|-----------|----------------|-------------|------------------|
| Coupling to app | none (reads WAL) | none (DB-side) | tight (ORM/app) |
| Write-path overhead | ~0 on source txn (async) | per-row, in txn | per-flush, in txn |
| Audit availability | eventual (pipeline lag) | immediate | immediate |
| Captures non-ORM writes | yes (any SQL) | yes (any SQL) | **no** (only via Hibernate) |
| Before/after image | full (REPLICA IDENTITY FULL) | full (`OLD`/`NEW`) | full (per-revision rows) |
| Attribution survival | row-carried → envelope | row-carried (`OLD`/`NEW`) | RevisionListener + columns |
| Storage location | separate store (scales out) | same DB (competes for IO) | same DB (competes for IO) |
| Schema-evolution cost | connector config | per-table trigger DDL | `_AUD` schema migration |
| Query ergonomics | History API / SQL | plain SQL | Envers query API / SQL |
| Operational complexity | high (Kafka/Connect) | low | low–medium |
| Failure isolation | source unaffected if pipeline down | mutation fails if audit fails | mutation fails if audit fails |

The quantitative table (`comparison.md`) is produced per run; paste both into
the thesis.
