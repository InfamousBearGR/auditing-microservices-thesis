package main

import (
	"log"
	"net/http"

	_ "history-api/docs"

	"history-api/config"
	"history-api/database"
	"history-api/handlers"
	"history-api/middleware"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
	httpSwagger "github.com/swaggo/http-swagger"
)

// @title Company History API
// @version 1.0
// @description Get audit logs for company changes from auditDb
// @host localhost:8081
// @BasePath /
// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization
// @description Enter your API key in the format: Bearer <api_key>
func main() {
	// Load configuration
	config.Load()

	// Initialize database service
	dbService := database.NewService()

	// Initialize handlers
	historyHandler := handlers.NewHistoryHandler(dbService)
	parquetHandler := handlers.NewParquetHandler(dbService)

	// Initialize middleware
	authMiddleware := middleware.NewAuthMiddleware(dbService)

	// Setup router
	r := mux.NewRouter()

	// Create a subrouter for authenticated routes
	apiRouter := r.PathPrefix("/").Subrouter()
	apiRouter.Use(authMiddleware.Authenticate)

	// JSON streaming endpoints (existing)
	apiRouter.HandleFunc("/getHistoryByDateRange", historyHandler.GetHistoryByDateRange).Methods("GET")
	apiRouter.HandleFunc("/getHistoryByChangeIdRange", historyHandler.GetHistoryByChangeIdRange).Methods("GET")

	// Parquet export endpoints (new - optimized for high-volume downloads)
	apiRouter.HandleFunc("/exportHistoryByDateRange", parquetHandler.ExportHistoryByDateRangeParquet).Methods("GET")
	apiRouter.HandleFunc("/exportHistoryByChangeIdRange", parquetHandler.ExportHistoryByChangeIdRangeParquet).Methods("GET")

	// Serve Swagger UI (no authentication required)
	r.PathPrefix("/swagger/").Handler(httpSwagger.WrapHandler)

	port := ":8081"
	log.Printf("Server starting on %s", port)
	log.Printf("Swagger UI available at http://localhost%s/swagger/", port)
	log.Fatal(http.ListenAndServe(port, r))
}
