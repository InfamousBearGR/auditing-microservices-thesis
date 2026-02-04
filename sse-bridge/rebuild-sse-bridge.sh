#!/bin/bash
set -e  # Exit on error

# Script to rebuild and restart only the sse-bridge service
# This is faster than rebuilding the entire stack

echo "=========================================="
echo "Rebuilding sse-bridge service..."
echo "=========================================="

echo ""
echo "Stopping sse-bridge container..."
docker-compose stop sse-bridge

echo ""
echo "Removing sse-bridge container..."
docker-compose rm -f sse-bridge

echo ""
echo "Building sse-bridge (no cache)..."
docker-compose build --no-cache sse-bridge

echo ""
echo "Starting sse-bridge..."
docker-compose up -d sse-bridge

echo ""
echo "=========================================="
echo "Waiting for service to start..."
echo "=========================================="
sleep 3

echo ""
echo "=========================================="
echo "sse-bridge Status:"
echo "=========================================="
docker-compose ps sse-bridge

echo ""
echo "=========================================="
echo "✅ sse-bridge rebuilt and restarted!"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose logs -f sse-bridge"
echo "  - Restart: docker-compose restart sse-bridge"
echo "  - Stop: docker-compose stop sse-bridge"
