# Real-Time Database Change Data Capture (CDC) System

A comprehensive microservices architecture that captures database changes in real-time using Change Data Capture (CDC), streams them via Kafka, provides real-time notifications through Server-Sent Events (SSE), and archives changes for historical analysis. The system is built around a **Business Registry** application — a full-stack CRUD platform for managing companies, persons, members, legal entities, and company capital.

## 🎯 Overview

This system demonstrates a modern event-driven architecture that:
- Provides a full-stack **Business Registry** application (Spring Boot API + React/Vite client) for managing business entities
- Captures all changes to the Business Registry's PostgreSQL database using **Debezium CDC**
- Streams change events through a **3-broker Apache Kafka** cluster (KRaft mode)
- Provides authenticated real-time change notifications via **Server-Sent Events (SSE)**
- Archives all changes to separate **TimescaleDB** time-series hypertables
- Exposes a **Go REST API** to query and export historical audit data (JSON streaming + Parquet)
- Implements **session-based authentication** in the Business Registry and **API key-based authentication** in the audit components

## 🏗️ Architecture

```
┌──────────────────────────────────────────┐
│         Business Registry Client         │
│      (React 19 + Vite + TypeScript)      │
│                  :5000                   │
└───────────────────┬──────────────────────┘
                    │ HTTP
                    ▼
┌──────────────────────────────────────────┐
│         Business Registry API            │
│      (Spring Boot 3 + Groovy + JPA)      │
│                  :8084                   │
└───────────────────┬──────────────────────┘
                    │ JDBC
                    ▼
┌──────────────────────────────────────────┐
│               mainDb                     │  (Source Database - PostgreSQL 15)
│  company, person, member, legal_entity,  │
│     company_capital, user_account, ...   │
└──────────────┬───────────────────────────┘
               │ WAL (Logical Replication)
               ▼
        ┌─────────────┐         ┌──────────────────────────────────┐
        │  Debezium   │────────▶│     Kafka Cluster (KRaft)        │
        │  Connect    │         │         kafka-1 :9092            │
        │   :8083     │         │         kafka-2 :9094            │
        └─────────────┘         │         kafka-3 :9095            │
                                └──────────┬───────────────────────┘
                                           │
                           ┌───────────────┼─────────────────┐
                           │               │                 │
                           ▼               ▼                 ▼
                ┌──────────────────┐  ┌─────────────┐  ┌─────────────┐
                │  Audit Consumer  │  │ SSE Bridge  │  │  Kafka UI   │
                │    (Groovy)      │  │  (Spring    │  │  (Web GUI)  │
                └────────┬─────────┘  │  WebFlux)   │  │   :8082     │
                         │            │   :8080     │  └─────────────┘
                         │            └──────┬──────┘
                         │                   │
                         ▼                   ▼
                ┌─────────────────┐   Real-time SSE
                │    auditDb      │   notifications
                │  (TimescaleDB)  │   with API key auth
                │     :5433       │
                └────────┬────────┘
                         │
                         ▼
                ┌─────────────┐
                │ History API │
                │     (Go)    │
                │    :8081    │
                └─────────────┘
```

## 📦 Components

### 1. **Business Registry Client** (React + Vite + TypeScript)
- **Purpose**: Frontend SPA for managing business registry data
- **Port**: 5000
- **Technology**: React 19, TypeScript, Vite, Material UI (MUI), TanStack Router, TanStack Query, React Hook Form, Zod, i18next (Greek & English)
- **Features**:
  - Full CRUD pages for: **Companies**, **Persons**, **Members**, **Legal Entities**, **Company Capital**
  - Session-based authentication (login/logout with server-side session)
  - Multi-language support (Greek / English) via i18next
  - Data grid tables with filtering, sorting, and pagination
  - Form validation with Zod schemas and React Hook Form
  - Reactive data fetching and caching with TanStack Query
  - Client-side routing with TanStack Router
  - Served via **Nginx** in production

### 2. **Business Registry API** (Spring Boot + Groovy)
- **Purpose**: RESTful backend for the Business Registry application
- **Port**: 8084
- **Technology**: Spring Boot 3.4, Groovy, Java 21, Spring Data JPA, Spring Security, PostgreSQL
- **Features**:
  - Session-based authentication with Spring Security
  - Role-based access control
  - Full CRUD for all business entities
  - i18n support (locale-aware responses for translated reference data)
  - Bean validation with Jakarta Validation
  - Audit metadata: every mutable entity stores `last_user_id`, `change_reason`, `date_created`, `last_updated`
  - All mutable tables have `REPLICA IDENTITY FULL` for complete CDC tracking
