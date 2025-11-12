# Homelab Server Setup & Optimization Guide

Complete guide for setting up and optimizing your Terra Office PC homelab server for the Hosting Panel development environment.

---

## 📋 Table of Contents

- [Server Specifications](#server-specifications)
- [Initial System Setup](#initial-system-setup)
- [Docker Installation & Configuration](#docker-installation--configuration)
- [Repository Setup & Service Deployment](#repository-setup--service-deployment)
- [PostgreSQL Optimization](#postgresql-optimization)
- [System Performance Tuning](#system-performance-tuning)
- [Security Hardening](#security-hardening)
- [Monitoring Setup](#monitoring-setup)
- [Backup Configuration](#backup-configuration)
- [Maintenance Scripts](#maintenance-scripts)
- [Troubleshooting](#troubleshooting)

---

## 🖥️ Server Specifications

### Hardware

**CPU**: Intel Core i5-6500 (Skylake, 6th gen)
- **Cores**: 4 cores, 4 threads (no hyperthreading)
- **Base Clock**: 3.2 GHz
- **Boost Clock**: 3.6 GHz
- **Cache**: 6MB L3, 256KB L2 per core
- **TDP**: 65W
- **Architecture**: x86_64
- **Virtualization**: VT-x enabled ✅

**RAM**: 64GB DDR3/DDR4
- **Type**: DDR3 or DDR4 (check with `sudo dmidecode --type memory | grep "Type:"`)
- **Amount**: 64GB (16GB per core - excellent ratio!)
- **Speed**: Check with `sudo dmidecode --type memory | grep "Speed:"`

**System Balance Assessment**:
- ✅ **Excellent RAM/CPU ratio** (16GB per core)
- ✅ Perfect for 10-15 Docker containers simultaneously
- ✅ Can run heavy PostgreSQL workloads + Redis + n8n + monitoring
- ✅ Plenty of RAM for caching and buffers
- ⚠️ CPU is the bottleneck, not RAM (limit concurrent builds to `-j3`)
- ✅ 32GB swap is perfect (50% of RAM)

### Partition Layout

```text
Physical Partitions:
├── /                     100GB    ext4      ✅ Perfect
├── /boot                 2GB      ext4      ✅ OK
└── /boot/efi             1GB      fat32     ✅ OK

LVM Volumes (ubuntu-vg):
├── /data                 200GB    xfs       ✅ Excellent (backups, exports)
├── /home                 80GB     xfs       ✅ OK (user files)
├── /opt                  80GB     xfs       ✅ OK (custom apps)
├── /var/lib/docker       150GB    xfs       ✅ Perfect (containers, images)
├── /var/lib/postgresql   150GB    xfs       ✅ Perfect (database files)
├── /var/log              30GB     xfs       ✅ Good (log files)
└── SWAP                  32GB     swap      ✅ OK

Total Allocated: ~825GB of 1TB
Free Space: ~175GB in LVM for future expansion
```

**Strengths of this layout:**
- ✅ Dedicated volumes for Docker and PostgreSQL (prevents disk space issues)
- ✅ XFS for database workloads (better performance than ext4)
- ✅ Separate /var/log (prevents logs from filling root)
- ✅ 175GB free space for expansion
- ✅ 32GB swap (ideal for system with 16-64GB RAM)

---

## 🚀 Initial System Setup

### 1. Check System Information

Before starting, verify your hardware:

```bash
# Check RAM details
sudo dmidecode --type memory | grep -A 20 "Memory Device" | grep -E "(Size|Type:|Speed:|Manufacturer)"

# Quick RAM summary
free -h

# Check if DDR3 or DDR4
sudo dmidecode --type memory | grep -i "type: ddr"

# CPU details
lscpu | grep -E "Model name|CPU\(s\)|MHz"

# Storage details
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE
df -hT
```

Expected output for your system:
- **RAM**: 64GB DDR3 or DDR4
- **CPU**: Intel(R) Core(TM) i5-6500 CPU @ 3.20GHz (4 cores)
- **Storage**: ~1TB with LVM volumes

### 2. Update System

```bash
# Update package lists and upgrade all packages
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    htop \
    iotop \
    ncdu \
    tree \
    net-tools \
    dnsutils \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Clean up
sudo apt autoremove -y
sudo apt autoclean
```

### 2. Set Hostname

```bash
# Set hostname to something meaningful
sudo hostnamectl set-hostname homelab-terra

# Update /etc/hosts
echo "127.0.1.1 homelab-terra" | sudo tee -a /etc/hosts
```

### 3. Configure Timezone and Locale

```bash
# Set timezone
sudo timedatectl set-timezone Europe/Bucharest  # or your timezone

# Verify
timedatectl

# Configure locale (if needed)
sudo dpkg-reconfigure locales
```

### 4. Enable Automatic Security Updates

```bash
# Install unattended-upgrades
sudo apt install -y unattended-upgrades

# Configure automatic updates
sudo dpkg-reconfigure -plow unattended-upgrades

# Edit configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

Add these lines:
```text
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
```

---

## 🐳 Docker Installation & Configuration

### 1. Install Docker

```bash
# Remove old Docker versions
sudo apt remove -y docker docker-engine docker.io containerd runc

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify installation
docker --version
docker compose version
```

### 2. Configure Docker for Dedicated Volume

Docker is already using `/var/lib/docker` (150GB XFS), but let's optimize it:

```bash
# Create Docker daemon config
sudo mkdir -p /etc/docker

sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false,
  "metrics-addr": "127.0.0.1:9323",
  "max-concurrent-downloads": 10,
  "max-concurrent-uploads": 5,
  "default-ulimits": {
    "nofile": {
      "Name": "nofile",
      "Hard": 64000,
      "Soft": 64000
    }
  }
}
EOF

# Restart Docker
sudo systemctl restart docker

# Verify
sudo docker info
```

**Docker CPU Optimization for 4-core i5-6500**:

Since you have 4 cores without hyperthreading, it's important to limit CPU usage per container:

```bash
# Update docker-compose.yml to add CPU limits
# Add this to each service that needs CPU limits:
```

Example for PostgreSQL in `docker-compose.yml`:
```yaml
services:
  postgres:
    image: postgres:16-alpine
    cpus: "2.0"              # Limit to 2 cores max (50% of 4 cores)
    mem_limit: 20g           # Limit to 20GB (with 64GB RAM)
    mem_reservation: 16g     # Reserve 16GB for shared_buffers
    # ... rest of config

  redis:
    image: redis:7.2-alpine
    cpus: "0.5"              # Limit to 0.5 cores
    mem_limit: 4g            # Redis memory limit
    mem_reservation: 2g      # Reserve 2GB
    # ... rest of config

  n8n:
    image: n8nio/n8n:latest
    cpus: "1.0"              # Limit to 1 core
    mem_limit: 4g            # n8n memory limit
    mem_reservation: 2g      # Reserve 2GB
    # ... rest of config
```

Recommended resource allocation for 64GB RAM + 4 cores:

**CPU limits:**
- PostgreSQL: 2.0 CPUs (50%)
- Redis: 0.5 CPUs (12.5%)
- n8n: 1.0 CPUs (25%)
- Prometheus: 0.5 CPUs
- Grafana: 0.5 CPUs
- Other services: 0.5 CPUs total

**Memory limits:**
- PostgreSQL: 20GB (31%)
- Redis: 4GB (6%)
- n8n: 4GB (6%)
- Prometheus: 2GB (3%)
- Grafana: 1GB (1.5%)
- Adminer: 512MB
- Redis Commander: 512MB
- System: ~32GB free for OS cache and buffers

### 3. Add User to Docker Group

```bash
# Add your user to docker group (replace 'your-username')
sudo usermod -aG docker $USER

# Apply group membership (logout/login or run)
newgrp docker

# Test (should work without sudo)
docker ps
```

### 4. Enable Docker on Boot

```bash
sudo systemctl enable docker
sudo systemctl enable containerd
```

---

## 📦 Repository Setup & Service Deployment

Now that Docker is installed, let's clone the repository and deploy all services using Docker Compose.

### 1. Clone the Repository

```bash
# Navigate to your preferred location (e.g., /opt or /home/username)
cd /opt

# Clone the repository
sudo git clone https://github.com/xerudro/next-js-panel.git

# Change ownership to your user (replace 'your-username')
sudo chown -R $USER:$USER /opt/next-js-panel

# Navigate to the homelab directory
cd /opt/next-js-panel/homelab
```

**Alternative location** (if you prefer /home):
```bash
cd ~
git clone https://github.com/xerudro/next-js-panel.git
cd next-js-panel/homelab
```

### 2. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit the environment file
nano .env
```

**Required changes in `.env`:**

```bash
# IMPORTANT: Change these passwords for security!
POSTGRES_PASSWORD=your_secure_postgres_password_here
REDIS_PASSWORD=your_secure_redis_password_here
N8N_PASSWORD=your_secure_n8n_password_here
GRAFANA_PASSWORD=your_secure_grafana_password_here

# JWT secret (generate a random 32+ character string)
JWT_SECRET=your_random_jwt_secret_minimum_32_characters_here

# SMTP Configuration (optional for development)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_specific_password

# Stripe keys (use test keys for development)
STRIPE_SECRET_KEY=sk_test_your_stripe_test_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_test_key
```

**Generate secure passwords:**
```bash
# Generate random passwords
openssl rand -base64 32  # For PostgreSQL
openssl rand -base64 32  # For Redis
openssl rand -base64 32  # For n8n
openssl rand -base64 32  # For Grafana
openssl rand -base64 48  # For JWT secret
```

### 3. Start All Services

**Before starting, clean up unused Docker networks** (prevents subnet exhaustion):
```bash
# Remove unused networks
docker network prune -f
```

Now start the services:
```bash
# Make sure you're in the homelab directory
cd /opt/next-js-panel/homelab  # or ~/next-js-panel/homelab

# Start all services in detached mode
docker compose up -d

# Watch the logs (optional)
docker compose logs -f
```

Expected output:
```text
[+] Running 8/8
 ✔ Network hosting_network         Created
 ✔ Container hosting_postgres       Started
 ✔ Container hosting_redis          Started
 ✔ Container hosting_prometheus     Started
 ✔ Container hosting_n8n            Started
 ✔ Container hosting_grafana        Started
 ✔ Container hosting_adminer        Started
 ✔ Container hosting_redis_commander Started
```

### 4. Verify Services are Running

```bash
# Check all containers
docker compose ps

# Check logs for any errors
docker compose logs

# Check specific service logs
docker compose logs postgres
docker compose logs n8n
docker compose logs redis
```

Expected output:
```text
NAME                      IMAGE                              STATUS
hosting_postgres          postgres:16-alpine                 Up (healthy)
hosting_redis             redis:7.2-alpine                   Up (healthy)
hosting_n8n               n8nio/n8n:latest                   Up
hosting_prometheus        prom/prometheus:latest             Up
hosting_grafana           grafana/grafana:latest             Up
hosting_adminer           adminer:latest                     Up
hosting_redis_commander   rediscommander/redis-commander     Up
```

### 5. Access Web Interfaces

Once all services are running, you can access them:

| Service | URL | Credentials |
|---------|-----|-------------|
| **n8n (Workflows)** | http://localhost:5678 | Username: admin<br>Password: (from .env N8N_PASSWORD) |
| **Grafana (Monitoring)** | http://localhost:3001 | Username: admin<br>Password: (from .env GRAFANA_PASSWORD) |
| **Prometheus (Metrics)** | http://localhost:9090 | No authentication |
| **Adminer (Database UI)** | http://localhost:8081 | System: PostgreSQL<br>Server: postgres<br>Username: hosting_dev<br>Password: (from .env POSTGRES_PASSWORD)<br>Database: hosting_platform |
| **Redis Commander** | http://localhost:8082 | No authentication |

**Test database connection:**
```bash
# Using psql inside the container
docker compose exec postgres psql -U hosting_dev -d hosting_platform

# You should see the PostgreSQL prompt:
hosting_platform=#

# Test query
\l  # List databases
\q  # Quit
```

**Test Redis connection:**
```bash
# Using redis-cli inside the container
docker compose exec redis redis-cli -a "your_redis_password_from_env"

# Test commands
PING  # Should return PONG
INFO server
EXIT
```

### 6. Manage Services

```bash
# Stop all services
docker compose down

# Stop and remove volumes (WARNING: deletes all data!)
docker compose down -v

# Restart a specific service
docker compose restart postgres

# View resource usage
docker stats

# View logs in real-time
docker compose logs -f

# Pull latest images
docker compose pull

# Rebuild containers
docker compose up -d --build
```

### 7. Database Initialization (Optional)

If you need to initialize the database with schemas or seed data:

```bash
# Create init-scripts directory if it doesn't exist
mkdir -p /opt/next-js-panel/homelab/init-scripts

# Add your SQL scripts
nano /opt/next-js-panel/homelab/init-scripts/01-init-schema.sql
```

Example `01-init-schema.sql`:
```sql
-- Create tables for the hosting platform
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    plan VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Apply initialization scripts:**
```bash
# Stop PostgreSQL
docker compose stop postgres

# Remove the container (data persists in volume)
docker compose rm -f postgres

# Start PostgreSQL (will run init scripts)
docker compose up -d postgres

# Check logs
docker compose logs postgres
```

### 8. Troubleshooting Service Deployment

**PostgreSQL won't start:**
```bash
# Check logs
docker compose logs postgres

# Common issues:
# 1. Port 5432 already in use
sudo lsof -i :5432  # Check what's using the port
sudo systemctl stop postgresql  # Stop system PostgreSQL if installed

# 2. Permission issues
sudo chown -R 999:999 /var/lib/docker/volumes/homelab_postgres_data/_data

# 3. Corrupted data volume
docker compose down
docker volume rm homelab_postgres_data
docker compose up -d postgres
```

**Redis authentication errors:**
```bash
# Verify password in .env matches docker-compose.yml
grep REDIS_PASSWORD .env

# Restart Redis
docker compose restart redis
```

**n8n not accessible:**
```bash
# Check if PostgreSQL is healthy (n8n depends on it)
docker compose ps postgres

# Check n8n logs
docker compose logs n8n

# Restart n8n
docker compose restart n8n
```

**Services using too much CPU/RAM:**
```bash
# Check resource usage
docker stats

# Add resource limits to docker-compose.yml (see Section 3.2 below)
```

**Network creation fails: "all predefined address pools have been fully subnetted":**
```bash
# This happens when Docker has exhausted its IP address ranges
# Solution 1: Clean up unused networks (RECOMMENDED)
docker network prune -f

# Solution 2: Remove specific unused networks
docker network ls
docker network rm network_name

# Solution 3: If you have many old containers/networks, clean everything
docker system prune -a --volumes
# WARNING: This removes ALL stopped containers, unused networks, and volumes

# After cleanup, try starting services again
docker compose up -d

# Verify network was created with custom subnet
docker network inspect homelab_hosting_network
```

---

## 🗄️ PostgreSQL Optimization

Your PostgreSQL data will be stored in `/var/lib/postgresql` (150GB XFS). Let's optimize it.

### 1. XFS Mount Options for PostgreSQL

Check current mount options:
```bash
mount | grep postgresql
```

Add optimizations to `/etc/fstab`:
```bash
sudo nano /etc/fstab
```

Find the line for `/var/lib/postgresql` and ensure it has these options:
```text
/dev/ubuntu-vg/postgresql_lv /var/lib/postgresql xfs defaults,noatime,nodiratime,largeio,inode64 0 2
```

**Explanation:**
- `noatime,nodiratime` - Don't update access times (reduces writes)
- `largeio` - Optimize for large I/O operations
- `inode64` - Allow 64-bit inode numbers (better for large filesystems)

Apply changes:
```bash
# Remount (if PostgreSQL is not running)
sudo mount -o remount /var/lib/postgresql

# Verify
mount | grep postgresql
```

### 2. PostgreSQL System Tuning

Create sysctl configuration for PostgreSQL:
```bash
sudo tee /etc/sysctl.d/99-postgresql.conf > /dev/null <<'EOF'
# PostgreSQL Performance Tuning

# Shared memory settings (for PostgreSQL shared_buffers)
# Optimized for 64GB RAM system
kernel.shmmax = 34359738368  # 32GB in bytes (50% of RAM)
kernel.shmall = 8388608      # 32GB in pages (4KB pages)

# Increase semaphore limits
kernel.sem = 250 32000 100 128

# Network tuning
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728

# File handle limits
fs.file-max = 2097152

# Virtual memory
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
vm.overcommit_memory = 2
EOF

# Apply settings
sudo sysctl -p /etc/sysctl.d/99-postgresql.conf
```

### 3. PostgreSQL Docker Container Optimization

When running PostgreSQL in Docker, use these environment variables and configs:

Create `homelab/postgres-config/postgresql.conf`:
```bash
mkdir -p homelab/postgres-config
```

```bash
cat > homelab/postgres-config/postgresql.conf <<'EOF'
# PostgreSQL Configuration for Development
# Optimized for 16-64GB RAM system with dedicated 150GB XFS volume

# CONNECTIONS
max_connections = 200
superuser_reserved_connections = 5

# MEMORY (optimized for 64GB RAM + 4-core i5-6500 system)
# With 64GB RAM, we can be generous with memory settings

shared_buffers = 16GB               # 25% of 64GB RAM
effective_cache_size = 48GB         # 75% of 64GB RAM (OS will cache)
work_mem = 64MB                     # Higher work_mem for complex queries
maintenance_work_mem = 2GB          # For VACUUM, CREATE INDEX (limited by 4 cores)
max_stack_depth = 7MB               # Default, safe value

# CHECKPOINT
checkpoint_completion_target = 0.9
wal_buffers = 16MB
min_wal_size = 1GB
max_wal_size = 4GB

# QUERY PLANNER
random_page_cost = 1.1              # SSD optimization (default 4.0)
effective_io_concurrency = 200      # SSD (default 1)

# LOGGING
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log'
log_rotation_age = 1d
log_rotation_size = 100MB
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_duration = off
log_lock_waits = on
log_statement = 'ddl'
log_temp_files = 0

# AUTOVACUUM (optimized for 4-core CPU)
autovacuum = on
autovacuum_max_workers = 2          # Reduced from 4 to avoid CPU contention
autovacuum_naptime = 30s
autovacuum_vacuum_threshold = 50
autovacuum_analyze_threshold = 50
autovacuum_vacuum_cost_delay = 10ms # Reduce I/O impact

# CLIENT CONNECTION DEFAULTS
timezone = 'UTC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'
EOF
```

Update your `docker-compose.yml` to use this config:
```yaml
services:
  postgres:
    image: postgres:16-alpine
    container_name: hosting_postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./postgres-config/postgresql.conf:/etc/postgresql/postgresql.conf
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
    # ... rest of config
```

---

## ⚡ System Performance Tuning

### 1. XFS Optimizations for Docker Volume

```bash
sudo nano /etc/fstab
```

Optimize Docker volume mount options:
```text
/dev/ubuntu-vg/docker_lv /var/lib/docker xfs defaults,noatime,nodiratime,logbufs=8,logbsize=256k 0 2
```

**Explanation:**
- `logbufs=8` - Increase log buffers (default 8, max 8)
- `logbsize=256k` - Increase log buffer size for better write performance

Remount:
```bash
sudo mount -o remount /var/lib/docker
```

### 2. I/O Scheduler Optimization

For SSDs, use `none` or `mq-deadline` scheduler:

```bash
# Check current scheduler
cat /sys/block/sda/queue/scheduler  # Replace sda with your disk

# Set scheduler permanently
sudo tee /etc/udev/rules.d/60-ioschedulers.rules > /dev/null <<'EOF'
# Set I/O scheduler for SSD
ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

# Set I/O scheduler for HDD
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### 3. Disable Unnecessary Services

```bash
# List all services
systemctl list-unit-files --type=service --state=enabled

# Disable unnecessary services (adjust based on your needs)
sudo systemctl disable snapd
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable avahi-daemon

# Stop them now
sudo systemctl stop snapd
sudo systemctl stop bluetooth
sudo systemctl stop cups
sudo systemctl stop avahi-daemon
```

### 4. CPU Governor and Frequency Scaling

Your Intel i5-6500 supports Intel Speed Shift (HWP), which is better than traditional governors:

```bash
# Check current governor and available governors
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Install cpufrequtils
sudo apt install -y cpufrequtils linux-tools-generic

# Check if Intel P-State is active (recommended for Skylake)
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver
# Should show: intel_pstate

# If intel_pstate is active, use performance mode
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

# Or for balanced performance/power, use powersave with performance bias
sudo tee /etc/default/cpufrequtils > /dev/null <<'EOF'
GOVERNOR="powersave"
MIN_SPEED="3200000"  # 3.2 GHz minimum
MAX_SPEED="3600000"  # 3.6 GHz maximum
EOF

# Restart service
sudo systemctl restart cpufrequtils

# Verify current frequency and governor
watch -n 1 "grep MHz /proc/cpuinfo | head -4 && cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
```

**Intel-specific tuning**:
```bash
# Enable Intel Turbo Boost (should be on by default)
cat /sys/devices/system/cpu/intel_pstate/no_turbo
# Should be 0 (turbo enabled)

# If disabled, enable it
echo 0 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

# Set energy performance preference (intel_pstate only)
for cpu in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
    echo "performance" | sudo tee $cpu
done

# Verify
cat /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference
```

### 5. Increase File Limits

```bash
# Edit limits
sudo nano /etc/security/limits.conf
```

Add these lines:
```text
*    soft nofile 65535
*    hard nofile 65535
*    soft nproc  65535
*    hard nproc  65535
root soft nofile 65535
root hard nofile 65535
root soft nproc  65535
root hard nproc  65535
```

Apply (logout/login required):
```bash
# Verify
ulimit -n
ulimit -u
```

---

## 🔒 Security Hardening

### 1. Configure Firewall (UFW)

```bash
# Install UFW
sudo apt install -y ufw

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (CRITICAL - do this first!)
sudo ufw allow 22/tcp comment 'SSH'

# Allow Docker Compose services (localhost only)
sudo ufw allow from 127.0.0.1 to any port 5432 comment 'PostgreSQL local'
sudo ufw allow from 127.0.0.1 to any port 6379 comment 'Redis local'
sudo ufw allow from 127.0.0.1 to any port 5678 comment 'n8n local'

# If accessing from local network (adjust to your subnet)
sudo ufw allow from 192.168.1.0/24 to any port 5678 comment 'n8n from LAN'
sudo ufw allow from 192.168.1.0/24 to any port 3001 comment 'Grafana from LAN'
sudo ufw allow from 192.168.1.0/24 to any port 9090 comment 'Prometheus from LAN'

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

### 2. Fail2Ban for SSH Protection

```bash
# Install fail2ban
sudo apt install -y fail2ban

# Create local config
sudo tee /etc/fail2ban/jail.local > /dev/null <<'EOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = your-email@example.com
sendername = Fail2Ban

[sshd]
enabled = true
port = 22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400
EOF

# Start and enable
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Check status
sudo fail2ban-client status sshd
```

### 3. SSH Hardening

```bash
# Backup SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit SSH config
sudo nano /etc/ssh/sshd_config
```

Recommended settings:
```text
# Basic settings
Port 22
Protocol 2
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication yes  # Set to 'no' after setting up SSH keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Security settings
X11Forwarding no
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2

# Limit users (optional)
AllowUsers your-username

# Logging
SyslogFacility AUTH
LogLevel VERBOSE
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

### 4. Automatic Security Updates

Already configured in Initial Setup, but verify:
```bash
sudo systemctl status unattended-upgrades
```

---

## 🏗️ Build Optimization for 4-Core CPU

When building applications (RUST, Go, Node.js) on your 4-core system:

### RUST Build Optimization

```bash
# Set build jobs in ~/.cargo/config.toml
mkdir -p ~/.cargo
cat > ~/.cargo/config.toml <<'EOF'
[build]
jobs = 3              # Use 3 cores, leave 1 for system

[profile.dev]
opt-level = 1         # Faster compilation in dev mode

[profile.release]
lto = "thin"          # Faster linking than full LTO
codegen-units = 4     # Parallel code generation
EOF
```

### Go Build Optimization

```bash
# Use GOMAXPROCS to limit Go build parallelism
export GOMAXPROCS=3

# Add to ~/.bashrc or ~/.zshrc
echo 'export GOMAXPROCS=3' >> ~/.bashrc
```

### Node.js/Next.js Build Optimization

```bash
# Limit Node.js build workers
export UV_THREADPOOL_SIZE=3

# For Next.js builds
# Add to package.json scripts:
# "build": "NODE_OPTIONS='--max-old-space-size=4096' next build"

# Add to ~/.bashrc
echo 'export UV_THREADPOOL_SIZE=3' >> ~/.bashrc
```

### Docker Build Optimization

```bash
# Limit build parallelism
docker build --build-arg JOBS=2 -t myimage .

# Or in Dockerfile:
# ARG JOBS=2
# RUN make -j${JOBS}
```

---

## 📊 Monitoring Setup

### 1. Install System Monitoring Tools

```bash
# Install monitoring tools
sudo apt install -y \
    htop \
    iotop \
    iftop \
    nethogs \
    sysstat \
    ncdu \
    glances

# Enable sysstat
sudo systemctl enable sysstat
sudo systemctl start sysstat
```

### 2. Docker Stats Monitoring Script

Create monitoring script:
```bash
cat > ~/bin/docker-stats.sh <<'EOF'
#!/bin/bash
# Docker container resource monitoring

echo "=== Docker Container Stats ==="
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

echo -e "\n=== Docker Disk Usage ==="
docker system df

echo -e "\n=== PostgreSQL Container Logs (last 10 lines) ==="
docker logs --tail 10 hosting_postgres 2>&1 | tail -10

echo -e "\n=== Redis Container Status ==="
docker exec hosting_redis redis-cli -a "${REDIS_PASSWORD:-dev_redis_password}" INFO | grep -E "(uptime_in_seconds|used_memory_human|connected_clients)"
EOF

chmod +x ~/bin/docker-stats.sh
mkdir -p ~/bin
```

Run it:
```bash
~/bin/docker-stats.sh
```

### 3. Disk Space Monitoring

```bash
cat > ~/bin/check-disk-space.sh <<'EOF'
#!/bin/bash
# Check disk space on all volumes

echo "=== Disk Usage by Volume ==="
df -h | grep -E "(Filesystem|/dev/mapper|/dev/sd|/dev/nvme)"

echo -e "\n=== LVM Volume Group Status ==="
sudo vgs

echo -e "\n=== LVM Logical Volumes ==="
sudo lvs

echo -e "\n=== Top 10 Largest Directories in /var/lib/docker ==="
sudo du -h /var/lib/docker 2>/dev/null | sort -rh | head -10

echo -e "\n=== Top 10 Largest Directories in /var/lib/postgresql ==="
sudo du -h /var/lib/postgresql 2>/dev/null | sort -rh | head -10

echo -e "\n=== Docker Disk Usage ==="
docker system df -v
EOF

chmod +x ~/bin/check-disk-space.sh
```

Run it:
```bash
~/bin/check-disk-space.sh
```

### 4. Setup Log Rotation

PostgreSQL and Docker logs are already rotated, but let's configure custom rotation:

```bash
sudo tee /etc/logrotate.d/homelab-custom > /dev/null <<'EOF'
/var/log/homelab/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
    sharedscripts
}
EOF
```

---

## 💾 Backup Configuration

### 1. Backup Script for PostgreSQL

```bash
cat > ~/bin/backup-postgres.sh <<'EOF'
#!/bin/bash
# PostgreSQL backup script

BACKUP_DIR="/data/backups/postgresql"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup all databases
echo "Starting PostgreSQL backup..."
docker exec hosting_postgres pg_dumpall -U hosting_dev | gzip > "$BACKUP_DIR/postgres_all_${TIMESTAMP}.sql.gz"

if [ $? -eq 0 ]; then
    echo "Backup completed: $BACKUP_DIR/postgres_all_${TIMESTAMP}.sql.gz"

    # Remove old backups
    find "$BACKUP_DIR" -name "postgres_all_*.sql.gz" -mtime +$RETENTION_DAYS -delete
    echo "Old backups (>$RETENTION_DAYS days) removed"
else
    echo "Backup failed!" >&2
    exit 1
fi

# Backup Docker volumes
echo "Backing up Docker volumes..."
docker run --rm \
    -v hosting_postgres_data:/source:ro \
    -v /data/backups/docker:/backup \
    alpine tar czf /backup/postgres_volume_${TIMESTAMP}.tar.gz -C /source .

echo "Docker volume backup completed"
EOF

chmod +x ~/bin/backup-postgres.sh
```

### 2. Backup Script for All Docker Data

```bash
cat > ~/bin/backup-docker.sh <<'EOF'
#!/bin/bash
# Backup all Docker volumes and configs

BACKUP_DIR="/data/backups/docker"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

echo "Stopping Docker containers..."
cd ~/next-js-panel/homelab
docker compose down

echo "Backing up Docker volumes..."
sudo tar czf "$BACKUP_DIR/docker_volumes_${TIMESTAMP}.tar.gz" \
    -C /var/lib/docker/volumes .

echo "Backing up configurations..."
tar czf "$BACKUP_DIR/docker_configs_${TIMESTAMP}.tar.gz" \
    -C ~/next-js-panel/homelab .

echo "Starting Docker containers..."
docker compose up -d

# Remove old backups
find "$BACKUP_DIR" -name "docker_*_*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $BACKUP_DIR"
du -sh "$BACKUP_DIR"
EOF

chmod +x ~/bin/backup-docker.sh
```

### 3. Automated Backups with Cron

```bash
# Edit crontab
crontab -e
```

Add these lines:
```text
# Daily PostgreSQL backup at 2 AM
0 2 * * * /home/your-username/bin/backup-postgres.sh >> /var/log/homelab/backup-postgres.log 2>&1

# Weekly full Docker backup (Sunday at 3 AM)
0 3 * * 0 /home/your-username/bin/backup-docker.sh >> /var/log/homelab/backup-docker.log 2>&1

# Daily disk space check at 8 AM
0 8 * * * /home/your-username/bin/check-disk-space.sh >> /var/log/homelab/disk-space.log 2>&1
```

Create log directory:
```bash
sudo mkdir -p /var/log/homelab
sudo chown $USER:$USER /var/log/homelab
```

---

## 🔧 Maintenance Scripts

### 1. Docker Cleanup Script

```bash
cat > ~/bin/docker-cleanup.sh <<'EOF'
#!/bin/bash
# Clean up Docker resources

echo "=== Docker Cleanup ==="

echo "Removing stopped containers..."
docker container prune -f

echo "Removing unused images..."
docker image prune -a -f

echo "Removing unused volumes..."
docker volume prune -f

echo "Removing unused networks..."
docker network prune -f

echo "Removing build cache..."
docker builder prune -a -f

echo -e "\n=== Docker Disk Usage After Cleanup ==="
docker system df

echo -e "\n=== Disk Space on /var/lib/docker ==="
df -h /var/lib/docker
EOF

chmod +x ~/bin/docker-cleanup.sh
```

### 2. System Update Script

```bash
cat > ~/bin/system-update.sh <<'EOF'
#!/bin/bash
# System update and cleanup script

echo "=== System Update ==="

echo "Updating package lists..."
sudo apt update

echo "Upgrading packages..."
sudo apt upgrade -y

echo "Removing unused packages..."
sudo apt autoremove -y

echo "Cleaning package cache..."
sudo apt autoclean

echo "Checking for distribution upgrade..."
sudo apt dist-upgrade -y

echo -e "\n=== System Info ==="
uname -a
lsb_release -a

echo -e "\n=== Disk Space ==="
df -h | grep -E "(Filesystem|/dev/mapper)"

echo "Update completed!"
EOF

chmod +x ~/bin/system-update.sh
```

### 3. Health Check Script

```bash
cat > ~/bin/health-check.sh <<'EOF'
#!/bin/bash
# Comprehensive health check

echo "=== System Health Check ==="
echo "Timestamp: $(date)"

echo -e "\n1. System Uptime:"
uptime

echo -e "\n2. Memory Usage:"
free -h

echo -e "\n3. Disk Usage:"
df -h | grep -E "(Filesystem|/dev/mapper)"

echo -e "\n4. CPU Load:"
cat /proc/loadavg

echo -e "\n5. Docker Service Status:"
systemctl status docker --no-pager | head -3

echo -e "\n6. Running Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Size}}"

echo -e "\n7. PostgreSQL Status:"
docker exec hosting_postgres pg_isready -U hosting_dev

echo -e "\n8. Redis Status:"
docker exec hosting_redis redis-cli -a "${REDIS_PASSWORD:-dev_redis_password}" PING

echo -e "\n9. Top 5 Processes by CPU:"
ps aux --sort=-%cpu | head -6

echo -e "\n10. Top 5 Processes by Memory:"
ps aux --sort=-%mem | head -6

echo -e "\n11. Network Connections:"
ss -tuln | grep LISTEN | grep -E "(5432|6379|5678|3001|9090)"

echo -e "\n=== Health Check Complete ==="
EOF

chmod +x ~/bin/health-check.sh
```

Run health check:
```bash
~/bin/health-check.sh
```

---

## 📈 Performance Monitoring

### 1. Install and Configure Netdata (Optional)

Netdata provides real-time performance monitoring:

```bash
# Install Netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh) --stable-channel --disable-telemetry

# Configure to start on boot
sudo systemctl enable netdata
sudo systemctl start netdata

# Access at: http://localhost:19999
# Or from LAN: http://your-server-ip:19999
```

Configure firewall for Netdata:
```bash
# Allow from LAN only
sudo ufw allow from 192.168.1.0/24 to any port 19999 comment 'Netdata from LAN'
```

### 2. Enable System Accounting

```bash
# Enable system accounting (already installed sysstat)
sudo systemctl enable sysstat
sudo systemctl start sysstat

# Configure to collect every 5 minutes
sudo nano /etc/cron.d/sysstat
```

Change to:
```text
*/5 * * * * root /usr/lib/sysstat/debian-sa1 1 1
```

View statistics:
```bash
# CPU stats
sar -u 1 5

# Memory stats
sar -r 1 5

# I/O stats
sar -b 1 5

# Network stats
sar -n DEV 1 5
```

---

## 🐛 Troubleshooting

### Common Issues and Solutions

#### 1. Docker Container Won't Start

```bash
# Check container logs
docker logs hosting_postgres
docker logs hosting_redis

# Check Docker daemon status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check disk space
df -h /var/lib/docker
```

#### 2. PostgreSQL Connection Issues

```bash
# Check if PostgreSQL is running
docker ps | grep postgres

# Check PostgreSQL logs
docker logs hosting_postgres

# Connect to PostgreSQL
docker exec -it hosting_postgres psql -U hosting_dev -d hosting_platform

# Check PostgreSQL connections
docker exec hosting_postgres psql -U hosting_dev -c "SELECT * FROM pg_stat_activity;"
```

#### 3. High Disk Usage

```bash
# Check what's using space
sudo ncdu /var/lib/docker
sudo ncdu /var/lib/postgresql

# Clean Docker
~/bin/docker-cleanup.sh

# Check Docker logs size
sudo du -sh /var/lib/docker/containers/*/*.log | sort -rh | head -10

# Truncate large logs
sudo truncate -s 0 /var/lib/docker/containers/*/­*-json.log
```

#### 4. High Memory Usage

```bash
# Check memory usage
free -h

# Check what's using memory
ps aux --sort=-%mem | head -20

# Check Docker container memory
docker stats --no-stream

# Restart containers if needed
cd ~/next-js-panel/homelab
docker compose restart
```

#### 5. LVM Volume Full

```bash
# Check LVM free space
sudo vgs
sudo lvs

# Extend a volume (example: extending /var/lib/docker by 50GB)
sudo lvextend -L +50G /dev/ubuntu-vg/docker_lv
sudo xfs_growfs /var/lib/docker

# Verify
df -h /var/lib/docker
```

---

## 📚 Daily Operations

### Daily Tasks

```bash
# Morning health check
~/bin/health-check.sh

# Check disk space
~/bin/check-disk-space.sh

# Check container status
docker ps
```

### Weekly Tasks

```bash
# System update
~/bin/system-update.sh

# Docker cleanup
~/bin/docker-cleanup.sh

# Full backup
~/bin/backup-docker.sh

# Review logs
sudo journalctl -xe --since "1 week ago" | grep -i error
```

### Monthly Tasks

```bash
# Review and rotate logs
sudo logrotate -f /etc/logrotate.conf

# Check for security updates
sudo apt update
sudo apt list --upgradable

# Review backup integrity
ls -lh /data/backups/

# Update Docker images
cd ~/next-js-panel/homelab
docker compose pull
docker compose up -d
```

---

## 🎯 Quick Reference Commands

### System Info
```bash
# System info
uname -a
lsb_release -a
hostnamectl

# CPU info
lscpu
cat /proc/cpuinfo | grep "model name" | head -1
cat /proc/cpuinfo | grep "cpu MHz"

# Check CPU temperature (if sensors installed)
sudo apt install -y lm-sensors
sudo sensors-detect  # Run once to detect sensors
sensors

# Resource usage
htop
iotop -o
iftop

# Disk usage
df -h
du -sh /*
ncdu /

# LVM info
sudo vgs
sudo lvs
sudo pvs
```

### Docker Commands
```bash
# Start services
cd ~/next-js-panel/homelab && docker compose up -d

# Stop services
cd ~/next-js-panel/homelab && docker compose down

# View logs
docker compose logs -f

# Stats
docker stats

# Cleanup
docker system prune -a
```

### PostgreSQL Commands
```bash
# Connect to PostgreSQL
docker exec -it hosting_postgres psql -U hosting_dev -d hosting_platform

# Backup
~/bin/backup-postgres.sh

# Check size
docker exec hosting_postgres psql -U hosting_dev -c "SELECT pg_size_pretty(pg_database_size('hosting_platform'));"
```

### Redis Commands
```bash
# Connect to Redis
docker exec -it hosting_redis redis-cli -a dev_redis_password

# Info
docker exec hosting_redis redis-cli -a dev_redis_password INFO

# Memory usage
docker exec hosting_redis redis-cli -a dev_redis_password INFO memory
```

---

## 📝 Notes

**Best Practices:**
1. ✅ Always test backup/restore procedures
2. ✅ Monitor disk space regularly (especially `/var/lib/docker` and `/var/lib/postgresql`)
3. ✅ Keep Docker images updated
4. ✅ Review logs weekly for errors
5. ✅ Maintain at least 20% free space on all volumes
6. ✅ Document any configuration changes

**Performance Tips:**
- Your 175GB free LVM space is excellent for expansion
- XFS is optimal for PostgreSQL and Docker
- Consider enabling `nobarrier` on XFS if you have UPS backup
- Monitor I/O wait with `iotop` during heavy loads

**Security Reminders:**
- Change default passwords in `.env` files
- Keep SSH keys secure
- Review firewall rules regularly
- Enable automatic security updates
- Use strong passwords for database users

---

**Created**: 2025-11-12
**Last Updated**: 2025-11-12
**Server**: Terra Office PC (Homelab)
**Purpose**: Development environment for Hosting Panel project
