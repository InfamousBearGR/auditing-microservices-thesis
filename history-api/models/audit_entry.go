package models

// AuditEntry represents a row in TimescaleDB
type AuditEntry struct {
	ID            int         `json:"id"`                                    // Identifier for the audit entry
	Before        interface{} `json:"before,omitempty" swaggertype:"object"` // Can be null for CREATE operations
	After         interface{} `json:"after,omitempty" swaggertype:"object"`  // Can be null for DELETE operations
	OperationType string      `json:"operation_type"`                        // e.g., "INSERT", "UPDATE", "DELETE"
	ChangedAt     string      `json:"changed_at"`                            // Date of change in ISO 8601 format
	ParentID      int         `json:"parent_id"`                             // ID of the topic record that was changed
	ChangeID      string      `json:"change_id"`                             // Unique identifier for the change, useful for tracing related changes
	ChangeReason  string      `json:"change_reason"`                         // Field to capture the reason for the change
}
