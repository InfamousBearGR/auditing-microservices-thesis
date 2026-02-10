# Real-Time Database Change Data Capture (CDC) System

A comprehensive microservices architecture that captures database changes in real-time using Change Data Capture (CDC), streams them via Kafka, provides real-time notifications through Server-Sent Events (SSE), and archives changes for historical analysis.

## 🎯 Overview

This system demonstrates a modern event-driven architecture that:
- Captures all changes to PostgreSQL database tables (`company` and `person`) using Debezium CDC
- Streams change events through Apache Kafka
- Provides authenticated real-time change notifications via Server-Sent Events (SSE)
- Archives all changes to separate TimescaleDB time-series hypertables
- Exposes a REST API to query historical changes
- Implements API key-based authentication and resource-level authorization

## 🏗️ Architecture

```
┌─────────────────────┐
│      mainDb         │ (Source Database - PostgreSQL)
│ (company + person)  │
└──────────┬──────────┘
           │ WAL (Logical Replication)
           ▼
    ┌─────────────┐         ┌─────────────┐
    │  Debezium   │────────▶│    Kafka    │
    │   Source    │         │  (Topics)   │
    └─────────────┘         └──────┬──────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
         ┌──────────────────┐  ┌─────────────┐  ┌─────────────┐
         │   Audit Consumer │  │ SSE Bridge  │  │  Kafka UI   │
         │     (Groovy)     │  │   (Spring   │  │  (Web GUI)  │
         └────────┬─────────┘  │   WebFlux)  │  │   :8082     │
                  │            │   :8080     │  └─────────────┘
                  │            └─────────────┘
                  │                   │
                  ▼                   ▼
         ┌─────────────────┐   Real-time SSE
         │     auditDb     │   notifications
         │  (TimescaleDB)  │     with auth
         │                 │     (API key)
         └────────┬────────┘
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
- **Purpose**: Source database containing the `company` and `person` tables
- **Port**: 5432
- **Features**: 
  - Configured with `wal_level=logical` for Change Data Capture
  - Tables have `REPLICA IDENTITY FULL` for complete change tracking
  - Auto-updated `last_updated` timestamps via triggers
- **Schema**: 
  - `company` table: `id`, `name`, `last_user_id`, `change_reason`, `date_created`, `last_updated`
  - `person` table: `id`, `name`, `surname`, `afm`, `last_user_id`, `change_reason`, `date_created`, `last_updated`

### 2. **Kafka** (Apache Kafka in KRaft mode)
- **Purpose**: Message broker for streaming change events
- **Port**: 9092
- **Features**:
  - Runs in KRaft mode (no Zookeeper required)
  - Auto-creates topics
  - Topics: `server.public.company`, `server.public.person` (created by Debezium)

### 3. **Kafka Connect** (Debezium)
- **Purpose**: CDC connector runtime for capturing database changes
- **Port**: 8083
- **Features**:
  - **Debezium Source Connector**: Monitors PostgreSQL Write-Ahead Log (WAL)
  - Captures INSERT, UPDATE, DELETE operations from `company` and `person` tables
  - Configured to exclude `date_created` and `last_updated` columns from change events
- **Configuration**: Automatically registered via `debezium/register-connector.sh` script

### 4. **auditDb** (TimescaleDB)
- **Purpose**: Time-series database for storing audit history
- **Port**: 5433 (mapped from 5432)
- **Features**:
  - Based on PostgreSQL with time-series extensions
  - Separate hypertables for each source table (partitioned by time and change_id)
  - Stores user account data for authentication
- **Schema**: 
  - `company_audit`: `id`, `before` (JSONB), `after` (JSONB), `operation_type`, `changed_at`, `changed_by_user_id`, `parent_id`, `change_id`, `business_change_id`, `change_reason`
  - `person_audit`: Same schema as `company_audit`
  - `user_account`: `id`, `api_key`, `access` (JSONB), `date_created`, `last_updated`

### 5. **auditConsumer** (Groovy Kafka Consumer)
- **Purpose**: Production-ready consumer that stores Kafka events in TimescaleDB
- **Technology**: Java 21 with Apache Kafka clients, PostgreSQL JDBC, Jackson JSON, Groovy
- **Features**:
  - Consumes from multiple Kafka topics (pattern matching: `server.public.*`)
  - Parses Debezium CDC messages
  - Dynamically routes events to appropriate audit tables based on source table name
  - Extracts metadata: operation type, timestamps, user IDs
  - Type-safe with compile-time checking
  - High-performance JVM optimization
  - Gradle-based build with fat JAR deployment
- **Architecture**: Multi-stage Docker build for minimal runtime image

### 6. **sse-bridge** (Spring Boot + WebFlux)
- **Purpose**: Provides real-time change notifications to web clients via SSE
- **Port**: 8080
- **Technology**: Java, Spring Boot, Spring WebFlux, Reactor Kafka, Groovy, Spring R2DBC
- **Endpoint**: `GET /stream/{tableName}` - Returns Server-Sent Events stream for specified table
- **Features**:
  - Reactive, non-blocking event streaming
  - Consumes from Kafka and pushes to connected clients
  - API key-based authentication (via `X-API-Key` header)
  - Resource-level authorization (users can only stream tables they have access to)
  - Heartbeat events to keep connections alive
  - Dynamic table selection via path parameter

### 7. **history-api** (Go + Gorilla Mux)
- **Purpose**: REST API for querying historical audit data
- **Port**: 8081
- **Technology**: Go, Gorilla Mux, PostgreSQL driver
- **Endpoints**:
  - `GET /getHistoryByDateRange?dateFrom=YYYY-MM-DD&dateTo=YYYY-MM-DD&topic=company` - Query audit logs by date range
  - `GET /getHistoryByChangeIdRange?changeIdFrom=N&changeIdTo=M&topic=company|person` - Query audit logs by change ID range
  - `GET /swagger/` - Interactive API documentation
- **Features**:
  - Swagger/OpenAPI documentation
  - JSON response format
  - Time-based and change ID-based queries on TimescaleDB
  - Supports both `company_audit` and `person_audit` tables via topic parameter

## 🚀 Quick Start

### Prerequisites

- Docker Engine 20.10+
- Docker Compose v2.22+ (for watch mode)
- Bash shell

### Starting the System

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd auditing-microservices-thesis
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
   UPDATE company SET name = 'New Name', last_user_id = 1, change_reason = 'Rebranding' WHERE id = 1;
   DELETE FROM company WHERE id = 2;
   ```

