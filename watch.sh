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
echo "  - sse-bridge (Groovy/Spring)"
echo "  - history-api (Go)"
echo "  - audit-consumer (Groovy)"
echo ""
echo "Press Ctrl+C to stop watching"
echo "=========================================="
echo ""

# Start docker compose watch with build
docker compose -f docker-compose.dev.yml watch
