# Prompt for AI Documentation/Presentation Generator

Use this prompt with another AI to generate comprehensive documentation or a PowerPoint presentation about the monitoring stack:

---

**PROMPT:**

Create a comprehensive technical documentation or PowerPoint presentation about a production-ready monitoring and observability stack. The stack is designed for the MOH (Ministry of Health) organization and includes the following components:

## Stack Overview

**Purpose:** Enterprise-grade monitoring, metrics collection, log aggregation, and visualization platform with long-term S3 storage integration.

**Architecture Type:** Docker Compose-based microservices architecture with reverse proxy.

## Core Components

### 1. **Prometheus** (v2.48.0)
- **Role:** Time-series metrics database and collection engine
- **Features:**
  - Scrapes metrics from multiple targets (Node Exporter, Telegraf)
  - Local storage with 45-minute retention (optimized for Thanos integration)
  - 15-minute block duration for efficient uploads
  - Lifecycle API enabled for configuration reloads
- **Storage:** Docker named volume (`prometheus-data`) for efficient hard links
- **Access:** Through Nginx reverse proxy only (no direct port exposure)

### 2. **Thanos Ecosystem** (v0.32.5)
Three components working together:

#### **Thanos Sidecar**
- **Role:** Uploads Prometheus blocks to S3 for long-term storage
- **Features:**
  - Monitors Prometheus TSDB for new blocks
  - Automatically uploads compacted blocks to AWS S3
  - Uses shared Docker volume with Prometheus for efficient hard links
  - Runs as root for proper file system permissions
- **Storage Backend:** AWS S3 (ap-south-1 region, bucket: adeaobserv)

#### **Thanos Store**
- **Role:** Queries historical data from S3
- **Features:**
  - Syncs blocks from S3 every 5 minutes
  - Maintains local index cache (250MB) for fast queries
  - Provides gRPC interface for querying historical data
- **Storage:** Local cache + S3 backend

#### **Thanos Query**
- **Role:** Unified query interface aggregating Prometheus + S3 data
- **Features:**
  - Queries both live Prometheus data and historical S3 data
  - Handles replica deduplication
  - Provides unified PromQL interface
  - Accessible via Nginx at `/thanos/` path
- **Endpoints:** Connects to Thanos Sidecar (live data) and Thanos Store (historical data)

### 3. **Loki** (v2.9.2)
- **Role:** Log aggregation system (Grafana Labs)
- **Features:**
  - Collects and stores logs from multiple sources
  - S3 backend for long-term log storage
  - Multi-tenant support (MOH tenant configured)
  - TSDB-based indexing for efficient queries
- **Storage:** Local WAL + S3 for long-term retention
- **Access:** Through Nginx reverse proxy

### 4. **Promtail** (v2.9.2)
- **Role:** Log shipper agent for Loki
- **Features:**
  - Collects logs from various sources
  - Ships logs to Loki for aggregation
  - Configurable scraping rules
- **Note:** Linux-specific paths commented out for Windows compatibility

### 5. **Grafana** (v10.2.2)
- **Role:** Visualization and dashboard platform
- **Features:**
  - Pre-provisioned dashboards (MOH folder with Linux Servers dashboard)
  - Connected to Prometheus, Loki, and Thanos Query as data sources
  - Dashboard auto-provisioning from `/storage/grafana/dashboards/MOH/`
  - Sub-path configuration for Nginx integration
- **Access:** Through Nginx at `/grafana/` path
- **Default Credentials:** admin/admin

### 6. **Nginx** (Alpine)
- **Role:** Reverse proxy and unified access point
- **Features:**
  - Single entry point for all services (ports 80/443)
  - Path-based routing:
    - `/prometheus/` → Prometheus
    - `/grafana/` → Grafana
    - `/thanos/` → Thanos Query UI
    - `/loki/` → Loki API
  - Handles WebSocket connections for real-time updates
  - Proper redirect handling and API routing
- **Security:** All backend services not directly exposed

## Architecture Highlights

### Data Flow:
1. **Metrics Collection:**
   - Node Exporter/Telegraf → Prometheus (scraping)
   - Prometheus stores locally (45min retention)
   - Prometheus creates blocks every 15 minutes
   - Thanos Sidecar uploads blocks to S3
   - Prometheus deletes old local data after retention period

2. **Query Flow:**
   - Recent queries (< 45min): Prometheus directly
   - Historical queries (> 45min): Thanos Store from S3
   - Unified view: Thanos Query aggregates both sources

3. **Log Flow:**
   - Promtail collects logs → Loki (local WAL)
   - Loki uploads to S3 for long-term storage
   - Grafana queries Loki for log visualization

### Storage Strategy:
- **Short-term:** Local Docker volumes (fast access)
- **Long-term:** AWS S3 (cost-effective, scalable)
- **Retention:** 
  - Prometheus local: 45 minutes
  - S3: Unlimited (configurable via lifecycle policies)

### Network Architecture:
- All services on isolated Docker bridge network (`monitoring`)
- Nginx as single entry point
- Internal service-to-service communication via service names
- No direct external access to backend services

## Key Features

1. **High Availability:** Thanos enables querying across time periods beyond local retention
2. **Cost Optimization:** Short local retention + S3 for long-term storage
3. **Scalability:** S3 backend supports unlimited data growth
4. **Unified Access:** Single Nginx entry point for all services
5. **Production Ready:** Proper security, lifecycle management, and monitoring
6. **Multi-tenant:** Loki configured for MOH tenant isolation

## Configuration Highlights

- **Prometheus Block Duration:** 15 minutes (test) / 2 hours (production recommended)
- **Prometheus Retention:** 45 minutes (test) / 6 hours (production recommended)
- **S3 Region:** ap-south-1 (Asia Pacific - Mumbai)
- **S3 Bucket:** adeaobserv
- **External Labels:** cluster=monitoring, environment=production, prometheus_replica=prometheus-0

## Access Points

- **Grafana Dashboards:** `http://localhost/grafana/`
- **Prometheus UI:** `http://localhost/prometheus/`
- **Thanos Query UI:** `http://localhost/thanos/`
- **Loki API:** `http://localhost/loki/`

## Technical Specifications

- **Container Orchestration:** Docker Compose
- **Volume Management:** Named volumes for data persistence
- **Service Dependencies:** Properly configured with health checks
- **Restart Policy:** `unless-stopped` for all services
- **Platform:** Windows-compatible (Linux paths commented out)

## Deployment

- Single command deployment: `docker compose up -d`
- All configurations in version control
- Environment variables for sensitive data (AWS credentials)
- Persistent storage for Grafana dashboards and configurations

---

**Please generate:**
1. A comprehensive technical documentation (Markdown format) OR
2. A professional PowerPoint presentation (10-15 slides) covering:
   - Architecture overview
   - Component details
   - Data flow diagrams
   - Storage strategy
   - Access and usage
   - Key benefits
   - Technical specifications

Include diagrams where appropriate and make it suitable for technical stakeholders and management presentations.

