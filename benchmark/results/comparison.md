# Audit-method comparison — results (median of 3 runs per scenario)

| Metric | baseline | cdc | triggers | envers |
|---|---|---|---|---|
| Total ops | 10,000 | 10,000 | 10,000 | 10,000 |
| Throughput (ops/s) | 29.3 | 26.5 | 29.3 | 29.4 |
| Mutations ok / err | 4,068 / 5,932 | 4,199 / 5,801 | 4,144 / 5,856 | 4,137 / 5,863 |
| Create p50 (ms) | 599.0 | 650.4 | 599.2 | 601.1 |
| Create p95 (ms) | 1,327.5 | 1,609.0 | 1,326.1 | 1,330.6 |
| Create p99 (ms) | 1,830.5 | 2,207.4 | 1,811.4 | 1,802.2 |
| Update p50 (ms) | 608.9 | 650.4 | 605.7 | 603.2 |
| Update p95 (ms) | 1,373.4 | 1,606.3 | 1,325.7 | 1,345.0 |
| Delete p50 (ms) | 598.0 | 637.6 | 582.4 | 584.2 |
| Overhead vs baseline (create p50) | +0.0% | +8.6% | +0.0% | +0.4% |
| Audit rows captured | 0 | 5,006 | 4,698 | 8,734 |
| Audit storage | — | 5.82 MB | 5.70 MB | 4.10 MB |
| Bytes / audit row | — | 1,219.1 B | 1,271.2 B | 492.4 B |
| Audit lag p50 (ms) | — | 605.6 | — | — |
| Audit lag p95 (ms) | — | 988.9 | — | — |
| Audit lag p99 (ms) | — | 1,351.2 | — | — |

_Synchronous methods (triggers, envers) commit audit rows inside the mutation transaction, so audit lag is ~0 and not measured; CDC lag is ingested_at − changed_at across all *_audit rows. Audit storage of TimescaleDB hypertables is measured with hypertable_size() (parent + chunks)._


## Run-to-run spread (min – max over 3 runs)

| Metric | baseline | cdc | triggers | envers |
|---|---|---|---|---|
| Create p50 (ms) | 596.7 – 652.2 | 636.4 – 709.2 | 598.4 – 601.2 | 589.0 – 605.3 |
| Create p95 (ms) | 1,325.0 – 1,462.7 | 1,564.2 – 1,752.0 | 1,308.5 – 1,330.1 | 1,307.9 – 1,342.7 |
| Create p99 (ms) | 1,809.0 – 1,980.9 | 2,202.6 – 2,379.3 | 1,794.8 – 1,820.3 | 1,796.1 – 1,837.1 |
| Update p50 (ms) | 604.0 – 665.7 | 633.7 – 712.7 | 594.3 – 607.5 | 599.9 – 610.1 |
| Throughput (ops/s) | 26.9 – 29.4 | 24.2 – 26.9 | 29.3 – 29.5 | 29.1 – 29.6 |
| Audit rows captured | 0 – 0 | 4,671 – 5,070 | 4,626 – 4,876 | 8,665 – 8,855 |
| Audit storage (MB) | 0.00 – 0.00 | 5.58 – 5.88 | 5.68 – 5.93 | 3.98 – 4.22 |
| Audit lag p50 (ms) | — | 596.5 – 626.6 | — | — |
| Audit lag p99 (ms) | — | 1,132.6 – 1,396.2 | — | — |

## Per-run values

| Scenario | Run | Create p50 | Create p95 | Create p99 | Update p50 | ops/s | Audit rows | Audit MB | Lag p50 | Lag p99 |
|---|---|---|---|---|---|---|---|---|---|---|
| baseline | 1 | 652.2 | 1,462.7 | 1,980.9 | 665.7 | 26.9 | 0 | — | — | — |
| baseline | 2 | 596.7 | 1,327.5 | 1,830.5 | 608.9 | 29.4 | 0 | — | — | — |
| baseline | 3 | 599.0 | 1,325.0 | 1,809.0 | 604.0 | 29.3 | 0 | — | — | — |
| cdc | 1 | 709.2 | 1,752.0 | 2,379.3 | 712.7 | 24.2 | 5,006 | 5.82 MB | 626.6 | 1,396.2 |
| cdc | 2 | 650.4 | 1,609.0 | 2,207.4 | 650.4 | 26.5 | 4,671 | 5.58 MB | 605.6 | 1,351.2 |
| cdc | 3 | 636.4 | 1,564.2 | 2,202.6 | 633.7 | 26.9 | 5,070 | 5.88 MB | 596.5 | 1,132.6 |
| triggers | 1 | 601.2 | 1,326.1 | 1,811.4 | 607.5 | 29.3 | 4,876 | 5.93 MB | — | — |
| triggers | 2 | 599.2 | 1,330.1 | 1,820.3 | 594.3 | 29.3 | 4,626 | 5.68 MB | — | — |
| triggers | 3 | 598.4 | 1,308.5 | 1,794.8 | 605.7 | 29.5 | 4,698 | 5.70 MB | — | — |
| envers | 1 | 601.1 | 1,342.7 | 1,837.1 | 603.2 | 29.1 | 8,734 | 4.10 MB | — | — |
| envers | 2 | 605.3 | 1,330.6 | 1,802.2 | 610.1 | 29.4 | 8,855 | 4.22 MB | — | — |
| envers | 3 | 589.0 | 1,307.9 | 1,796.1 | 599.9 | 29.6 | 8,665 | 3.98 MB | — | — |