# Test Server

Production-like test server with both Telegraf and Node Exporter for comprehensive monitoring.

## Services

- **Telegraf**: Exposes metrics on port 9273 (Telegraf format)
- **Node Exporter**: Exposes metrics on port 9100 (Prometheus format)

## Usage

```bash
# Start both exporters
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f
```

## Metrics Collected

### Telegraf (port 9273)
- CPU (per-core and total)
- Memory
- Disk usage and I/O
- Network interfaces
- System load average
- Processes
- Swap
- Docker containers (if available)
- Network statistics
- File system stats

### Node Exporter (port 9100)
- CPU metrics
- Memory metrics
- Disk metrics
- Network metrics
- System load average
- File system metrics
- Hardware metrics

## Configuration

Both exporters are automatically discovered by Prometheus:
- Telegraf: `test-server-telegraf:9273` (job: `telegraf`)
- Node Exporter: `test-server-node-exporter:9100` (job: `node-exporter`)

Configured in:
- `Monitor stack/prometheus/targets-telegraf.json`
- `Monitor stack/prometheus/targets-node-exporter.json`

## Testing

```bash
# Test Telegraf metrics
curl http://localhost:9273/metrics | grep system_load

# Test Node Exporter metrics
curl http://localhost:9100/metrics | grep node_load
```

## Dashboards

- **Telegraf**: Use "Healthplug - Linux Server" dashboard
- **Node Exporter**: Use "Linux Hosts Metrics | Base" dashboard
