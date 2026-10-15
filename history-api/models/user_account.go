package models

import "encoding/json"

// UserAccount represents a user account with API key and access permissions
type UserAccount struct {
	ID          int             `json:"id"`
	APIKey      string          `json:"api_key"`
	Access      json.RawMessage `json:"access"` // JSONB field storing topic access
	DateCreated string          `json:"date_created"`
	LastUpdated string          `json:"last_updated"`
}

// HasAccessToTopic checks if the user has access to a specific topic.
// The access JSONB maps table names to booleans, e.g. {"company": true, "person": false}
// — the same document the SSE Bridge checks, so one key grants the same tables in both.
func (u *UserAccount) HasAccessToTopic(topic string) bool {
	if !Topic(topic).IsValid() {
		return false
	}
	var access map[string]bool
	if err := json.Unmarshal(u.Access, &access); err != nil {
		return false
	}
	return access[topic]
}
