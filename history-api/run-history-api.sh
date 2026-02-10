#!/bin/bash

# Change to the history-api directory
cd "$(dirname "$0")" || exit

# Install Air for hot reload
go install github.com/air-verse/air@latest

# Install swag CLI tool for Swagger generation
go install github.com/swaggo/swag/cmd/swag@latest

# Download Go dependencies
go mod download

# Generate Swagger documentation
swag init

# Run with hot reload
air