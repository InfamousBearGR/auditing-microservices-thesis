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

	"github.com/apache/arrow/go/v18/arrow"
	"github.com/apache/arrow/go/v18/arrow/array"
	"github.com/apache/arrow/go/v18/arrow/memory"
	"github.com/apache/arrow/go/v18/parquet"
	"github.com/apache/arrow/go/v18/parquet/compress"
	"github.com/apache/arrow/go/v18/parquet/pqarrow"
)

// ParquetHandler handles Parquet export requests
type ParquetHandler struct {
	dbService *database.Service
}

// NewParquetHandler creates a new parquet handler
func NewParquetHandler(dbService *database.Service) *ParquetHandler {
	return &ParquetHandler{
		dbService: dbService,
	}
}

// buildArrowSchema creates the Arrow schema for audit entries
func buildArrowSchema() *arrow.Schema {
	return arrow.NewSchema(
		[]arrow.Field{
			{Name: "id", Type: arrow.PrimitiveTypes.Int32, Nullable: false},
			{Name: "before", Type: arrow.BinaryTypes.String, Nullable: true},
			{Name: "after", Type: arrow.BinaryTypes.String, Nullable: true},
			{Name: "operation_type", Type: arrow.BinaryTypes.String, Nullable: false},
			{Name: "changed_at", Type: arrow.BinaryTypes.String, Nullable: false},
			{Name: "parent_id", Type: arrow.PrimitiveTypes.Int32, Nullable: false},
			{Name: "change_id", Type: arrow.BinaryTypes.String, Nullable: false},
			{Name: "change_reason", Type: arrow.BinaryTypes.String, Nullable: false},
		},
		nil,
	)
}

// writeParquetFileStreaming writes audit entries to a Parquet file using streaming
func (h *ParquetHandler) writeParquetFileStreaming(w http.ResponseWriter, streamFunc func(func(*models.AuditEntry) error) (bool, error)) error {
	pool := memory.NewGoAllocator()
	schema := buildArrowSchema()

	// Write Parquet file to response
	props := parquet.NewWriterProperties(
		parquet.WithCompression(compress.Codecs.Snappy),
		parquet.WithDictionaryDefault(true),
	)

	writer, err := pqarrow.NewFileWriter(schema, w, props, pqarrow.DefaultWriterProps())
	if err != nil {
		return fmt.Errorf("failed to create parquet writer: %w", err)
	}
	defer func() {
		if err := writer.Close(); err != nil {
			log.Println("Error closing parquet writer:", err)
		}
	}()

	// Create Arrow record builders
	builder := array.NewRecordBuilder(pool, schema)
	defer builder.Release()

	const batchSize = 1000 // Write records in batches of 1000
	currentBatchSize := 0
	hasData := false

	// Callback function to process each entry
	callback := func(entry *models.AuditEntry) error {
		hasData = true

		builder.Field(0).(*array.Int32Builder).Append(int32(entry.ID))

		// Handle nullable Before field
		if entry.Before != nil {
			beforeJSON, _ := json.Marshal(entry.Before)
			builder.Field(1).(*array.StringBuilder).Append(string(beforeJSON))
		} else {
			builder.Field(1).(*array.StringBuilder).AppendNull()
		}

		// Handle nullable After field
		if entry.After != nil {
			afterJSON, _ := json.Marshal(entry.After)
			builder.Field(2).(*array.StringBuilder).Append(string(afterJSON))
		} else {
			builder.Field(2).(*array.StringBuilder).AppendNull()
		}

		builder.Field(3).(*array.StringBuilder).Append(entry.OperationType)
		builder.Field(4).(*array.StringBuilder).Append(entry.ChangedAt)
		builder.Field(5).(*array.Int32Builder).Append(int32(entry.ParentID))
		builder.Field(6).(*array.StringBuilder).Append(entry.ChangeID)
		builder.Field(7).(*array.StringBuilder).Append(entry.ChangeReason)

		currentBatchSize++

		// Write batch when it reaches the batch size
		if currentBatchSize >= batchSize {
			rec := builder.NewRecord()
			if err := writer.Write(rec); err != nil {
				rec.Release()
				return fmt.Errorf("failed to write record batch: %w", err)
			}
			rec.Release()
			currentBatchSize = 0
		}

		return nil
	}

	// Stream data from database
	foundData, err := streamFunc(callback)
	if err != nil {
		return fmt.Errorf("streaming error: %w", err)
	}

	if !foundData && !hasData {
		return fmt.Errorf("no data found")
	}

	// Write any remaining records in the final batch
	if currentBatchSize > 0 {
		rec := builder.NewRecord()
		if err := writer.Write(rec); err != nil {
			rec.Release()
			return fmt.Errorf("failed to write final record batch: %w", err)
		}
		rec.Release()
	}

	return nil
}

