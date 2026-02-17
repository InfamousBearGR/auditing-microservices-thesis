package middleware

import (
	"context"
	"log"
	"net/http"
	"strings"

	"history-api/database"
	"history-api/models"
)

// contextKey is a custom type for context keys to avoid collisions
type contextKey string

const (
	// UserContextKey is the key for storing user in context
	UserContextKey contextKey = "user"
)

// AuthMiddleware handles API key authentication
type AuthMiddleware struct {
	dbService *database.Service
}

// NewAuthMiddleware creates a new authentication middleware
func NewAuthMiddleware(dbService *database.Service) *AuthMiddleware {
	return &AuthMiddleware{
		dbService: dbService,
	}
}

// Authenticate validates the API key and attaches user to request context
func (m *AuthMiddleware) Authenticate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Extract API key from Authorization header
		apiKey := extractAPIKey(r)
		if apiKey == "" {
			http.Error(w, "Missing or invalid Authorization header. Use 'Bearer <api_key>'", http.StatusUnauthorized)
			return
		}

		// Validate API key and get user
		user, err := m.dbService.GetUserByAPIKey(apiKey)
		if err != nil {
			log.Println("Authentication error:", err)
			http.Error(w, "Invalid API key", http.StatusUnauthorized)
			return
		}

		// Add user to request context
		ctx := context.WithValue(r.Context(), UserContextKey, user)
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

// CheckTopicAccess validates that the authenticated user has access to the requested topic
func CheckTopicAccess(r *http.Request, topic string) bool {
	user, ok := r.Context().Value(UserContextKey).(*models.UserAccount)
	if !ok {
		return false
	}

	return user.HasAccessToTopic(topic)
}

// extractAPIKey extracts the API key from the Authorization header
// Expects format: "Bearer <api_key>" or just "<api_key>"
func extractAPIKey(r *http.Request) string {
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}

	// Check if it's in "Bearer <token>" format
	parts := strings.SplitN(authHeader, " ", 2)
	if len(parts) == 2 && strings.ToLower(parts[0]) == "bearer" {
		return strings.TrimSpace(parts[1])
	}

	// Otherwise, treat the entire header value as the API key
	return strings.TrimSpace(authHeader)
}
