# Linux benchmark run — 2026-10-14

Re-run of the audit-method benchmark (baseline | cdc | triggers | envers) on a
Linux workstation, 5 round-robin repeats per scenario. CDC audit storage is
reported uncompressed (main run) and after **TimescaleDB native compression**
(a separate 3-run CDC-only measurement of the same workload).

## Host

| | |
|---|---|
| Date | 2026-10-14, main run 17:09 – 18:58 EEST (+03:00); cdc compression run 18:59 – 19:20 |
| `uname -a` | `Linux InfamousBearArch 7.2.9-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 03 Oct 2026 11:43:28 +0000 x86_64 GNU/Linux` |
| CPU | AMD Ryzen 7 5700X3D, 8 cores / 16 threads, 1 socket |
| RAM | 31 GiB (≈23 GiB available at start) |
| Disk | Docker root `/var/lib/docker` on `/dev/sdd2` (ext4) — Samsung SSD 860 EVO 250 GB, **SATA SSD** (non-rotational); 8.5 GB free during the run |
| Docker | Engine 27.2.1 (overlayfs, cgroup v2, systemd cgroup driver), Compose 5.6.0 |
| TimescaleDB | 2.25.2 on PostgreSQL 15 (`timescale/timescaledb:latest-pg15`) |
| Other images | mainDb `postgres:15-alpine`, Debezium Connect 3.4.2.Final, `apache/kafka:latest` (3 brokers, KRaft), k6 v2.0.0 (`grafana/k6:latest`) |
| Background load | none (load avg ≈0.4–0.7 before start; nothing else run during the benchmark) |

All services co-located on this one machine — absolute numbers are
hardware-specific; the relationships between methods are the point.

## Commands

```bash
# main run (all 4 scenarios × 5 repeats, round-robin)
REPEATS=5 VUS=64 TOTAL_OPS=10000 CDC_DRAIN_S=120 ./benchmark/run-all.sh 2>&1 | tee benchmark/results/run.log
python3 benchmark/summarize.py benchmark/results

# cdc-only compression measurement (3 repeats, no segmentby) — separate results dir, main results untouched
SCENARIOS=cdc REPEATS=3 VUS=64 TOTAL_OPS=10000 CDC_DRAIN_S=120 COMPRESS_SEGMENTBY='' \
  RESULTS_DIR="$PWD/benchmark/results/cdc-segmentby-none" ./benchmark/run-all.sh \
  2>&1 | tee benchmark/results/cdc-segmentby-none/run.log
```

Completeness: `results/{baseline,cdc,triggers,envers}/run-1..5/` each contain
`k6-summary.json` + `storage.csv`; every `cdc/run-k/` also has `lag.csv`.
`cdc-segmentby-none/cdc/run-1..3/` have `k6-summary.json`, `storage.csv`,
`lag.csv`, `storage_compressed.csv` and `compression_settings.txt`. No connector failures, no drain timeouts, no
compression errors in either log.

## Results (median of 5 runs per scenario)

| Metric | baseline | cdc | triggers | envers |
|---|---|---|---|---|
| Total ops | 10,000 | 10,000 | 10,000 | 10,000 |
| Throughput (ops/s) | 35.4 | 33.8 | 35.5 | 35.5 |
| Mutations ok / err | 4,123 / 5,877 | 4,134 / 5,866 | 4,142 / 5,858 | 4,181 / 5,819 |
| Create p50 (ms) | 490.6 | 512.5 | 496.0 | 492.3 |
| Create p95 (ms) | 1,060.2 | 1,164.2 | 1,065.5 | 1,060.2 |
| Create p99 (ms) | 1,438.4 | 1,573.3 | 1,454.1 | 1,434.2 |
| Update p50 (ms) | 497.5 | 519.5 | 499.6 | 494.0 |
| Update p95 (ms) | 1,067.5 | 1,174.0 | 1,068.1 | 1,068.4 |
| Delete p50 (ms) | 492.1 | 508.0 | 489.6 | 496.1 |
| Overhead vs baseline (create p50) | +0.0% | +4.5% | +1.1% | +0.4% |
| Audit rows captured | 0 | 4,981 | 4,808 | 8,735 |
| Audit storage | — | 5.77 MB | 5.72 MB | 3.66 MB |
| Bytes / audit row | — | 1,213.8 B | 1,247.2 B | 439.8 B |
| Audit lag p50 (ms) | — | 568.3 | — | — |
| Audit lag p95 (ms) | — | 922.2 | — | — |
| Audit lag p99 (ms) | — | 1,000.1 | — | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks)._

### Run-to-run spread (min – max over 5 runs)

