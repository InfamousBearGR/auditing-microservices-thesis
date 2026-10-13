# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Change Data Capture (CDC) audit pipeline built around a **Business Registry** CRUD application. Mutations to the source PostgreSQL DB are captured by Debezium, streamed through a 3-broker Kafka cluster (KRaft, no Zookeeper), and fanned out to two downstream paths: real-time SSE notifications and a TimescaleDB audit archive queryable via a Go REST API. This is a thesis project.

The thesis also **compares this CDC pipeline against two other auditing methods** — DB triggers and Hibernate Envers — via a reproducible benchmark in `benchmark/`. See the "Audit method comparison" note below.

The full data flow:
```
Client (React) → Business Registry API (Spring/Groovy) → mainDb (PostgreSQL, wal_level=logical)
  → Debezium → Kafka (server.public.<table>) → ┬→ Audit Consumer → auditDb (TimescaleDB hypertables) → History API (Go)
                                                └→ SSE Bridge (WebFlux) → browser SSE clients
```

## Components (and their directories)

| Dir | Service | Stack | Port |
|-----|---------|-------|------|
| `business-registry/client` | `business-registry-client` | React 19 + Vite + TS + MUI + TanStack Router/Query + i18next | 5000 |
| `business-registry/api` | `business-registry-api` | Spring Boot 3.4 + Groovy + Java 21 + JPA + Spring Security | 8084 |
| `mainDb/` | `mainDb` | PostgreSQL 15 (source DB, logical replication) | 5432 |
| `audit-consumer/` | `audit-consumer` | Groovy 4 + raw Kafka clients + JDBC (fat JAR via Shadow) | — |
| `sse-bridge/` | `sse-bridge` | Spring Boot 3.4 + WebFlux + Reactor Kafka + R2DBC + Groovy | 8080 |
| `history-api/` | `history-api` | Go + Gorilla Mux + Apache Arrow Parquet + Swagger | 8081 |
| `auditDb/` | `auditDb` (container `timescaledb`) | TimescaleDB on PostgreSQL 15 | 5433→5432 |
| `debezium/` | `debezium` / `debezium-setup` | Debezium Connect (PostgreSQL connector) | 8083 |
| `kafka-ui/` | `kafka-ui` | Provectus Kafka UI | 8082 |

Kafka brokers: `kafka-1` :9092, `kafka-2` :9094, `kafka-3` :9095.

## Running the system

Everything is Docker Compose orchestrated; you rarely run a service directly on the host.

```bash
docker compose up -d                          # start full stack (prod images)
docker compose logs -f debezium-setup         # watch until connector registration completes
./rebuild.sh                                   # full teardown (down -v) + no-cache rebuild + up
docker compose logs -f <service-name>          # tail one service
```

### Dev / watch mode (hot reload)

Use `docker-compose.dev.yml`, not the prod file. It enables `docker compose watch` so source edits sync into the running containers:

```bash
./watch.sh                                     # == docker compose -f docker-compose.dev.yml watch
```

Watched paths: `business-registry/api/src` (sync+restart), `business-registry/client/src` (sync), `sse-bridge/src` (sync), `history-api/` (sync), `audit-consumer/src` (sync+restart). The JVM services run with Spring DevTools and Go runs under Air (`history-api/.air.toml`) for in-container reloads.

### Per-service rebuild (faster than full stack)

Each JVM/Go service has its own script: `audit-consumer/rebuild-audit-consumer.sh`, `sse-bridge/rebuild-sse-bridge.sh`, `history-api/rebuild-history-api.sh`. They stop → rm → `build --no-cache` → up a single service.

## Building & testing individual services

The three JVM services are **independent Gradle projects** (each has its own `gradlew`, `build.gradle`, `settings.gradle` — there is no root Gradle build). Run Gradle from inside the service directory:

```bash
# business-registry/api  or  sse-bridge  (Spring Boot, bootJar)
./gradlew build
./gradlew bootRun
./gradlew test                                 # JUnit Platform
./gradlew test --tests '*SomeClassTest*'       # single test class

# audit-consumer (plain Groovy app, packaged as a fat JAR — no Spring)
./gradlew shadowJar                            # build dependsOn shadowJar; jar task is disabled

# history-api (Go module, go 1.25)
go build ./...
go test ./...
go test ./handlers -run TestName               # single test
```

