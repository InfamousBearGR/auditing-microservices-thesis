# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | cdc |
|---|---|
| Total ops | 10,000 |
| Throughput (ops/s) | 33.9 |
| Mutations ok / err | 4,142 / 5,858 |
| Create p50 (ms) | 508.0 |
| Create p95 (ms) | 1,148.9 |
| Create p99 (ms) | 1,573.6 |
| Update p50 (ms) | 516.0 |
| Update p95 (ms) | 1,157.5 |
| Delete p50 (ms) | 502.8 |
| Overhead vs baseline (create p50) | — |
| Audit rows captured | 4,753 |
| Audit storage | 5.64 MB |
| Audit storage (compressed) | 4.01 MB |
| Compression ratio | 1.41× |
| Bytes / audit row | 1,244.4 B |
| Audit lag p50 (ms) | 583.3 |
| Audit lag p95 (ms) | 937.4 |
| Audit lag p99 (ms) | 1,097.1 |
| Audit lag max (ms) | 1,415.7 |
| SSE events received | 4,753 |
| SSE lag p50 (ms) | 272.3 |
| SSE lag p95 (ms) | 495.3 |
| SSE lag p99 (ms) | 520.0 |
| SSE lag max (ms) | 561.6 |
| Integrity: trigger rows (ground truth) | — |
| Integrity: CDC rows | — |
| Integrity: missing events | — |
| Integrity: duplicate events | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression (no segmentby, orderby changed_at DESC) and running compress_chunk() on all chunks; compression ratio = uncompressed / compressed bytes, summed over all *_audit hypertables. SSE lag = arrival at an external SSE client − commit time (sse_probe.py). cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | cdc |
|---|---|
| Create p50 (ms) | 506.5 – 510.0 |
| Create p95 (ms) | 1,140.8 – 1,162.2 |
| Create p99 (ms) | 1,544.0 – 1,600.0 |
| Update p50 (ms) | 514.2 – 521.4 |
| Throughput (ops/s) | 33.8 – 33.9 |
| Audit rows captured | 4,481 – 4,938 |
| Audit storage (MB) | 5.52 – 5.80 |
| Audit storage compressed (MB) | 4.01 – 4.03 |
| Compression ratio | 1.38 – 1.45 |
| Audit lag p50 (ms) | 580.2 – 595.8 |
| Audit lag p99 (ms) | 1,016.2 – 1,880.6 |
| SSE lag p50 (ms) | 258.7 – 283.6 |
| SSE lag p99 (ms) | 512.4 – 535.9 |
| Integrity: missing events | — |
| Integrity: duplicate events | — |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Audit MB (compressed) | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| cdc | 1 | 509.3 | 1,162.2 | 1,562.4 | 515.2 | 33.9 | 4,938 | 5.80 MB | 4.01 MB | 592.5 | 1,016.2 |
| cdc | 2 | 506.5 | 1,140.8 | 1,600.0 | 516.0 | 33.9 | 4,721 | 5.64 MB | 4.01 MB | 583.3 | 1,097.1 |
| cdc | 3 | 507.8 | 1,157.2 | 1,587.5 | 514.2 | 33.9 | 4,753 | 5.63 MB | 4.01 MB | 580.2 | 1,880.6 |
| cdc | 4 | 510.0 | 1,148.9 | 1,573.6 | 521.4 | 33.8 | 4,481 | 5.52 MB | 4.02 MB | 580.7 | 1,139.9 |
| cdc | 5 | 508.0 | 1,142.5 | 1,544.0 | 521.3 | 33.9 | 4,925 | 5.79 MB | 4.03 MB | 595.8 | 1,028.4 |