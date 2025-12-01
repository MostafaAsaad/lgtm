#!/bin/sh
# Generate Thanos config from environment variables

cat > /etc/thanos/storage.yml <<EOF
type: S3
config:
  bucket: ${S3_BUCKET:-observability}
  endpoint: ${S3_ENDPOINT:-s3.amazonaws.com}
  region: ${AWS_REGION:-us-east-1}
  access_key: ${AWS_ACCESS_KEY_ID}
  secret_key: ${AWS_SECRET_ACCESS_KEY}
  insecure: false
  signature_version2: false
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 0s
    insecure_skip_verify: false
  trace:
    enable: false
EOF







