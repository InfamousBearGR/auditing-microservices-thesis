# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Total ops | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 | 10,000 |
| Load model | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) | closed (shared-iterations) |
| Throughput (ops/s) | 800.6 | 597.0 | 737.3 | 764.6 | 667.5 | 712.7 |
| Mutations ok / err | 9,867 / 133 | 9,874 / 126 | 9,878 / 122 | 9,863 / 137 | 9,877 / 123 | 9,865 / 135 |
| Errors 4xx / 5xx | 133 / 0 | 126 / 0 | 122 / 0 | 137 / 0 | 123 / 0 | 135 / 0 |
| Logins / re-logins | 10,000 / 9,992 | 10,000 / 9,992 | 10,000 / 9,992 | 10,000 / 9,992 | 10,000 / 9,992 | 10,000 / 9,992 |
| Login p50 (ms) | 1.5 | 1.7 | 1.5 | 1.5 | 1.5 | 1.6 |
| Create p50 (ms) | 6.3 | 6.8 | 6.5 | 6.5 | 6.5 | 6.5 |
| Create p95 (ms) | 9.1 | 14.5 | 12.0 | 10.4 | 12.3 | 11.6 |
| Create p99 (ms) | 12.6 | 36.0 | 17.0 | 14.8 | 20.0 | 17.1 |
| Update p50 (ms) | 6.5 | 7.3 | 6.7 | 6.7 | 6.6 | 6.8 |
| Update p95 (ms) | 10.4 | 16.8 | 14.1 | 12.4 | 14.1 | 13.4 |
| Delete p50 (ms) | 6.5 | 7.4 | 6.8 | 6.6 | 6.7 | 6.9 |
| Overhead vs baseline (create p50) | +0.0% | +6.9% | +2.2% | +2.2% | +2.2% | +3.4% |
| Audit rows captured | 0 | 17,982 | 17,816 | 25,976 | 0 | 0 |
| Audit storage | — | 13.47 MB | 13.08 MB | 3.98 MB | — | — |
| Audit storage after VACUUM FULL | — | 12.63 MB | 12.52 MB | 3.59 MB | — | — |
| Dead tuples in audit tables | — | 0 | 0 | 0 | — | — |
| Audit storage (compressed) | — | 5.14 MB | — | — | — | — |
| Compression ratio | — | 2.46× | — | — | — | — |
| Bytes / audit row | — | 785.4 B | 769.7 B | 160.5 B | — | — |
| Audit lag p50 (ms) | — | 742.3 | — | — | — | — |
| Audit lag p95 (ms) | — | 1,191.8 | — | — | — | — |
| Audit lag p99 (ms) | — | 1,477.7 | — | — | — | — |
| Audit lag max (ms) | — | 1,770.9 | — | — | — | — |
| SSE events received | — | 17,982 | — | — | — | — |
| SSE lag p50 (ms) | — | 526.7 | — | — | — | — |
| SSE lag p95 (ms) | — | 896.2 | — | — | — | — |
| SSE lag p99 (ms) | — | 961.6 | — | — | — | — |
| SSE lag max (ms) | — | 1,043.0 | — | — | — | — |
| SSE commit→Debezium p50 (ms) | — | 202.0 | — | — | — | — |
| SSE Debezium→client p50 (ms) | — | 335.4 | — | — | — | — |
| SSE duplicate / stale events | — | 0 / 0 | — | — | — | — |
| Integrity: trigger rows (ground truth) | — | — | — | — | — | — |
| Integrity: CDC rows | — | — | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression (no segmentby, orderby changed_at DESC) and running compress_chunk() on all chunks; compression ratio = uncompressed / compressed bytes, summed over all *_audit hypertables. SSE lag = arrival at an external SSE client − commit time (Debezium source.ts_ms, the same reference as the audit store's changed_at), split into commit→Debezium (envelope ts_ms) and Debezium→client (sse_probe.py). Audit storage = on-disk size including dead tuples of rolled-back transactions; 'after VACUUM FULL' = size of the live rows only. cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| Create p50 (ms) | 6.3 – 6.4 | 6.7 – 6.8 | 6.4 – 6.5 | 6.4 – 6.6 | 6.4 – 6.5 | 6.5 – 6.7 |
| Create p95 (ms) | 8.9 – 9.5 | 13.7 – 15.6 | 10.4 – 12.5 | 10.0 – 11.9 | 11.7 – 12.7 | 10.5 – 12.0 |
| Create p99 (ms) | 12.2 – 14.5 | 27.9 – 67.9 | 14.7 – 18.6 | 13.8 – 16.5 | 17.3 – 32.8 | 15.4 – 19.5 |
| Update p50 (ms) | 6.4 – 6.5 | 7.0 – 7.3 | 6.6 – 6.8 | 6.7 – 6.9 | 6.6 – 6.7 | 6.8 – 7.1 |
| Throughput (ops/s) | 769.3 – 813.1 | 576.6 – 624.6 | 720.3 – 748.6 | 733.8 – 771.9 | 657.0 – 701.2 | 690.4 – 715.3 |
| Audit rows captured | 0 – 0 | 17,585 – 18,357 | 17,570 – 18,301 | 25,811 – 26,170 | 0 – 0 | 0 – 0 |
| Audit storage (MB) | 0.00 – 0.00 | 13.34 – 13.61 | 13.01 – 13.34 | 3.95 – 4.10 | 0.00 – 0.00 | 0.00 – 0.00 |
| Audit storage compressed (MB) | — | 5.13 – 5.16 | — | — | — | — |
| Compression ratio | — | 2.43 – 2.47 | — | — | — | — |
| Audit lag p50 (ms) | — | 667.8 – 792.5 | — | — | — | — |
| Audit lag p99 (ms) | — | 1,279.8 – 1,646.8 | — | — | — | — |
| SSE lag p50 (ms) | — | 492.0 – 607.1 | — | — | — | — |
| SSE lag p99 (ms) | — | 923.4 – 963.1 | — | — | — | — |
| Integrity: missing events | — | — | — | — | — | — |
| Integrity: duplicate events | — | — | — | — | — | — |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Audit MB (compressed) | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| baseline | 1 | 6.3 | 9.1 | 13.2 | 6.4 | 769.3 | 0 | — | — | — | — |
| baseline | 2 | 6.3 | 8.9 | 12.2 | 6.5 | 813.1 | 0 | — | — | — | — |
| baseline | 3 | 6.4 | 9.5 | 14.5 | 6.5 | 800.6 | 0 | — | — | — | — |
| baseline | 4 | 6.3 | 8.9 | 12.6 | 6.5 | 797.9 | 0 | — | — | — | — |
| baseline | 5 | 6.3 | 9.1 | 12.3 | 6.4 | 808.9 | 0 | — | — | — | — |
| cdc | 1 | 6.7 | 14.2 | 33.2 | 7.0 | 624.6 | 17,982 | 13.54 MB | 5.14 MB | 780.8 | 1,646.8 |
| cdc | 2 | 6.8 | 13.7 | 27.9 | 7.3 | 596.6 | 17,985 | 13.47 MB | 5.14 MB | 792.5 | 1,597.9 |
| cdc | 3 | 6.8 | 15.4 | 38.4 | 7.3 | 597.0 | 17,585 | 13.34 MB | 5.13 MB | 708.6 | 1,279.8 |
| cdc | 4 | 6.8 | 15.6 | 67.9 | 7.3 | 576.6 | 18,357 | 13.61 MB | 5.15 MB | 742.3 | 1,453.5 |
| cdc | 5 | 6.7 | 14.5 | 36.0 | 7.1 | 618.8 | 17,891 | 13.40 MB | 5.16 MB | 667.8 | 1,477.7 |
| triggers | 1 | 6.5 | 11.9 | 17.0 | 6.7 | 747.0 | 17,816 | 13.02 MB | — | — | — |
| triggers | 2 | 6.4 | 10.4 | 14.7 | 6.6 | 748.6 | 17,868 | 13.10 MB | — | — | — |
| triggers | 3 | 6.5 | 12.0 | 17.2 | 6.8 | 720.3 | 18,301 | 13.34 MB | — | — | — |
| triggers | 4 | 6.5 | 12.4 | 18.6 | 6.6 | 726.0 | 17,769 | 13.01 MB | — | — | — |
| triggers | 5 | 6.4 | 12.5 | 16.7 | 6.7 | 737.3 | 17,570 | 13.08 MB | — | — | — |
| envers | 1 | 6.5 | 10.4 | 14.8 | 6.7 | 771.9 | 25,976 | 3.98 MB | — | — | — |
| envers | 2 | 6.4 | 10.6 | 15.1 | 6.7 | 764.6 | 25,887 | 3.96 MB | — | — | — |
| envers | 3 | 6.5 | 10.2 | 14.7 | 6.7 | 759.4 | 26,101 | 4.10 MB | — | — | — |
| envers | 4 | 6.6 | 11.9 | 16.5 | 6.9 | 733.8 | 25,811 | 3.95 MB | — | — | — |
| envers | 5 | 6.4 | 10.0 | 13.8 | 6.7 | 769.2 | 26,170 | 3.98 MB | — | — | — |
| cdc-idle | 1 | 6.4 | 12.5 | 20.0 | 6.6 | 667.5 | 0 | — | — | — | — |
| cdc-idle | 2 | 6.5 | 12.3 | 17.3 | 6.7 | 701.2 | 0 | — | — | — | — |
| cdc-idle | 3 | 6.5 | 12.7 | 21.6 | 6.6 | 657.3 | 0 | — | — | — | — |
| cdc-idle | 4 | 6.5 | 11.7 | 18.7 | 6.7 | 657.0 | 0 | — | — | — | — |
| cdc-idle | 5 | 6.5 | 12.3 | 32.8 | 6.6 | 670.7 | 0 | — | — | — | — |
| cdc-slot | 1 | 6.5 | 12.0 | 19.5 | 6.8 | 712.7 | 0 | — | — | — | — |
| cdc-slot | 2 | 6.5 | 11.5 | 16.6 | 6.8 | 715.3 | 0 | — | — | — | — |
| cdc-slot | 3 | 6.5 | 10.5 | 15.4 | 6.8 | 714.1 | 0 | — | — | — | — |
| cdc-slot | 4 | 6.7 | 11.7 | 19.3 | 7.1 | 690.4 | 0 | — | — | — | — |
| cdc-slot | 5 | 6.6 | 11.6 | 17.1 | 6.9 | 711.0 | 0 | — | — | — | — |

## Statistical comparison with baseline

Δ = median(scenario) − median(baseline) over the runs; CI = 95 % bootstrap interval of Δ (10 000 resamples of the runs); p = exact two-sided Mann–Whitney U. A CI that contains 0 or p > 0.05 means the difference is within run-to-run noise.

| Scenario | Metric | baseline | scenario | Δ | Δ % | 95 % CI of Δ | p |
|---|---|---|---|---|---|---|---|
| cdc | Create p50 (ms) | 6.3 | 6.8 | +0.4 | +6.9% | [+0.3, +0.5] | 0.008 |
| cdc | Create p95 (ms) | 9.1 | 14.5 | +5.4 | +59.8% | [+4.6, +6.6] | 0.008 |
| cdc | Create p99 (ms) | 12.6 | 36.0 | +23.4 | +185.6% | [+15.3, +55.3] | 0.008 |
| cdc | Update p50 (ms) | 6.5 | 7.3 | +0.8 | +12.8% | [+0.5, +0.9] | 0.008 |
| cdc | Delete p50 (ms) | 6.5 | 7.4 | +0.9 | +14.1% | [+0.6, +1.1] | 0.008 |
| cdc | Throughput (ops/s) | 800.6 | 597.0 | -203.6 | -25.4% | [-224.0, -172.4] | 0.008 |
| triggers | Create p50 (ms) | 6.3 | 6.5 | +0.1 | +2.2% | [+0.1, +0.2] | 0.008 |
| triggers | Create p95 (ms) | 9.1 | 12.0 | +2.9 | +32.4% | [+1.3, +3.5] | 0.008 |
| triggers | Create p99 (ms) | 12.6 | 17.0 | +4.4 | +35.2% | [+2.1, +6.0] | 0.008 |
| triggers | Update p50 (ms) | 6.5 | 6.7 | +0.2 | +3.3% | [+0.1, +0.3] | 0.008 |
| triggers | Delete p50 (ms) | 6.5 | 6.8 | +0.2 | +3.7% | [+0.2, +0.3] | 0.008 |
| triggers | Throughput (ops/s) | 800.6 | 737.3 | -63.3 | -7.9% | [-87.1, -32.0] | 0.008 |
| envers | Create p50 (ms) | 6.3 | 6.5 | +0.1 | +2.2% | [+0.1, +0.2] | 0.008 |
| envers | Create p95 (ms) | 9.1 | 10.4 | +1.3 | +13.9% | [+0.9, +2.8] | 0.008 |
| envers | Create p99 (ms) | 12.6 | 14.8 | +2.2 | +17.7% | [+0.3, +3.9] | 0.016 |
| envers | Update p50 (ms) | 6.5 | 6.7 | +0.2 | +3.3% | [+0.2, +0.4] | 0.008 |
| envers | Delete p50 (ms) | 6.5 | 6.6 | +0.1 | +1.6% | [+0.0, +0.4] | 0.008 |
| envers | Throughput (ops/s) | 800.6 | 764.6 | -36.0 | -4.5% | [-66.8, -4.7] | 0.016 |
| cdc-idle | Create p50 (ms) | 6.3 | 6.5 | +0.1 | +2.2% | [+0.1, +0.2] | 0.008 |
| cdc-idle | Create p95 (ms) | 9.1 | 12.3 | +3.3 | +35.8% | [+2.6, +3.7] | 0.008 |
| cdc-idle | Create p99 (ms) | 12.6 | 20.0 | +7.4 | +58.8% | [+4.2, +20.2] | 0.008 |
| cdc-idle | Update p50 (ms) | 6.5 | 6.6 | +0.2 | +2.8% | [+0.1, +0.2] | 0.008 |
| cdc-idle | Delete p50 (ms) | 6.5 | 6.7 | +0.2 | +2.3% | [+0.1, +0.2] | 0.008 |
| cdc-idle | Throughput (ops/s) | 800.6 | 667.5 | -133.1 | -16.6% | [-152.0, -98.7] | 0.008 |
| cdc-slot | Create p50 (ms) | 6.3 | 6.5 | +0.2 | +3.4% | [+0.2, +0.4] | 0.008 |
| cdc-slot | Create p95 (ms) | 9.1 | 11.6 | +2.5 | +27.5% | [+1.4, +2.9] | 0.008 |
| cdc-slot | Create p99 (ms) | 12.6 | 17.1 | +4.5 | +35.7% | [+2.2, +7.2] | 0.008 |
| cdc-slot | Update p50 (ms) | 6.5 | 6.8 | +0.3 | +5.1% | [+0.3, +0.6] | 0.008 |
| cdc-slot | Delete p50 (ms) | 6.5 | 6.9 | +0.4 | +5.7% | [+0.3, +1.0] | 0.008 |
| cdc-slot | Throughput (ops/s) | 800.6 | 712.7 | -87.9 | -11.0% | [-110.3, -56.7] | 0.008 |
