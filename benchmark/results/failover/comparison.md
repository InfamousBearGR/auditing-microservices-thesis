# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | cdc-failover |
|---|---|
| Total ops | 10,000 |
| Load model | open, 50 ops/s |
| Throughput (ops/s) | 49.9 |
| Mutations ok / err | 9,872 / 128 |
| Errors 4xx / 5xx | 128 / 0 |
| Logins / re-logins | 10,000 / 9,936 |
| Login p50 (ms) | 1.3 |
| Create p50 (ms) | 4.5 |
| Create p95 (ms) | 8.0 |
| Create p99 (ms) | 98.5 |
| Update p50 (ms) | 5.1 |
| Update p95 (ms) | 9.6 |
| Delete p50 (ms) | 5.4 |
| Overhead vs baseline (create p50) | — |
| Audit rows captured | 17,985 |
| Audit storage | 13.52 MB |
| Audit storage after VACUUM FULL | 12.65 MB |
| Dead tuples in audit tables | 0 |
| Bytes / audit row | 788.0 B |
| Audit lag p50 (ms) | 791.2 |
| Audit lag p95 (ms) | 36,661.8 |
| Audit lag p99 (ms) | 44,171.2 |
| Audit lag max (ms) | 46,525.7 |
| SSE events received | 17,985 |
| SSE lag p50 (ms) | 573.4 |
| SSE lag p95 (ms) | 21,268.7 |
| SSE lag p99 (ms) | 28,741.7 |
| SSE lag max (ms) | 30,487.0 |
| SSE commit→Debezium p50 (ms) | 253.0 |
| SSE Debezium→client p50 (ms) | 310.3 |
| SSE duplicate / stale events | 0 / 0 |
| Integrity: trigger rows (ground truth) | 17,985 |
| Integrity: CDC rows | 17,985 |
| Integrity: missing events | 0 |
| Integrity: duplicate events | 0 |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). SSE lag = arrival at an external SSE client − commit time (Debezium source.ts_ms, the same reference as the audit store's changed_at), split into commit→Debezium (envelope ts_ms) and Debezium→client (sse_probe.py). Audit storage = on-disk size including dead tuples of rolled-back transactions; 'after VACUUM FULL' = size of the live rows only. cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | cdc-failover |
|---|---|
| Create p50 (ms) | 4.5 – 4.5 |
| Create p95 (ms) | 7.8 – 8.2 |
| Create p99 (ms) | 89.3 – 140.7 |
| Update p50 (ms) | 5.0 – 5.1 |
| Throughput (ops/s) | 49.9 – 49.9 |
| Audit rows captured | 17,653 – 18,087 |
| Audit storage (MB) | 13.39 – 13.59 |
| Audit lag p50 (ms) | 776.4 – 826.2 |
| Audit lag p99 (ms) | 43,613.1 – 44,352.2 |
| SSE lag p50 (ms) | 572.4 – 575.5 |
| SSE lag p99 (ms) | 28,550.2 – 30,832.2 |
| Integrity: missing events | 0 – 0 |
| Integrity: duplicate events | 0 – 0 |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|
| cdc-failover | 1 | 4.5 | 8.0 | 95.2 | 5.0 | 49.9 | 17,985 | 13.52 MB | 826.2 | 43,613.1 |
| cdc-failover | 2 | 4.5 | 7.8 | 89.3 | 5.1 | 49.9 | 17,653 | 13.39 MB | 778.5 | 44,352.2 |
| cdc-failover | 3 | 4.5 | 8.2 | 136.6 | 5.1 | 49.9 | 18,087 | 13.59 MB | 776.4 | 44,171.2 |
| cdc-failover | 4 | 4.5 | 8.0 | 98.5 | 5.1 | 49.9 | 17,994 | 13.50 MB | 791.5 | 44,275.8 |
| cdc-failover | 5 | 4.5 | 7.9 | 140.7 | 5.1 | 49.9 | 17,951 | 13.53 MB | 791.2 | 44,153.0 |
