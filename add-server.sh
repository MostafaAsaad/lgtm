#!/bin/bash
# Script to add a new server to monitoring
# Usage: ./add-server.sh <SERVER_IP> <SERVER_NAME> <TYPE> [ENVIRONMENT]
# TYPE: 'telegraf' or 'node-exporter'

if [ $# -lt 3 ]; then
    echo "Usage: $0 <SERVER_IP> <SERVER_NAME> <TYPE> [ENVIRONMENT]"
    echo "  TYPE: 'telegraf' (port 9273) or 'node-exporter' (port 9100)"
    echo "Example: $0 192.168.1.100 web-server-01 telegraf production"
    echo "Example: $0 192.168.1.101 db-server-01 node-exporter production"
    exit 1
fi

SERVER_IP=$1
SERVER_NAME=$2
TYPE=$3
ENVIRONMENT=${4:-production}

# Validate type
if [ "$TYPE" != "telegraf" ] && [ "$TYPE" != "node-exporter" ]; then
    echo "Error: TYPE must be 'telegraf' or 'node-exporter'"
    exit 1
fi

# Set port and targets file based on type
if [ "$TYPE" = "telegraf" ]; then
    PORT=9273
    TARGETS_FILE="prometheus/targets-telegraf.json"
else
    PORT=9100
    TARGETS_FILE="prometheus/targets-node-exporter.json"
fi

# Create backup
cp "$TARGETS_FILE" "${TARGETS_FILE}.bak"

# Add new server entry
python3 << EOF
import json
import sys

with open('$TARGETS_FILE', 'r') as f:
    targets = json.load(f)

# Check if server already exists
for target in targets:
    if target['labels'].get('server_name') == '$SERVER_NAME':
        print(f"Error: Server '$SERVER_NAME' already exists!")
        sys.exit(1)

# Add new server
new_server = {
    "targets": ["$SERVER_IP:$PORT"],
    "labels": {
        "server_name": "$SERVER_NAME",
        "server_ip": "$SERVER_IP",
        "environment": "$ENVIRONMENT",
        "exporter_type": "$TYPE"
    }
}

targets.append(new_server)

with open('$TARGETS_FILE', 'w') as f:
    json.dump(targets, f, indent=2)

print(f"✓ Added server: $SERVER_NAME ($SERVER_IP)")
print(f"  Type: $TYPE (port $PORT)")
print(f"  Prometheus will auto-reload in 30 seconds")
EOF

