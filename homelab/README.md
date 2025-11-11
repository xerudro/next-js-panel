# Homelab Development Environment

Complete Docker Compose setup for local development on your Terra Office PC homelab.

## 📦 Services Included

| Service | Port | Purpose | Admin Access |
|---------|------|---------|--------------|
| PostgreSQL 16 | 5432 | Primary database | - |
| Redis 7.2 | 6379 | Session storage & caching | - |
| n8n | 5678 | Workflow automation | admin/admin |
| Prometheus | 9090 | Metrics collection | http://localhost:9090 |
| Grafana | 3001 | Monitoring dashboards | admin/admin |
| Adminer | 8081 | Database UI | http://localhost:8081 |
| Redis Commander | 8082 | Redis UI | http://localhost:8082 |

## 🚀 Quick Start

### 1. Prerequisites

- Docker 20.x or later
- Docker Compose 2.x or later
- At least 4GB RAM available
- 20GB disk space

Check versions:
```bash
docker --version
docker compose version
```

### 2. Initial Setup

Clone and navigate to the homelab directory:
```bash
cd /path/to/next-js-panel/homelab
```

Create environment file:
```bash
cp .env.example .env
```

Edit `.env` and update passwords:
```bash
nano .env
# or
vim .env
```

**Important**: Change all default passwords in `.env` before starting!

### 3. Start Services

Start all services:
```bash
docker compose up -d
```

Check service status:
```bash
docker compose ps
```

View logs:
```bash
docker compose logs -f
```

View logs for specific service:
```bash
docker compose logs -f postgres
docker compose logs -f n8n
```

### 4. Verify Services

Check PostgreSQL:
```bash
docker compose exec postgres psql -U hosting_dev -d hosting_platform -c "SELECT version();"
```

Check Redis:
```bash
docker compose exec redis redis-cli -a dev_redis_password PING
```

Access web UIs:
- **n8n**: http://localhost:5678 (admin/admin)
- **Grafana**: http://localhost:3001 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Adminer**: http://localhost:8081
- **Redis Commander**: http://localhost:8082

## 🗄️ Database Management

### Connect to PostgreSQL

From host machine:
```bash
psql -h localhost -U hosting_dev -d hosting_platform
```

From Docker:
```bash
docker compose exec postgres psql -U hosting_dev -d hosting_platform
```

Using Adminer:
- URL: http://localhost:8081
- System: PostgreSQL
- Server: postgres
- Username: hosting_dev
- Password: (from .env)
- Database: hosting_platform

### Run Migrations

When you have migration scripts:
```bash
# From your API gateway directory
sqlx migrate run --database-url postgresql://hosting_dev:dev_password@localhost:5432/hosting_platform
```

### Backup Database

Manual backup:
```bash
docker compose exec postgres pg_dump -U hosting_dev hosting_platform > backup_$(date +%Y%m%d_%H%M%S).sql
```

Restore backup:
```bash
docker compose exec -T postgres psql -U hosting_dev hosting_platform < backup_20250111_120000.sql
```

### Reset Database

**Warning**: This will delete all data!
```bash
docker compose down -v
docker compose up -d postgres
```

## 📊 Monitoring Setup

### Prometheus Configuration

The `prometheus.yml` file is configured to scrape metrics from:
- Prometheus itself (port 9090)
- API Gateway (port 8080)
- Go Microservices (ports 8081-8084)
- Next.js app (port 3000)
- n8n (port 5678)

To add custom scrape targets, edit `prometheus.yml` and restart:
```bash
docker compose restart prometheus
```

### Grafana Dashboards

Access Grafana at http://localhost:3001 (admin/admin)

**Add Prometheus as Data Source**:
1. Go to Configuration → Data Sources
2. Click "Add data source"
3. Select "Prometheus"
4. URL: `http://prometheus:9090`
5. Click "Save & Test"

**Import Dashboards**:
1. Go to Dashboards → Import
2. Use dashboard IDs:
   - **PostgreSQL**: 9628 (PostgreSQL Database)
   - **Redis**: 11835 (Redis Dashboard)
   - **Node Exporter**: 1860 (Node Exporter Full)
   - **Go Services**: 10826 (Go Metrics)

## 🔧 n8n Workflow Automation

Access n8n at http://localhost:5678 (admin/admin)

### Example Workflows to Create

