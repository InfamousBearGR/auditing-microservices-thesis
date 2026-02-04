# Company History API

A Go REST API that retrieves audit logs for company changes from TimescaleDB.

## Features

- Query audit history by date
- Swagger/OpenAPI documentation
- JSON response format
- PostgreSQL/TimescaleDB integration

## Swagger Documentation

After starting the server, access the Swagger UI at:

```
http://localhost:8081/swagger/
```

## API Endpoints

### GET /history

Retrieves all audit entries for company changes on a specific date.

**Query Parameters:**
- `date` (required): Date in YYYY-MM-DD format

**Example Request:**
```bash
curl "http://localhost:8081/history?date=2026-02-03"
```

**Example Response:**
```json
[
  {
    "id": 1,
    "changes": {
      "field": "value"
    },
    "changed_at": "2026-02-03T10:30:00Z"
  }
]
```

## Development

### Prerequisites

- Go 1.25.6 or higher
- PostgreSQL/TimescaleDB

### Install Dependencies

```bash
go mod tidy
```

### Generate Swagger Documentation

After making changes to the API annotations, regenerate the Swagger docs:

```bash
swag init
```

This will update the files in the `docs/` directory.

### Build

```bash
go build -o history-api .
```

### Run

```bash
export DB_HOST=localhost
export DB_USER=your_user
export DB_PASSWORD=your_password
export DB_NAME=your_database

./history-api
```

The server will start on port 8081.

## Environment Variables

- `DB_HOST`: Database host (default: localhost)
- `DB_USER`: Database user
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name

## Dependencies

- `github.com/gorilla/mux` - HTTP router
- `github.com/lib/pq` - PostgreSQL driver
- `github.com/swaggo/http-swagger` - Swagger UI handler
- `github.com/swaggo/swag` - Swagger documentation generator
