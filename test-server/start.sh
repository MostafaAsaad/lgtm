#!/bin/bash
# Start test server with both Telegraf and Node Exporter

echo "Starting Test Server..."
docker compose up -d

echo ""
echo "✓ Test server started!"
echo ""
echo "Services running:"
echo "  - Telegraf:      http://localhost:9273/metrics"
echo "  - Node Exporter: http://localhost:9100/metrics"
echo ""
echo "Make sure the monitoring stack is running first:"
echo "  cd ../Monitor\\ stack && docker compose up -d"
echo ""
echo "Both exporters will be automatically discovered by Prometheus within 30 seconds."
