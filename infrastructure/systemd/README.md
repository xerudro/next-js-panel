# systemd Service Files

systemd unit files for running the Hosting Panel services in production on the AX 43 server.

---

## Services Overview

| Service | Port | Description | Dependencies |
|---------|------|-------------|--------------|
| **hosting-api-gateway** | 8080 | RUST API Gateway | PostgreSQL, Redis |
| **hosting-user-service** | 8081 | User Management (Go) | PostgreSQL |
| **hosting-billing-service** | 8082 | Billing & Payments (Go) | PostgreSQL, Redis |
| **hosting-provisioning-service** | 8083 | Server Provisioning (Go) | PostgreSQL |
| **hosting-email-service** | 8084 | Email Sending (Go) | None |
| **hosting-frontend** | 3000 | Next.js Frontend | None |

---

## Installation

### 1. Copy Service Files

```bash
# Copy all service files to systemd directory
sudo cp infrastructure/systemd/*.service /etc/systemd/system/

# Set proper permissions
sudo chmod 644 /etc/systemd/system/hosting-*.service
```

### 2. Create Service User

```bash
# Create hosting user and group
sudo useradd -r -s /bin/false -d /opt/hosting-panel hosting

# Create application directories
sudo mkdir -p /opt/hosting-panel/{api-gateway,services,frontend}
sudo chown -R hosting:hosting /opt/hosting-panel
```

### 3. Deploy Application Binaries

```bash
# Copy your built binaries to the server
# API Gateway (RUST)
sudo cp target/release/api-gateway /opt/hosting-panel/api-gateway/
sudo chown hosting:hosting /opt/hosting-panel/api-gateway/api-gateway
sudo chmod +x /opt/hosting-panel/api-gateway/api-gateway

# Microservices (Go)
sudo cp services/user-service/user-service /opt/hosting-panel/services/user-service/
sudo cp services/billing-service/billing-service /opt/hosting-panel/services/billing-service/
sudo cp services/provisioning-service/provisioning-service /opt/hosting-panel/services/provisioning-service/
sudo cp services/email-service/email-service /opt/hosting-panel/services/email-service/

# Set ownership and permissions
sudo chown -R hosting:hosting /opt/hosting-panel/services
sudo chmod +x /opt/hosting-panel/services/*/*

# Frontend (Next.js)
sudo cp -r frontend/.next /opt/hosting-panel/frontend/
sudo cp frontend/package.json /opt/hosting-panel/frontend/
sudo chown -R hosting:hosting /opt/hosting-panel/frontend
```

### 4. Create Environment Files

Each service needs a `.env` file in its directory:

```bash
# API Gateway
sudo nano /opt/hosting-panel/api-gateway/.env
```

**Example .env for API Gateway**:
```env
DATABASE_URL=postgresql://hosting:password@localhost:5432/hosting_platform
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-very-long-secret-key-minimum-32-characters
RUST_LOG=info
PORT=8080
```

**Example .env for User Service**:
```env
DATABASE_URL=postgresql://hosting:password@localhost:5432/hosting_platform
GO_ENV=production
PORT=8081
```

Repeat for all services. See `infrastructure/deployment/.env.example` for full templates.

### 5. Reload systemd

```bash
# Reload systemd to recognize new services
sudo systemctl daemon-reload
```

---

## Service Management

### Start Services

```bash
# Start all services
sudo systemctl start hosting-api-gateway
sudo systemctl start hosting-user-service
sudo systemctl start hosting-billing-service
sudo systemctl start hosting-provisioning-service
sudo systemctl start hosting-email-service
sudo systemctl start hosting-frontend
```

**Or start all at once**:
```bash
sudo systemctl start hosting-{api-gateway,user-service,billing-service,provisioning-service,email-service,frontend}
```

### Enable Auto-Start on Boot

```bash
# Enable services to start automatically
sudo systemctl enable hosting-api-gateway
sudo systemctl enable hosting-user-service
sudo systemctl enable hosting-billing-service
sudo systemctl enable hosting-provisioning-service
sudo systemctl enable hosting-email-service
sudo systemctl enable hosting-frontend
```