3. **Stream real-time changes** (in another terminal)
   ```bash
   # Stream company changes with authentication
   curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/company
   
   # Or stream person changes
   curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/person
   ```
   You should see change events as they happen!

4. **Query historical changes**
   ```bash
   # Query by date range
   curl "http://localhost:8081/getHistoryByDateRange?dateFrom=2026-02-03&dateTo=2026-02-10&topic=company"
   
   # Query by change ID range
   curl "http://localhost:8081/getHistoryByChangeIdRange?changeIdFrom=1&changeIdTo=100&topic=company"
   ```

## 📡 API Endpoints

### SSE Bridge (Real-time)
```bash
# Stream company change events in real-time
curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/company

# Stream person change events in real-time
curl -H "X-API-Key: sample_api_key_123" http://localhost:8080/stream/person
```

### History API (Historical queries)
```bash
# Get all company changes for a date range
curl "http://localhost:8081/getHistoryByDateRange?dateFrom=2026-02-03&dateTo=2026-02-10&topic=company"

# Get all person changes for a date range
curl "http://localhost:8081/getHistoryByDateRange?dateFrom=2026-02-03&dateTo=2026-02-10&topic=person"

# Get changes by change ID range
curl "http://localhost:8081/getHistoryByChangeIdRange?changeIdFrom=1&changeIdTo=100&topic=company"

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
- `sse-bridge/src` - Groovy/Spring application
- `history-api/` - Go application
- `audit-consumer/src` - Groovy Kafka consumer

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
- `SPRING_R2DBC_URL`: R2DBC connection URL for TimescaleDB
- `SPRING_R2DBC_USERNAME`: Database username
- `SPRING_R2DBC_PASSWORD`: Database password

#### audit-consumer
- `KAFKA_BROKER`: Kafka broker address (default: `kafka:9092`)
- `KAFKA_GROUP`: Consumer group ID
- `KAFKA_TOPIC`: Topic pattern to subscribe to (default: `server.public.*`)
- `DB_HOST`: TimescaleDB host
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name

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

| Component               | Technology                       | Purpose                                     |
|-------------------------|----------------------------------|---------------------------------------------|
| Source DB               | PostgreSQL 15                    | Transactional database with CDC enabled     |
| CDC Source              | Debezium Connector               | Change data capture from PostgreSQL WAL     |
| Streaming               | Apache Kafka (KRaft)             | Event streaming platform (no Zookeeper)     |
| Audit Consumer          | Groovy (Java 21) + Kafka clients | Stream processing and audit log storage     |
| Time-series DB          | TimescaleDB                      | Audit log storage with hypertables          |
| SSE Service             | Spring Boot + WebFlux + R2DBC    | Real-time notifications with authentication |
| History API             | Go + Gorilla Mux + Swagger       | REST API for historical queries             |
| Kafka UI                | Provectus Kafka UI               | Web interface for Kafka management          |
| Container Orchestration | Docker Compose                   | Service management and deployment           |

## 🔐 Authentication & Security

The SSE Bridge implements API key-based authentication with resource-level authorization:

### API Key Authentication
- All `/stream/{tableName}` endpoints require authentication
- API keys are passed via the `X-API-Key` header
- Keys are validated against the `user_account` table in TimescaleDB

### Resource-Level Authorization
- Each user account has an `access` JSONB field defining allowed resources
- Example: `{"company": true, "person": false}` grants access only to company streams
- Unauthorized access attempts return HTTP 403 Forbidden

### Default Credentials
A sample API key is pre-configured for testing:
```
API Key: sample_api_key_123
Access: {"company": true, "person": true}
```

### Adding New Users
```sql
-- Connect to auditDb
docker exec -it timescaledb psql -U admin -d auditdb

-- Insert new user
INSERT INTO user_account (api_key, access, date_created, last_updated)
VALUES ('your_new_api_key', '{"company": true, "person": false}', now(), now());
```

## 🎓 Use Cases

This architecture is suitable for:
- **Audit Logging**: Track all changes to critical data with user attribution
- **Real-time Notifications**: Notify authenticated users of database changes instantly
- **Data Replication**: Replicate changes to multiple systems
- **Event Sourcing**: Build event-driven architectures
- **Compliance**: Maintain immutable audit trails with access controls
- **Analytics**: Analyze change patterns over time

