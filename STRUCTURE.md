# Monitoring Stack Structure

```
Monitor stack/
├── docker-compose.yml          # Main stack: Prometheus, Grafana, Loki, Promtail
├── prometheus/
│   ├── prometheus.yml          # Prometheus config (rarely edit)
│   └── targets.json            # ⭐ SINGLE FILE for all servers (edit this!)
├── grafana/
│   ├── provisioning/           # Auto-provisioned datasources & dashboards
│   └── dashboards/            # Custom dashboards
├── loki/
│   ├── loki-config.yml        # Loki configuration
│   └── promtail-config.yml    # Promtail configuration
├── telegraf/
│   └── telegraf.conf          # Telegraf template
├── add-server.sh              # Helper script to add servers
├── start.sh                   # Quick start script
├── README.md                  # Full documentation
└── QUICKSTART.md              # Quick reference

test-server/
├── docker-compose.yml         # Test server with Telegraf
├── telegraf.conf              # Telegraf config for test server
├── start.sh                   # Quick start script
└── README.md                  # Test server docs
```

## Key Features

✅ **Single Configuration Point**: All servers in `prometheus/targets.json`
✅ **Auto-Discovery**: Prometheus reloads every 30 seconds
✅ **No Restarts**: Add servers without restarting services
✅ **Template-Based**: Copy `test-server` for new servers
✅ **Complete Stack**: Metrics (Prometheus) + Logs (Loki) + Visualization (Grafana)

## Adding Servers

**Just edit one file**: `Monitor stack/prometheus/targets.json`

No need to edit:
- ❌ docker-compose.yml
- ❌ prometheus.yml
- ❌ Any other config files

