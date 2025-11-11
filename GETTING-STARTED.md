# Getting Started - Quick Start Guide

**Welcome to the Unified Hosting Control Panel project!**

This guide will help you get started with development in under 30 minutes.

---

## 🎯 Prerequisites Checklist

Before you begin, ensure you have:

- [ ] **Docker** 20.x or later installed
- [ ] **Docker Compose** 2.x or later installed
- [ ] **Git** installed and configured
- [ ] **Node.js** 20.x or later (for frontend development)
- [ ] **RUST** 1.70+ (for API gateway development)
- [ ] **Go** 1.21+ (for microservices development)
- [ ] **GitHub account** with access to this repository
- [ ] **GitHub Copilot** and/or **Claude Code** (optional but recommended)

### Verify Prerequisites

```bash
# Check Docker
docker --version
docker compose version

# Check programming languages
node --version
npm --version
rustc --version
cargo --version
go version

# Check Git
git --version
```

---

## 🚀 Quick Start (5 Minutes)

### 1. Clone the Repository

```bash
git clone https://github.com/xerudro/next-js-panel.git
cd next-js-panel
```

### 2. Start Development Environment

```bash
cd homelab
./quick-start.sh
```

This will:
- Create `.env` from template (you'll be prompted to edit it)
- Start all Docker services (PostgreSQL, Redis, n8n, Prometheus, Grafana)
- Run health checks
- Display access URLs

**Alternative** (using Makefile):
```bash
cd homelab
make init
```

### 3. Verify Services

```bash
make health
make test
```

### 4. Access Services

Open these URLs in your browser:

- **n8n**: http://localhost:5678 (admin/admin)
- **Grafana**: http://localhost:3001 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Adminer**: http://localhost:8081 (PostgreSQL UI)
- **Redis Commander**: http://localhost:8082 (Redis UI)

### 5. Connect to Database

**Using psql** (if installed):
```bash
psql -h localhost -U hosting_dev -d hosting_platform
```

**Using Adminer** (Web UI):
- URL: http://localhost:8081
- System: PostgreSQL
- Server: postgres
- Username: hosting_dev
- Password: (from `.env` file)
- Database: hosting_platform

**Test connection**:
```bash
cd homelab
make shell-postgres
# Then run: \dt (list tables)
```

---

## 📖 Understanding the Project

### Project Documentation

Start by reading these documents in order:

1. **[README.md](README.md)** - Project overview and tech stack
2. **[SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md)** - Your 9-month development roadmap
3. **[PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md)** - Complete directory layout
4. **[USER-STORIES.md](USER-STORIES.md)** - 40 user stories (your product backlog)
5. **[homelab/README.md](homelab/README.md)** - Homelab environment details

### Quick Reference

**Key Files**:
- `SOLO-SPRINT-PLAN.md` - Your week-by-week task list
- `PRODUCT-BACKLOG.csv` - Import into project management tool
- `homelab/Makefile` - 20+ helpful commands
- `homelab/docker-compose.yml` - All development services

**Documentation Directory**:
```text
docs/
├── Unified_Hosting_Platform_PRD.md           # Product requirements
├── USER-STORIES.md                            # User stories
├── PRODUCT-BACKLOG-REVIEW.md                  # Backlog analysis
├── SOLO-SPRINT-PLAN.md                        # 9-month plan
└── PROJECT-STRUCTURE.md                       # Code structure
```

---

## 🏗️ Sprint 0: Getting Ready for Development

You are currently in **Pre-Sprint 0** phase. Here's what to do next:

### Week 0: Environment Setup (This Week)

**Tasks**:
- [x] Clone repository *(you just did this)*
- [x] Start homelab services *(you just did this)*
- [ ] Read all documentation
- [ ] Set up your IDE (VS Code recommended)
- [ ] Install recommended extensions
- [ ] Familiarize yourself with the tech stack

**IDE Setup** (VS Code):

```bash
# Recommended extensions
code --install-extension rust-lang.rust-analyzer
code --install-extension golang.go
code --install-extension dbaeumer.vscode-eslint
code --install-extension bradlc.vscode-tailwindcss
code --install-extension GitHub.copilot
```

Create `.vscode/settings.json`:
```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "rust-analyzer.checkOnSave.command": "clippy",
  "go.lintTool": "golangci-lint",
  "typescript.updateImportsOnFileMove.enabled": "always"
}
```

### Week 1-2: Sprint 0 - Infrastructure Foundation

See [SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md) for detailed tasks.

**Sprint 0 Goals**:
1. Set up CI/CD pipeline (GitHub Actions)
2. Create database schema and migrations
3. Initialize project structure

**Get Started**:
```bash
# Review Sprint 0 tasks
cat SOLO-SPRINT-PLAN.md | grep -A 50 "Sprint 0:"

# Or open in browser/editor
```

---

## 🧰 Essential Commands

### Homelab Management

```bash
cd homelab

# Start all services
make up

# Stop all services
make down

# View logs
make logs

# Check service health
make health

# Run connectivity tests
make test

# Backup database
make backup

# Restore database
make restore BACKUP=backups/backup_20250111_120000.sql

# Open PostgreSQL shell
make shell-postgres

# Open Redis CLI
make shell-redis

# Show all available commands
make help
```

### Git Workflow

```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: Add your feature"

# Push to remote
git push -u origin feature/your-feature-name

# Create Pull Request on GitHub
```

### Docker Quick Reference

```bash
# View running containers
docker ps

# View container logs
docker logs -f hosting_postgres
docker logs -f hosting_redis

# Execute command in container
docker exec -it hosting_postgres psql -U hosting_dev

# View resource usage
docker stats

# Clean up
docker system prune -a
```

---

## 🎓 Learning Path

### Week 1: Foundation Knowledge

**Day 1**: Project overview and planning
- [ ] Read README.md
- [ ] Read SOLO-SPRINT-PLAN.md
- [ ] Review USER-STORIES.md

**Day 2**: Technology stack
- [ ] Next.js 16 documentation: [https://nextjs.org/docs](https://nextjs.org/docs)
- [ ] React 19 features: [https://react.dev](https://react.dev)
- [ ] Server Components: [https://nextjs.org/docs/app/building-your-application/rendering/server-components](https://nextjs.org/docs/app/building-your-application/rendering/server-components)

**Day 3**: Backend technologies
- [ ] RUST basics: [https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/)
- [ ] Actix-web: [https://actix.rs](https://actix.rs)
- [ ] Go basics: [https://go.dev/tour/](https://go.dev/tour/)

**Day 4**: Database and infrastructure
- [ ] PostgreSQL tutorial: [https://www.postgresql.org/docs/](https://www.postgresql.org/docs/)
- [ ] Docker Compose: [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
- [ ] NGINX basics: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)

**Day 5**: Development workflow
- [ ] GitHub Actions: [https://docs.github.com/en/actions](https://docs.github.com/en/actions)
- [ ] Git workflow best practices
- [ ] Testing strategies

### Resources by Technology

**Next.js & React**:
- [Next.js 15 Docs]([https://nextjs.org/docs](https://nextjs.org/docs))
- [React 19 Docs]([https://react.dev](https://react.dev))
- [Tailwind CSS]([https://tailwindcss.com/docs](https://tailwindcss.com/docs))
- [TypeScript Handbook]([https://www.typescriptlang.org/docs/](https://www.typescriptlang.org/docs/))

**RUST**:
- [The Rust Book]([https://doc.rust-lang.org/book/](https://doc.rust-lang.org/book/))
- [Rust by Example]([https://doc.rust-lang.org/rust-by-example/](https://doc.rust-lang.org/rust-by-example/))
- [Actix Web Guide]([https://actix.rs/docs/](https://actix.rs/docs/))
- [SQLx Documentation]([https://docs.rs/sqlx/latest/sqlx/](https://docs.rs/sqlx/latest/sqlx/))

**Go**:
- [Go Tour]([https://go.dev/tour/](https://go.dev/tour/))
- [Effective Go]([https://go.dev/doc/effective_go](https://go.dev/doc/effective_go))
- [Fiber Framework]([https://docs.gofiber.io](https://docs.gofiber.io))
- [GORM ORM]([https://gorm.io/docs/](https://gorm.io/docs/))

**DevOps**:
- [Docker Documentation]([https://docs.docker.com](https://docs.docker.com))
- [PostgreSQL Docs]([https://www.postgresql.org/docs/](https://www.postgresql.org/docs/))
- [n8n Documentation]([https://docs.n8n.io/](https://docs.n8n.io/))
- [Prometheus Docs]([https://prometheus.io/docs/](https://prometheus.io/docs/))

---

## 💡 Development Tips

### 1. Use AI Tools Extensively

**GitHub Copilot**:
- Enable in your IDE
- Use for boilerplate generation
- Let it suggest unit tests
- Accept suggestions for type definitions

**Claude Code**:
- Use for architecture decisions
- Get help with complex algorithms
- Debug difficult issues
- Review code before committing

**Expected productivity boost**: 30-40% faster development

### 2. Follow the Weekly Theme

**Backend Week** (odd weeks):
- Focus on RUST and Go code
- Write APIs and business logic
- Don't context-switch to frontend

**Frontend Week** (even weeks):
- Focus on Next.js and React
- Build UI components
- Integrate with APIs

This reduces cognitive load and improves focus.

### 3. Write Tests as You Go

Don't defer testing to the end. Write tests immediately after implementing features:

```bash
# RUST
cargo test

# Go
go test ./...

# Next.js
npm test
npm run test:e2e
```

### 4. Commit Frequently

Small, frequent commits are better than large ones:

```bash
# Good
git commit -m "feat: Add user authentication endpoint"
git commit -m "test: Add user authentication tests"

# Not as good
git commit -m "feat: Add entire user management system"
```

### 5. Use the Makefile

The homelab Makefile has 20+ helpful commands. Use them!

```bash
cd homelab
make help        # See all commands
make up          # Start services
make logs        # View logs
make backup      # Backup database
```

---

## 🐛 Troubleshooting

### Services Won't Start

**Problem**: `docker compose up -d` fails

**Solutions**:
1. Check Docker is running: `docker ps`
2. Check for port conflicts: `sudo lsof -i :5432` (Linux/Mac)
3. Check logs: `docker compose logs postgres`
4. Remove volumes and restart: `docker compose down -v && docker compose up -d`

### Can't Connect to Database

**Problem**: Connection refused on port 5432

**Solutions**:
1. Check PostgreSQL is running: `docker compose ps postgres`
2. Check PostgreSQL logs: `docker compose logs postgres`
3. Verify credentials in `.env` file
4. Test with: `make shell-postgres`

### n8n Won't Load

**Problem**: http://localhost:5678 not accessible

**Solutions**:
1. Check n8n is running: `docker compose ps n8n`
2. Check n8n logs: `docker compose logs n8n`
3. Wait a few more seconds (can take 10-15 seconds to start)
4. Restart: `docker compose restart n8n`

### Out of Disk Space

**Problem**: Docker uses too much disk

**Solutions**:
```bash
# Check disk usage
docker system df

# Clean up
docker system prune -a
docker volume prune
```

### More Help

1. Check [homelab/README.md](homelab/README.md) troubleshooting section
2. Check service logs: `make logs`
3. Run health checks: `make health`
4. Create GitHub issue with logs

---

## 📞 Getting Help

### Documentation

- **Homelab**: [homelab/README.md](homelab/README.md)
- **Sprint Plan**: [SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md)
- **Project Structure**: [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md)
- **User Stories**: [USER-STORIES.md](USER-STORIES.md)

### Community Resources

- **Next.js Discord**: [https://nextjs.org/discord](https://nextjs.org/discord)
- **Rust Users Forum**: [https://users.rust-lang.org/](https://users.rust-lang.org/)
- **Go Forum**: [https://forum.golangbridge.org/](https://forum.golangbridge.org/)
- **Stack Overflow**: Tag your questions appropriately

### Project Issues

Create a GitHub issue: [https://github.com/xerudro/next-js-panel/issues](https://github.com/xerudro/next-js-panel/issues)

---

## ✅ Next Steps Checklist

After completing this guide:

- [ ] Homelab environment running successfully
- [ ] Accessed all web UIs (n8n, Grafana, Adminer)
- [ ] Connected to PostgreSQL database
- [ ] Read project documentation (README, Sprint Plan)
- [ ] Set up IDE with recommended extensions
- [ ] Understand the 9-month development timeline
- [ ] Ready to begin Sprint 0, Week 1

**You're now ready to start development!** 🎉

Proceed to [SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md) and begin **Sprint 0, Week 1, Day 1**.

---

**Last Updated**: 2025-11-11
**Status**: Pre-Sprint 0
**Next**: Begin Sprint 0 - Infrastructure Foundation