**1. Invoice Generation Workflow**:
- Trigger: Webhook from billing service
- Action: Generate PDF invoice
- Action: Send email via SMTP

**2. Customer Onboarding**:
- Trigger: New customer created
- Action: Send welcome email
- Action: Create default website
- Action: Notify admin

**3. Backup Notifications**:
- Trigger: Daily schedule (cron)
- Action: Check backup status
- Action: Send notification if failed

**4. Payment Reminders**:
- Trigger: Daily schedule
- Action: Check overdue invoices
- Action: Send reminder emails

### Database Connection in n8n

n8n is configured to use PostgreSQL for storing workflows.

To connect n8n to your application database:
1. Create new PostgreSQL node in workflow
2. Host: `postgres`
3. Port: `5432`
4. Database: `hosting_platform`
5. User: `hosting_dev`
6. Password: (from .env)

## 🔍 Redis Management

### Redis CLI

Access Redis CLI:
```bash
docker compose exec redis redis-cli -a dev_redis_password
```

Common commands:
```bash
# List all keys
KEYS *

# Get key value
GET key_name

# Set key value
SET key_name "value"

# Delete key
DEL key_name

# Check memory usage
INFO memory

# Monitor commands in real-time
MONITOR
```

### Redis Commander UI

Access at http://localhost:8082

Features:
- Browse all keys
- Edit values
- View memory usage
- Execute commands

## 🐳 Docker Management

### Start/Stop Services

Start all:
```bash
docker compose up -d
```

Stop all:
```bash
docker compose down
```

Stop and remove volumes (deletes data):
```bash
docker compose down -v
```

Restart specific service:
```bash
docker compose restart postgres
```

### View Logs

All services:
```bash
docker compose logs -f
```

Specific service:
```bash
docker compose logs -f postgres
docker compose logs -f redis
docker compose logs -f n8n
```

Last 100 lines:
```bash
docker compose logs --tail=100 postgres
```

### Resource Usage

View resource consumption:
```bash
docker stats
```

View disk usage:
```bash
docker system df
```

Clean up unused resources:
```bash
docker system prune -a
```

### Update Services

Pull latest images:
```bash
docker compose pull
```

Recreate containers:
```bash
docker compose up -d --force-recreate
```

## 🔐 Security Notes

### Development Environment

This setup is for **development only**. Do not expose these services to the internet!

**Default Security Measures**:
- All services on localhost only
- Basic authentication enabled (n8n, Grafana)
- Redis password protected
- PostgreSQL password protected

### Production Considerations

When moving to production (AX 43):
- Use strong, unique passwords (32+ characters)
- Enable SSL/TLS for all connections
- Use Docker secrets instead of .env
- Configure firewall rules
- Enable audit logging
- Regular security updates
- Backup encryption

## 📁 Directory Structure

```
homelab/
├── docker-compose.yml          # Main Docker Compose configuration
├── prometheus.yml              # Prometheus scrape configuration
├── .env                        # Environment variables (create from .env.example)
├── .env.example                # Environment template
├── README.md                   # This file
├── init-scripts/               # PostgreSQL init scripts (optional)
├── n8n-workflows/              # n8n workflow exports (optional)
├── grafana-dashboards/         # Grafana dashboard configs (optional)
└── grafana-datasources/        # Grafana datasource configs (optional)
```

## 🧪 Testing the Setup

### 1. Health Checks

All services should be healthy:
```bash
docker compose ps
```

Expected output:
```
NAME                   STATUS              PORTS
hosting_postgres       Up (healthy)        0.0.0.0:5432->5432/tcp
hosting_redis          Up (healthy)        0.0.0.0:6379->6379/tcp
hosting_n8n            Up                  0.0.0.0:5678->5678/tcp
hosting_prometheus     Up                  0.0.0.0:9090->9090/tcp
hosting_grafana        Up                  0.0.0.0:3001->3000/tcp
```

### 2. Database Connection Test

Create test table:
```bash
docker compose exec postgres psql -U hosting_dev -d hosting_platform -c "
CREATE TABLE IF NOT EXISTS test (
    id SERIAL PRIMARY KEY,
    message TEXT
);
INSERT INTO test (message) VALUES ('Hello from homelab!');
SELECT * FROM test;
"
```

### 3. Redis Connection Test

