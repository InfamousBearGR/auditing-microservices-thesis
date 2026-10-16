# Audit-method comparison — by concurrency level (VUs)

Median per scenario (and run, when REPEATS>1). Overhead = create p50 relative to baseline at the same level.


## Create p50 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 6.3 | 6.8 (+6.9%) | 6.5 (+2.2%) | 6.5 (+2.2%) | 6.5 (+2.2%) | 6.5 (+3.4%) |
| 64 | 18.3 | 25.7 (+40.3%) | 19.5 (+6.5%) | 21.0 (+14.6%) | 19.6 (+7.1%) | 22.0 (+20.0%) |

## Create p95 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 9.1 | 14.5 | 12.0 | 10.4 | 12.3 | 11.6 |
| 64 | 37.2 | 77.8 | 46.3 | 43.7 | 48.0 | 53.1 |

## Create p99 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 12.6 | 36.0 | 17.0 | 14.8 | 20.0 | 17.1 |
| 64 | 99.5 | 166.6 | 137.1 | 89.9 | 150.0 | 117.0 |

## Throughput (ops/s)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | 800.6 | 597.0 | 737.3 | 764.6 | 667.5 | 712.7 |
| 64 | 1,363.1 | 811.7 | 1,262.1 | 1,242.4 | 1,062.6 | 1,046.5 |

## Audit lag p50 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 742.3 | — | — | — | — |
| 64 | — | 1,319.2 | — | — | — | — |

## Audit lag p99 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 1,477.7 | — | — | — | — |
| 64 | — | 3,290.6 | — | — | — | — |

## SSE lag p50 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 526.7 | — | — | — | — |
| 64 | — | 621.7 | — | — | — | — |

## SSE lag p99 (ms)

| VUs | baseline | cdc | triggers | envers | cdc-idle | cdc-slot |
|---|---|---|---|---|---|---|
| 8 | — | 961.6 | — | — | — | — |
| 64 | — | 1,017.0 | — | — | — | — |
