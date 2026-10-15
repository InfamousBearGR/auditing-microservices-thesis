# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | cdc-failover |
|---|---|
| Total ops | 10,000 |
| Throughput (ops/s) | 33.9 |
| Mutations ok / err | 4,130 / 5,870 |
| Create p50 (ms) | 510.4 |
| Create p95 (ms) | 1,136.7 |
| Create p99 (ms) | 1,544.7 |
| Update p50 (ms) | 515.0 |
| Update p95 (ms) | 1,146.6 |
| Delete p50 (ms) | 508.0 |
| Overhead vs baseline (create p50) | — |
| Audit rows captured | 4,760 |
| Audit storage | 5.67 MB |
| Bytes / audit row | 1,249.5 B |
| Audit lag p50 (ms) | 655.2 |
| Audit lag p95 (ms) | 30,335.1 |
| Audit lag p99 (ms) | 43,454.1 |
| Audit lag max (ms) | 46,446.5 |
| SSE events received | 4,760 |
| SSE lag p50 (ms) | 276.3 |
| SSE lag p95 (ms) | 3,418.1 |
| SSE lag p99 (ms) | 11,101.7 |
| SSE lag max (ms) | 15,413.6 |
| Integrity: trigger rows (ground truth) | 4,760 |
| Integrity: CDC rows | 4,760 |
| Integrity: missing events | 0 |
| Integrity: duplicate events | 0 |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). SSE lag = arrival at an external SSE client − commit time (sse_probe.py). cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | cdc-failover |
|---|---|
| Create p50 (ms) | 508.7 – 518.7 |
| Create p95 (ms) | 1,130.6 – 1,162.4 |
| Create p99 (ms) | 1,528.0 – 1,566.0 |
| Update p50 (ms) | 510.0 – 523.8 |
| Throughput (ops/s) | 33.8 – 34.0 |
| Audit rows captured | 4,639 – 4,887 |
| Audit storage (MB) | 5.59 – 5.77 |
| Audit lag p50 (ms) | 643.5 – 667.9 |
| Audit lag p99 (ms) | 42,817.0 – 43,981.1 |
| SSE lag p50 (ms) | 269.8 – 286.8 |
| SSE lag p99 (ms) | 10,607.3 – 12,926.4 |
| Integrity: missing events | 0 – 0 |
| Integrity: duplicate events | 0 – 0 |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|
| cdc-failover | 1 | 518.7 | 1,130.6 | 1,533.7 | 513.6 | 33.9 | 4,855 | 5.67 MB | 659.4 | 43,454.1 |
| cdc-failover | 2 | 510.4 | 1,133.2 | 1,528.0 | 522.0 | 33.8 | 4,887 | 5.77 MB | 643.5 | 42,817.0 |
| cdc-failover | 3 | 517.3 | 1,162.4 | 1,562.2 | 515.0 | 33.9 | 4,749 | 5.67 MB | 644.0 | 43,871.3 |
| cdc-failover | 4 | 510.3 | 1,159.5 | 1,544.7 | 510.0 | 33.9 | 4,639 | 5.59 MB | 667.9 | 43,981.1 |
| cdc-failover | 5 | 508.7 | 1,136.7 | 1,566.0 | 523.8 | 34.0 | 4,760 | 5.66 MB | 655.2 | 42,872.0 |