```bash
# client (business-registry/client)
npm install
npm run dev                                    # Vite dev server
npm run build                                  # tsc -b && vite build
npm run lint                                   # eslint
```

Note: the JVM services have **no committed `gradle-wrapper.jar`** — `./gradlew` won't run on the host. Build them via Docker (the Dockerfiles download Gradle), e.g. `docker compose build business-registry-api`.

### Benchmark (audit-method comparison)

```bash
./benchmark/run-all.sh                         # all 4 scenarios: baseline | cdc | triggers | envers
SCENARIOS="cdc triggers" VUS=8 TOTAL_OPS=2000 CDC_DRAIN_S=90 ./benchmark/run-all.sh
```

Orchestrator does `down -v` → bring up only the services a scenario needs → toggle the method → run the k6 workload (`benchmark/load.js`, via the `grafana/k6` container) → collect DB metrics (`collect.sh`) → `summarize.py` writes `benchmark/results/comparison.{md,csv}`. See `benchmark/README.md`.

## Architecture notes that span files

- **CDC contract.** Debezium is configured in `debezium/register-connector.sh` (registered once by the `debezium-setup` container). Its `table.include.list` is a regex over `public.*` that **excludes the other audit methods' tables** (`*_trigger_audit`, `*_aud`, `revinfo`) so CDC never audits trigger/Envers output; it names topics `server.public.<table>` and **excludes `date_created`/`last_updated`** from change events. All mutable source tables use `REPLICA IDENTITY FULL` so both before- and after-images are captured — this is set up in `mainDb/init.sql`. `snapshot.mode` is env-driven (`SNAPSHOT_MODE`, default `initial`; the benchmark uses it to control seed-snapshot behavior). Changing which columns/tables are tracked means editing this script, not application code.

- **Audit attribution flows through the row, not the connection.** Every mutable entity carries `last_user_id` and `change_reason` columns. The Business Registry API writes these on each mutation; Debezium ships them in the change event; the audit consumer reads them out of the Debezium envelope to populate `changed_by_user_id` / `change_reason` in the audit tables. If you add a new entity, it must carry these columns for attribution to survive end to end.

- **Audit consumer is table-agnostic and dynamic.** `audit-consumer` (`auditConsumer/`, `kafkaService/`, `databaseService/`) subscribes to all `server.public.*` topics and routes each event to a `<table>_audit` hypertable derived from the source table name in the Debezium `source` block. Audit rows are `{ before JSONB, after JSONB, operation_type, changed_at, changed_by_user_id, change_id, business_change_id, change_reason, ... }`. Adding a new source table generally needs a matching `<table>_audit` hypertable in `auditDb/init.sql` but no consumer code change.

- **Audit method comparison (thesis).** Besides CDC, two more methods are implemented for the 6 core mutable entities, stored in their native idiomatic form, each toggleable so the benchmark can run them in isolation:
  - *DB triggers* — `capture_trigger_audit()` + `<t>_trigger_audit` tables + AFTER row triggers, all appended to `mainDb/init.sql` (created `ENABLE`d; toggle with `ALTER TABLE … DISABLE/ENABLE TRIGGER <t>_audit_trigger`). Synchronous, in the mutation txn.
  - *Hibernate Envers* — `@Audited` on the 6 entity classes + a custom `REVINFO` (`com.business.registry.audit` package: `AuditRevisionEntity`/`AuditRevisionListener`, with user pulled from a per-request `AuditContext` set by `AuditContextFilter`). Dependency is `org.hibernate.orm:hibernate-envers`. **OFF by default** (`hibernate.integration.envers.enabled=false` in base profiles); enabled via the `envers` profile (`BR_API_PROFILES=prod,envers`), which also flips `ddl-auto` to `update` to create the `_AUD` tables. `REVINFO` is pre-created in `mainDb/init.sql` because it is a mapped `@Entity` that `validate` checks on every boot. If you add/annotate an entity, mark `@ManyToOne` targets `RelationTargetAuditMode.NOT_AUDITED` unless the target is also `@Audited`.
  - *CDC lag* — `ingested_at TIMESTAMPTZ DEFAULT now()` was added to every `*_audit` table in `auditDb/init.sql`; CDC lag = `ingested_at − changed_at`. Synchronous methods commit in-txn so their lag is ~0.
  - Benchmark users `bench1..bench64` are seeded in `mainDb/init.sql` (one per k6 VU) — required because Spring Security's `maximumSessions(1)` + `SessionAuthenticationFilter` mean the load generator must use a distinct user per VU and re-login per iteration (see `benchmark/README.md`).