Test Redis:
```bash
docker compose exec redis redis-cli -a dev_redis_password SET test "Hello Redis"
docker compose exec redis redis-cli -a dev_redis_password GET test
```

### 4. n8n Workflow Test

1. Access http://localhost:5678
2. Create new workflow
3. Add "Schedule" trigger (every minute)
4. Add "HTTP Request" node
5. URL: http://httpbin.org/get
6. Activate workflow
7. Check executions

## 🐛 Troubleshooting

### PostgreSQL won't start

Check logs:
```bash
docker compose logs postgres
```

Common issues:
- Port 5432 already in use (stop other PostgreSQL)
- Permissions issue (check volume permissions)
- Insufficient memory

Fix permissions:
```bash
docker compose down -v
docker compose up -d postgres
```

### Redis connection refused

Check if Redis is running:
```bash
docker compose ps redis
```

Check Redis logs:
```bash
docker compose logs redis
```

Test connection:
```bash
docker compose exec redis redis-cli -a dev_redis_password PING
```

### n8n can't connect to database

Check n8n logs:
```bash
docker compose logs n8n
```

Verify PostgreSQL is running:
```bash
docker compose ps postgres
```

Restart n8n:
```bash
docker compose restart n8n
```

### Prometheus not scraping targets

Check Prometheus logs:
```bash
docker compose logs prometheus
```

Verify configuration:
```bash
docker compose exec prometheus cat /etc/prometheus/prometheus.yml
```

Check targets in UI:
- Go to http://localhost:9090/targets
- All targets should show "UP" status

### Out of disk space

Check disk usage:
```bash
docker system df
```

Clean up:
```bash
# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove everything unused
docker system prune -a --volumes
```

### Services slow or unresponsive

Check resource usage:
```bash
docker stats
```

Increase Docker resources:
- Docker Desktop: Settings → Resources
- Recommended: 4GB RAM minimum, 8GB preferred

### Can't access web UIs

Check if ports are available:
```bash
# Linux/Mac
sudo lsof -i :5678
sudo lsof -i :3001

# Windows
netstat -ano | findstr :5678
```

Change ports in `docker-compose.yml` if needed:
```yaml
ports:
  - "5679:5678"  # Changed from 5678
```

## 📝 Next Steps

After setting up the homelab:

1. **Verify all services are running**
   ```bash
   docker compose ps
   ```

2. **Create initial database schema**
   - Set up migrations in your API gateway
   - Run initial migration

3. **Configure n8n workflows**
   - Create invoice generation workflow
   - Set up email notifications
   - Configure backup notifications

4. **Set up Grafana dashboards**
   - Import PostgreSQL dashboard
   - Import Redis dashboard
   - Create custom application dashboards

5. **Start development**
   - Clone API gateway repository
   - Clone microservices repositories
   - Clone Next.js frontend repository
   - Update connection strings to point to homelab services

6. **Begin Sprint 0, Week 1**
   - Follow SOLO-SPRINT-PLAN.md
   - Start with CI/CD pipeline setup
   - Implement database schema and migrations

## 🔗 Useful Links

- **Docker Compose Documentation**: https://docs.docker.com/compose/
- **PostgreSQL Documentation**: https://www.postgresql.org/docs/
- **Redis Documentation**: https://redis.io/documentation
- **n8n Documentation**: https://docs.n8n.io/
- **Prometheus Documentation**: https://prometheus.io/docs/
- **Grafana Documentation**: https://grafana.com/docs/

## 💡 Tips

1. **Use Docker Desktop Dashboard**: Visual interface for managing containers
2. **Enable Docker BuildKit**: Faster builds
   ```bash
   export DOCKER_BUILDKIT=1
   ```
3. **Use Docker Compose profiles**: Start only needed services
4. **Regular backups**: Backup PostgreSQL and n8n workflows weekly
5. **Monitor resources**: Keep an eye on disk space and memory
6. **Update images monthly**: Keep services up to date
7. **Use .dockerignore**: Faster builds and smaller images

## 📞 Support

If you encounter issues:
1. Check logs: `docker compose logs -f [service]`
2. Verify configuration: `.env` file and `docker-compose.yml`
3. Check Docker resources: Memory and disk space
4. Restart services: `docker compose restart`
5. Full reset: `docker compose down -v && docker compose up -d`

---

**Created**: 2025-11-11
**Last Updated**: 2025-11-11
**Status**: Ready for Development 🚀
