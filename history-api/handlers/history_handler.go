package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"history-api/database"
	"history-api/models"
)

// HistoryHandler handles history-related HTTP requests
type HistoryHandler struct {
	dbService *database.Service
}

// NewHistoryHandler creates a new history handler
func NewHistoryHandler(dbService *database.Service) *HistoryHandler {
	return &HistoryHandler{
		dbService: dbService,
	}
}

// validateTopic validates and returns the topic parameter from the request
func validateTopic(r *http.Request) (string, error) {
	topic := r.URL.Query().Get("topic")
	if topic == "" {
		return "", fmt.Errorf("topic parameter required")
	}

	// Validate topic using the Topic enum
	topicEnum := models.Topic(topic)
	if !topicEnum.IsValid() {
		return "", fmt.Errorf("topic parameter unrecognized")
	}

	return topic, nil
}

// respondWithError sends an error response with the given status code and message
func respondWithError(w http.ResponseWriter, statusCode int, message string) {
	http.Error(w, message, statusCode)
}

// respondWithJSON sends a JSON response with the given data
func respondWithJSON(w http.ResponseWriter, data interface{}) error {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Println("Error encoding response:", err)
		return err
	}
	return nil
}

// handleHistoryResponse handles the common response logic for history endpoints
func handleHistoryResponse(w http.ResponseWriter, history []models.AuditEntry, notFoundMessage string) {
	if len(history) == 0 {
		respondWithError(w, http.StatusNotFound, notFoundMessage)
		return
	}

	if err := respondWithJSON(w, history); err != nil {
		respondWithError(w, http.StatusInternalServerError, "Error encoding response")
	}
}

// GetHistoryByDateRange godoc
// @Summary Get audit history for a specific date
// @Description Retrieves all audit entries for company changes on a specific date
// @Tags history
// @Accept json
// @Produce json
// @Param dateFrom query string true "Date in YYYY-MM-DD format" example(2026-02-10)
// @Param dateTo query string true "Date in YYYY-MM-DD format" example(2026-02-10)
// @Param topic query string true "Topic name" Enums(company, person) example(company)
// @Success 200 {array} models.AuditEntry "Successfully retrieved audit entries"
// @Failure 400 {string} string "dateFrom parameter required"
// @Failure 404 {string} string "No audit entries found for the specified date range"
// @Failure 500 {string} string "Error fetching audit entries"
// @Router /getHistoryByDateRange [get]
func (h *HistoryHandler) GetHistoryByDateRange(w http.ResponseWriter, r *http.Request) {
	dateFrom := r.URL.Query().Get("dateFrom")
	if dateFrom == "" {
		respondWithError(w, http.StatusBadRequest, "dateFrom parameter required")
		return
	}

	if _, err := time.Parse("2006-01-02", dateFrom); err != nil {
		respondWithError(w, http.StatusBadRequest, "dateFrom must be in YYYY-MM-DD format")
		return
	}

	dateTo := r.URL.Query().Get("dateTo")
	if dateTo == "" {
		respondWithError(w, http.StatusBadRequest, "dateTo parameter required")
		return
	}

	if _, err := time.Parse("2006-01-02", dateTo); err != nil {
		respondWithError(w, http.StatusBadRequest, "dateTo must be in YYYY-MM-DD format")
		return
	}

	topic, err := validateTopic(r)
	if err != nil {
		respondWithError(w, http.StatusBadRequest, err.Error())
		return
	}

	history, err := h.dbService.GetAuditEntriesByDate(dateFrom, dateTo, topic)
	if err != nil {
		log.Println("Error fetching audit entries:", err)
		respondWithError(w, http.StatusInternalServerError, "Error fetching audit entries")
		return
	}

	handleHistoryResponse(w, history, "No audit entries found for the specified date range")
}

// GetHistoryByChangeIdRange godoc
// @Summary Get audit history for a specific change_id range
// @Description Retrieves all audit entries within a specific change_id range
// @Tags history
// @Accept json
// @Produce json
// @Param changeIdFrom query integer true "Starting change_id (inclusive)" example(1)
// @Param changeIdTo query integer true "Ending change_id (inclusive)" example(100)
// @Param topic query string true "Topic name" Enums(company, person) example(company)
// @Success 200 {array} models.AuditEntry "Successfully retrieved audit entries"
// @Failure 400 {string} string "changeIdFrom parameter required or invalid"
// @Failure 404 {string} string "No audit entries found for the specified change_id range"
// @Failure 500 {string} string "Error fetching audit entries"
// @Router /getHistoryByChangeIdRange [get]
func (h *HistoryHandler) GetHistoryByChangeIdRange(w http.ResponseWriter, r *http.Request) {
	changeIdFromStr := r.URL.Query().Get("changeIdFrom")
	if changeIdFromStr == "" {
		respondWithError(w, http.StatusBadRequest, "changeIdFrom parameter required")
		return
	}

	var changeIdFrom int64
	if _, err := fmt.Sscanf(changeIdFromStr, "%d", &changeIdFrom); err != nil {
		respondWithError(w, http.StatusBadRequest, "changeIdFrom must be a valid integer")
		return
	}

	changeIdToStr := r.URL.Query().Get("changeIdTo")
	if changeIdToStr == "" {
		respondWithError(w, http.StatusBadRequest, "changeIdTo parameter required")
		return
	}

	var changeIdTo int64
	if _, err := fmt.Sscanf(changeIdToStr, "%d", &changeIdTo); err != nil {
		respondWithError(w, http.StatusBadRequest, "changeIdTo must be a valid integer")
		return
	}

	if changeIdFrom > changeIdTo {
		respondWithError(w, http.StatusBadRequest, "changeIdFrom must be less than or equal to changeIdTo")
		return
	}

	topic, err := validateTopic(r)
	if err != nil {
		respondWithError(w, http.StatusBadRequest, err.Error())
		return
	}

	history, err := h.dbService.GetAuditEntriesByChangeIdRange(changeIdFrom, changeIdTo, topic)
	if err != nil {
		log.Println("Error fetching audit entries:", err)
		respondWithError(w, http.StatusInternalServerError, "Error fetching audit entries")
		return
	}

	handleHistoryResponse(w, history, "No audit entries found for the specified change_id range")
}
