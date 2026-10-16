# Audit-method comparison — results (median of 5 runs per scenario)

| Metric | baseline | cdc | triggers | envers |
|---|---|---|---|---|
| Total ops | 20,000 | 19,998 | 20,001 | 20,001 |
| Load model | open, 100 ops/s | open, 100 ops/s | open, 100 ops/s | open, 100 ops/s |
| Throughput (ops/s) | 99.7 | 99.7 | 99.7 | 99.7 |
| Mutations ok / err | 19,586 / 414 | 19,579 / 421 | 19,586 / 415 | 19,588 / 413 |
| Errors 4xx / 5xx | 414 / 0 | 421 / 0 | 415 / 0 | 413 / 0 |
| Logins / re-logins | 20,000 / 19,936 | 19,998 / 19,934 | 20,001 / 19,937 | 20,001 / 19,937 |
| Login p50 (ms) | 1.2 | 1.3 | 1.2 | 1.2 |
| Create p50 (ms) | 4.0 | 4.2 | 4.2 | 4.3 |
| Create p95 (ms) | 5.0 | 7.9 | 5.7 | 5.6 |
| Create p99 (ms) | 7.2 | 134.9 | 9.4 | 8.1 |
| Update p50 (ms) | 4.3 | 4.6 | 4.6 | 4.7 |
| Update p95 (ms) | 6.2 | 9.6 | 7.0 | 7.0 |
| Delete p50 (ms) | 4.5 | 4.9 | 4.8 | 4.7 |
| Overhead vs baseline (create p50) | +0.0% | +4.5% | +3.8% | +5.6% |
| Audit rows captured | 0 | 37,857 | 37,966 | 51,946 |
| Audit storage | — | 24.75 MB | 27.77 MB | 7.60 MB |
| Audit storage after VACUUM FULL | — | 23.56 MB | 26.48 MB | 6.91 MB |
| Dead tuples in audit tables | — | 0 | 0 | 0 |
| Audit storage (compressed) | — | 6.77 MB | — | — |
| Compression ratio | — | 3.48× | — | — |
| Bytes / audit row | — | 685.5 B | 766.9 B | 153.4 B |
| Audit lag p50 (ms) | — | 568.0 | — | — |
| Audit lag p95 (ms) | — | 926.1 | — | — |
| Audit lag p99 (ms) | — | 1,022.4 | — | — |
| Audit lag max (ms) | — | 1,603.8 | — | — |
| SSE events received | — | 37,857 | — | — |
| SSE lag p50 (ms) | — | 517.0 | — | — |
| SSE lag p95 (ms) | — | 867.4 | — | — |
| SSE lag p99 (ms) | — | 960.8 | — | — |
| SSE lag max (ms) | — | 1,461.3 | — | — |
| SSE commit→Debezium p50 (ms) | — | 258.0 | — | — |
| SSE Debezium→client p50 (ms) | — | 257.2 | — | — |
| SSE duplicate / stale events | — | 0 / 0 | — | — |
| Integrity: trigger rows (ground truth) | — | — | — | — |
| Integrity: CDC rows | — | — | — | — |
| Integrity: missing events | — | — | — | — |
| Integrity: duplicate events | — | — | — | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks). Compressed (cdc only) = hypertable_size() after enabling TimescaleDB compression (no segmentby, orderby changed_at DESC) and running compress_chunk() on all chunks; compression ratio = uncompressed / compressed bytes, summed over all *_audit hypertables. SSE lag = arrival at an external SSE client − commit time (Debezium source.ts_ms, the same reference as the audit store's changed_at), split into commit→Debezium (envelope ts_ms) and Debezium→client (sse_probe.py). Audit storage = on-disk size including dead tuples of rolled-back transactions; 'after VACUUM FULL' = size of the live rows only. cdc-idle = CDC stack running without a connector (contention only); cdc-slot = connector streaming, no consumer/audit DB; cdc-failover = consumer SIGKILL + broker crash during the run, with triggers as ground truth for the missing/duplicate counts._


## Run-to-run spread (min – max over 5 runs)

| Metric | baseline | cdc | triggers | envers |
|---|---|---|---|---|
| Create p50 (ms) | 4.0 – 4.2 | 4.2 – 4.2 | 4.2 – 4.2 | 4.3 – 4.3 |
| Create p95 (ms) | 4.9 – 5.5 | 7.8 – 8.4 | 5.7 – 5.8 | 5.4 – 5.8 |
| Create p99 (ms) | 7.1 – 7.5 | 119.7 – 162.7 | 8.4 – 10.9 | 7.8 – 8.7 |
| Update p50 (ms) | 4.3 – 4.5 | 4.6 – 4.6 | 4.6 – 4.6 | 4.6 – 4.7 |
| Throughput (ops/s) | 99.7 – 99.7 | 99.7 – 99.7 | 99.7 – 99.7 | 99.7 – 99.7 |
| Audit rows captured | 0 – 0 | 37,699 – 38,484 | 37,456 – 38,693 | 51,638 – 52,201 |
| Audit storage (MB) | 0.00 – 0.00 | 24.74 – 25.05 | 27.52 – 28.36 | 7.57 – 8.02 |
| Audit storage compressed (MB) | — | 6.77 – 6.79 | — | — |
| Compression ratio | — | 3.47 – 3.52 | — | — |
| Audit lag p50 (ms) | — | 553.5 – 580.0 | — | — |
| Audit lag p99 (ms) | — | 986.6 – 1,155.2 | — | — |
| SSE lag p50 (ms) | — | 501.5 – 531.0 | — | — |
| SSE lag p99 (ms) | — | 945.4 – 968.6 | — | — |
| Integrity: missing events | — | — | — | — |
| Integrity: duplicate events | — | — | — | — |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Audit MB (compressed) | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| baseline | 1 | 4.0 | 5.5 | 7.5 | 4.3 | 99.7 | 0 | — | — | — | — |
| baseline | 2 | 4.0 | 4.9 | 7.2 | 4.3 | 99.7 | 0 | — | — | — | — |
| baseline | 3 | 4.0 | 5.0 | 7.1 | 4.3 | 99.7 | 0 | — | — | — | — |
| baseline | 4 | 4.2 | 5.1 | 7.2 | 4.5 | 99.7 | 0 | — | — | — | — |
| baseline | 5 | 4.1 | 5.0 | 7.2 | 4.3 | 99.7 | 0 | — | — | — | — |
| cdc | 1 | 4.2 | 7.8 | 162.7 | 4.6 | 99.7 | 37,699 | 24.75 MB | 6.79 MB | 567.6 | 1,155.2 |
| cdc | 2 | 4.2 | 8.2 | 128.6 | 4.6 | 99.7 | 37,857 | 24.74 MB | 6.77 MB | 577.8 | 1,022.4 |
| cdc | 3 | 4.2 | 8.4 | 140.3 | 4.6 | 99.7 | 37,704 | 24.74 MB | 6.77 MB | 568.0 | 1,118.5 |
| cdc | 4 | 4.2 | 7.8 | 134.9 | 4.6 | 99.7 | 38,159 | 24.87 MB | 6.77 MB | 580.0 | 1,020.8 |
| cdc | 5 | 4.2 | 7.9 | 119.7 | 4.6 | 99.7 | 38,484 | 25.05 MB | 6.77 MB | 553.5 | 986.6 |
| triggers | 1 | 4.2 | 5.8 | 9.8 | 4.6 | 99.7 | 38,693 | 28.36 MB | — | — | — |
| triggers | 2 | 4.2 | 5.7 | 8.7 | 4.6 | 99.7 | 37,923 | 27.70 MB | — | — | — |
| triggers | 3 | 4.2 | 5.7 | 10.9 | 4.6 | 99.7 | 37,966 | 27.80 MB | — | — | — |
| triggers | 4 | 4.2 | 5.7 | 9.4 | 4.6 | 99.7 | 38,280 | 27.77 MB | — | — | — |
| triggers | 5 | 4.2 | 5.7 | 8.4 | 4.6 | 99.7 | 37,456 | 27.52 MB | — | — | — |
| envers | 1 | 4.3 | 5.6 | 8.0 | 4.7 | 99.7 | 52,094 | 7.57 MB | — | — | — |
| envers | 2 | 4.3 | 5.6 | 8.2 | 4.7 | 99.7 | 51,946 | 7.84 MB | — | — | — |
| envers | 3 | 4.3 | 5.7 | 8.7 | 4.7 | 99.7 | 52,201 | 8.02 MB | — | — | — |
| envers | 4 | 4.3 | 5.8 | 8.1 | 4.6 | 99.7 | 51,638 | 7.59 MB | — | — | — |
| envers | 5 | 4.3 | 5.4 | 7.8 | 4.7 | 99.7 | 51,775 | 7.60 MB | — | — | — |

## Statistical comparison with baseline

Δ = median(scenario) − median(baseline) over the runs; CI = 95 % bootstrap interval of Δ (10 000 resamples of the runs); p = exact two-sided Mann–Whitney U. A CI that contains 0 or p > 0.05 means the difference is within run-to-run noise.

| Scenario | Metric | baseline | scenario | Δ | Δ % | 95 % CI of Δ | p |
|---|---|---|---|---|---|---|---|
| cdc | Create p50 (ms) | 4.0 | 4.2 | +0.2 | +4.5% | [+0.1, +0.2] | 0.008 |
| cdc | Create p95 (ms) | 5.0 | 7.9 | +2.9 | +57.8% | [+2.5, +3.3] | 0.008 |
| cdc | Create p99 (ms) | 7.2 | 134.9 | +127.7 | +1771.4% | [+112.5, +155.4] | 0.008 |
| cdc | Update p50 (ms) | 4.3 | 4.6 | +0.2 | +5.6% | [+0.1, +0.3] | 0.008 |
| cdc | Delete p50 (ms) | 4.5 | 4.9 | +0.4 | +8.1% | [+0.2, +0.4] | 0.008 |
| cdc | Throughput (ops/s) | 99.7 | 99.7 | -0.0 | -0.0% | [-0.1, -0.0] | 0.008 |
| triggers | Create p50 (ms) | 4.0 | 4.2 | +0.2 | +3.8% | [+0.0, +0.2] | 0.008 |
| triggers | Create p95 (ms) | 5.0 | 5.7 | +0.7 | +13.0% | [+0.2, +0.8] | 0.008 |
| triggers | Create p99 (ms) | 7.2 | 9.4 | +2.2 | +30.2% | [+1.1, +3.7] | 0.008 |
| triggers | Update p50 (ms) | 4.3 | 4.6 | +0.2 | +5.3% | [+0.1, +0.3] | 0.008 |
| triggers | Delete p50 (ms) | 4.5 | 4.8 | +0.3 | +7.1% | [+0.1, +0.4] | 0.008 |
| triggers | Throughput (ops/s) | 99.7 | 99.7 | +0.0 | +0.0% | [-0.0, +0.0] | 0.841 |
| envers | Create p50 (ms) | 4.0 | 4.3 | +0.2 | +5.6% | [+0.1, +0.3] | 0.008 |
| envers | Create p95 (ms) | 5.0 | 5.6 | +0.6 | +11.3% | [+0.1, +0.8] | 0.016 |
| envers | Create p99 (ms) | 7.2 | 8.1 | +0.9 | +11.9% | [+0.5, +1.5] | 0.008 |
| envers | Update p50 (ms) | 4.3 | 4.7 | +0.3 | +7.0% | [+0.2, +0.4] | 0.008 |
| envers | Delete p50 (ms) | 4.5 | 4.7 | +0.2 | +5.3% | [+0.1, +0.3] | 0.008 |
| envers | Throughput (ops/s) | 99.7 | 99.7 | +0.0 | +0.0% | [-0.0, +0.0] | 1.000 |
