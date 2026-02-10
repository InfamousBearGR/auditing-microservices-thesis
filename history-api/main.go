package main

import (
	"log"
	"net/http"

	_ "history-api/docs"

	"history-api/config"
	"history-api/database"
	"history-api/handlers"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	httpSwagger "github.com/swaggo/http-swagger"
)

// @title Company History API
// @version 1.0
// @description Get audit logs for company changes from auditDb
// @host localhost:8081
// @BasePath /
func main() {
	// Load configuration
	config.Load()

	// Initialize database service
	dbService := database.NewService()

	// Initialize handlers
	historyHandler := handlers.NewHistoryHandler(dbService)

	// Setup router
	r := mux.NewRouter()
	r.HandleFunc("/getHistoryByDateRange", historyHandler.GetHistoryByDateRange).Methods("GET")
	r.HandleFunc("/getHistoryByChangeIdRange", historyHandler.GetHistoryByChangeIdRange).Methods("GET")

	// Serve Swagger UI
	r.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)

	port := ":8081"
	log.Printf("Server starting on %s", port)
	log.Printf("Swagger UI available at http://localhost%s/swagger/", port)
	log.Fatal(http.ListenAndServe(port, r))
}
