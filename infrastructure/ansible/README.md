# Ansible Playbooks for Hosting Panel

Ansible automation for setting up and deploying the Hosting Panel to Hetzner AX 43.

---

## 📋 Prerequisites

### On Your Local Machine

```bash
# Install Ansible
# Ubuntu/Debian
sudo apt install ansible

# macOS
brew install ansible

# Verify installation
ansible --version
```

### SSH Access

Ensure you have SSH access to the server:

```bash
# Test connection
ssh root@your-server-ip

# Or with key
ssh -i ~/.ssh/id_ed25519 root@your-server-ip
```

---

## 📁 Directory Structure

```
ansible/
├── inventory/
│   ├── production.ini       # Production server inventory
│   └── staging.ini          # Staging server inventory (optional)
├── playbooks/
│   ├── setup-ax43.yml       # Initial server setup
│   ├── deploy-app.yml       # Application deployment
│   └── backup.yml           # Backup tasks (optional)
└── README.md                # This file
```

---

## 🚀 Usage

### 1. Configure Inventory

Edit `inventory/production.ini`:

```ini
[ax43]
hosting-panel ansible_host=YOUR_SERVER_IP ansible_user=root

[ax43:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
server_hostname=hosting-panel.yourdomain.com
app_domain=yourdomain.com
app_user=hosting
app_dir=/opt/hosting-panel
```

Replace:
- `YOUR_SERVER_IP` with your AX 43 IP address
- `yourdomain.com` with your actual domain
- SSH key path if different

### 2. Set Environment Variables

Create a `.env` file in the ansible directory:

```bash
export POSTGRES_PASSWORD="your-strong-postgres-password"
export REDIS_PASSWORD="your-strong-redis-password"
```

Load it:
```bash
source .env
```

**Or** use Ansible Vault (recommended):

```bash
# Create vault file
ansible-vault create vars/secrets.yml

# Add:
postgres_password: your-strong-postgres-password
redis_password: your-strong-redis-password

# Use in playbook:
# vars_files:
#   - vars/secrets.yml
```

### 3. Test Connection

```bash
ansible -i inventory/production.ini ax43 -m ping
```

Expected output:
```
hosting-panel | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## 🏗️ Initial Server Setup

### Run Setup Playbook

This playbook:
- Updates system packages
- Configures firewall (UFW)
- Installs PostgreSQL 16
- Installs Redis 7.2
- Installs NGINX
- Installs Node.js 20
- Creates application user and directories
- Configures swap
- Sets up monitoring

```bash
# From the infrastructure/ansible directory
cd infrastructure/ansible

# Run playbook
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml

# With verbose output
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml -v
```

**Expected duration**: 10-15 minutes

### Verify Setup

```bash
# SSH to server
ssh root@your-server-ip

# Check services
systemctl status postgresql
systemctl status redis
systemctl status nginx

# Check firewall
ufw status

# Check application directories
ls -la /opt/hosting-panel
```

---

## 🚢 Application Deployment

### Build Binaries Locally

Before deploying, build all binaries:

```bash
# From project root
cd /path/to/next-js-panel

# Build API Gateway (RUST)
cd api-gateway
cargo build --release

# Build Go Services
cd ../services/user-service && go build
cd ../billing-service && go build
cd ../provisioning-service && go build
cd ../email-service && go build

# Build Frontend (Next.js)
cd ../../frontend
npm run build
```

### Deploy Application

```bash
# From infrastructure/ansible directory
cd infrastructure/ansible

# Export project path
export PWD=/path/to/next-js-panel

# Run deployment playbook
ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml

# With verbose output
ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml -vv
```

**What this does**:
1. Stops all services
2. Backs up existing binaries
3. Copies new binaries to server
4. Copies systemd service files
5. Restarts all services
6. Checks service health

**Expected duration**: 5-10 minutes

### Verify Deployment

```bash
# SSH to server
ssh root@your-server-ip

# Check service status
systemctl status hosting-*

# Check logs
journalctl -u hosting-api-gateway -f
journalctl -u hosting-frontend -f

# Test API
curl http://localhost:8080/health

