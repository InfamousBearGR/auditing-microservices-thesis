package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"history-api/database"
	"history-api/middleware"
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

// GetHistoryByDateRange godoc
// @Summary Get audit history for a specific date
// @Description Retrieves all audit entries for company changes on a specific date
// @Tags history
// @Accept json
// @Produce json
// @Param dateFrom query string true "Date in YYYY-MM-DD format" example(2026-02-10)
// @Param dateTo query string true "Date in YYYY-MM-DD format" example(2026-02-10)
// @Param topic query string true "Topic name" Enums(company, person, legal_entity, member, company_stocks, company_capital) example(company)
// @Security ApiKeyAuth
// @Success 200 {array} models.AuditEntry "Successfully retrieved audit entries"
// @Failure 400 {string} string "dateFrom parameter required"
// @Failure 401 {string} string "Unauthorized - Invalid API key"
// @Failure 403 {string} string "Forbidden - Access denied to topic"
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

	// Check if user has access to the requested topic
	if !middleware.CheckTopicAccess(r, topic) {
		respondWithError(w, http.StatusForbidden, "Access denied to topic: "+topic)
		return
	}

	// Stream the response as JSON array
	w.Header().Set("Content-Type", "application/json")
	encoder := json.NewEncoder(w)

	// Write the opening bracket
	if _, err := w.Write([]byte("[")); err != nil {
		log.Println("Error writing opening bracket:", err)
		return
	}

	first := true
	hasRows, err := h.dbService.StreamAuditEntriesByDate(dateFrom, dateTo, topic, func(entry *models.AuditEntry) error {
		// Add comma before subsequent entries
		if !first {
			if _, err := w.Write([]byte(",")); err != nil {
				return fmt.Errorf("error writing comma: %w", err)
			}
		}
		first = false

		// Encode and write the entry
		return encoder.Encode(entry)
	})

	// Write the closing bracket
	if _, err := w.Write([]byte("]")); err != nil {
		log.Println("Error writing closing bracket:", err)
		return
	}

	if err != nil {
		log.Println("Error streaming audit entries:", err)
		// Can't send error response after starting to write body
		return
	}

	if !hasRows {
		// Already wrote "[]", which is correct for empty result
		log.Println("No audit entries found for the specified date range")
	}
}

// GetHistoryByChangeIdRange godoc
// @Summary Get audit history for a specific change_id range
// @Description Retrieves all audit entries within a specific change_id range
// @Tags history
// @Accept json
// @Produce json
// @Param changeIdFrom query integer true "Starting change_id (inclusive)" example(1)
// @Param changeIdTo query integer true "Ending change_id (inclusive)" example(100)
// @Param topic query string true "Topic name" Enums(company, person, legal_entity, member, company_stocks, company_capital) example(company)
// @Security ApiKeyAuth
// @Success 200 {array} models.AuditEntry "Successfully retrieved audit entries"
// @Failure 400 {string} string "changeIdFrom parameter required or invalid"
// @Failure 401 {string} string "Unauthorized - Invalid API key"
// @Failure 403 {string} string "Forbidden - Access denied to topic"
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

	// Check if user has access to the requested topic
	if !middleware.CheckTopicAccess(r, topic) {
		respondWithError(w, http.StatusForbidden, "Access denied to topic: "+topic)
		return
	}

	// Stream the response as JSON array
	w.Header().Set("Content-Type", "application/json")
	encoder := json.NewEncoder(w)

	// Write the opening bracket
	if _, err := w.Write([]byte("[")); err != nil {
		log.Println("Error writing opening bracket:", err)
		return
	}

	first := true
	hasRows, err := h.dbService.StreamAuditEntriesByChangeIdRange(changeIdFrom, changeIdTo, topic, func(entry *models.AuditEntry) error {
		// Add comma before subsequent entries
		if !first {
			if _, err := w.Write([]byte(",")); err != nil {
				return fmt.Errorf("error writing comma: %w", err)
			}
		}
		first = false

		// Encode and write the entry
		return encoder.Encode(entry)
	})

	// Write the closing bracket
	if _, err := w.Write([]byte("]")); err != nil {
		log.Println("Error writing closing bracket:", err)
		return
	}

	if err != nil {
		log.Println("Error streaming audit entries:", err)
		// Can't send error response after starting to write body
		return
	}

	if !hasRows {
		// Already wrote "[]", which is correct for empty result
		log.Println("No audit entries found for the specified change_id range")
	}
}
