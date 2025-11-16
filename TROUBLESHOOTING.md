# Troubleshooting Guide

## No Data in Grafana Dashboard

### Step 1: Check if containers are running

```bash
# Check monitoring stack
cd "Monitor stack"
docker compose ps

# Check test server
cd ../test-server
docker compose ps
```

### Step 2: Verify Test Server is sending metrics

```bash
# Test if Telegraf is exposing metrics
curl http://localhost:9273/metrics
```

You should see Prometheus-formatted metrics. If not, the test-server isn't running.

### Step 3: Check Prometheus targets

Go to: http://localhost:9090/targets

Look for:
- ✅ Green = UP (working)
- ❌ Red = DOWN (not accessible)

### Step 4: Verify network connectivity

The test-server needs to be accessible from Prometheus. Options:

**Option A: Same Docker network (Recommended)**
- Test-server must connect to `monitor-stack_monitoring` network
- Use service name in targets.json: `"test-server:9273"`

**Option B: Host network**
- Test-server exposes port 9273 on host
- Use in targets.json: `"host.docker.internal:9273"` (Mac/Windows) or `"localhost:9273"` (Linux)

### Step 5: Check Grafana datasource

1. Go to Grafana: http://localhost:3000
2. Configuration → Data Sources
3. Click "Prometheus"
4. Click "Save & Test"
5. Should show green checkmark

### Common Issues

**Issue: "No data" in dashboard**
- Prometheus isn't scraping the server
- Check Prometheus targets page
- Verify server is in `targets.json`

**Issue: Server not in dropdown**
- Dashboard variable query might be wrong
- Check dashboard variable: `label_values(up{job="telegraf"}, server_name)`

**Issue: Can't connect to test-server**
- Test-server container not running
- Network not connected
- Port 9273 not exposed