// ExportHistoryByDateRangeParquet godoc
// @Summary Export audit history as Parquet file by date range
// @Description Downloads audit entries for a date range as a Parquet file (optimized for high-volume data)
// @Tags export
// @Accept json
// @Produce application/octet-stream
// @Param dateFrom query string true "Date in YYYY-MM-DD format" example(2026-02-10)
// @Param dateTo query string true "Date in YYYY-MM-DD format" example(2026-02-10)
// @Param topic query string true "Topic name" Enums(company, person, legal_entity, member) example(company)
// @Security ApiKeyAuth
// @Success 200 {file} binary "Parquet file download"
// @Failure 400 {string} string "dateFrom parameter required"
// @Failure 401 {string} string "Unauthorized - Invalid API key"
// @Failure 403 {string} string "Forbidden - Access denied to topic"
// @Failure 404 {string} string "No audit entries found"
// @Failure 500 {string} string "Error generating Parquet file"
// @Router /exportHistoryByDateRange [get]
func (h *ParquetHandler) ExportHistoryByDateRangeParquet(w http.ResponseWriter, r *http.Request) {
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

	// Set headers for Parquet file download
	filename := fmt.Sprintf("%s_audit_%s_to_%s.parquet", topic, dateFrom, dateTo)
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))

	// Create streaming function
	streamFunc := func(callback func(*models.AuditEntry) error) (bool, error) {
		return h.dbService.StreamAuditEntriesByDate(dateFrom, dateTo, topic, callback)
	}

	// Write Parquet file using streaming
	if err := h.writeParquetFileStreaming(w, streamFunc); err != nil {
		if err.Error() == "no data found" {
			// Headers already written, can't send proper error response
			log.Printf("No audit entries found for date range %s to %s", dateFrom, dateTo)
			return
		}
		log.Println("Error writing Parquet file:", err)
		// Can't send error after headers are written
		return
	}

	log.Printf("Successfully exported entries to Parquet file: %s", filename)
}

// ExportHistoryByChangeIdRangeParquet godoc
// @Summary Export audit history as Parquet file by change ID range
// @Description Downloads audit entries for a change ID range as a Parquet file (optimized for high-volume data)
// @Tags export
// @Accept json
// @Produce application/octet-stream
// @Param changeIdFrom query integer true "Starting change_id (inclusive)" example(1)
// @Param changeIdTo query integer true "Ending change_id (inclusive)" example(100)
// @Param topic query string true "Topic name" Enums(company, person, legal_entity, member) example(company)
// @Security ApiKeyAuth
// @Success 200 {file} binary "Parquet file download"
// @Failure 400 {string} string "changeIdFrom parameter required"
// @Failure 401 {string} string "Unauthorized - Invalid API key"
// @Failure 403 {string} string "Forbidden - Access denied to topic"
// @Failure 404 {string} string "No audit entries found"
// @Failure 500 {string} string "Error generating Parquet file"
// @Router /exportHistoryByChangeIdRange [get]
func (h *ParquetHandler) ExportHistoryByChangeIdRangeParquet(w http.ResponseWriter, r *http.Request) {
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

	// Set headers for Parquet file download
	filename := fmt.Sprintf("%s_audit_changes_%d_to_%d.parquet", topic, changeIdFrom, changeIdTo)
	w.Header().Set("Content-Type", "application/octet-stream")
	w.Header().Set("Content-Disposition", fmt.Sprintf("attachment; filename=%s", filename))

	// Create streaming function
	streamFunc := func(callback func(*models.AuditEntry) error) (bool, error) {
		return h.dbService.StreamAuditEntriesByChangeIdRange(changeIdFrom, changeIdTo, topic, callback)
	}

	// Write Parquet file using streaming
	if err := h.writeParquetFileStreaming(w, streamFunc); err != nil {
		if err.Error() == "no data found" {
			// Headers already written, can't send proper error response
			log.Printf("No audit entries found for change_id range %d to %d", changeIdFrom, changeIdTo)
			return
		}
		log.Println("Error writing Parquet file:", err)
		// Can't send error after headers are written
		return
	}

	log.Printf("Successfully exported entries to Parquet file: %s", filename)
}