# Test Frontend
curl http://localhost:3000
```

---

## 📝 Playbook Reference

### setup-ax43.yml

**Purpose**: Initial server provisioning

**Tasks**:
- System updates
- Firewall configuration
- PostgreSQL installation and setup
- Redis installation and configuration
- NGINX installation
- Node.js installation
- Certbot installation
- Monitoring tools installation
- Application user creation
- Directory structure creation
- Swap configuration

**Variables**:
- `server_hostname`: Server hostname
- `app_domain`: Application domain
- `app_user`: Application user (default: hosting)
- `app_dir`: Application directory (default: /opt/hosting-panel)
- `postgres_password`: PostgreSQL password (from env or vault)
- `redis_password`: Redis password (from env or vault)

**Usage**:
```bash
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml
```

### deploy-app.yml

**Purpose**: Deploy application binaries and restart services

**Tasks**:
- Stop services
- Backup existing binaries
- Copy new binaries
- Deploy Frontend build
- Copy systemd service files
- Reload systemd
- Start services
- Health check

**Variables**:
- `local_build_dir`: Path to project (from $PWD)

**Usage**:
```bash
PWD=/path/to/project ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml
```

---

## 🔄 Common Tasks

### Deploy Specific Service

Use tags (add to playbook):

```bash
# Deploy only API Gateway
ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml --tags api-gateway

# Deploy only Frontend
ansible-playbook -i inventory/production.ini playbooks/deploy-app.yml --tags frontend
```

### Rollback Deployment

```bash
# SSH to server
ssh root@your-server-ip

# Find backup
ls -la /opt/hosting-panel/backups/

# Restore backup
sudo cp /opt/hosting-panel/backups/2025-11-11/api-gateway.backup /opt/hosting-panel/api-gateway/api-gateway

# Restart service
sudo systemctl restart hosting-api-gateway
```

### Update Environment Variables

1. Edit `.env` file on server:
```bash
ssh root@your-server-ip
nano /opt/hosting-panel/api-gateway/.env
```

2. Restart service:
```bash
sudo systemctl restart hosting-api-gateway
```

### Run Only Specific Tasks

Use `--start-at-task`:

```bash
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml --start-at-task="Install PostgreSQL"
```

---

## 🐛 Troubleshooting

### Connection Failed

```bash
# Test SSH manually
ssh -i ~/.ssh/id_ed25519 root@your-server-ip

# Check inventory file
cat inventory/production.ini

# Test with verbose
ansible -i inventory/production.ini ax43 -m ping -vvv
```

### Playbook Failed

```bash
# Run with verbose output
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml -vv

# Check last task
# Playbook will show failed task name

# Run from failed task
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml --start-at-task="Task Name"
```

### Service Won't Start

```bash
# SSH to server
ssh root@your-server-ip

# Check logs
journalctl -u hosting-api-gateway -n 50

# Check binary exists
ls -la /opt/hosting-panel/api-gateway/api-gateway

# Check permissions
sudo -u hosting /opt/hosting-panel/api-gateway/api-gateway
```

### PostgreSQL Connection Failed

```bash
# Check PostgreSQL is running
systemctl status postgresql

# Test connection
psql -h localhost -U hosting -d hosting_platform

# Check password in .env
cat /opt/hosting-panel/api-gateway/.env | grep DATABASE_URL
```

---

## 🔒 Security Best Practices

### Use Ansible Vault

Store sensitive data in encrypted vault:

```bash
# Create vault
ansible-vault create vars/secrets.yml

# Edit vault
ansible-vault edit vars/secrets.yml

# Use in playbook
ansible-playbook -i inventory/production.ini playbooks/setup-ax43.yml --ask-vault-pass
```

### Use SSH Key Authentication

```bash
# Generate key if you don't have one
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy to server
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@your-server-ip

# Test
ssh -i ~/.ssh/id_ed25519 root@your-server-ip
```

### Limit Root Access

After setup, create a non-root user:

```bash
# Update inventory to use non-root user
[ax43]
hosting-panel ansible_host=your-server-ip ansible_user=deployer ansible_become=yes
```

---

## 📚 Additional Playbooks (To Be Created)

### backup.yml
- Backup database
- Backup application config
- Upload to object storage

### update.yml
- Update system packages
- Restart services if needed

### ssl-renew.yml
- Renew SSL certificates
- Reload NGINX

### monitoring.yml
- Install additional monitoring tools
- Configure alerts

---

## 📖 Ansible Documentation

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Playbook Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)

---

**Last Updated**: 2025-11-11
**Status**: Ready for Use
