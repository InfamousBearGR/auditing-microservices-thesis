package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "history-api/docs"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	httpSwagger "github.com/swaggo/http-swagger"
)

// AuditEntry represents a row in TimescaleDB
type AuditEntry struct {
	ID        int         `json:"id"`
	Changes   interface{} `json:"changes"`
	ChangedAt string      `json:"changed_at"`
}

// getHistory godoc
// @Summary Get audit history for a specific date
// @Description Retrieves all audit entries for company changes on a specific date
// @Tags history
// @Accept json
// @Produce json
// @Param date query string true "Date in YYYY-MM-DD format"
// @Success 200 {array} AuditEntry "Successfully retrieved audit entries"
// @Failure 400 {string} string "Bad Request - date parameter required"
// @Failure 500 {string} string "Internal Server Error"
// @Router /history [get]
func getHistory(w http.ResponseWriter, r *http.Request) {
	date := r.URL.Query().Get("date") // Format YYYY-MM-DD
	if date == "" {
		http.Error(w, "date parameter required", http.StatusBadRequest)
		return
	}

	connStr := fmt.Sprintf("host=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("DB_HOST"), os.Getenv("DB_USER"), os.Getenv("DB_PASSWORD"), os.Getenv("DB_NAME"))

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		http.Error(w, "Database connection error", http.StatusInternalServerError)
		return
	}
	defer func(db *sql.DB) {
		err := db.Close()
		if err != nil {
			log.Println("Error closing database:", err)
		}
	}(db)

	// Query for a specific day
	query := `SELECT id, changes, changed_at FROM company_audit
	WHERE changed_at::date = $1`

	rows, err := db.Query(query, date)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer func(rows *sql.Rows) {
		err := rows.Close()
		if err != nil {
			log.Println("Error closing rows:", err)
		}
	}(rows)

	var history []AuditEntry
	for rows.Next() {
		var h AuditEntry
		var changesStr string
		if err := rows.Scan(&h.ID, &changesStr, &h.ChangedAt); err != nil {
			log.Println(err)
			continue
		}
		// Parse JSON string into interface{}
		if err := json.Unmarshal([]byte(changesStr), &h.Changes); err != nil {
			log.Println("Error parsing changes JSON:", err)
			h.Changes = changesStr // Fallback to raw string
		}
		history = append(history, h)
	}

	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(history); err != nil {
		log.Println("Error encoding response:", err)
		http.Error(w, "Error encoding response", http.StatusInternalServerError)
		return
	}
}

// @title Company History API
// @version 1.0
// @description Get audit logs for company changes from TimescaleDB
// @host localhost:8081
// @BasePath /
func main() {
	r := mux.NewRouter()
	r.HandleFunc("/history", getHistory).Methods("GET")

	// Serve Swagger UI
	r.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)

	port := ":8081"
	log.Printf("Server starting on %s", port)
	log.Printf("Swagger UI available at http://localhost%s/swagger/", port)
	log.Fatal(http.ListenAndServe(port, r))
}
