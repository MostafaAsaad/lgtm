# Monitoring Stack

Complete monitoring solution with Prometheus, Grafana, Loki, supporting both Telegraf and Node Exporter.

## Architecture

- **Prometheus**: Metrics collection and storage
- **Grafana**: Visualization and dashboards
- **Loki**: Log aggregation
- **Promtail**: Log shipper for Loki
- **Telegraf**: Metrics agent (port 9273) - supported
- **Node Exporter**: Metrics agent (port 9100) - supported

## Quick Start

1. **Start the monitoring stack:**
   ```bash
   cd "Monitor stack"
   docker compose up -d
   ```

2. **Start test server:**
   ```bash
   cd ../test-server
   docker compose up -d
   ```

3. **Access services:**
   - Grafana: http://localhost:3000 (admin/admin)
   - Prometheus: http://localhost:9090
   - Loki: http://localhost:3100

## Adding New Servers

The stack supports both **Telegraf** (port 9273) and **Node Exporter** (port 9100).

### Method 1: Use the add-server script (Recommended)

```bash
./add-server.sh <SERVER_IP> <SERVER_NAME> <TYPE> [ENVIRONMENT]
```

**Type options:**
- `telegraf` - For servers running Telegraf (port 9273)
- `node-exporter` - For servers running Node Exporter (port 9100)

**Examples:**
```bash
# Add a Telegraf server
./add-server.sh 192.168.1.100 web-server-01 telegraf production

# Add a Node Exporter server
./add-server.sh 192.168.1.101 db-server-01 node-exporter production
```

Prometheus will automatically reload the configuration every 30 seconds.

### Method 2: Edit targets files manually

**For Telegraf servers**, edit `prometheus/targets-telegraf.json`:

```json
[
  {
    "targets": ["192.168.1.100:9273"],
    "labels": {
      "server_name": "web-server-01",
      "server_ip": "192.168.1.100",
      "environment": "production",
      "exporter_type": "telegraf"
    }
  }
]
```

**For Node Exporter servers**, edit `prometheus/targets-node-exporter.json`:

```json
[
  {
    "targets": ["192.168.1.101:9100"],
    "labels": {
      "server_name": "db-server-01",
      "server_ip": "192.168.1.101",
      "environment": "production",
      "exporter_type": "node-exporter"
    }
  }
]
```

## Server Requirements

Each server needs either:
- **Telegraf** running on port 9273, OR
- **Node Exporter** running on port 9100

Use the `test-server` as a template for Telegraf setup.

## Configuration Files

- `prometheus/prometheus.yml` - Prometheus configuration (rarely needs changes)
- `prometheus/targets-telegraf.json` - **Telegraf servers** (edit this to add Telegraf servers)
- `prometheus/targets-node-exporter.json` - **Node Exporter servers** (edit this to add Node Exporter servers)
- `loki/loki-config.yml` - Loki configuration
- `grafana/provisioning/` - Grafana datasources and dashboards (auto-provisioned)

## Dynamic Configuration

The stack is designed to be **highly dynamic**:

1. **Separate Configuration Files**: Telegraf and Node Exporter servers are in separate files
2. **Auto-Reload**: Prometheus automatically discovers new servers every 30 seconds
3. **No Restart Required**: Add servers without restarting any services
4. **Template-Based**: Use `test-server` as a template for Telegraf setup

## Server Setup

Each server needs:
1. Either Telegraf (port 9273) or Node Exporter (port 9100) running
2. Network access to the Prometheus server
3. Proper firewall rules (allow the appropriate port)

**For Telegraf servers**, use the `test-server` directory as a template.

**For Node Exporter servers**, install and run Node Exporter:
```bash
# Download and run Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
cd node_exporter-1.7.0.linux-amd64
./node_exporter
```

Or use Docker:
```bash
docker run -d --name node-exporter -p 9100:9100 prom/node-exporter
```

