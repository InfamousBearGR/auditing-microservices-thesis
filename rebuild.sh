#!/bin/bash
# Script to rebuild and restart all Docker services
# This will rebuild images from Dockerfiles and restart the entire stack
set -e  # Exit on error
echo "=========================================="
echo "Stopping and removing all containers..."
echo "=========================================="
docker-compose down -v
echo ""
echo "=========================================="
echo "Removing old images to force rebuild..."
echo "=========================================="
docker-compose rm -f
echo ""
echo "=========================================="
echo "Building all services (including Dockerfiles)..."
echo "=========================================="
docker-compose build --no-cache
echo ""
echo "=========================================="
echo "Starting all services..."
echo "=========================================="
docker-compose up -d
echo ""
echo "=========================================="
echo "Waiting for services to start..."
echo "=========================================="
sleep 5
echo ""
echo "=========================================="
echo "Service Status:"
echo "=========================================="
docker-compose ps
echo ""
echo "=========================================="
echo "✅ All services rebuilt and restarted!"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  - View logs: docker-compose logs -f"
echo "  - View specific service logs: docker-compose logs -f <service-name>"
echo "  - Stop all: docker-compose down"
echo "  - Stop all + remove volumes: docker-compose down -v"
echo ""
