# Audit-method comparison — results (median of 3 runs per scenario)

| Metric | cdc |
|---|---|
| Total ops | 10,000 |
| Throughput (ops/s) | 33.5 |
| Mutations ok / err | 4,170 / 5,830 |
| Create p50 (ms) | 516.4 |
| Create p95 (ms) | 1,171.5 |
| Create p99 (ms) | 1,605.7 |
| Update p50 (ms) | 515.9 |
| Update p95 (ms) | 1,186.3 |
| Delete p50 (ms) | 515.9 |
| Overhead vs baseline (create p50) | — |
| Audit rows captured | 5,056 |
| Audit storage | 5.87 MB |
| Audit storage (compressed) | 4.02 MB |
| Compression ratio | 1.46× |
| Bytes / audit row | 1,216.8 B |
| Audit lag p50 (ms) | 586.7 |
| Audit lag p95 (ms) | 933.2 |
| Audit lag p99 (ms) | 1,070.3 |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression (no segmentby, orderby changed_at DESC) and running compress_chunk() on all chunks; compression ratio = uncompressed / compressed bytes, summed over all *_audit hypertables._


## Run-to-run spread (min – max over 3 runs)

| Metric | cdc |
|---|---|
| Create p50 (ms) | 512.3 – 518.1 |
| Create p95 (ms) | 1,144.1 – 1,192.7 |
| Create p99 (ms) | 1,573.8 – 1,609.1 |
| Update p50 (ms) | 512.6 – 523.7 |
| Throughput (ops/s) | 33.3 – 33.7 |
| Audit rows captured | 4,683 – 5,167 |
| Audit storage (MB) | 5.65 – 5.91 |
| Audit storage compressed (MB) | 4.01 – 4.02 |
| Compression ratio | 1.41 – 1.47 |
| Audit lag p50 (ms) | 583.8 – 592.9 |
| Audit lag p99 (ms) | 963.5 – 1,183.3 |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Audit MB (compressed) | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cdc | 1 | 512.3 | 1,144.1 | 1,573.8 | 515.9 | 33.7 | 5,167 | 5.91 MB | 4.02 MB | 592.9 | 1,183.3 |
| cdc | 2 | 518.1 | 1,192.7 | 1,609.1 | 512.6 | 33.5 | 4,683 | 5.65 MB | 4.01 MB | 586.7 | 1,070.3 |
| cdc | 3 | 516.4 | 1,171.5 | 1,605.7 | 523.7 | 33.3 | 5,056 | 5.87 MB | 4.02 MB | 583.8 | 963.5 |