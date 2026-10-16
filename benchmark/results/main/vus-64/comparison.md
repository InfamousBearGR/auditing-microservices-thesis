# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Total ops | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 |
| Load model | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) |
| Throughput (ops/s) | 1,363.1 | 811.7 | 1,262.1 | 1,242.4 | 1,062.6 | 1,046.5 |
| Mutations ok / err | 9,868 / 132 | 9,869 / 131 | 9,866 / 134 | 9,862 / 138 | 9,861 / 139 | 9,858 / 142 |
| Errors 4xx / 5xx | 132 / 0 | 131 / 0 | 134 / 0 | 138 / 0 | 139 / 0 | 142 / 0 |
| Logins / re-logins | 10,000 / 9,936 | 10,000 / 9,936 | 10,000 / 9,936 | 10,000 / 9,936 | 10,000 / 9,936 | 10,000 / 9,936 |
| Login p50 (ms) | 11.6 | 17.8 | 12.3 | 12.9 | 13.0 | 15.2 |
| Create p50 (ms) | 18.3 | 25.7 | 19.5 | 21.0 | 19.6 | 22.0 |
| Create p95 (ms) | 37.2 | 77.8 | 46.3 | 43.7 | 48.0 | 53.1 |
| Create p99 (ms) | 99.5 | 166.6 | 137.1 | 89.9 | 150.0 | 117.0 |
| Update p50 (ms) | 20.7 | 30.2 | 22.6 | 24.3 | 22.6 | 25.4 |
| Update p95 (ms) | 45.3 | 92.4 | 52.4 | 52.6 | 59.7 | 64.9 |
| Delete p50 (ms) | 20.7 | 29.5 | 22.3 | 23.4 | 22.2 | 25.3 |
| Overhead vs baseline (create p50) | +0.0% | +40.3% | +6.5% | +14.6% | +7.1% | +20.0% |
| Audit rows captured | 0 | 18,104 | 17,969 | 25,643 | 0 | 0 |
| Audit storage | — | 13.56 MB | 13.68 MB | 4.46 MB | — | — |
| Audit storage after VACUUM FULL | — | 12.70 MB | 12.66 MB | 3.55 MB | — | — |
| Dead tuples in audit tables | — | 0 | 0 | 0 | — | — |
| Audit storage (compressed) | — | 5.16 MB | — | — | — | — |
| Compression ratio | — | 2.46× | — | — | — | — |
| Bytes / audit row | — | 785.5 B | 798.3 B | 182.4 B | — | — |
| Audit lag p50 (ms) | — | 1,319.2 | — | — | — | — |
| Audit lag p95 (ms) | — | 2,899.1 | — | — | — | — |
| Audit lag p99 (ms) | — | 3,290.6 | — | — | — | — |
| Audit lag max (ms) | — | 3,475.6 | — | — | — | — |
| SSE events received | — | 18,104 | — | — | — | — |
| SSE lag p50 (ms) | — | 621.7 | — | — | — | — |
| SSE lag p95 (ms) | — | 903.6 | — | — | — | — |
| SSE lag p99 (ms) | — | 1,017.0 | — | — | — | — |
| SSE lag max (ms) | — | 1,114.2 | — | — | — | — |
| SSE commit→Debezium p50 (ms) | — | 243.0 | — | — | — | — |
| SSE Debezium→client p50 (ms) | — | 380.1 | — | — | — | — |
| SSE duplicate / stale events | — | 0 / 0 | — | — | — | — |
| Integrity: trigger rows (ground truth) | — | — | — | — | — | — |
| Integrity: CDC rows | — | — | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression (no segmentby, orderby changed_at DESC) and running compress_chunk() on all chunks; compression ratio = uncompressed / compressed bytes, summed over all *_audit hypertables. SSE lag = arrival at an external SSE client − commit time (Debezium source.ts_ms, the same reference as the audit store's changed_at), split into commit→Debezium (envelope ts_ms) and Debezium→client (sse_probe.py). Audit storage = on-disk size including dead tuples of rolled-back transactions; 'after VACUUM FULL' = size of the live rows only. cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 17.9 – 18.7 | 25.3 – 26.2 | 19.2 – 19.8 | 20.2 – 21.6 | 19.4 – 20.1 | 21.6 – 23.0 |
| Create p95 (ms) | 36.8 – 38.7 | 72.0 – 83.6 | 41.3 – 52.3 | 41.7 – 44.8 | 45.6 – 52.2 | 52.4 – 60.5 |
| Create p99 (ms) | 81.9 – 115.2 | 132.6 – 210.6 | 123.8 – 182.4 | 83.3 – 113.2 | 116.0 – 161.4 | 101.0 – 144.1 |
| Update p50 (ms) | 20.5 – 21.7 | 29.0 – 30.8 | 22.2 – 23.1 | 23.2 – 25.3 | 22.4 – 23.5 | 24.7 – 26.4 |
| Throughput (ops/s) | 1,326.0 – 1,379.3 | 769.7 – 837.1 | 1,235.7 – 1,281.7 | 1,208.7 – 1,277.7 | 1,010.8 – 1,074.0 | 1,032.5 – 1,062.2 |
| Audit rows captured | 0 – 0 | 17,947 – 18,224 | 17,832 – 18,381 | 25,488 – 25,858 | 0 – 0 | 0 – 0 |
| Audit storage (MB) | 0.00 – 0.00 | 13.42 – 13.59 | 13.56 – 13.82 | 4.33 – 4.56 | 0.00 – 0.00 | 0.00 – 0.00 |
| Audit storage compressed (MB) | — | 5.15 – 5.17 | — | — | — | — |
| Compression ratio | — | 2.44 – 2.46 | — | — | — | — |
| Audit lag p50 (ms) | — | 1,046.8 – 1,430.5 | — | — | — | — |
| Audit lag p99 (ms) | — | 2,872.2 – 3,856.9 | — | — | — | — |
| SSE lag p50 (ms) | — | 537.7 – 666.2 | — | — | — | — |
| SSE lag p99 (ms) | — | 966.5 – 1,075.6 | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Audit MB (compressed) | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| baseline | 1 | 17.9 | 36.9 | 97.4 | 20.6 | 1,379.3 | 0 | — | — | — | — |
| baseline | 2 | 18.7 | 38.7 | 81.9 | 21.7 | 1,326.0 | 0 | — | — | — | — |
| baseline | 3 | 18.3 | 37.4 | 102.6 | 20.7 | 1,363.1 | 0 | — | — | — | — |
| baseline | 4 | 18.5 | 37.2 | 115.2 | 21.3 | 1,343.2 | 0 | — | — | — | — |
| baseline | 5 | 18.0 | 36.8 | 99.5 | 20.5 | 1,374.9 | 0 | — | — | — | — |
| cdc | 1 | 26.2 | 75.7 | 166.6 | 30.4 | 811.7 | 17,947 | 13.42 MB | 5.15 MB | 1,326.2 | 3,018.8 |
| cdc | 2 | 25.3 | 78.8 | 132.6 | 29.2 | 824.3 | 18,104 | 13.56 MB | 5.17 MB | 1,319.2 | 3,856.9 |
| cdc | 3 | 25.4 | 77.8 | 175.4 | 29.0 | 837.1 | 17,949 | 13.45 MB | 5.15 MB | 1,430.5 | 3,484.4 |
| cdc | 4 | 26.2 | 83.6 | 210.6 | 30.8 | 769.7 | 18,200 | 13.56 MB | 5.16 MB | 1,046.8 | 3,290.6 |
| cdc | 5 | 25.7 | 72.0 | 160.2 | 30.2 | 805.3 | 18,224 | 13.59 MB | 5.17 MB | 1,295.6 | 2,872.2 |
| triggers | 1 | 19.5 | 47.0 | 123.8 | 22.4 | 1,262.1 | 17,832 | 13.56 MB | — | — | — |
| triggers | 2 | 19.6 | 41.3 | 182.4 | 22.6 | 1,274.7 | 18,197 | 13.74 MB | — | — | — |
| triggers | 3 | 19.2 | 46.3 | 137.1 | 22.2 | 1,281.7 | 18,381 | 13.82 MB | — | — | — |
| triggers | 4 | 19.5 | 44.3 | 127.2 | 22.7 | 1,262.0 | 17,969 | 13.63 MB | — | — | — |
| triggers | 5 | 19.8 | 52.3 | 164.2 | 23.1 | 1,235.7 | 17,958 | 13.68 MB | — | — | — |
| envers | 1 | 20.8 | 43.2 | 89.9 | 24.1 | 1,262.3 | 25,858 | 4.56 MB | — | — | — |
| envers | 2 | 21.4 | 44.3 | 96.6 | 25.0 | 1,208.7 | 25,697 | 4.52 MB | — | — | — |
| envers | 3 | 21.0 | 43.7 | 113.2 | 24.3 | 1,242.4 | 25,636 | 4.45 MB | — | — | — |
| envers | 4 | 21.6 | 44.8 | 83.3 | 25.3 | 1,231.8 | 25,643 | 4.33 MB | — | — | — |
| envers | 5 | 20.2 | 41.7 | 88.4 | 23.2 | 1,277.7 | 25,488 | 4.46 MB | — | — | — |
| cdc-idle | 1 | 19.8 | 47.5 | 161.4 | 22.5 | 1,010.8 | 0 | — | — | — | — |
| cdc-idle | 2 | 19.6 | 52.2 | 154.2 | 22.6 | 1,073.3 | 0 | — | — | — | — |
| cdc-idle | 3 | 19.4 | 48.0 | 150.0 | 22.4 | 1,051.2 | 0 | — | — | — | — |
| cdc-idle | 4 | 19.6 | 45.6 | 116.0 | 22.6 | 1,074.0 | 0 | — | — | — | — |
| cdc-idle | 5 | 20.1 | 50.9 | 148.6 | 23.5 | 1,062.6 | 0 | — | — | — | — |
| cdc-slot | 1 | 21.6 | 52.5 | 116.2 | 24.7 | 1,059.7 | 0 | — | — | — | — |
| cdc-slot | 2 | 23.0 | 53.1 | 117.0 | 26.4 | 1,046.2 | 0 | — | — | — | — |
| cdc-slot | 3 | 21.8 | 60.5 | 144.1 | 25.4 | 1,046.5 | 0 | — | — | — | — |
| cdc-slot | 4 | 22.0 | 52.4 | 124.0 | 25.2 | 1,062.2 | 0 | — | — | — | — |
| cdc-slot | 5 | 22.7 | 55.5 | 101.0 | 26.2 | 1,032.5 | 0 | — | — | — | — |

## Statistical comparison with baseline

Δ = median(scenario) − median(baseline) over the runs; CI = 95 % bootstrap interval of Δ (10 000 resamples of the runs); p = exact two-sided Mann–Whitney U. A CI that contains 0 or p > 0.05 means the difference is within run-to-run noise.

| Scenario | Metric | baseline | scenario | Δ | Δ % | 95 % CI of Δ | p |
|---|---|---|---|---|---|---|---|
| cdc | Create p50 (ms) | 18.3 | 25.7 | +7.4 | +40.3% | [+6.7, +8.2] | 0.008 |
| cdc | Create p95 (ms) | 37.2 | 77.8 | +40.6 | +109.1% | [+34.8, +46.4] | 0.008 |
| cdc | Create p99 (ms) | 99.5 | 166.6 | +67.1 | +67.5% | [+33.1, +111.1] | 0.008 |
| cdc | Update p50 (ms) | 20.7 | 30.2 | +9.5 | +45.9% | [+7.7, +10.1] | 0.008 |
| cdc | Delete p50 (ms) | 20.7 | 29.5 | +8.8 | +42.6% | [+7.8, +9.4] | 0.008 |
| cdc | Throughput (ops/s) | 1,363.1 | 811.7 | -551.4 | -40.5% | [-593.4, -506.1] | 0.008 |
| triggers | Create p50 (ms) | 18.3 | 19.5 | +1.2 | +6.5% | [+0.8, +1.7] | 0.008 |
| triggers | Create p95 (ms) | 37.2 | 46.3 | +9.1 | +24.5% | [+4.1, +15.1] | 0.008 |
| triggers | Create p99 (ms) | 99.5 | 137.1 | +37.6 | +37.8% | [+21.2, +82.9] | 0.008 |
| triggers | Update p50 (ms) | 20.7 | 22.6 | +1.9 | +9.3% | [+0.9, +2.4] | 0.008 |
| triggers | Delete p50 (ms) | 20.7 | 22.3 | +1.6 | +7.8% | [+0.9, +2.6] | 0.008 |
| triggers | Throughput (ops/s) | 1,363.1 | 1,262.1 | -101.0 | -7.4% | [-127.3, -61.5] | 0.008 |
| envers | Create p50 (ms) | 18.3 | 21.0 | +2.7 | +14.6% | [+1.9, +3.5] | 0.008 |
| envers | Create p95 (ms) | 37.2 | 43.7 | +6.5 | +17.4% | [+4.5, +7.6] | 0.008 |
| envers | Create p99 (ms) | 99.5 | 89.9 | -9.6 | -9.6% | [-25.3, +14.7] | 0.421 |
| envers | Update p50 (ms) | 20.7 | 24.3 | +3.6 | +17.4% | [+2.4, +4.6] | 0.008 |
| envers | Delete p50 (ms) | 20.7 | 23.4 | +2.7 | +13.0% | [+2.0, +3.6] | 0.008 |
| envers | Throughput (ops/s) | 1,363.1 | 1,242.4 | -120.7 | -8.9% | [-154.4, -65.5] | 0.008 |
| cdc-idle | Create p50 (ms) | 18.3 | 19.6 | +1.3 | +7.1% | [+0.9, +1.9] | 0.008 |
| cdc-idle | Create p95 (ms) | 37.2 | 48.0 | +10.8 | +28.9% | [+8.4, +15.0] | 0.008 |
| cdc-idle | Create p99 (ms) | 99.5 | 150.0 | +50.5 | +50.7% | [+16.5, +68.1] | 0.008 |
| cdc-idle | Update p50 (ms) | 20.7 | 22.6 | +1.9 | +9.2% | [+0.9, +2.8] | 0.008 |
| cdc-idle | Delete p50 (ms) | 20.7 | 22.2 | +1.5 | +7.1% | [+0.8, +2.2] | 0.008 |
| cdc-idle | Throughput (ops/s) | 1,363.1 | 1,062.6 | -300.5 | -22.0% | [-352.3, -263.5] | 0.008 |
| cdc-slot | Create p50 (ms) | 18.3 | 22.0 | +3.7 | +20.0% | [+3.1, +4.8] | 0.008 |
| cdc-slot | Create p95 (ms) | 37.2 | 53.1 | +15.9 | +42.7% | [+14.4, +23.3] | 0.008 |
| cdc-slot | Create p99 (ms) | 99.5 | 117.0 | +17.5 | +17.5% | [+1.0, +44.6] | 0.032 |
| cdc-slot | Update p50 (ms) | 20.7 | 25.4 | +4.7 | +22.9% | [+3.5, +5.7] | 0.008 |
| cdc-slot | Delete p50 (ms) | 20.7 | 25.3 | +4.6 | +22.2% | [+3.8, +6.1] | 0.008 |
| cdc-slot | Throughput (ops/s) | 1,363.1 | 1,046.5 | -316.5 | -23.2% | [-333.1, -279.5] | 0.008 |
