# Audit-method benchmark

Compares three auditing strategies for the Business Registry against a no-audit
baseline, under one fixed, reproducible CRUD workload. Built for the thesis.

| Scenario | Method | Where audit lives | When it commits |
|----------|--------|-------------------|-----------------|
| `baseline` | none | — | — |
| `cdc` | Debezium CDC → Kafka → audit-consumer | `auditDb` (TimescaleDB hypertables) | **async**, out-of-band |
| `triggers` | PostgreSQL `AFTER` row triggers | `mainDb` (`<t>_trigger_audit`) | **sync**, same txn |
| `envers` | Hibernate Envers | `mainDb` (`<t>_AUD` + `REVINFO`) | **sync**, same txn |

Scope: the 6 core mutable entities — `company`, `person`, `legal_entity`,
`member`, `company_stocks`, `company_capital`.

## Run

```bash
./benchmark/run-all.sh                         # all 4 scenarios, default 10 VUs x 2000 ops
SCENARIOS="baseline triggers" VUS=20 TOTAL_OPS=5000 ./benchmark/run-all.sh
REPEATS=3 VUS=64 TOTAL_OPS=10000 ./benchmark/run-all.sh   # 3 runs per scenario (round-robin); median + spread reported
```

Requirements: Docker + Docker Compose. k6 runs as the `grafana/k6` container on
the compose network (no host install). `python3` for the summary (optional —
raw CSV/JSON are written regardless). `VUS` ≤ 64 (one seeded `bench<n>` user per VU).

### Load model

The app uses Spring Security session auth with `maximumSessions(1)` (one session
per user) and a `SessionAuthenticationFilter` that expires a session after its
first authenticated state-change. So the generator:

- gives **each VU its own user** `bench<__VU>` (seeded `bench1..bench64` in
  `mainDb/init.sql`, password `testPassword`) so VUs don't evict each other;
- **re-logs in once per iteration** before the mutation. Login cost is identical
  across all four scenarios and is excluded from the `op_create/update/delete`
  latency trends, so it does not distort the per-method comparison (it does make
  end-to-end throughput login-bound — read throughput as "audited ops incl. re-auth").

Create endpoints return `ResponseEntity<Void>`, so new ids aren't tracked;
updates/deletes operate on the seeded entity set. A portion of random ops fail on
constraint/FK violations by design (same as the client stress-test) — see the
`mutations ok / err` row.

The orchestrator, per scenario: `down -v` → bring up only the services that
method needs → toggle triggers / Envers profile → run the k6 workload →
(`cdc` only) wait for the async pipeline to drain → snapshot DB metrics.

## Outputs (`benchmark/results/`)

- `<scenario>/k6-summary.json` — full k6 metrics (latency trends, throughput).
- `<scenario>/storage.csv` — per audit-table row counts + size. TimescaleDB hypertables are measured with `hypertable_size()` (parent + chunks + indexes); `pg_total_relation_size()` on a hypertable parent reports only the empty parent relation (~40 kB), which is why older runs under-reported the CDC audit volume.
- `<scenario>/run-<k>/…` — the same files per run when `REPEATS>1`; `comparison.md` then shows the median across runs, a min–max spread table and the per-run values.
- `cdc/lag.csv` — end-to-end CDC lag percentiles (`ingested_at − changed_at`, ms).
- `comparison.md` / `comparison.csv` — combined table across scenarios.

## How each method is toggled

- **Triggers** — created `ENABLE`d in `mainDb/init.sql`; `run-all.sh` does
  `ALTER TABLE … DISABLE/ENABLE TRIGGER …` per scenario.
- **Envers** — off by default (`hibernate.integration.envers.enabled=false`);
  the `envers` scenario boots the API with `BR_API_PROFILES=prod,envers`, which
  enables the integrator and lets `ddl-auto=update` create the `_AUD` tables.
  `REVINFO` is pre-created in `mainDb/init.sql` (it is a mapped `@Entity`, so it
  must satisfy `validate` on every boot). Attribution: `AuditRevisionListener`
  stamps `changed_by_user_id` from the per-request `AuditContext`; `change_reason`
  + `last_user_id` also survive as audited entity columns in each `_AUD` row.
- **CDC** — only the `cdc` scenario starts Kafka + Debezium + `audit-consumer`.
  `ingested_at DEFAULT now()` on the `*_audit` tables marks consumer write time;
  `changed_at` is Debezium's source commit time.

## Qualitative comparison (for the write-up)

| Dimension | CDC (Debezium) | DB triggers | Hibernate Envers |
|-----------|----------------|-------------|------------------|
| Coupling to app | none (reads WAL) | none (DB-side) | tight (ORM/app) |
| Write-path overhead | ~0 on source txn (async) | per-row, in txn | per-flush, in txn |
| Audit availability | eventual (pipeline lag) | immediate | immediate |
| Captures non-ORM writes | yes (any SQL) | yes (any SQL) | **no** (only via Hibernate) |
| Before/after image | full (REPLICA IDENTITY FULL) | full (`OLD`/`NEW`) | full (per-revision rows) |
| Attribution survival | row-carried → envelope | row-carried (`OLD`/`NEW`) | RevisionListener + columns |
| Storage location | separate store (scales out) | same DB (competes for IO) | same DB (competes for IO) |
| Schema-evolution cost | connector config | per-table trigger DDL | `_AUD` schema migration |
| Query ergonomics | History API / SQL | plain SQL | Envers query API / SQL |
| Operational complexity | high (Kafka/Connect) | low | low–medium |
| Failure isolation | source unaffected if pipeline down | mutation fails if audit fails | mutation fails if audit fails |

The quantitative table (`comparison.md`) is produced per run; paste both into
the thesis.
