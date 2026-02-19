#!/bin/bash
echo "Rebuilding business-registry..."
docker-compose build business-registry
docker-compose up -d business-registry
echo "business-registry rebuilt and restarted"