- **Two separate auth models — don't conflate them.**
  - *Business Registry* (API + client): Spring Security **session** auth (cookie). Users/roles live in `mainDb` (`user_account`, `roles`). One concurrent session per user. Test user: `admin` / `testPassword`.
  - *Audit layer* (SSE Bridge + History API): **API-key** auth validated against `auditDb.user_api_account`. The `access` JSONB column does resource-level authorization per table (e.g. `{"company": true, "person": false}`); requests for tables the key can't access return 403. SSE Bridge reads the key from `X-API-Key`; History API uses `Authorization: Bearer <key>`. Test key: `sample_api_key_123`.

- **SSE Bridge is fully reactive.** It consumes Kafka via Reactor Kafka and pushes to clients over `GET /stream/{tableName}` using WebFlux + R2DBC (for the auth lookup). Keep this path non-blocking — no blocking JDBC/JPA here (contrast with the audit consumer, which uses plain blocking JDBC).

- **History API dual output.** Same queries, two formats: JSON streaming (`/getHistoryBy*`) and Parquet export (`/exportHistoryBy*`), by date range or `change_id` range, with the target table passed as `?topic=<table>`. Swagger UI at `/swagger/`; regenerate docs with `swag init` (output in `history-api/docs/`).

- **i18n.** The client uses i18next (Greek + English). The API also serves locale-aware reference data — translation mapping lives under `business-registry/api/src/main/resources/i18n` and the `mapper/i18n` package.

## Conventions

- Two Docker Compose files: `docker-compose.yml` (prod) and `docker-compose.dev.yml` (watch + DevTools/Air). Each service has both a `Dockerfile` and a `Dockerfile.dev`. Edit the matching pair when changing build/runtime setup.
- All JVM services target Java 21 and use Groovy (with `groovyOptions.parameters = true` where Spring needs parameter names).
- Spring profiles select config: `application-prod.properties` vs `application-dev.properties` per service (`SPRING_PROFILES_ACTIVE`); audit-consumer uses `GROOVY_PROFILES_ACTIVE`; history-api uses `ENV_FILE` pointing at `.env.prod` / `.env.dev`.
- DB credentials in this thesis project are `admin`/`admin` for both Postgres instances.

## graphify

This project has a knowledge graph at graphify-out/ with god nodes, community structure, and cross-file relationships.

Rules:
- For codebase questions, first run `graphify query "<question>"` when graphify-out/graph.json exists. Use `graphify path "<A>" "<B>"` for relationships and `graphify explain "<concept>"` for focused concepts. These return a scoped subgraph, usually much smaller than GRAPH_REPORT.md or raw grep output.
- If graphify-out/wiki/index.md exists, use it for broad navigation instead of raw source browsing.
- Read graphify-out/GRAPH_REPORT.md only for broad architecture review or when query/path/explain do not surface enough context.
- After modifying code, run `graphify update .` to keep the graph current (AST-only, no API cost).
- Graph first, then confirm with grep/Read before acting. Known blind spots in this repo:
  - Table references inside strings (`@Table("…")`, `@Query("SELECT …")`, raw SQL in Go/Groovy) are not linked — e.g. `user_api_account` has no edges to the SSE Bridge or History API code that uses it. Grep for table names.
  - Many Groovy and `build.gradle` files only partially parse, so their symbols/edges may be missing.
  - Same-named symbols across services can be conflated (name-based resolution). Check `source_file` on every node before trusting a cross-service edge.
  - `graphify update .` re-clusters and replaces community names with hub-node names.
