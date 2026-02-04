#!/bin/bash
# Script to rebuild and restart only the audit-consumer service
# This is faster than rebuilding the entire stack
set -e  # Exit on error

echo "=========================================="
echo "Rebuilding audit-consumer service..."
echo "=========================================="

echo ""
echo "Stopping audit-consumer container..."
docker-compose stop audit-consumer

echo ""
echo "Removing audit-consumer container..."
docker-compose rm -f audit-consumer

echo ""
echo "Building audit-consumer (no cache)..."
docker-compose build --no-cache audit-consumer

echo ""
echo "Starting audit-consumer..."
docker-compose up -d audit-consumer

echo ""
echo "=========================================="
echo "Waiting for service to start..."
echo "=========================================="
sleep 3

echo ""
echo "=========================================="
echo "audit-consumer Status:"
echo "=========================================="
docker-compose ps audit-consumer

echo ""
echo "=========================================="
echo "✅ audit-consumer rebuilt and restarted!"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose logs -f audit-consumer"
echo "  - Restart: docker-compose restart audit-consumer"
echo "  - Stop: docker-compose stop audit-consumer"
echo ""
