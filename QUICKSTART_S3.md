# Quick Start Guide - S3 Storage Setup

## ✅ Prerequisites

1. **AWS Account** with S3 access
2. **S3 Bucket** named `observability` (or update `.env` with your bucket name)
3. **AWS Credentials** (Access Key ID and Secret Access Key)

## 🚀 Setup Steps

### Step 1: Configure AWS Credentials

Edit the `.env` file in the project root and replace the placeholder values:

```bash
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_REGION=us-east-1
S3_ENDPOINT=s3.amazonaws.com
S3_BUCKET=observability
```

### Step 2: Create S3 Bucket

Create an S3 bucket named `observability` (or use your preferred name and update `.env`):

**Via AWS Console:**
1. Go to S3 → Create bucket
2. Name: `observability`
3. Region: Match your `AWS_REGION` in `.env`
4. Create bucket

**Via AWS CLI:**
```bash
aws s3 mb s3://observability --region us-east-1
```

### Step 3: Set Bucket Permissions

Ensure your AWS credentials have these permissions:
- `s3:PutObject`
- `s3:GetObject`
- `s3:DeleteObject`
- `s3:ListBucket`

### Step 4: Start Services

```bash
docker compose up -d
```

### Step 5: Verify Setup

1. **Check Thanos Sidecar** (uploads metrics to S3):
   ```bash
   docker logs thanos-sidecar
   ```
   Look for: `msg="uploading block"`

2. **Check Loki** (stores logs in S3):
   ```bash
   docker logs loki
   ```
   Should show no S3 connection errors

3. **Check S3 Bucket**:
   - Go to AWS Console → S3 → `observability` bucket
   - You should see:
     - Thanos blocks (directories with timestamps)
     - Loki chunks and index files

4. **Access Thanos UI**:
   - Open: `http://localhost/thanos`
   - Check "Stores" tab - should show both Prometheus and S3 stores

## 📊 What's Stored in S3

### Thanos (Metrics)
- Prometheus time-series blocks
- Organized by time ranges
- Automatically uploaded every 2 hours

### Loki (Logs)
- Log chunks
- Index files
- Automatically compacted and managed

## 🔧 Troubleshooting

### Issue: "Access Denied" errors
**Solution:** Check AWS credentials and bucket permissions

### Issue: Thanos not uploading
**Solution:** 
```bash
docker logs thanos-sidecar
# Check for S3 connection errors
```

### Issue: Loki not storing logs
**Solution:**
```bash
docker logs loki
# Verify S3 bucket name and credentials
```

### Issue: Can't access Thanos UI
**Solution:** 
- Check Nginx: `docker logs nginx-proxy`
- Verify service is running: `docker ps | grep thanos-query`

## 🎯 Next Steps

1. **Add Thanos to Grafana:**
   - Grafana → Configuration → Data Sources
   - Add Prometheus datasource
   - URL: `http://thanos-query:10903`
   - This gives you access to historical metrics from S3

2. **Monitor S3 Costs:**
   - Set up S3 lifecycle rules to move old data to cheaper storage
   - Configure retention policies in Prometheus and Loki

3. **Backup:**
   - Your data is now in S3 - consider enabling versioning
   - Set up cross-region replication if needed

## 📝 Environment Variables Reference

| Variable | Description | Default |
|----------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS access key | Required |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | Required |
| `AWS_REGION` | AWS region | `us-east-1` |
| `S3_ENDPOINT` | S3 endpoint | `s3.amazonaws.com` |
| `S3_BUCKET` | S3 bucket name | `observability` |

## ✅ Verification Checklist

- [ ] `.env` file created with AWS credentials
- [ ] S3 bucket `observability` created
- [ ] AWS credentials have proper permissions
- [ ] Services started: `docker compose up -d`
- [ ] Thanos sidecar uploading blocks (check logs)
- [ ] Loki storing logs in S3 (check logs)
- [ ] Thanos UI accessible: `http://localhost/thanos`
- [ ] S3 bucket contains data (check AWS Console)





