package models

// Topic represents valid audit topic types
type Topic string

const (
	// TopicCompany represents the company audit topic
	TopicCompany Topic = "company"
	// TopicPerson represents the person audit topic
	TopicPerson Topic = "person"
)

// IsValid checks if the topic is a valid enum value
func (t Topic) IsValid() bool {
	switch t {
	case TopicCompany, TopicPerson:
		return true
	}
	return false
}

// String returns the string representation of the topic
func (t Topic) String() string {
	return string(t)
}

// AllTopics returns all valid topic values
func AllTopics() []Topic {
	return []Topic{TopicCompany, TopicPerson}
}

// AllTopicStrings returns all valid topic values as strings
func AllTopicStrings() []string {
	return []string{string(TopicCompany), string(TopicPerson)}
}
