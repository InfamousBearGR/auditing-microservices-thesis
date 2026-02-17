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

// StreamAuditQuery executes a query and streams results via callback function
// The callback receives each audit entry as it's read from the database
// Returns true if at least one row was processed
func (s *Service) StreamAuditQuery(query string, callback func(*models.AuditEntry) error, args ...interface{}) (bool, error) {
	db, err := s.connect()
	if err != nil {
		return false, err
	}
	defer func(db *sql.DB) {
		if err := db.Close(); err != nil {
			log.Println("Error closing database:", err)
		}
	}(db)

	rows, err := db.Query(query, args...)
	if err != nil {
		return false, fmt.Errorf("query error: %w", err)
	}
	defer func(rows *sql.Rows) {
		if err := rows.Close(); err != nil {
			log.Println("Error closing rows:", err)
		}
	}(rows)

	rowCount := 0
	for rows.Next() {
		h, err := scanAuditEntry(rows)
		if err != nil {
			log.Println("Error scanning row:", err)
			continue
		}

		if err := callback(h); err != nil {
			return rowCount > 0, fmt.Errorf("callback error: %w", err)
		}
		rowCount++
	}

	if err := rows.Err(); err != nil {
		return rowCount > 0, fmt.Errorf("rows iteration error: %w", err)
	}

	return rowCount > 0, nil
}

// StreamAuditEntriesByDate streams audit entries for a specific date range via callback
func (s *Service) StreamAuditEntriesByDate(dateFrom string, dateTo string, topic string, callback func(*models.AuditEntry) error) (bool, error) {
	query := fmt.Sprintf(`SELECT id, before, after, operation_type, changed_at, parent_id, change_id, change_reason 
	          FROM %s_audit
	          WHERE changed_at::date >= $1 and changed_at::date <= $2`, topic)

	return s.StreamAuditQuery(query, callback, dateFrom, dateTo)
}

// StreamAuditEntriesByChangeIdRange streams audit entries for a specific change_id range via callback
func (s *Service) StreamAuditEntriesByChangeIdRange(changeIdFrom int64, changeIdTo int64, topic string, callback func(*models.AuditEntry) error) (bool, error) {
	query := fmt.Sprintf(`SELECT id, before, after, operation_type, changed_at, parent_id, change_id, change_reason 
	          FROM %s_audit
	          WHERE change_id >= $1 AND change_id <= $2
	          ORDER BY change_id`, topic)

	return s.StreamAuditQuery(query, callback, changeIdFrom, changeIdTo)
}

// GetUserByAPIKey retrieves a user account by API key
func (s *Service) GetUserByAPIKey(apiKey string) (*models.UserAccount, error) {
	db, err := s.connect()
	if err != nil {
		return nil, err
	}
	defer func(db *sql.DB) {
		if err := db.Close(); err != nil {
			log.Println("Error closing database:", err)
		}
	}(db)

	query := `SELECT id, api_key, access, date_created, last_updated 
	          FROM user_api_account 
	          WHERE api_key = $1`

	var user models.UserAccount
	err = db.QueryRow(query, apiKey).Scan(
		&user.ID,
		&user.APIKey,
		&user.Access,
		&user.DateCreated,
		&user.LastUpdated,
	)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("invalid API key")
	}
	if err != nil {
		return nil, fmt.Errorf("database error: %w", err)
	}

	return &user, nil
}
