# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Total ops | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 |
| Throughput (ops/s) | 35.8 | 33.9 | 35.8 | 35.6 | 34.3 | 34.3 |
| Mutations ok / err | 4,083 / 5,917 | 4,108 / 5,892 | 4,144 / 5,856 | 4,064 / 5,936 | 4,092 / 5,908 | 4,085 / 5,915 |
| Create p50 (ms) | 489.6 | 510.4 | 486.8 | 490.3 | 505.0 | 505.6 |
| Create p95 (ms) | 1,056.4 | 1,154.9 | 1,046.2 | 1,052.4 | 1,123.0 | 1,117.9 |
| Create p99 (ms) | 1,426.8 | 1,567.9 | 1,419.7 | 1,433.8 | 1,533.7 | 1,519.5 |
| Update p50 (ms) | 494.5 | 516.2 | 495.3 | 494.6 | 513.7 | 512.5 |
| Update p95 (ms) | 1,057.9 | 1,151.0 | 1,047.4 | 1,061.8 | 1,127.7 | 1,121.0 |
| Delete p50 (ms) | 480.1 | 509.1 | 486.0 | 484.8 | 499.9 | 499.0 |
| Overhead vs baseline (create p50) | +0.0% | +4.2% | -0.6% | +0.2% | +3.1% | +3.3% |
| Audit rows captured | 0 | 4,754 | 4,772 | 8,449 | 0 | 0 |
| Audit storage | — | 5.68 MB | 5.54 MB | 3.74 MB | — | — |
| Audit storage (compressed) | — | 4.01 MB | — | — | — | — |
| Compression ratio | — | 1.42× | — | — | — | — |
| Bytes / audit row | — | 1,252.8 B | 1,217.1 B | 464.4 B | — | — |
| Audit lag p50 (ms) | — | 585.7 | — | — | — | — |
| Audit lag p95 (ms) | — | 938.5 | — | — | — | — |
| Audit lag p99 (ms) | — | 1,087.6 | — | — | — | — |
| Audit lag max (ms) | — | 1,344.9 | — | — | — | — |
| SSE events received | — | 4,754 | — | — | — | — |
| SSE lag p50 (ms) | — | 265.8 | — | — | — | — |
| SSE lag p95 (ms) | — | 502.6 | — | — | — | — |
| SSE lag p99 (ms) | — | 543.2 | — | — | — | — |
| SSE lag max (ms) | — | 570.1 | — | — | — | — |
| Integrity: trigger rows (ground truth) | — | — | — | — | — | — |
| Integrity: CDC rows | — | — | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression (no segmentby, orderby changed_at DESC) and running compress_chunk() on all chunks; compression ratio = uncompressed / compressed bytes, summed over all *_audit hypertables. SSE lag = arrival at an external SSE client − commit time (sse_probe.py). cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 481.5 – 491.8 | 501.3 – 513.1 | 486.2 – 493.6 | 488.9 – 492.1 | 502.1 – 507.0 | 503.2 – 506.8 |
| Create p95 (ms) | 1,047.6 – 1,058.2 | 1,129.3 – 1,159.1 | 1,041.2 – 1,057.9 | 1,052.0 – 1,057.2 | 1,099.8 – 1,134.7 | 1,111.6 – 1,125.7 |
| Create p99 (ms) | 1,404.8 – 1,437.7 | 1,528.8 – 1,612.2 | 1,404.1 – 1,447.6 | 1,408.8 – 1,457.9 | 1,503.4 – 1,547.6 | 1,513.8 – 1,540.4 |
| Update p50 (ms) | 491.0 – 497.2 | 511.0 – 519.7 | 491.1 – 498.4 | 493.8 – 501.1 | 511.1 – 516.8 | 508.1 – 517.4 |
| Throughput (ops/s) | 35.7 – 36.0 | 33.9 – 34.0 | 35.6 – 35.8 | 35.5 – 35.8 | 34.2 – 34.3 | 34.2 – 34.4 |
| Audit rows captured | 0 – 0 | 4,660 – 4,848 | 4,569 – 4,907 | 8,345 – 9,139 | 0 – 0 | 0 – 0 |
| Audit storage (MB) | 0.00 – 0.00 | 5.63 – 5.73 | 5.37 – 5.67 | 3.54 – 3.78 | 0.00 – 0.00 | 0.00 – 0.00 |
| Audit storage compressed (MB) | — | 4.00 – 4.02 | — | — | — | — |
| Compression ratio | — | 1.41 – 1.43 | — | — | — | — |
| Audit lag p50 (ms) | — | 563.0 – 602.2 | — | — | — | — |
| Audit lag p99 (ms) | — | 1,027.9 – 1,205.9 | — | — | — | — |
| SSE lag p50 (ms) | — | 260.8 – 285.4 | — | — | — | — |
| SSE lag p99 (ms) | — | 532.4 – 587.9 | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Audit MB (compressed) | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| baseline | 1 | 487.3 | 1,056.4 | 1,427.6 | 495.4 | 35.8 | 0 | — | — | — | — |
| baseline | 2 | 490.4 | 1,048.5 | 1,404.8 | 494.5 | 35.8 | 0 | — | — | — | — |
| baseline | 3 | 481.5 | 1,057.8 | 1,426.8 | 497.2 | 36.0 | 0 | — | — | — | — |
| baseline | 4 | 491.8 | 1,058.2 | 1,437.7 | 491.3 | 35.8 | 0 | — | — | — | — |
| baseline | 5 | 489.6 | 1,047.6 | 1,407.9 | 491.0 | 35.7 | 0 | — | — | — | — |
| cdc | 1 | 510.4 | 1,133.9 | 1,551.2 | 515.9 | 34.0 | 4,848 | 5.73 MB | 4.02 MB | 602.2 | 1,027.9 |
| cdc | 2 | 507.0 | 1,155.8 | 1,612.2 | 517.9 | 33.9 | 4,718 | 5.64 MB | 4.01 MB | 579.4 | 1,091.2 |
| cdc | 3 | 501.3 | 1,129.3 | 1,567.9 | 519.7 | 34.0 | 4,660 | 5.63 MB | 4.00 MB | 587.9 | 1,029.0 |
| cdc | 4 | 513.1 | 1,159.1 | 1,578.6 | 511.0 | 33.9 | 4,803 | 5.70 MB | 4.01 MB | 563.0 | 1,205.9 |
| cdc | 5 | 513.0 | 1,154.9 | 1,528.8 | 516.2 | 33.9 | 4,754 | 5.68 MB | 4.01 MB | 585.7 | 1,087.6 |
| triggers | 1 | 486.2 | 1,046.2 | 1,419.7 | 498.4 | 35.8 | 4,907 | 5.54 MB | — | — | — |
| triggers | 2 | 486.7 | 1,041.2 | 1,404.1 | 491.1 | 35.8 | 4,716 | 5.51 MB | — | — | — |
| triggers | 3 | 486.8 | 1,054.2 | 1,408.0 | 495.3 | 35.6 | 4,772 | 5.67 MB | — | — | — |
| triggers | 4 | 490.1 | 1,046.0 | 1,423.9 | 496.2 | 35.8 | 4,569 | 5.37 MB | — | — | — |
| triggers | 5 | 493.6 | 1,057.9 | 1,447.6 | 492.8 | 35.7 | 4,829 | 5.65 MB | — | — | — |
| envers | 1 | 489.3 | 1,055.1 | 1,415.8 | 501.1 | 35.8 | 9,139 | 3.77 MB | — | — | — |
| envers | 2 | 490.3 | 1,052.0 | 1,408.8 | 494.3 | 35.6 | 8,345 | 3.73 MB | — | — | — |
| envers | 3 | 492.1 | 1,057.2 | 1,438.3 | 494.6 | 35.6 | 8,391 | 3.54 MB | — | — | — |
| envers | 4 | 488.9 | 1,052.3 | 1,433.8 | 493.8 | 35.7 | 8,676 | 3.78 MB | — | — | — |
| envers | 5 | 491.4 | 1,052.4 | 1,457.9 | 499.8 | 35.5 | 8,449 | 3.74 MB | — | — | — |
| cdc-idle | 1 | 503.8 | 1,134.7 | 1,503.4 | 511.1 | 34.2 | 0 | — | — | — | — |
| cdc-idle | 2 | 505.0 | 1,123.0 | 1,547.6 | 513.4 | 34.3 | 0 | — | — | — | — |
| cdc-idle | 3 | 502.1 | 1,118.8 | 1,533.8 | 516.8 | 34.3 | 0 | — | — | — | — |
| cdc-idle | 4 | 507.0 | 1,132.1 | 1,533.7 | 515.1 | 34.3 | 0 | — | — | — | — |
| cdc-idle | 5 | 505.7 | 1,099.8 | 1,521.7 | 513.7 | 34.3 | 0 | — | — | — | — |
| cdc-slot | 1 | 505.6 | 1,117.9 | 1,513.8 | 517.4 | 34.4 | 0 | — | — | — | — |
| cdc-slot | 2 | 506.8 | 1,111.6 | 1,519.5 | 512.5 | 34.3 | 0 | — | — | — | — |
| cdc-slot | 3 | 504.3 | 1,113.2 | 1,527.2 | 508.1 | 34.3 | 0 | — | — | — | — |
| cdc-slot | 4 | 505.6 | 1,125.7 | 1,540.4 | 516.2 | 34.2 | 0 | — | — | — | — |
| cdc-slot | 5 | 503.2 | 1,120.6 | 1,514.0 | 510.9 | 34.4 | 0 | — | — | — | — |