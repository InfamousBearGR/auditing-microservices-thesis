# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Total ops | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 |
| Throughput (ops/s) | 39.6 | 37.4 | 39.7 | 39.7 | 37.9 | 38.0 |
| Mutations ok / err | 4,101 / 2,145 | 4,080 / 2,169 | 4,130 / 1,973 | 4,081 / 2,015 | 4,061 / 2,044 | 4,154 / 1,988 |
| Create p50 (ms) | 7.5 | 7.3 | 7.8 | 8.0 | 7.5 | 7.5 |
| Create p95 (ms) | 31.0 | 26.0 | 35.3 | 33.5 | 26.2 | 32.1 |
| Create p99 (ms) | 48.9 | 51.8 | 50.3 | 51.5 | 49.6 | 50.4 |
| Update p50 (ms) | 4.2 | 4.2 | 4.4 | 4.3 | 4.2 | 4.4 |
| Update p95 (ms) | 18.0 | 18.2 | 18.3 | 22.7 | 20.4 | 18.7 |
| Delete p50 (ms) | 2.9 | 2.9 | 2.8 | 2.8 | 2.9 | 2.9 |
| Overhead vs baseline (create p50) | +0.0% | -2.4% | +3.8% | +6.6% | -0.4% | -0.3% |
| Audit rows captured | 0 | 4,613 | 4,717 | 8,509 | 0 | 0 |
| Audit storage | — | 5.60 MB | 4.17 MB | 2.10 MB | — | — |
| Audit storage (compressed) | — | 4.00 MB | — | — | — | — |
| Compression ratio | — | 1.40× | — | — | — | — |
| Bytes / audit row | — | 1,273.3 B | 927.4 B | 259.0 B | — | — |
| Audit lag p50 (ms) | — | 560.1 | — | — | — | — |
| Audit lag p95 (ms) | — | 904.5 | — | — | — | — |
| Audit lag p99 (ms) | — | 981.5 | — | — | — | — |
| Audit lag max (ms) | — | 1,153.0 | — | — | — | — |
| SSE events received | — | 4,613 | — | — | — | — |
| SSE lag p50 (ms) | — | 251.6 | — | — | — | — |
| SSE lag p95 (ms) | — | 487.6 | — | — | — | — |
| SSE lag p99 (ms) | — | 514.3 | — | — | — | — |
| SSE lag max (ms) | — | 536.5 | — | — | — | — |
| Integrity: trigger rows (ground truth) | — | — | — | — | — | — |
| Integrity: CDC rows | — | — | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression (no segmentby, orderby changed_at DESC) and running compress_chunk() on all chunks; compression ratio = uncompressed / compressed bytes, summed over all *_audit hypertables. SSE lag = arrival at an external SSE client − commit time (sse_probe.py). cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 5.2 – 7.7 | 5.6 – 7.4 | 7.7 – 8.0 | 7.9 – 8.7 | 7.4 – 7.6 | 7.4 – 8.0 |
| Create p95 (ms) | 13.7 – 35.0 | 15.5 – 33.0 | 21.5 – 37.0 | 32.1 – 38.8 | 20.3 – 32.6 | 19.0 – 40.3 |
| Create p99 (ms) | 46.6 – 50.1 | 47.1 – 53.1 | 48.7 – 52.3 | 50.7 – 53.2 | 49.3 – 50.7 | 49.9 – 51.7 |
| Update p50 (ms) | 4.1 – 5.1 | 4.1 – 4.7 | 3.9 – 4.6 | 3.9 – 4.8 | 4.1 – 4.8 | 3.8 – 5.1 |
| Throughput (ops/s) | 39.1 – 39.8 | 37.4 – 37.5 | 39.4 – 40.3 | 39.5 – 40.1 | 37.4 – 38.0 | 37.2 – 38.3 |
| Audit rows captured | 0 – 0 | 4,533 – 4,845 | 4,650 – 4,805 | 8,371 – 8,836 | 0 – 0 | 0 – 0 |
| Audit storage (MB) | 0.00 – 0.00 | 5.53 – 5.67 | 4.00 – 4.27 | 1.82 – 2.17 | 0.00 – 0.00 | 0.00 – 0.00 |
| Audit storage compressed (MB) | — | 3.99 – 4.01 | — | — | — | — |
| Compression ratio | — | 1.38 – 1.42 | — | — | — | — |
| Audit lag p50 (ms) | — | 558.6 – 570.4 | — | — | — | — |
| Audit lag p99 (ms) | — | 975.7 – 1,008.4 | — | — | — | — |
| SSE lag p50 (ms) | — | 234.5 – 270.3 | — | — | — | — |
| SSE lag p99 (ms) | — | 509.7 – 515.4 | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Audit MB (compressed) | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| baseline | 1 | 5.2 | 13.7 | 46.6 | 4.2 | 39.2 | 0 | — | — | — | — |
| baseline | 2 | 7.7 | 34.4 | 50.1 | 5.1 | 39.8 | 0 | — | — | — | — |
| baseline | 3 | 7.4 | 18.6 | 49.4 | 4.4 | 39.6 | 0 | — | — | — | — |
| baseline | 4 | 7.5 | 31.0 | 48.7 | 4.1 | 39.8 | 0 | — | — | — | — |
| baseline | 5 | 7.7 | 35.0 | 48.9 | 4.1 | 39.1 | 0 | — | — | — | — |
| cdc | 1 | 5.6 | 15.5 | 47.1 | 4.2 | 37.4 | 4,845 | 5.67 MB | 3.99 MB | 558.6 | 981.5 |
| cdc | 2 | 7.3 | 26.0 | 51.8 | 4.2 | 37.4 | 4,613 | 5.64 MB | 3.99 MB | 558.7 | 978.4 |
| cdc | 3 | 7.4 | 33.0 | 52.8 | 4.7 | 37.4 | 4,683 | 5.60 MB | 4.00 MB | 570.4 | 993.7 |
| cdc | 4 | 7.3 | 27.9 | 51.6 | 4.5 | 37.5 | 4,580 | 5.58 MB | 4.00 MB | 560.1 | 1,008.4 |
| cdc | 5 | 7.3 | 22.1 | 53.1 | 4.1 | 37.5 | 4,533 | 5.53 MB | 4.01 MB | 562.3 | 975.7 |
| triggers | 1 | 8.0 | 37.0 | 49.9 | 4.6 | 39.4 | 4,742 | 4.17 MB | — | — | — |
| triggers | 2 | 7.7 | 35.3 | 51.2 | 3.9 | 40.3 | 4,693 | 4.00 MB | — | — | — |
| triggers | 3 | 7.9 | 33.1 | 50.3 | 4.5 | 40.3 | 4,650 | 4.01 MB | — | — | — |
| triggers | 4 | 7.7 | 21.5 | 48.7 | 4.2 | 39.6 | 4,717 | 4.23 MB | — | — | — |
| triggers | 5 | 7.8 | 35.9 | 52.3 | 4.4 | 39.7 | 4,805 | 4.27 MB | — | — | — |
| envers | 1 | 8.7 | 38.8 | 52.4 | 4.7 | 39.5 | 8,371 | 2.05 MB | — | — | — |
| envers | 2 | 7.9 | 33.5 | 53.2 | 4.3 | 40.1 | 8,836 | 2.16 MB | — | — | — |
| envers | 3 | 8.0 | 33.5 | 50.7 | 3.9 | 39.6 | 8,554 | 2.17 MB | — | — | — |
| envers | 4 | 8.0 | 32.1 | 51.5 | 4.3 | 39.9 | 8,509 | 2.10 MB | — | — | — |
| envers | 5 | 8.0 | 36.3 | 51.2 | 4.8 | 39.7 | 8,459 | 1.82 MB | — | — | — |
| cdc-idle | 1 | 7.4 | 20.3 | 49.4 | 4.2 | 38.0 | 0 | — | — | — | — |
| cdc-idle | 2 | 7.5 | 26.2 | 49.3 | 4.6 | 37.4 | 0 | — | — | — | — |
| cdc-idle | 3 | 7.5 | 20.4 | 49.6 | 4.1 | 37.7 | 0 | — | — | — | — |
| cdc-idle | 4 | 7.6 | 29.8 | 50.7 | 4.1 | 37.9 | 0 | — | — | — | — |
| cdc-idle | 5 | 7.4 | 32.6 | 50.4 | 4.8 | 37.9 | 0 | — | — | — | — |
| cdc-slot | 1 | 7.6 | 33.7 | 51.4 | 3.9 | 38.1 | 0 | — | — | — | — |
| cdc-slot | 2 | 7.4 | 23.6 | 49.9 | 4.4 | 38.0 | 0 | — | — | — | — |
| cdc-slot | 3 | 8.0 | 40.3 | 51.7 | 4.6 | 37.2 | 0 | — | — | — | — |
| cdc-slot | 4 | 7.4 | 19.0 | 50.0 | 3.8 | 38.3 | 0 | — | — | — | — |
| cdc-slot | 5 | 7.5 | 32.1 | 50.4 | 5.1 | 37.9 | 0 | — | — | — | — |