- **Key Endpoints**:
  - `POST /api/auth/login` — Login (returns session)
  - `POST /api/auth/logout` — Logout
  - `GET  /api/auth/status` — Session status
  - `GET/POST/PUT/DELETE /api/company/**` — Company management
  - `GET/POST/PUT/DELETE /api/person/**` — Person management
  - `GET/POST/PUT/DELETE /api/member/**` — Member management
  - `GET/POST/PUT/DELETE /api/legalEntity/**` — Legal entity management
  - `GET/POST/PUT/DELETE /api/companyCapital/**` — Company capital management

### 3. **mainDb** (PostgreSQL 15)
- **Purpose**: Source transactional database for the Business Registry
- **Port**: 5432
- **Features**:
  - Configured with `wal_level=logical` for Change Data Capture
  - All mutable tables have `REPLICA IDENTITY FULL` for complete before/after change tracking
  - Auto-updated `last_updated` timestamps via triggers
- **Key Tables**: `company`, `person`, `member`, `legal_entity`, `company_capital`, `user_account`, `roles`, `languages`, `countries`, `regions`, `prefectures`, `municipalities`, `currencies`, `legal_types`, `company_statuses`, `stock_types`

### 4. **Kafka** (Apache Kafka in KRaft mode — 3 brokers)
- **Purpose**: Message broker for streaming change events
- **Ports**: 9092 (kafka-1), 9094 (kafka-2), 9095 (kafka-3)
- **Features**:
  - Runs in KRaft mode (no Zookeeper required)
  - 3-broker cluster for fault tolerance
  - Auto-creates topics
  - Topics created by Debezium follow the pattern: `server.public.<table_name>`

### 5. **Kafka UI** (Provectus)
- **Purpose**: Web interface for monitoring and managing the Kafka cluster
- **Port**: 8082

### 6. **Debezium Connect**
- **Purpose**: CDC connector runtime for capturing database changes from the WAL
- **Port**: 8083
- **Features**:
  - **Debezium PostgreSQL Source Connector** monitoring all `public.*` tables
  - Captures INSERT, UPDATE, DELETE operations
  - Excludes `date_created` and `last_updated` columns from change events
  - Publishes full before/after row images to Kafka topics
- **Configuration**: Automatically registered on startup via `debezium/register-connector.sh`

### 7. **auditDb** (TimescaleDB on PostgreSQL 15)
- **Purpose**: Time-series database for storing structured audit history
- **Port**: 5433 (mapped from 5432)
- **Features**:
  - PostgreSQL-based with TimescaleDB extension
  - Separate **hypertables** per source table (partitioned by `changed_at` and `change_id`)
  - Stores API credentials for the audit-layer services
- **Audit Tables**: `company_audit`, `person_audit`, `legal_entity_audit`, `member_audit`, `roles_audit`, `user_account_audit`, `languages_audit`, `countries_audit`, and more
- **Audit Schema** (per table): `id`, `before` (JSONB), `after` (JSONB), `operation_type`, `changed_at`, `changed_by_user_id`, `parent_id`, `change_id`, `business_change_id`, `change_reason`
- **API credentials table**: `user_api_account` — `id`, `api_key`, `access` (JSONB), `date_created`, `last_updated`

### 8. **Audit Consumer** (Groovy + Kafka Clients)
- **Purpose**: Consumes Kafka CDC events and persists them to auditDb
- **Technology**: Java 21, Apache Kafka Clients 3.9, PostgreSQL JDBC, Jackson, Groovy 4, SLF4J
- **Features**:
  - Subscribes to all CDC topics matching `server.public.*`
  - Parses Debezium envelope format (before/after/op/source)
  - Dynamically routes events to the correct audit hypertable based on the source table name
  - Extracts operation type, user attribution, and business change metadata
  - Fat JAR deployment via Gradle Shadow plugin
  - Multi-stage Docker build for minimal runtime image

### 9. **SSE Bridge** (Spring Boot + WebFlux)
- **Purpose**: Streams real-time CDC events to web clients over Server-Sent Events
- **Port**: 8080
- **Technology**: Spring Boot 3.4, Spring WebFlux, Reactor Kafka, R2DBC, Groovy, Java 21
- **Endpoint**: `GET /stream/{tableName}` — Returns an SSE stream for the specified table
- **Features**:
  - Reactive, non-blocking event streaming via Project Reactor
  - Consumes from Kafka using Reactor Kafka and pushes to SSE clients
  - **API key authentication** via `X-API-Key` header, validated against auditDb
  - **Resource-level authorization** — users can only stream tables they have access to
  - Heartbeat events to keep connections alive

