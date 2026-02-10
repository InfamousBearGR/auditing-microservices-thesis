package database

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"history-api/models"

	_ "github.com/lib/pq"
)

// Service represents the database service
type Service struct {
	connStr string
}

// NewService creates a new database service instance
func NewService() *Service {
	connStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable port=%s",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)
	return &Service{connStr: connStr}
}

// connect establishes a connection to the database
func (s *Service) connect() (*sql.DB, error) {
	db, err := sql.Open("postgres", s.connStr)
	if err != nil {
		return nil, fmt.Errorf("database connection error: %w", err)
	}
	return db, nil
}

// parseJSONField parses a nullable JSON string into an interface{}
func parseJSONField(nullStr sql.NullString) interface{} {
	if !nullStr.Valid {
		return nil
	}

	var result interface{}
	if err := json.Unmarshal([]byte(nullStr.String), &result); err != nil {
		log.Println("Error parsing JSON:", err)
		return nullStr.String // Fallback to raw string
	}
	return result
}

// scanAuditEntry scans a database row into an AuditEntry struct
func scanAuditEntry(rows *sql.Rows) (*models.AuditEntry, error) {
	var h models.AuditEntry
	var beforeStr, afterStr sql.NullString

	if err := rows.Scan(&h.ID, &beforeStr, &afterStr, &h.OperationType, &h.ChangedAt, &h.ParentID, &h.ChangeID, &h.ChangeReason); err != nil {
		return nil, err
	}

	h.Before = parseJSONField(beforeStr)
	h.After = parseJSONField(afterStr)

	return &h, nil
}

// executeAuditQuery executes a query and returns audit entries
func (s *Service) executeAuditQuery(query string, args ...interface{}) ([]models.AuditEntry, error) {
	db, err := s.connect()
	if err != nil {
		return nil, err
	}
	defer func(db *sql.DB) {
		if err := db.Close(); err != nil {
			log.Println("Error closing database:", err)
		}
	}(db)

	rows, err := db.Query(query, args...)
	if err != nil {
		return nil, fmt.Errorf("query error: %w", err)
	}
	defer func(rows *sql.Rows) {
		if err := rows.Close(); err != nil {
			log.Println("Error closing rows:", err)
		}
	}(rows)

	var history []models.AuditEntry
	for rows.Next() {
		h, err := scanAuditEntry(rows)
		if err != nil {
			log.Println("Error scanning row:", err)
			continue
		}
		history = append(history, *h)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("rows iteration error: %w", err)
	}

	return history, nil
}

// GetAuditEntriesByDate retrieves all audit entries for a specific date
func (s *Service) GetAuditEntriesByDate(dateFrom string, dateTo string, topic string) ([]models.AuditEntry, error) {
	query := fmt.Sprintf(`SELECT id, before, after, operation_type, changed_at, parent_id, change_id, change_reason 
	          FROM %s_audit
	          WHERE changed_at::date >= $1 and changed_at::date <= $2`, topic)

	return s.executeAuditQuery(query, dateFrom, dateTo)
}

// GetAuditEntriesByChangeIdRange retrieves all audit entries for a specific change_id range
func (s *Service) GetAuditEntriesByChangeIdRange(changeIdFrom int64, changeIdTo int64, topic string) ([]models.AuditEntry, error) {
	query := fmt.Sprintf(`SELECT id, before, after, operation_type, changed_at, parent_id, change_id, change_reason 
	          FROM %s_audit
	          WHERE change_id >= $1 AND change_id <= $2
	          ORDER BY change_id`, topic)

	return s.executeAuditQuery(query, changeIdFrom, changeIdTo)
}
