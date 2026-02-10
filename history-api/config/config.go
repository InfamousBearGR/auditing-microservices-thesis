package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

// Load loads environment variables from the appropriate .env file
func Load() {
	envFile := os.Getenv("ENV_FILE")
	if envFile == "" {
		envFile = ".env.dev" // Default to development
	}

	if err := godotenv.Load(envFile); err != nil {
		log.Printf("Warning: Error loading %s file: %v", envFile, err)
		log.Printf("Continuing with existing environment variables...")
	} else {
		log.Printf("Loaded environment from %s", envFile)
	}
}
