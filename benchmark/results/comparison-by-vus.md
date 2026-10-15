# Audit-method comparison — by concurrency level (VUs)

Median per scenario (and run, when REPEATS>1). Overhead = create p50 relative to baseline at the same level.


## Create p50 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 7.5 | 7.3 (-2.4%) | 7.8 (+3.8%) | 8.0 (+6.6%) | 7.5 (-0.4%) | 7.5 (-0.3%) |
| 64 | 489.6 | 510.4 (+4.2%) | 486.8 (-0.6%) | 490.3 (+0.2%) | 505.0 (+3.1%) | 505.6 (+3.3%) |

## Create p95 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 31.0 | 26.0 | 35.3 | 33.5 | 26.2 | 32.1 |
| 64 | 1,056.4 | 1,154.9 | 1,046.2 | 1,052.4 | 1,123.0 | 1,117.9 |

## Create p99 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 48.9 | 51.8 | 50.3 | 51.5 | 49.6 | 50.4 |
| 64 | 1,426.8 | 1,567.9 | 1,419.7 | 1,433.8 | 1,533.7 | 1,519.5 |

## Throughput (ops/s)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 39.6 | 37.4 | 39.7 | 39.7 | 37.9 | 38.0 |
| 64 | 35.8 | 33.9 | 35.8 | 35.6 | 34.3 | 34.3 |

## Audit lag p50 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 560.1 | — | — | — | — |
| 64 | — | 585.7 | — | — | — | — |

## Audit lag p99 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 981.5 | — | — | — | — |
| 64 | — | 1,087.6 | — | — | — | — |

## SSE lag p50 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 251.6 | — | — | — | — |
| 64 | — | 265.8 | — | — | — | — |

## SSE lag p99 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 514.3 | — | — | — | — |
| 64 | — | 543.2 | — | — | — | — |
