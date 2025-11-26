# Thanos & Loki S3 Storage Setup Guide

## Overview
- **Thanos**: Stores Prometheus metrics in S3 for long-term retention
- **Loki**: Stores logs in S3 (already supports S3 natively)

## Prerequisites
- AWS S3 bucket (or S3-compatible storage like MinIO)
- AWS credentials (Access Key ID and Secret Access Key)
- S3 bucket name

## 1. Thanos Setup for Prometheus Metrics

### Architecture
- **Prometheus**: Continues to scrape and store metrics locally (short-term)
- **Thanos Sidecar**: Uploads Prometheus blocks to S3
- **Thanos Store**: Queries historical data from S3
- **Thanos Query**: Aggregates queries from Prometheus + S3

### Step 1: Create Thanos configuration

Create `thanos/thanos-config.yml`:
```yaml
type: S3
config:
  bucket: your-bucket-name
  endpoint: s3.amazonaws.com  # or your S3-compatible endpoint
  region: us-east-1
  access_key: YOUR_ACCESS_KEY
  secret_key: YOUR_SECRET_KEY
  insecure: false
  signature_version2: false
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 0s
    insecure_skip_verify: false
  trace:
    enable: false
```

### Step 2: Update docker-compose.yml

Add these services to your `docker-compose.yml`:

```yaml
  # Thanos Sidecar - uploads Prometheus data to S3
  thanos-sidecar:
    image: quay.io/thanos/thanos:v0.32.5
    container_name: thanos-sidecar
    restart: unless-stopped
    volumes:
      - ./storage/prometheus:/var/prometheus:ro
      - ./thanos/thanos-config.yml:/etc/thanos/storage.yml:ro
    command:
      - sidecar
      - --prometheus.url=http://prometheus:9090
      - --tsdb.path=/var/prometheus
      - --objstore.config-file=/etc/thanos/storage.yml
      - --shipper.upload-compacted
    networks:
      - monitoring
    depends_on:
      - prometheus

  # Thanos Store - queries historical data from S3
  thanos-store:
    image: quay.io/thanos/thanos:v0.32.5
    container_name: thanos-store
    restart: unless-stopped
    volumes:
      - ./thanos/thanos-config.yml:/etc/thanos/storage.yml:ro
    command:
      - store
      - --objstore.config-file=/etc/thanos/storage.yml
      - --data-dir=/var/thanos/store
      - --grpc-address=0.0.0.0:10901
      - --http-address=0.0.0.0:10902
      - --index-cache-size=250MB
      - --sync-block-duration=5m
    networks:
      - monitoring

  # Thanos Query - aggregates Prometheus + S3 queries
  thanos-query:
    image: quay.io/thanos/thanos:v0.32.5
    container_name: thanos-query
    restart: unless-stopped
    command:
      - query
      - --http-address=0.0.0.0:10903
      - --query.replica-label=prometheus_replica
      - --store=prometheus:10901
      - --store=thanos-store:10901
    networks:
      - monitoring
    depends_on:
      - prometheus
      - thanos-sidecar
      - thanos-store
```

### Step 3: Update Prometheus configuration

Update `prometheus/prometheus.yml` to add external labels:
```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'monitoring'
    environment: 'production'
    prometheus_replica: 'prometheus-0'  # Required for Thanos
```

### Step 4: Update Nginx configuration

Add Thanos Query to `nginx/nginx.conf`:
```nginx
location /thanos/ {
    proxy_pass http://thanos-query:10903/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```

## 2. Loki S3 Storage Setup

### Update Loki configuration

Update `loki/loki-config.yml` to use S3:

```yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

common:
  instance_addr: 127.0.0.1
  path_prefix: /loki
  storage:
    s3:
      bucketnames: your-loki-bucket-name
      endpoint: s3.amazonaws.com
      region: us-east-1
      access_key_id: YOUR_ACCESS_KEY
      secret_access_key: YOUR_SECRET_KEY
      insecure: false
      s3forcepathstyle: false
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory

schema_config:
  configs:
    - from: 2020-10-24
      store: tsdb
      object_store: s3
      schema: v13
      index:
        prefix: index_
        period: 24h

compactor:
  working_directory: /loki/compactor
  shared_store: s3
  compaction_interval: 10m
  retention_enabled: true
  retention_delete_delay: 2h
  retention_delete_worker_count: 150

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s
```

## 3. Environment Variables (Alternative)

Instead of hardcoding credentials, use environment variables:

### For Thanos:
```yaml
environment:
  - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  - AWS_REGION=${AWS_REGION}
```

### For Loki:
```yaml
environment:
  - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
  - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
  - AWS_REGION=${AWS_REGION}
```

## 4. Security Best Practices

1. **Use IAM roles** instead of access keys when possible (if running on AWS)
2. **Store credentials in environment variables** or secrets management
3. **Use S3 bucket policies** to restrict access
4. **Enable S3 versioning** for data protection
5. **Enable S3 lifecycle policies** to manage costs (move old data to Glacier)

## 5. Cost Optimization

- **S3 Lifecycle Rules**: Move old data to cheaper storage classes
- **Compression**: Both Thanos and Loki compress data
- **Retention Policies**: Set appropriate retention periods
- **S3 Intelligent-Tiering**: Automatically move data to optimal storage class

## 6. Testing

1. Start services: `docker compose up -d`
2. Check Thanos sidecar logs: `docker logs thanos-sidecar`
3. Verify S3 uploads: Check your S3 bucket for blocks
4. Query Thanos: Access `http://localhost/thanos` via Nginx
5. Check Loki: Verify logs are being stored in S3 bucket

## 7. Grafana Integration

Add Thanos Query as a Prometheus datasource in Grafana:
- URL: `http://thanos-query:10903`
- Access: proxy
- This will give you access to both recent (Prometheus) and historical (S3) data






