#!/bin/bash
# Script to watch for file changes and automatically rebuild affected Docker services
# Uses docker compose watch feature (Docker Compose v2.22+)
set -e  # Exit on error

echo "=========================================="
echo "Starting Docker Compose Watch Mode"
echo "=========================================="
echo ""
echo "This will monitor your files and automatically:"
echo "  - Rebuild services when source files change"
echo "  - Restart containers as needed"
echo ""
echo "Watching services:"
echo "  - sse-bridge (Kotlin/Spring)"
echo "  - history-api (Go)"
echo ""
echo "Press Ctrl+C to stop watching"
echo "=========================================="
echo ""

# First, ensure services are up
echo "Starting services..."
docker-compose up -d

echo ""
echo "Starting watch mode..."
echo "=========================================="
echo ""

# Start docker compose watch
docker compose watch