| Metric | baseline | cdc | triggers | envers |
|---|---|---|---|---|
| Create p50 (ms) | 488.4 – 495.9 | 504.9 – 521.1 | 489.2 – 503.4 | 491.2 – 496.5 |
| Create p95 (ms) | 1,056.2 – 1,067.0 | 1,152.3 – 1,213.7 | 1,053.7 – 1,089.2 | 1,045.5 – 1,084.9 |
| Create p99 (ms) | 1,415.3 – 1,453.1 | 1,533.5 – 1,661.4 | 1,444.0 – 1,483.6 | 1,417.1 – 1,484.4 |
| Update p50 (ms) | 495.8 – 501.6 | 512.7 – 528.1 | 490.7 – 500.7 | 492.6 – 505.7 |
| Throughput (ops/s) | 35.3 – 35.5 | 33.1 – 33.9 | 34.8 – 35.6 | 35.0 – 35.6 |
| Audit rows captured | 0 – 0 | 4,637 – 5,226 | 4,667 – 5,056 | 8,529 – 9,035 |
| Audit storage (MB) | 0.00 – 0.00 | 5.56 – 5.94 | 5.51 – 5.92 | 3.41 – 3.80 |
| Audit lag p50 (ms) | — | 563.4 – 599.6 | — | — |
| Audit lag p99 (ms) | — | 982.5 – 1,034.6 | — | — |

Per-run values: `benchmark/results/comparison.md`.

## CDC audit storage: uncompressed vs compressed (per table, median of 3 runs)

Compression = `ALTER TABLE … SET (timescaledb.compress, compress_orderby = 'changed_at DESC')`
(no segmentby) + `compress_chunk()` on every chunk; sizes are `hypertable_size()`
before/after (incl. indexes and per-chunk overhead). "TSDB stats" =
`hypertable_compression_stats()` `before/after_compression_total_bytes`.

| Table | Rows | Uncompressed (kB) | Compressed (kB) | Ratio | TSDB stats before→after (kB) |
|---|---:|---:|---:|---:|---:|
| company_audit | 1,322 | 1,216 | 656 | 1.85× | 1,176 → 488 |
| company_capital_audit | 117 | 392 | 424 | 0.92× | 352 → 256 |
| company_stocks_audit | 591 | 560 | 424 | 1.32× | 520 → 256 |
| legal_entity_audit | 1,369 | 1,152 | 648 | 1.78× | 1,112 → 480 |
| member_audit | 251 | 528 | 424 | 1.25× | 488 → 256 |
| person_audit | 1,435 | 1,328 | 696 | 1.91× | 1,288 → 528 |

21 zero-row tables: 40 kB uncompressed / 40 kB compressed each

Total over all 27 `*_audit` hypertables: **5.87 MB → 4.02 MB (1.46×)**; over
the 6 populated tables only: ≈5.05 MB → ≈3.20 MB (≈1.58×). Run-to-run spread:
4.01–4.02 MB compressed, 1.41–1.47×. Full table: `cdc-segmentby-none/comparison.md`.

## Notes / anything unusual

- **Compression works best on the large tables:** `company`, `person` and
  `legal_entity` audit tables compress 1.8–1.9× by `hypertable_size()` and
  ~2.4× by TimescaleDB's own chunk stats. The `before`/`after` JSONB is already
  TOAST/pglz-compressed by PostgreSQL, which limits further gains.
- **Fixed per-hypertable floor.** Each hypertable is space-partitioned into 4
  (`change_id`), so even a tiny table owns several chunks + indexes; compressed
  populated tables bottom out at ~424 kB, and the 21 empty `*_audit` tables cost
  40 kB each (≈0.82 MB total, identical before/after) — this dilutes the overall
  ratio toward 1 and makes the smallest table (`company_capital_audit`, ~117
  rows) compress slightly <1×.
- **Faster than the previous (3-run) host:** throughput ≈35 ops/s vs ≈29,
  create p50 ≈490 ms vs ≈600 ms. CDC write-path overhead (create p50) is
  **+4.5%** here vs +8.6% before; CDC lag p50 ≈568 ms (was ≈606 ms). The
  relationships between methods are unchanged.
- Run-to-run spread is tight (create p50 within ±2% per scenario); triggers
  (+1.1%) and Envers (+0.4%) stay within baseline noise.
- ≈58% of k6 mutations fail on constraint/FK violations **by design** (random
  ops on a fixed seed set); identical across scenarios.
- Envers audit storage ≈3.66 MB (was ≈4.10 MB) — within its own run-to-run
  spread (3.41–3.80 MB); row count includes `revinfo`.
- Root filesystem was 96–97% full (8.5 GB free); every scenario does `down -v`,
  so usage did not grow and no I/O errors occurred.
- The compression run's latency/lag (create p50 516 ms, lag p50 587 ms)
  matches the main cdc runs, so its storage numbers are comparable.