**Or enable all at once**:
```bash
sudo systemctl enable hosting-{api-gateway,user-service,billing-service,provisioning-service,email-service,frontend}
```

### Check Service Status

```bash
# Check status of all services
sudo systemctl status hosting-api-gateway
sudo systemctl status hosting-user-service
sudo systemctl status hosting-billing-service
sudo systemctl status hosting-provisioning-service
sudo systemctl status hosting-email-service
sudo systemctl status hosting-frontend
```

**Or check all at once**:
```bash
sudo systemctl status hosting-*
```

### View Logs

```bash
# View logs for a specific service
sudo journalctl -u hosting-api-gateway -f

# View logs for all hosting services
sudo journalctl -u "hosting-*" -f

# View logs from the last hour
sudo journalctl -u hosting-api-gateway --since "1 hour ago"

# View logs with specific priority (errors only)
sudo journalctl -u hosting-api-gateway -p err
```

### Restart Services

```bash
# Restart a single service
sudo systemctl restart hosting-api-gateway

# Restart all services
sudo systemctl restart hosting-{api-gateway,user-service,billing-service,provisioning-service,email-service,frontend}
```

### Stop Services

```bash
# Stop a single service
sudo systemctl stop hosting-api-gateway

# Stop all services
sudo systemctl stop hosting-{api-gateway,user-service,billing-service,provisioning-service,email-service,frontend}
```

### Reload Configuration

If you update a `.env` file:

```bash
# Reload environment and restart
sudo systemctl daemon-reload
sudo systemctl restart hosting-api-gateway
```

---

## Monitoring & Health Checks

### Check if Services are Running

```bash
# List all hosting services
sudo systemctl list-units "hosting-*"

# Check if a service is active
sudo systemctl is-active hosting-api-gateway

# Check if a service is enabled
sudo systemctl is-enabled hosting-api-gateway
```

### Monitor Service Restarts

```bash
# Show restart count
sudo systemctl show hosting-api-gateway -p NRestarts

# Show service uptime
sudo systemctl show hosting-api-gateway -p ActiveEnterTimestamp
```

### View Service Resources

```bash
# Show resource usage
sudo systemd-cgtop

# Show specific service resources
sudo systemctl status hosting-api-gateway | grep -E "(Memory|CPU)"
```

---

## Troubleshooting

### Service Won't Start

**Check the logs**:
```bash
sudo journalctl -u hosting-api-gateway -n 50
```

**Common issues**:
1. **Binary not found**: Check file path in ExecStart
2. **Permission denied**: Check ownership and execute permissions
3. **Database connection failed**: Check DATABASE_URL in .env
4. **Port already in use**: Check if another process is using the port

**Check binary exists**:
```bash
ls -la /opt/hosting-panel/api-gateway/api-gateway
```

**Test binary manually**:
```bash
sudo -u hosting /opt/hosting-panel/api-gateway/api-gateway
```

### Service Keeps Restarting

**Check restart count**:
```bash
sudo systemctl show hosting-api-gateway -p NRestarts
```

**View crash logs**:
```bash
sudo journalctl -u hosting-api-gateway --since "10 minutes ago"
```

**Disable auto-restart temporarily**:
```bash
sudo systemctl edit hosting-api-gateway
```
Add:
```ini
[Service]
Restart=no
```

### Port Conflicts

**Check what's using a port**:
```bash
sudo ss -tulpn | grep :8080
```

**Kill process on port**:
```bash
sudo fuser -k 8080/tcp
```

### Permission Issues

**Fix ownership**:
```bash
sudo chown -R hosting:hosting /opt/hosting-panel
```

**Fix permissions**:
```bash
sudo chmod +x /opt/hosting-panel/api-gateway/api-gateway
sudo chmod 600 /opt/hosting-panel/api-gateway/.env
```

### Database Connection Issues