### 10. **History API** (Go)
- **Purpose**: REST API for querying and exporting historical audit data from auditDb
- **Port**: 8081
- **Technology**: Go, Gorilla Mux, `lib/pq` PostgreSQL driver, Apache Arrow Parquet, Swagger/OpenAPI
- **Endpoints**:
  - `GET /getHistoryByDateRange?dateFrom=YYYY-MM-DD&dateTo=YYYY-MM-DD&topic=<table>` — Stream audit logs as JSON by date range
  - `GET /getHistoryByChangeIdRange?changeIdFrom=N&changeIdTo=M&topic=<table>` — Stream audit logs as JSON by change ID range
  - `GET /exportHistoryByDateRange?dateFrom=YYYY-MM-DD&dateTo=YYYY-MM-DD&topic=<table>` — Export audit logs as **Parquet** file by date range
  - `GET /exportHistoryByChangeIdRange?changeIdFrom=N&changeIdTo=M&topic=<table>` — Export audit logs as **Parquet** file by change ID range
  - `GET /swagger/` — Interactive Swagger UI
- **Features**:
  - **Dual export format**: JSON streaming (real-time queries) and Apache Parquet (bulk analytics downloads — 2–10× smaller, compatible with Pandas, Spark, Excel, etc.)
  - API key authentication and resource-level authorization (same model as SSE Bridge)
  - Supports any audit table via the `topic` query parameter

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.22+ (for watch/dev mode)
- Bash shell

### Starting the System (Production)

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd auditing-microservices-thesis
   ```

2. **Start all services**
   ```bash
   docker compose up -d
   ```

3. **Wait for services to initialize** (about 30–60 seconds)
   ```bash
   docker compose logs -f debezium-setup
   ```
   Wait until you see "Registering Postgres Connector..." completed.

4. **Verify all services are running**
   ```bash
   docker compose ps
   ```

5. **Access the Business Registry**
   ```
   http://localhost:5000
   ```

### Making Changes and Observing CDC

1. **Use the Business Registry client** to create/update/delete companies, persons, members, etc. at `http://localhost:5000`

   **Or** connect to the source database directly:
   ```bash
   docker exec -it mainDb psql -U admin -d mainDb
   ```
   ```sql
   UPDATE company SET name = 'New Name', last_user_id = 1, change_reason = 'Rebranding' WHERE id = 1;
   ```

2. **Stream real-time changes** (in another terminal)
   ```bash
   curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/company
   ```

3. **Query historical changes**
   ```bash
   curl "http://localhost:8081/getHistoryByDateRange?dateFrom=2026-01-01&dateTo=2026-12-31&topic=company"
   ```

## 📡 API Reference

### Business Registry API (`localhost:8084`)
```bash
# Authentication
POST /api/auth/login          # Login with username/password
POST /api/auth/logout         # Logout
GET  /api/auth/status         # Check session status

# Business Entities (all require authentication)
GET/POST/PUT/DELETE /api/company/**
GET/POST/PUT/DELETE /api/person/**
GET/POST/PUT/DELETE /api/member/**
GET/POST/PUT/DELETE /api/legalEntity/**
GET/POST/PUT/DELETE /api/companyCapital/**
```

### SSE Bridge — Real-time streams (`localhost:8080`)
```bash
# Stream change events (requires X-API-Key header)
curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/company
curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/person
curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/member
```

### History API — Historical queries (`localhost:8081`)
```bash
# JSON streaming
curl "http://localhost:8081/getHistoryByDateRange?dateFrom=2026-01-01&dateTo=2026-12-31&topic=company"
curl "http://localhost:8081/getHistoryByChangeIdRange?changeIdFrom=1&changeIdTo=100&topic=person"

# Parquet export (binary download)
curl -o company.parquet "http://localhost:8081/exportHistoryByDateRange?dateFrom=2026-01-01&dateTo=2026-12-31&topic=company"
curl -o person.parquet  "http://localhost:8081/exportHistoryByChangeIdRange?changeIdFrom=1&changeIdTo=100&topic=person"

# Interactive docs
open http://localhost:8081/swagger/
```

### Kafka UI (`localhost:8082`)
Browse topics, consumer groups, and messages at `http://localhost:8082`

## 🛠️ Development

### Watch Mode (Auto-rebuild on changes)

The project includes a Docker Compose watch mode that automatically rebuilds or syncs services when source code changes:

```bash
./watch.sh
# or
docker compose -f docker-compose.dev.yml watch
```

This monitors:
- `business-registry/api/src` — Spring Boot API (sync + restart)
- `business-registry/client/src` — React client (sync)
- `sse-bridge/src` — Spring WebFlux SSE service (sync)
- `history-api/` — Go application (sync)
- `audit-consumer/src` — Groovy Kafka consumer (rebuild on gradle changes)

### Manual Rebuild

To rebuild all services from scratch:

```bash
./rebuild.sh
```

This script will:
1. Stop all containers
2. Remove volumes
3. Rebuild all images without cache
4. Start all services
5. Display service status

### Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f business-registry-api
docker compose logs -f business-registry-client
docker compose logs -f sse-bridge
docker compose logs -f history-api
docker compose logs -f audit-consumer
docker compose logs -f debezium
```

## 🔧 Configuration

### Environment Variables

#### business-registry-api
- `SPRING_PROFILES_ACTIVE`: `prod` (production) or `dev` (development with hot reload)
- Configured via `application-prod.properties` / `application-dev.properties`
- Datasource URL: `jdbc:postgresql://mainDb:5432/mainDb`

#### sse-bridge
- `SPRING_PROFILES_ACTIVE`: Spring profile
- `SPRING_KAFKA_BOOTSTRAP_SERVERS`: Kafka broker addresses
- R2DBC connection to auditDb configured in `application-prod.properties`

#### audit-consumer
- `GROOVY_PROFILES_ACTIVE`: Active profile
- `SPRING_KAFKA_BOOTSTRAP_SERVERS`: Kafka broker addresses
- Database connection to auditDb configured in `application-prod.properties`

#### history-api
- `ENV_FILE`: Path to the environment file (`.env.prod`)
- Contains `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` for auditDb

### Modifying the CDC Configuration

Edit `debezium/register-connector.sh` to:
- Change which tables to monitor (`table.include.list`)
- Modify topic naming (`topic.prefix`)
- Adjust snapshot mode, excluded columns, or other connector settings

## 📚 Technology Stack

| Component                | Technology                                        | Purpose                                            |
|--------------------------|---------------------------------------------------|----------------------------------------------------|
| Business Registry Client | React 19 + TypeScript + Vite + MUI + i18next      | Full-stack SPA for business registry management    |
| Business Registry API    | Spring Boot 3.4 + Groovy + Java 21 + Spring JPA   | RESTful backend with session-based auth            |
| Source DB                | PostgreSQL 15                                     | Transactional database with CDC enabled            |
| CDC Source               | Debezium PostgreSQL Connector                     | Change data capture from PostgreSQL WAL            |
| Streaming                | Apache Kafka 3 (KRaft, 3 brokers)                 | Event streaming platform — no Zookeeper            |
| Kafka UI                 | Provectus Kafka UI                                | Web interface for Kafka management                 |
| Audit Consumer           | Groovy 4 + Java 21 + Apache Kafka Clients         | CDC event processing and audit log storage         |
| Time-series DB           | TimescaleDB (PostgreSQL 15)                       | Audit log storage with time-series hypertables     |
| SSE Service              | Spring Boot 3.4 + WebFlux + Reactor Kafka + R2DBC | Real-time push notifications with API key auth     |
| History API              | Go + Gorilla Mux + Apache Arrow Parquet + Swagger | REST API for historical queries and Parquet export |
| Container Orchestration  | Docker Compose                                    | Service management and deployment                  |

## 🔐 Authentication & Security

### Business Registry (session-based)
- The Business Registry API uses **Spring Security** with **HTTP session authentication**
- Users log in via `POST /api/auth/login` with username and password
- The server creates a session; subsequent requests are authenticated by the session cookie
- Only one concurrent session per user is allowed
- User accounts and roles are stored in **mainDb** (`user_account`, `roles` tables)
- Test User:
  ```
  Username: admin
  Password: testPassword
  Role: ADMIN
  ```

### Audit Layer (API key-based)
Both the **SSE Bridge** and **History API** use API key authentication:
- API keys are passed via the `Authorization: Bearer <api_key>` header (History API) or `X-API-Key` header (SSE Bridge)
- Keys are validated against the `user_api_account` table in **auditDb**
- Each account has an `access` JSONB field defining allowed resources (tables)
- Example: `{"company": true, "person": false}` grants access only to company data
- Unauthorized access returns HTTP 403 Forbidden

### Default API Key for Testing
```
API Key: sample_api_key_123
Access:  {"company": true, "person": true}
```

### Adding New API Users
```bash
# Connect to auditDb
docker exec -it timescaledb psql -U admin -d auditdb

-- Insert new API user
INSERT INTO user_api_account (api_key, access, date_created, last_updated)
VALUES ('your_new_api_key', '{"company": true, "person": true}', now(), now());
```

## 🎓 Use Cases

This architecture is suitable for:
- **Audit Logging**: Track all changes to critical data with full user attribution and before/after snapshots
- **Real-time Notifications**: Notify authenticated clients of database changes instantly via SSE
- **Compliance & Governance**: Maintain immutable, time-series audit trails with fine-grained access controls
- **Analytics & Reporting**: Export historical change data as Parquet files for use with Pandas, Spark, or Excel
- **Event Sourcing**: Build event-driven architectures on top of existing relational databases
- **Data Replication**: Fan-out database changes to multiple downstream consumers via Kafka
