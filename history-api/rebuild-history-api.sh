#!/bin/bash
# Script to rebuild and restart only the history-api service
# This is faster than rebuilding the entire stack
set -e  # Exit on error

echo "=========================================="
echo "Rebuilding history-api service..."
echo "=========================================="

echo ""
echo "Stopping history-api container..."
docker-compose stop history-api

echo ""
echo "Removing history-api container..."
docker-compose rm -f history-api

echo ""
echo "Building history-api (no cache)..."
docker-compose build --no-cache history-api

echo ""
echo "Starting history-api..."
docker-compose up -d history-api

echo ""
echo "=========================================="
echo "Waiting for service to start..."
echo "=========================================="
sleep 3

echo ""
echo "=========================================="
echo "history-api Status:"
echo "=========================================="
docker-compose ps history-api

echo ""
echo "=========================================="
echo "✅ history-api rebuilt and restarted!"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose logs -f history-api"
echo "  - Restart: docker-compose restart history-api"
echo "  - Stop: docker-compose stop history-api"
echo ""