**Test PostgreSQL connection**:
```bash
psql -h localhost -U hosting -d hosting_platform
```

**Check PostgreSQL is running**:
```bash
sudo systemctl status postgresql
```

**Check Redis is running**:
```bash
sudo systemctl status redis
```

---

## Deployment Updates

When deploying a new version:

```bash
# 1. Build new binary locally
cargo build --release

# 2. Copy to server (with backup)
sudo cp /opt/hosting-panel/api-gateway/api-gateway /opt/hosting-panel/api-gateway/api-gateway.backup
sudo cp target/release/api-gateway /opt/hosting-panel/api-gateway/

# 3. Restart service
sudo systemctl restart hosting-api-gateway

# 4. Check logs
sudo journalctl -u hosting-api-gateway -f

# 5. If issues, rollback
# sudo cp /opt/hosting-panel/api-gateway/api-gateway.backup /opt/hosting-panel/api-gateway/api-gateway
# sudo systemctl restart hosting-api-gateway
```

---

## Security Notes

### File Permissions

All service files should be owned by root with 644 permissions:
```bash
sudo chown root:root /etc/systemd/system/hosting-*.service
sudo chmod 644 /etc/systemd/system/hosting-*.service
```

Application binaries should be owned by the `hosting` user:
```bash
sudo chown hosting:hosting /opt/hosting-panel/*/
sudo chmod 755 /opt/hosting-panel  # Directory
sudo chmod +x /opt/hosting-panel/*/*  # Binaries
```

Environment files should be readable only by the `hosting` user:
```bash
sudo chown hosting:hosting /opt/hosting-panel/*/.env
sudo chmod 600 /opt/hosting-panel/*/.env
```

### Service Hardening

All service files include security hardening:
- **NoNewPrivileges**: Prevents privilege escalation
- **PrivateTmp**: Isolated /tmp directory
- **ProtectSystem**: Read-only /usr and /boot
- **ProtectHome**: No access to /home
- **Resource Limits**: Prevents resource exhaustion

### Firewall Configuration

Ensure only NGINX can access backend services:

```bash
# Allow NGINX to access backend
sudo ufw allow from 127.0.0.1 to any port 8080:8084 proto tcp

# Block external access to backend ports
sudo ufw deny 8080:8084/tcp
```

---

## Complete Service Lifecycle

### Fresh Installation

```bash
# 1. Copy service files
sudo cp infrastructure/systemd/*.service /etc/systemd/system/

# 2. Create user
sudo useradd -r -s /bin/false hosting

# 3. Create directories
sudo mkdir -p /opt/hosting-panel/{api-gateway,services/{user-service,billing-service,provisioning-service,email-service},frontend}

# 4. Deploy binaries (see Deployment guide)
# ... copy files ...

# 5. Create .env files
# ... create environment files ...

# 6. Set ownership
sudo chown -R hosting:hosting /opt/hosting-panel

# 7. Reload systemd
sudo systemctl daemon-reload

# 8. Start and enable services
sudo systemctl enable --now hosting-{api-gateway,user-service,billing-service,provisioning-service,email-service,frontend}

# 9. Check status
sudo systemctl status hosting-*
```

### Uninstallation

```bash
# 1. Stop services
sudo systemctl stop hosting-*

# 2. Disable services
sudo systemctl disable hosting-*

# 3. Remove service files
sudo rm /etc/systemd/system/hosting-*.service

# 4. Reload systemd
sudo systemctl daemon-reload

# 5. Remove application files (optional)
sudo rm -rf /opt/hosting-panel

# 6. Remove user (optional)
sudo userdel hosting
```

---

## Related Documentation

- [Production Deployment Guide](../deployment/PRODUCTION-DEPLOYMENT.md)
- [Ansible Playbooks](../ansible/README.md)
- [NGINX Configuration](../nginx/README.md)
- [Service Management](../deployment/SERVICE-MANAGEMENT.md)

---

**Last Updated**: 2025-11-11
**Status**: Ready for Production
