# S3 Setup Instructions

## Quick Start

1. **Create S3 Bucket:**
   - Create a single bucket called `observability` (or your preferred name)
   - Both Thanos metrics and Loki logs will be stored in this bucket

2. **Create `.env` file:**
   Create a `.env` file in the project root with your S3 credentials:

```bash
# AWS S3 Configuration
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
AWS_REGION=us-east-1

# S3 Endpoint (use s3.amazonaws.com for AWS, or your S3-compatible endpoint)
S3_ENDPOINT=s3.amazonaws.com

# S3 Bucket Name (shared by Thanos and Loki)
S3_BUCKET=observability
```

3. **Start the services:**
```bash
docker compose up -d
```

## What Was Configured

### Thanos (Prometheus Metrics to S3)
- **Thanos Sidecar**: Uploads Prometheus blocks to S3 every 2 hours
- **Thanos Store**: Queries historical data from S3
- **Thanos Query**: Aggregates queries from Prometheus + S3
- Access Thanos UI at: `http://localhost/thanos`

### Loki (Logs to S3)
- **Loki**: Now stores all logs in S3 instead of local filesystem
- Automatic compaction and retention management
- Access via Grafana (Loki datasource)

## Grafana Integration

To query historical metrics from S3 via Thanos:

1. Go to Grafana → Configuration → Data Sources
2. Add a new Prometheus datasource:
   - Name: `Thanos Query`
   - URL: `http://thanos-query:10903`
   - Access: Proxy
3. Use this datasource in your dashboards to access both recent (Prometheus) and historical (S3) data

## Verification

1. **Check Thanos Sidecar logs:**
   ```bash
   docker logs thanos-sidecar
   ```
   Look for "uploading block" messages

2. **Check S3 bucket:**
   - Verify blocks are being uploaded to your `observability` bucket (Thanos stores in root)
   - Verify logs are being stored in your `observability` bucket (Loki stores in different paths)

3. **Access Thanos UI:**
   - Visit `http://localhost/thanos`
   - Check "Stores" to see both Prometheus and S3 stores

## Troubleshooting

- **No data in S3?** Check AWS credentials and bucket permissions
- **Thanos not uploading?** Check `docker logs thanos-sidecar` for errors
- **Loki not storing?** Check `docker logs loki` for S3 connection errors

## Cost Optimization Tips

1. **S3 Lifecycle Rules**: Move old data to cheaper storage classes (Glacier)
2. **Retention Policies**: Configure retention in Prometheus and Loki configs
3. **Compression**: Both Thanos and Loki compress data automatically

