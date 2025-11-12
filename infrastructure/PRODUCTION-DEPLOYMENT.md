# Production Deployment Guide - Hetzner AX 43

Complete guide for deploying the Hosting Panel to production on Hetzner AX 43 using systemd.

---

## 📋 Table of Contents

- [Server Specifications](#server-specifications)
- [Prerequisites](#prerequisites)
- [Initial Server Setup](#initial-server-setup)
- [Install Dependencies](#install-dependencies)
- [Database Setup](#database-setup)
- [Application Deployment](#application-deployment)
- [NGINX Configuration](#nginx-configuration)
- [SSL Certificates](#ssl-certificates)
- [Monitoring Setup](#monitoring-setup)
- [Backup Configuration](#backup-configuration)
- [Security Hardening](#security-hardening)
- [Post-Deployment Checklist](#post-deployment-checklist)

---

## 🖥️ Server Specifications

**Hetzner AX 43**:
- **CPU**: AMD Ryzen 7 3700X (8 cores / 16 threads)
- **RAM**: 64 GB DDR4 ECC
- **Storage**: 2x 512 GB NVMe SSD (RAID 1)
- **Network**: 1 Gbit/s connection
- **OS**: Ubuntu 22.04 LTS (recommended)
- **Cost**: €49-59/month

**Capacity**:
- Can host 500-1000+ customer websites
- Handles 10,000+ req/s with proper optimization

---

## ✅ Prerequisites

Before starting deployment:

- [ ] AX 43 server provisioned and accessible
- [ ] Root SSH access configured
- [ ] Domain name pointing to server IP
- [ ] GitHub repository access
- [ ] Stripe API keys (for billing)
- [ ] SMTP credentials (for emails)

---

## 🚀 Initial Server Setup

### 1. Connect to Server

```bash
ssh root@your-server-ip
```

### 2. Update System

```bash
apt update && apt upgrade -y
apt install -y curl wget git build-essential
```

### 3. Set Hostname

```bash
hostnamectl set-hostname hosting-panel.yourdomain.com
echo "127.0.0.1 hosting-panel.yourdomain.com" >> /etc/hosts
```

### 4. Configure Firewall

```bash
# Install UFW
apt install -y ufw

# Allow SSH (IMPORTANT: Do this first!)
ufw allow 22/tcp

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Block direct access to backend services
ufw deny 8080:8084/tcp

# Enable firewall
ufw --force enable

# Check status
ufw status verbose
```

### 5. Create Application User

```bash
# Create hosting user
useradd -r -m -s /bin/bash -d /opt/hosting-panel hosting

# Add to sudo group (for provisioning tasks)
usermod -aG sudo hosting

# Create SSH key for deployment
sudo -u hosting ssh-keygen -t ed25519 -C "hosting@ax43"
```

### 6. Set Up Swap (Optional but Recommended)

```bash
# Create 8GB swap
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Verify
free -h
```

---

## 📦 Install Dependencies

### 1. PostgreSQL 16

```bash
# Add PostgreSQL repository
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list

# Install PostgreSQL
apt update
apt install -y postgresql-16 postgresql-contrib-16

# Start and enable
systemctl start postgresql
systemctl enable postgresql

# Check status
systemctl status postgresql
```

### 2. Redis 7.2

```bash
# Add Redis repository
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list

# Install Redis
apt update
apt install -y redis

# Configure Redis
sed -i 's/^# requirepass.*/requirepass your-strong-redis-password/' /etc/redis/redis.conf
sed -i 's/^bind 127.0.0.1/bind 127.0.0.1/' /etc/redis/redis.conf

# Restart Redis
systemctl restart redis
systemctl enable redis

# Check status
systemctl status redis
```

### 3. NGINX 1.26

```bash
# Install NGINX
apt install -y nginx

# Start and enable
systemctl start nginx
systemctl enable nginx

# Check status
systemctl status nginx
```

### 4. Node.js 20 (for Next.js)

```bash
# Install Node.js 20 via NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verify
node --version
npm --version
```

### 5. Certbot (for SSL)

```bash
# Install Certbot
apt install -y certbot python3-certbot-nginx

# Verify
certbot --version
```

### 6. Monitoring Tools

```bash
# Install Prometheus Node Exporter
apt install -y prometheus-node-exporter

# Install Prometheus (optional, or use homelab)
apt install -y prometheus

# Install Grafana (optional)
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | tee /etc/apt/sources.list.d/grafana.list
apt update
apt install -y grafana

# Enable monitoring
systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter
```

---

## 🗄️ Database Setup

### 1. Configure PostgreSQL

```bash
# Switch to postgres user
sudo -u postgres psql

# In PostgreSQL prompt:
CREATE USER hosting WITH PASSWORD 'your-strong-password';
CREATE DATABASE hosting_platform OWNER hosting;
GRANT ALL PRIVILEGES ON DATABASE hosting_platform TO hosting;

# Enable extensions
\c hosting_platform
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

# Exit
\q
```

### 2. Configure PostgreSQL for Remote Access (if needed)

```bash
# Edit postgresql.conf
nano /etc/postgresql/16/main/postgresql.conf

# Find and update:
listen_addresses = 'localhost'  # Keep localhost only for security

# Edit pg_hba.conf
nano /etc/postgresql/16/main/pg_hba.conf

# Add:
local   all             hosting                                 scram-sha-256
host    all             hosting         127.0.0.1/32            scram-sha-256

# Restart PostgreSQL
systemctl restart postgresql
```

### 3. Test Database Connection

```bash
# Test connection
psql -h localhost -U hosting -d hosting_platform

# Should connect successfully
# Type \q to exit
```

### 4. Run Database Migrations

```bash
# Copy init script from repository
sudo -u hosting mkdir -p /opt/hosting-panel/migrations
sudo -u hosting cp homelab/init-scripts/01-init-databases.sql /opt/hosting-panel/migrations/

# Run init script
sudo -u postgres psql -d hosting_platform -f /opt/hosting-panel/migrations/01-init-databases.sql
```

---

## 🚢 Application Deployment

### 1. Create Directory Structure

```bash
# Create application directories
sudo -u hosting mkdir -p /opt/hosting-panel/{api-gateway,services/{user-service,billing-service,provisioning-service,email-service},frontend,logs,backups}

# Set permissions
chown -R hosting:hosting /opt/hosting-panel
chmod 755 /opt/hosting-panel
```

### 2. Build Binaries Locally

On your development machine:

```bash
# Build RUST API Gateway
cd api-gateway
cargo build --release

# Build Go Microservices
cd ../services/user-service
go build -o user-service

cd ../billing-service
go build -o billing-service

cd ../provisioning-service
go build -o provisioning-service

cd ../email-service
go build -o email-service

# Build Next.js Frontend
cd ../../frontend
npm run build
```

### 3. Deploy Binaries to Server

```bash
# From your local machine:

# Deploy API Gateway
scp target/release/api-gateway hosting@your-server:/opt/hosting-panel/api-gateway/

# Deploy Microservices
scp services/user-service/user-service hosting@your-server:/opt/hosting-panel/services/user-service/
scp services/billing-service/billing-service hosting@your-server:/opt/hosting-panel/services/billing-service/
scp services/provisioning-service/provisioning-service hosting@your-server:/opt/hosting-panel/services/provisioning-service/
scp services/email-service/email-service hosting@your-server:/opt/hosting-panel/services/email-service/

# Deploy Frontend
scp -r frontend/.next hosting@your-server:/opt/hosting-panel/frontend/
scp frontend/package.json hosting@your-server:/opt/hosting-panel/frontend/
scp frontend/package-lock.json hosting@your-server:/opt/hosting-panel/frontend/
```

### 4. Set Executable Permissions

On the server:

```bash
# Make binaries executable
chmod +x /opt/hosting-panel/api-gateway/api-gateway
chmod +x /opt/hosting-panel/services/user-service/user-service
chmod +x /opt/hosting-panel/services/billing-service/billing-service
chmod +x /opt/hosting-panel/services/provisioning-service/provisioning-service
chmod +x /opt/hosting-panel/services/email-service/email-service

# Install frontend dependencies
cd /opt/hosting-panel/frontend
npm ci --only=production
```

### 5. Create Environment Files

**API Gateway** (`/opt/hosting-panel/api-gateway/.env`):
```env
DATABASE_URL=postgresql://hosting:your-password@localhost:5432/hosting_platform
REDIS_URL=redis://:your-redis-password@localhost:6379
JWT_SECRET=your-very-long-secret-key-minimum-64-characters-recommended
RUST_LOG=info
RUST_BACKTRACE=1
PORT=8080
HOST=127.0.0.1
CORS_ORIGINS=https://yourdomain.com
```

**User Service** (`/opt/hosting-panel/services/user-service/.env`):
```env
DATABASE_URL=postgresql://hosting:your-password@localhost:5432/hosting_platform
GO_ENV=production
PORT=8081
HOST=127.0.0.1
```

**Billing Service** (`/opt/hosting-panel/services/billing-service/.env`):
```env
DATABASE_URL=postgresql://hosting:your-password@localhost:5432/hosting_platform
REDIS_URL=redis://:your-redis-password@localhost:6379
GO_ENV=production
PORT=8082
HOST=127.0.0.1
STRIPE_SECRET_KEY=sk_live_your_stripe_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret
```

**Provisioning Service** (`/opt/hosting-panel/services/provisioning-service/.env`):
```env
DATABASE_URL=postgresql://hosting:your-password@localhost:5432/hosting_platform
GO_ENV=production
PORT=8083
HOST=127.0.0.1
NGINX_CONFIG_PATH=/etc/nginx/sites-available
PHP_FPM_POOL_PATH=/etc/php/8.2/fpm/pool.d
```

**Email Service** (`/opt/hosting-panel/services/email-service/.env`):
```env
GO_ENV=production
PORT=8084
HOST=127.0.0.1
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM=noreply@yourdomain.com
```

**Frontend** (`/opt/hosting-panel/frontend/.env.production`):
```env
NODE_ENV=production
PORT=3000
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
```

**Set permissions**:
```bash
# Protect .env files
chmod 600 /opt/hosting-panel/*/.env
chmod 600 /opt/hosting-panel/frontend/.env.production
chown hosting:hosting /opt/hosting-panel/*/.env
chown hosting:hosting /opt/hosting-panel/frontend/.env.production
```

### 6. Install systemd Service Files

```bash
# Copy service files
cp infrastructure/systemd/*.service /etc/systemd/system/

# Set permissions
chmod 644 /etc/systemd/system/hosting-*.service

# Reload systemd
systemctl daemon-reload
```

### 7. Start Services

```bash
# Enable and start all services
systemctl enable --now hosting-{api-gateway,user-service,billing-service,provisioning-service,email-service,frontend}

# Check status
systemctl status hosting-*
```

### 8. Verify Services

```bash
# Check if services are listening
ss -tulpn | grep -E "(8080|8081|8082|8083|8084|3000)"

# Test API Gateway
curl http://localhost:8080/health

# Test Frontend
curl http://localhost:3000

# Check logs
journalctl -u hosting-api-gateway -f
```

---

## 🌐 NGINX Configuration

### 1. Create NGINX Configuration

`/etc/nginx/sites-available/hosting-panel`:
```nginx
# API Gateway upstream
upstream api_gateway {
    server 127.0.0.1:8080;
    keepalive 32;
}

# Frontend upstream
upstream frontend {
    server 127.0.0.1:3000;
    keepalive 32;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name yourdomain.com www.yourdomain.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

# Main HTTPS server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # SSL Configuration (will be added by Certbot)
    # ssl_certificate /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;

    # Logging
    access_log /var/log/nginx/hosting-panel-access.log;
    error_log /var/log/nginx/hosting-panel-error.log;

    # API routes
    location /api/ {
        proxy_pass http://api_gateway;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Frontend routes
    location / {
        proxy_pass http://frontend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Next.js specific
        proxy_buffering off;
    }

    # Static files (Next.js)
    location /_next/static/ {
        proxy_pass http://frontend;
        proxy_cache_valid 200 60m;
        add_header Cache-Control "public, max-age=3600, immutable";
    }
}
```

### 2. Enable Site

```bash
# Create symlink
ln -s /etc/nginx/sites-available/hosting-panel /etc/nginx/sites-enabled/

# Test configuration
nginx -t

# Reload NGINX
systemctl reload nginx
```

---

## 🔒 SSL Certificates

### 1. Obtain SSL Certificate

```bash
# Stop NGINX temporarily
systemctl stop nginx

# Obtain certificate
certbot certonly --standalone -d yourdomain.com -d www.yourdomain.com

# Start NGINX
systemctl start nginx

# Reload NGINX to use certificates
systemctl reload nginx
```

### 2. Auto-Renewal

```bash
# Test renewal
certbot renew --dry-run

# Auto-renewal is configured by default
systemctl status certbot.timer
```

---

## 📊 Monitoring Setup

### 1. Configure Prometheus Node Exporter

Already installed and running on port 9100.

### 2. Connect to Homelab Prometheus

On your homelab Prometheus (`homelab/prometheus.yml`), add:

```yaml
scrape_configs:
  - job_name: 'ax43-production'
    static_configs:
      - targets: ['your-server-ip:9100']
        labels:
          environment: 'production'
          server: 'ax43'
```

### 3. Set Up Grafana Dashboards

Import dashboards in your homelab Grafana:
- Node Exporter Full (ID: 1860)
- NGINX metrics (if using nginx-prometheus-exporter)

---

## 💾 Backup Configuration

### 1. Create Backup Script

`/opt/hosting-panel/scripts/backup.sh`:
```bash
#!/bin/bash

BACKUP_DIR="/opt/hosting-panel/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Backup database
pg_dump -U hosting hosting_platform | gzip > $BACKUP_DIR/db_backup_$DATE.sql.gz

# Backup application config
tar -czf $BACKUP_DIR/config_backup_$DATE.tar.gz /opt/hosting-panel/*/.env

# Keep only last 7 days
find $BACKUP_DIR -name "*.gz" -mtime +7 -delete

echo "Backup completed: $DATE"
```

Make executable:
```bash
chmod +x /opt/hosting-panel/scripts/backup.sh
chown hosting:hosting /opt/hosting-panel/scripts/backup.sh
```

### 2. Create Cron Job

```bash
# Edit crontab for hosting user
sudo -u hosting crontab -e

# Add daily backup at 2 AM
0 2 * * * /opt/hosting-panel/scripts/backup.sh >> /opt/hosting-panel/logs/backup.log 2>&1
```

### 3. Upload to Object Storage (Optional)

Install rclone and configure Hetzner Object Storage:
```bash
apt install -y rclone
rclone config  # Follow prompts to add Hetzner S3
```

Update backup script to upload:
```bash
# Add to backup.sh
rclone copy $BACKUP_DIR hetzner-s3:hosting-backups/
```

---

## 🔐 Security Hardening

### 1. SSH Hardening

```bash
# Edit SSH config
nano /etc/ssh/sshd_config

# Update:
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no

# Restart SSH
systemctl restart sshd
```

### 2. Install Fail2Ban

```bash
apt install -y fail2ban

# Configure
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
nano /etc/fail2ban/jail.local

# Enable and start
systemctl enable fail2ban
systemctl start fail2ban
```

### 3. Enable Unattended Upgrades

```bash
apt install -y unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades
```

### 4. Configure Log Rotation

`/etc/logrotate.d/hosting-panel`:
```
/opt/hosting-panel/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 hosting hosting
    sharedscripts
}
```

---

## ✅ Post-Deployment Checklist

- [ ] All services are running (`systemctl status hosting-*`)
- [ ] Database connection working
- [ ] Redis connection working
- [ ] NGINX serving traffic
- [ ] SSL certificate valid
- [ ] Firewall configured correctly
- [ ] Backups running daily
- [ ] Monitoring connected to homelab
- [ ] Log rotation configured
- [ ] Services auto-start on boot
- [ ] Application accessible via domain
- [ ] API health check passing
- [ ] Email sending working
- [ ] Payment processing (Stripe) configured

### Test Commands

```bash
# Check all services
systemctl status hosting-*

# Test API
curl https://yourdomain.com/api/health

# Test frontend
curl https://yourdomain.com

# Check logs
journalctl -u hosting-* --since "1 hour ago"

# Verify auto-start
systemctl list-units --type=service --state=enabled | grep hosting
```

---

## 🚨 Troubleshooting

See [Service Management Guide](systemd/README.md#troubleshooting) for detailed troubleshooting steps.

---

## 📚 Related Documentation

- [systemd Service Files](systemd/README.md)
- [Ansible Playbooks](ansible/README.md)
- [Solo Sprint Plan](../SOLO-SPRINT-PLAN.md)

---

**Deployment Guide Version**: 1.0
**Last Updated**: 2025-11-11
**Target Server**: Hetzner AX 43
**Status**: Ready for Production Deployment
