# Quick Start Guide

## 1. Start Monitoring Stack

```bash
cd "Monitor stack"
docker compose up -d
```

Wait ~10 seconds for services to start, then access:
- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100

## 2. Start Test Server

```bash
cd ../test-server
docker compose up -d
```

The test server will automatically appear in Prometheus within 30 seconds.

## 3. Add Production Servers

Edit `prometheus/targets.json` and add:

```json
{
  "targets": ["<IP>:9273"],
  "labels": {
    "server_name": "my-server",
    "server_ip": "<IP>",
    "environment": "production"
  }
}
```

**That's it!** Prometheus auto-reloads every 30 seconds.

## 4. View in Grafana

1. Go to http://localhost:3000
2. Login (admin/admin)
3. Go to Dashboards → System Overview
4. Select server from dropdown

## Troubleshooting

- **Server not appearing?** Check Prometheus targets: http://localhost:9090/targets
- **No metrics?** Verify Telegraf is running on the server: `curl http://<IP>:9273/metrics`
- **Network issues?** Ensure firewall allows port 9273

