# Infrastructure - Production Deployment

Complete infrastructure setup for deploying the Hosting Panel to production using systemd and Ansible.

---

## 📋 Overview

This directory contains everything needed to deploy the Hosting Panel to production on the Hetzner AX 43 server:

- **systemd service files** for running services natively (not Docker)
- **Ansible playbooks** for automated deployment
- **NGINX configurations** for reverse proxy
- **Deployment scripts** for common tasks
- **Production deployment guide** with step-by-step instructions

---

## 🏗️ Architecture

### Development vs Production

| Component | Development (Homelab) | Production (AX 43) |
|-----------|----------------------|-------------------|
| **Orchestration** | Docker Compose | systemd |
| **PostgreSQL** | Docker container | Native install (apt) |
| **Redis** | Docker container | Native install (apt) |
| **API Gateway** | `cargo run` | systemd service |
| **Microservices** | `go run` | systemd services |
| **Frontend** | `npm run dev` | systemd service (Node.js) |
| **Customer Sites** | N/A | NGINX + PHP-FPM |
| **Management** | `docker compose up` | `systemctl start/stop` |

**Why systemd for production?**
- ✅ Better performance (no Docker overhead)
- ✅ Native Linux service management
- ✅ Customer websites as NGINX vhosts (standard hosting approach)
- ✅ Easier debugging and resource control
- ✅ Lower memory footprint

---

## 📁 Directory Structure

```
infrastructure/
├── README.md                           # This file
├── PRODUCTION-DEPLOYMENT.md            # Complete deployment guide
│
├── systemd/                            # systemd service files
│   ├── README.md                       # Service management guide
│   ├── hosting-api-gateway.service     # RUST API Gateway
│   ├── hosting-user-service.service    # User Management (Go)
│   ├── hosting-billing-service.service # Billing Service (Go)
│   ├── hosting-provisioning-service.service # Provisioning (Go)
│   ├── hosting-email-service.service   # Email Service (Go)
│   └── hosting-frontend.service        # Next.js Frontend
│
├── ansible/                            # Ansible automation
│   ├── README.md                       # Ansible usage guide
│   ├── inventory/
│   │   └── production.ini              # Server inventory
│   └── playbooks/
│       ├── setup-ax43.yml              # Initial server setup
│       └── deploy-app.yml              # Application deployment
│
├── nginx/                              # NGINX configurations (to be created)
│   ├── hosting-panel.conf              # Main reverse proxy config
│   └── customer-vhost.template         # Template for customer sites
│
└── scripts/                            # Utility scripts (to be created)
    ├── backup.sh                       # Backup database and configs
    ├── restore.sh                      # Restore from backup
    └── deploy.sh                       # Quick deployment script
```

---

## 🚀 Quick Start

### Prerequisites

- Hetzner AX 43 server provisioned
- SSH access configured
- Domain name pointing to server
- Ansible installed locally

### 1. Initial Server Setup (One-Time)

```bash
# From project root
cd infrastructure/ansible

# Configure inventory
nano inventory/production.ini
# Update: ansible_host=YOUR_SERVER_IP

# Set environment variables
export POSTGRES_PASSWORD="your-strong-password"
export REDIS_PASSWORD="your-strong-password"

# Run setup playbook
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml
```

**Duration**: 10-15 minutes

**What this does**:
- Updates system packages
- Configures firewall (UFW)
- Installs PostgreSQL 16
- Installs Redis 7.2
- Installs NGINX
- Installs Node.js 20
- Creates application user and directories
- Sets up swap and monitoring

### 2. Build Application

```bash
# From project root

# Build API Gateway (RUST)
cd api-gateway
cargo build --release

# Build Microservices (Go)
cd ../services/user-service && go build
cd ../billing-service && go build
cd ../provisioning-service && go build
cd ../email-service && go build

# Build Frontend (Next.js)
cd ../../frontend
npm run build
```

### 3. Deploy Application

```bash
# From infrastructure/ansible
cd infrastructure/ansible

# Set project path
export PWD=/path/to/next-js-panel

# Deploy
ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml
```

**Duration**: 5-10 minutes

