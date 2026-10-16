# Audit-method comparison — results (median of 3 runs per scenario)

| Metric | cdc-failover |
|---|---|
| Total ops | 20,000 |
| Load model | open, 50 ops/s |
| Throughput (ops/s) | 49.9 |
| Mutations ok / err | 19,594 / 406 |
| Errors 4xx / 5xx | 406 / 0 |
| Logins / re-logins | 20,000 / 19,936 |
| Login p50 (ms) | 1.3 |
| Create p50 (ms) | 4.4 |
| Create p95 (ms) | 7.3 |
| Create p99 (ms) | 109.1 |
| Update p50 (ms) | 4.9 |
| Update p95 (ms) | 8.7 |
| Delete p50 (ms) | 5.3 |
| Overhead vs baseline (create p50) | — |
| Audit rows captured | 37,991 |
| Audit storage | 24.84 MB |
| Audit storage after VACUUM FULL | 23.64 MB |
| Dead tuples in audit tables | 0 |
| Bytes / audit row | 685.7 B |
| Audit lag p50 (ms) | 13,007.0 |
| Audit lag p95 (ms) | 157,121.5 |
| Audit lag p99 (ms) | 173,369.3 |
| Audit lag max (ms) | 177,076.6 |
| SSE events received | 37,991 |
| SSE lag p50 (ms) | 814.0 |
| SSE lag p95 (ms) | 155,948.7 |
| SSE lag p99 (ms) | 172,967.9 |
| SSE lag max (ms) | 177,052.9 |
| SSE commit→Debezium p50 (ms) | 329.0 |
| SSE Debezium→client p50 (ms) | 442.1 |
| SSE duplicate / stale events | 0 / 0 |
| Integrity: trigger rows (ground truth) | 37,991 |
| Integrity: CDC rows | 37,991 |
| Integrity: missing events | 0 |
| Integrity: duplicate events | 0 |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). SSE lag = arrival at an external SSE client − commit time (Debezium source.ts_ms, the same reference as the audit store's changed_at), split into commit→Debezium (envelope ts_ms) and Debezium→client (sse_probe.py). Audit storage = on-disk size including dead tuples of rolled-back transactions; 'after VACUUM FULL' = size of the live rows only. cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 3 runs)

| Metric | cdc-failover |
|---|---|
| Create p50 (ms) | 4.4 – 4.4 |
| Create p95 (ms) | 7.2 – 7.4 |
| Create p99 (ms) | 104.9 – 122.2 |
| Update p50 (ms) | 4.9 – 4.9 |
| Throughput (ops/s) | 49.9 – 49.9 |
| Audit rows captured | 37,888 – 38,182 |
| Audit storage (MB) | 24.77 – 24.93 |
| Audit lag p50 (ms) | 605.7 – 19,347.8 |
| Audit lag p99 (ms) | 42,379.2 – 181,002.9 |
| SSE lag p50 (ms) | 521.4 – 856.3 |
| SSE lag p99 (ms) | 8,595.2 – 180,767.0 |
| Integrity: missing events | 0 – 0 |
| Integrity: duplicate events | 0 – 0 |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|
| cdc-failover | 1 | 4.4 | 7.2 | 104.9 | 4.9 | 49.9 | 38,182 | 24.93 MB | 605.7 | 42,379.2 |
| cdc-failover | 2 | 4.4 | 7.3 | 122.2 | 4.9 | 49.9 | 37,991 | 24.77 MB | 19,347.8 | 181,002.9 |
| cdc-failover | 3 | 4.4 | 7.4 | 109.1 | 4.9 | 49.9 | 37,888 | 24.84 MB | 13,007.0 | 173,369.3 |
