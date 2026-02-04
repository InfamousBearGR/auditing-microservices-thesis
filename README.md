# Real-Time Database Change Data Capture (CDC) System

A comprehensive microservices architecture that captures database changes in real-time using Change Data Capture (CDC), streams them via Kafka, provides real-time notifications through Server-Sent Events (SSE), and archives changes for historical analysis.

## 🎯 Overview

This system demonstrates a modern event-driven architecture that:
- Captures all changes to a PostgreSQL database table using Debezium CDC
- Streams change events through Apache Kafka
- Provides real-time change notifications via Server-Sent Events (SSE)
- Archives all changes to a TimescaleDB time-series database
- Exposes a REST API to query historical changes

## 🏗️ Architecture

```
┌─────────────┐
│   mainDb    │ (Source Database - PostgreSQL)
│  (company)  │
└──────┬──────┘
       │ WAL (Logical Replication)
       ▼
┌─────────────┐         ┌─────────────┐
│  Debezium   │────────▶│    Kafka    │
│   Source    │         │   (Topic)   │
└─────────────┘         └──────┬──────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
                ▼                             ▼
         ┌─────────────┐            ┌─────────────────┐
         │ SSE Bridge  │            │     Groovy      │
         │  (Spring)   │            │    Consumer     │
         │   :8080     │            └────────┬────────┘
         └─────────────┘                     │
                                             ▼
         Real-time                    ┌─────────────┐
         notifications                │   auditDb   │
         to clients                   │(TimescaleDB)│
                                      └──────┬──────┘
                                             │
                                             ▼
                                      ┌─────────────┐
                                      │ History API │
                                      │    (Go)     │
                                      │   :8081     │
                                      └─────────────┘
```

## 📦 Components

### 1. **mainDb** (PostgreSQL)
- **Purpose**: Source database containing the `company` table
- **Port**: 5432
- **Features**: 
  - Configured with `wal_level=logical` for Change Data Capture
  - Table has `REPLICA IDENTITY FULL` for complete change tracking
- **Schema**: `company` table with fields: `id`, `name`, `test`

### 2. **Kafka** (Apache Kafka in KRaft mode)
- **Purpose**: Message broker for streaming change events
- **Port**: 9092
- **Features**:
  - Runs in KRaft mode (no Zookeeper required)
  - Auto-creates topics
  - Topic: `server.public.company` (created by Debezium)

### 3. **Kafka Connect** (Debezium + JDBC Sink)
- **Purpose**: Unified connector runtime for CDC and sink operations
- **Port**: 8083
- **Features**:
  - **Debezium Source Connector**: Monitors PostgreSQL Write-Ahead Log (WAL)
  - **JDBC Sink Connector**: Writes audit records to TimescaleDB
  - Captures INSERT, UPDATE, DELETE operations
  - Single runtime for both source and sink connectors
- **Configuration**: Automatically registered via connector setup scripts

### 4. **auditDb** (TimescaleDB)
- **Purpose**: Time-series database for storing audit history
- **Port**: 5433 (mapped from 5432)
- **Features**:
  - Based on PostgreSQL with time-series extensions
  - Hypertable for efficient time-series queries
- **Schema**: `company_audit` table with fields: `id`, `changes` (JSONB), `changed_at`

### 5. **auditConsumer** (Groovy Kafka Consumer)
- **Purpose**: Production-ready consumer that stores Kafka events in TimescaleDB
- **Technology**: Java 21 with Apache Kafka clients, PostgreSQL JDBC, Jackson JSON, Groovy
- **Features**:
  - Reads from Kafka topic `server.public.company`
  - Parses Debezium CDC messages
  - Writes JSON as TEXT to database
  - PostgreSQL GENERATED columns auto-convert to JSONB (no triggers!)
  - Type-safe with compile-time checking
  - High-performance JVM optimization
  - Gradle-based build with fat JAR deployment
- **Architecture**: Multi-stage Docker build for minimal runtime image

### 6. **sse-bridge** (Spring Boot + WebFlux)
- **Purpose**: Provides real-time change notifications to web clients via SSE
- **Port**: 8080
- **Technology**: Java, Spring Boot, Spring WebFlux, Reactor Kafka, Groovy
- **Endpoint**: `GET /stream` - Returns Server-Sent Events stream
- **Features**:
  - Reactive, non-blocking event streaming
  - Consumes from Kafka and pushes to connected clients