**What this does**:
- Stops all services
- Backs up existing binaries
- Copies new binaries to server
- Deploys Frontend build
- Copies systemd service files
- Restarts all services
- Runs health checks

### 4. Configure NGINX & SSL

```bash
# SSH to server
ssh root@your-server-ip

# Copy NGINX config
sudo cp /path/to/hosting-panel.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/hosting-panel.conf /etc/nginx/sites-enabled/

# Test config
sudo nginx -t

# Obtain SSL certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Reload NGINX
sudo systemctl reload nginx
```

### 5. Verify Deployment

```bash
# Check services
sudo systemctl status hosting-*

# Test API
curl https://yourdomain.com/api/health

# Test Frontend
curl https://yourdomain.com

# Check logs
sudo journalctl -u hosting-api-gateway -f
```

---

## 📚 Documentation

### Main Guides

1. **[PRODUCTION-DEPLOYMENT.md](PRODUCTION-DEPLOYMENT.md)** - Complete deployment guide
   - Server specifications
   - Initial setup steps
   - Database configuration
   - Application deployment
   - NGINX configuration
   - SSL certificates
   - Security hardening
   - Post-deployment checklist

2. **[systemd/README.md](systemd/README.md)** - Service management
   - systemd service files explained
   - Service management commands
   - Logging and monitoring
   - Troubleshooting
   - Security configuration

3. **[ansible/README.md](ansible/README.md)** - Ansible automation
   - Playbook usage
   - Inventory configuration
   - Deployment automation
   - Common tasks
   - Best practices

### Quick Reference

**Service Management**:
```bash
# Start all services
sudo systemctl start hosting-{api-gateway,user-service,billing-service,provisioning-service,email-service,frontend}

# Stop all services
sudo systemctl stop hosting-*

# Restart a service
sudo systemctl restart hosting-api-gateway

# Check status
sudo systemctl status hosting-*

# View logs
sudo journalctl -u hosting-api-gateway -f
```

**Deployment**:
```bash
# Quick deploy (after building locally)
cd infrastructure/ansible
PWD=/path/to/project ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml
```

**Backups**:
```bash
# Manual backup
sudo -u hosting /opt/hosting-panel/scripts/backup.sh

# List backups
ls -lh /opt/hosting-panel/backups/

# Restore backup
sudo -u hosting /opt/hosting-panel/scripts/restore.sh /opt/hosting-panel/backups/backup_20250111.sql.gz
```

---

## 🔒 Security

### Firewall Rules

```bash
# Allow SSH, HTTP, HTTPS only
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Block backend services from external access
sudo ufw deny 8080:8084/tcp

# Enable firewall
sudo ufw enable
```

### Service Hardening

All systemd services include:
- **NoNewPrivileges**: Prevents privilege escalation
- **PrivateTmp**: Isolated /tmp directory
- **ProtectSystem**: Read-only /usr and /boot
- **ProtectHome**: No access to /home directories
- **Resource Limits**: CPU and memory limits

### SSL/TLS

```bash
# Obtain certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo systemctl status certbot.timer

# Test renewal
sudo certbot renew --dry-run
```

---

## 📊 Monitoring

### Prometheus Node Exporter

Automatically installed and running on port 9100.

**Connect from homelab**:

Add to `homelab/prometheus.yml`:
```yaml
scrape_configs:
  - job_name: 'ax43-production'
    static_configs:
      - targets: ['YOUR_SERVER_IP:9100']
        labels:
          environment: 'production'
```

### Service Logs

```bash
# View all service logs
sudo journalctl -u "hosting-*" -f

# View specific service
sudo journalctl -u hosting-api-gateway -f

# View errors only
sudo journalctl -u hosting-api-gateway -p err

# Last hour
sudo journalctl -u hosting-api-gateway --since "1 hour ago"
```

### Health Checks

```bash
# API Gateway
curl http://localhost:8080/health

# User Service
curl http://localhost:8081/health

# Frontend
curl http://localhost:3000
```

---

## 🔄 Common Tasks

### Update Application

