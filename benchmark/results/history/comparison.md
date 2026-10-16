# Audit-method comparison — results


## History API — streaming the whole audit table

500,000 synthetic rows in company_audit (533.72 MB in TimescaleDB); checks passed: 5 / 5. Peak memory = VmHWM of the service process (restarted before each request).

| Format | Response size | Time (s) | Time to first byte (s) | Peak RSS | RSS at start | Bytes / row |
|---|---|---|---|---|---|---|
| JSON stream | 398.18 MB | 10.2 | 0.0 | 59.6 MB | 42.6 MB | 835.0 B |
| Parquet export | 42.55 MB | 9.6 | 0.0 | 73.6 MB | 42.6 MB | 89.2 B |
