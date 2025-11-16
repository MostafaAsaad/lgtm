#!/bin/bash
# Start the monitoring stack

echo "Starting Monitoring Stack..."
docker compose up -d

echo ""
echo "Waiting for services to be ready..."
sleep 5

echo ""
echo "✓ Services started!"
echo ""
echo "Access points:"
echo "  - Grafana:    http://localhost:3000 (admin/admin)"
echo "  - Prometheus: http://localhost:9090"
echo "  - Loki:       http://localhost:3100"
echo ""
echo "To add a server, edit: prometheus/targets.json"
echo "Or use: ./add-server.sh <IP> <NAME> [ENV]"

