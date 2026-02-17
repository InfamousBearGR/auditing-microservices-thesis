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

// TopicAccess represents the access permissions for different topics
type TopicAccess struct {
	Company     bool `json:"company"`
	Person      bool `json:"person"`
	LegalEntity bool `json:"legal_entity"`
	Member      bool `json:"member"`
}

// HasAccessToTopic checks if the user has access to a specific topic
func (u *UserAccount) HasAccessToTopic(topic string) bool {
	var access TopicAccess
	if err := json.Unmarshal(u.Access, &access); err != nil {
		return false
	}

	switch Topic(topic) {
	case TopicCompany:
		return access.Company
	case TopicPerson:
		return access.Person
	case TopicLegalEntity:
		return access.LegalEntity
	case TopicMember:
		return access.Member
	default:
		return false
	}
}