### 7. **history-api** (Go + Gorilla Mux)
- **Purpose**: REST API for querying historical audit data
- **Port**: 8081
- **Technology**: Go, Gorilla Mux, PostgreSQL driver
- **Endpoints**:
  - `GET /history?date=YYYY-MM-DD` - Query audit logs by date
  - `GET /swagger/` - Interactive API documentation
- **Features**:
  - Swagger/OpenAPI documentation
  - JSON response format
  - Time-based queries on TimescaleDB

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.22+ (for watch mode)
- Bash shell

### Starting the System

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd diplomatiki
   ```

2. **Start all services**
   ```bash
   docker-compose up -d
   ```

3. **Wait for services to initialize** (about 30 seconds)
   ```bash
   docker-compose logs -f debezium-setup
   ```
   Wait until you see "Registering Postgres Connector..." completed.

4. **Verify all services are running**
   ```bash
   docker-compose ps
   ```

### Making Changes and Observing CDC

1. **Connect to the source database**
   ```bash
   docker exec -it mainDb psql -U admin -d mainDb
   ```

2. **Make a change to the company table**
   ```sql
   UPDATE company SET name = 'New Name' WHERE id = 1;
   DELETE FROM company WHERE id = 2;
   ```

3. **Stream real-time changes** (in another terminal)
   ```bash
   curl http://localhost:8080/stream
   ```
   You should see change events as they happen!

4. **Query historical changes**
   ```bash
   curl "http://localhost:8081/history?date=2026-02-03"
   ```

## 📡 API Endpoints

### SSE Bridge (Real-time)
```bash
# Stream change events in real-time
curl http://localhost:8080/stream
```

### History API (Historical queries)
```bash
# Get all changes for a specific date
curl "http://localhost:8081/history?date=2026-02-03"

# Access Swagger UI
open http://localhost:8081/swagger/
```

## 🛠️ Development

### Watch Mode (Auto-rebuild on changes)

The project includes a watch mode that automatically rebuilds services when source code changes:

```bash
./watch.sh
```

This monitors:
- `sse-bridge/src` - Kotlin/Spring application
- `history-api/` - Go application

### Manual Rebuild

To rebuild all services from scratch:

```bash
./rebuild.sh
```

This script will:
1. Stop all containers
2. Remove volumes
3. Rebuild images without cache
4. Start all services
5. Display service status

### Viewing Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f sse-bridge
docker-compose logs -f history-api
docker-compose logs -f debezium
docker-compose logs -f auditConsumer  # Groovy Kafka consumer
```

## 🔧 Configuration

### Environment Variables

#### sse-bridge
- `KAFKA_BROKER`: Kafka broker address (default: `kafka:9092`)

#### history-api
- `DB_HOST`: TimescaleDB host
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name

### Modifying the CDC Configuration

Edit `debezium/register-connector.sh` to:
- Change which tables to monitor (`table.include.list`)
- Modify topic naming (`topic.prefix`)
- Adjust connector settings

### Customizing the Audit Consumer

Edit `audit-consumer/src/main/groovy/auditConsumer/AuditConsumer.groovy` to:
- Modify data transformation logic
- Add custom field mappings
- Implement batch processing
- Add error handling and retries
- Tune performance settings

## 📚 Technology Stack

| Component | Technology                       | Purpose |
|-----------|----------------------------------|---------|
| Source DB | PostgreSQL 15                    | Transactional database |
| CDC Source | Debezium Connector               | Change data capture from PostgreSQL |
| Streaming | Apache Kafka (KRaft)             | Event streaming platform |
| Audit Consumer | Groovy (Java 21) + Kafka clients | Stream processing and database writes |
| Time-series DB | TimescaleDB                      | Audit log storage with GENERATED columns |
| SSE Service | Spring Boot + WebFlux            | Real-time notifications |
| History API | Go + Gorilla Mux                 | REST API |
| Container Orchestration | Docker Compose                   | Service management |

## 🎓 Use Cases

This architecture is suitable for:
- **Audit Logging**: Track all changes to critical data
- **Real-time Notifications**: Notify users of database changes instantly
- **Data Replication**: Replicate changes to multiple systems
- **Event Sourcing**: Build event-driven architectures
- **Compliance**: Maintain immutable audit trails
- **Analytics**: Analyze change patterns over time