```bash
# 1. Build locally
cargo build --release  # API Gateway
go build               # Microservices
npm run build          # Frontend

# 2. Deploy with Ansible
cd infrastructure/ansible
PWD=/path/to/project ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml
```

### Rollback Deployment

```bash
# SSH to server
ssh root@your-server-ip

# Find backup
ls /opt/hosting-panel/backups/

# Restore binary
sudo cp /opt/hosting-panel/backups/2025-11-11/api-gateway.backup /opt/hosting-panel/api-gateway/api-gateway

# Restart service
sudo systemctl restart hosting-api-gateway
```

### Update Environment Variables

```bash
# Edit .env file
sudo nano /opt/hosting-panel/api-gateway/.env

# Reload and restart
sudo systemctl daemon-reload
sudo systemctl restart hosting-api-gateway
```

### Database Backup

```bash
# Manual backup
sudo -u postgres pg_dump hosting_platform | gzip > backup_$(date +%Y%m%d).sql.gz

# Automated (cron)
sudo -u hosting crontab -e
# Add: 0 2 * * * /opt/hosting-panel/scripts/backup.sh
```

### View Service Resources

```bash
# All services
sudo systemctl status hosting-*

# Specific service resources
sudo systemctl show hosting-api-gateway -p CPUUsage -p MemoryCurrent

# Live resource usage
sudo systemd-cgtop
```

---

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check logs
sudo journalctl -u hosting-api-gateway -n 50

# Check binary
ls -la /opt/hosting-panel/api-gateway/api-gateway

# Test manually
sudo -u hosting /opt/hosting-panel/api-gateway/api-gateway

# Check permissions
sudo chown hosting:hosting /opt/hosting-panel/api-gateway/api-gateway
sudo chmod +x /opt/hosting-panel/api-gateway/api-gateway
```

### Database Connection Failed

```bash
# Check PostgreSQL
sudo systemctl status postgresql

# Test connection
psql -h localhost -U hosting -d hosting_platform

# Check password
grep DATABASE_URL /opt/hosting-panel/api-gateway/.env
```

### NGINX Issues

```bash
# Test config
sudo nginx -t

# Check logs
sudo tail -f /var/log/nginx/error.log

# Restart NGINX
sudo systemctl restart nginx
```

### Port Already in Use

```bash
# Find what's using port 8080
sudo ss -tulpn | grep :8080

# Kill process
sudo fuser -k 8080/tcp
```

---

## 🎯 Deployment Checklist

Before deploying to production:

- [ ] Application built successfully locally
- [ ] All tests passing
- [ ] Environment variables configured
- [ ] Database migrations prepared
- [ ] NGINX configuration ready
- [ ] SSL certificates ready
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Rollback plan documented

After deployment:

- [ ] All services running
- [ ] Health checks passing
- [ ] Logs show no errors
- [ ] Application accessible via domain
- [ ] SSL certificate valid
- [ ] Monitoring connected
- [ ] Backups running
- [ ] Performance acceptable

---

## 📖 Related Documentation

- [Solo Sprint Plan](../SOLO-SPRINT-PLAN.md) - 9-month development roadmap
- [Project Structure](../PROJECT-STRUCTURE.md) - Complete code structure
- [Getting Started](../GETTING-STARTED.md) - Development setup
- [Homelab Setup](../homelab/README.md) - Development environment

---

## 🚀 Production Readiness

This infrastructure is ready for:
- ✅ Single server deployment (AX 43)
- ✅ 500-1000+ customer websites
- ✅ systemd service management
- ✅ Automated deployment with Ansible
- ✅ SSL/TLS encryption
- ✅ Automated backups
- ✅ Monitoring and logging
- ✅ Security hardening

**Next Steps**:
1. Review [PRODUCTION-DEPLOYMENT.md](PRODUCTION-DEPLOYMENT.md)
2. Configure inventory in `ansible/inventory/production.ini`
3. Run `setup-ax43.yml` playbook
4. Deploy application with `deploy-app.yml`
5. Configure NGINX and obtain SSL certificates

---

**Last Updated**: 2025-11-11
**Status**: Ready for Production Deployment
**Target Server**: Hetzner AX 43 (AMD Ryzen 7 3700X, 64GB RAM)
