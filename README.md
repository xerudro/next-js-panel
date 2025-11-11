# Unified Hosting Control Panel - Next.js Edition

**Enterprise hosting control panel with billing automation, reseller management, and advanced security**

[![Status](https://img.shields.io/badge/status-in%20development-yellow)](https://github.com/xerudro/next-js-panel)
[![Stack](https://img.shields.io/badge/stack-Next.js%2016%20%7C%20React%2019%20%7C%20RUST%20%7C%20Go-blue)](https://github.com/xerudro/next-js-panel)
[![Sprint](https://img.shields.io/badge/sprint-Pre--Sprint%200-orange)](SOLO-SPRINT-PLAN.md)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Documentation](#documentation)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Status](#project-status)
- [Development Timeline](#development-timeline)
- [Contributing](#contributing)

---

## 🎯 Overview

A modern, full-featured hosting control panel designed for:
- **Super Admins**: Platform management, server provisioning, billing configuration
- **Resellers**: White-label hosting management, customer billing, support tickets
- **Customers**: Website management, file manager, database tools, email accounts
- **Technical Users**: SSH/SFTP access, PHP configuration, cron jobs, Git integration

### Key Features

- **Multi-tenant Architecture**: Support for resellers with white-label branding
- **Automated Billing**: Stripe integration, invoice generation, auto-renewals
- **Website Hosting**: NGINX-based hosting with PHP-FPM, MySQL, SSL
- **Developer Tools**: SSH, SFTP, Git integration, PHP version management
- **Security**: JWT authentication, 2FA, role-based access control
- **Monitoring**: Prometheus metrics, Grafana dashboards, audit logging

---

## 📚 Documentation

### Product Documentation

| Document | Description | Status |
|----------|-------------|--------|
| [📄 PRD](Unified_Hosting_Platform_PRD.md) | Product Requirements Document | ✅ Complete |
| [📘 Implementation Guide](Unified-Hosting-Platform-Implementation-Guide.md) | Technical implementation details | ✅ Complete |
| [📊 User Stories](USER-STORIES.md) | 40 detailed user stories | ✅ Complete |

### Planning & Roadmap

| Document | Description | Status |
|----------|-------------|--------|
| [📋 Product Backlog Review](PRODUCT-BACKLOG-REVIEW.md) | Comprehensive backlog analysis | ✅ Complete |
| [📊 Product Backlog CSV](PRODUCT-BACKLOG.csv) | 47 stories ready for import | ✅ Complete |
| [📅 Sprint Planning Guide](SPRINT-PLANNING-GUIDE.md) | 6-sprint team plan (14 weeks) | ✅ Complete |
| [🗺️ MVP Roadmap](MVP-ROADMAP.md) | 3-month visual timeline | ✅ Complete |

### Solo Developer Setup

| Document | Description | Status |
|----------|-------------|--------|
| [👤 Solo Developer Setup](SOLO-DEVELOPER-SETUP.md) | Infrastructure & cost analysis | ✅ Complete |
| [🚀 Solo Sprint Plan](SOLO-SPRINT-PLAN.md) | **18-sprint plan (9 months)** | ✅ Complete |
| [🛠️ Homelab Setup](homelab/README.md) | Docker Compose development env | ✅ Complete |

### Production Deployment

| Document | Description | Status |
|----------|-------------|--------|
| [🏗️ Infrastructure Overview](infrastructure/README.md) | Production deployment overview | ✅ Complete |
| [📖 Production Guide](infrastructure/PRODUCTION-DEPLOYMENT.md) | Complete deployment to AX 43 | ✅ Complete |
| [⚙️ systemd Services](infrastructure/systemd/README.md) | Service management with systemd | ✅ Complete |
| [🤖 Ansible Playbooks](infrastructure/ansible/README.md) | Automated deployment | ✅ Complete |

---

## 🛠️ Tech Stack

### Frontend
- **Next.js 16** - App Router, Server Components (RSC)
- **React 19** - Latest features and optimizations
- **TypeScript 5.x** - Type safety
- **Tailwind CSS 4.x** - Utility-first styling
- **Zustand** - State management
- **React Query** - Data fetching and caching
- **React Hook Form + Zod** - Form validation
- **Lucide React** - Icon library

### Backend
- **RUST** - API Gateway (Actix-web / Axum)
- **Go** - Microservices (Fiber framework)
  - User Management Service
  - Billing Service
  - Provisioning Service
  - Email Service
  - Support Ticket Service

### Database & Storage
- **PostgreSQL 16+** - Primary database
- **Redis 7.2+** - Session storage & caching
- **Hetzner Object Storage** - Backups

### Infrastructure
- **Hetzner AX 43** - Production server (8-core, 64GB RAM, 2x512GB NVMe)
- **NGINX 1.26** - Reverse proxy & web server
- **systemd** - Service management (production)
- **Docker Compose** - Development environment only (homelab)
- **Ansible** - Automated deployment
- **GitHub Actions** - CI/CD pipeline

### Monitoring & Automation
- **Prometheus** - Metrics collection
- **Grafana** - Monitoring dashboards
- **n8n** - Workflow automation
- **NATS** - Message broker

---

## 🚀 Getting Started

### Prerequisites

- **Docker** 20.x or later
- **Docker Compose** 2.x or later
- **Node.js** 20.x or later (for Next.js development)
- **RUST** 1.70+ (for API gateway development)
- **Go** 1.21+ (for microservices development)
- **PostgreSQL** 16+ (via Docker or homelab)

### Quick Start (Homelab Development Environment)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/xerudro/next-js-panel.git
   cd next-js-panel
   ```

2. **Set up homelab environment**:
   ```bash
   cd homelab
   make init
   ```
   This will:
   - Create `.env` from template
   - Start all services (PostgreSQL, Redis, n8n, Prometheus, Grafana)
   - Run health checks

3. **Access services**:
   - **n8n**: http://localhost:5678 (admin/admin)
   - **Grafana**: http://localhost:3001 (admin/admin)
   - **Prometheus**: http://localhost:9090
   - **Adminer**: http://localhost:8081
   - **Redis Commander**: http://localhost:8082

4. **Verify setup**:
   ```bash
   make health
   make test
   ```

For detailed setup instructions, see [Homelab Setup Guide](homelab/README.md).

### Development Workflow

**Weekly Theme Approach** (reduces context switching):

**Backend Week** (Week 1 of sprint):
- Morning: RUST/Go development
- Afternoon: Testing & integration

**Frontend Week** (Week 2 of sprint):
- Morning: Next.js development
- Afternoon: UI/UX & integration

See [SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md) for detailed workflow.

---

## 📊 Project Status

### Current Phase: **Pre-Sprint 0**

Setting up development environment and project structure.

### Sprint Progress

| Sprint | Status | Dates | Points | Key Deliverables |
|--------|--------|-------|--------|------------------|
| **Pre-Sprint** | 🟡 In Progress | Now | - | Homelab setup, project scaffolding |
| **Sprint 0** | 🔴 Not Started | Weeks 1-2 | 21 | CI/CD, Database schema |
| **Sprint 1** | 🔴 Not Started | Weeks 3-4 | 13 | Authentication system |
| **Sprint 2** | 🔴 Not Started | Weeks 5-6 | 13 | API Gateway, Monitoring |

**Next Milestone**: Complete homelab setup → Begin Sprint 0

### Development Timeline

- **Estimated MVP Launch**: 9 months (36 weeks)
- **Expected Velocity**: 10-15 points/sprint (with AI assistance)
- **Total Story Points**: 152 points for MVP

See [SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md) for full timeline.

---

## 💰 Cost Analysis

### Monthly Operating Costs

**Development Phase**: €14-27/month
- 2 VPS servers: €16-32/month
- Homelab electricity: €5-10/month
- GitHub Pro + Copilot: €0 (already subscribed)

**Production Phase**: €60-82/month
- Hetzner AX 43: €49-59/month (already have)
- 2 VPS servers: €16-32/month
- Hetzner Object Storage: €8/month (500GB)
- Homelab: €5-10/month

**Break-even Point**: 8-10 customers @ €10/month

See [SOLO-DEVELOPER-SETUP.md](SOLO-DEVELOPER-SETUP.md) for detailed analysis.

---

## 🎯 MVP Scope

### Phase 1: Core Features (Sprints 0-5)

**Technical Infrastructure**:
- ✅ CI/CD pipeline
- ✅ Database schema & migrations
- ✅ API Gateway with rate limiting
- ✅ JWT authentication with 2FA
- ✅ Monitoring & observability

**Admin Features**:
- ✅ Super Admin dashboard
- ✅ User management
- ✅ Package management
- ✅ Billing configuration

**Reseller Features**:
- ✅ Reseller dashboard
- ✅ Customer management
- ✅ Invoice management

**Customer Features**:
- ✅ Customer dashboard
- ✅ Website management
- ✅ Backup & restore
- ✅ Billing & invoices

**Developer Tools**:
- ✅ SSH access
- ✅ SFTP access
- ✅ PHP configuration
- ✅ Cron jobs

### Phase 2: Advanced Features (Post-MVP)

Deferred to months 10-12:
- File manager
- Email account management
- SSL certificate management
- Domain management
- White-label branding
- Custom pricing
- Support ticket system

---

## 🤝 Contributing

This is currently a solo developer project, but contributions are welcome!

### Development Principles

1. **Consistency**: Code daily, even if only 2-4 hours
2. **Focus**: Stick to weekly themes (Backend vs Frontend)
3. **AI Assistance**: Use GitHub Copilot and Claude Code extensively
4. **Scope Discipline**: Don't add features outside the plan
5. **Testing**: Write tests as you code (don't defer)
6. **Documentation**: Document as you build

### AI Tools in Use

- **GitHub Copilot**: Boilerplate generation, unit tests, type definitions
- **Claude Code**: Architecture decisions, debugging, code review
- **Expected Productivity Boost**: 30-40% faster development

---

## 📂 Repository Structure

```
next-js-panel/
├── homelab/                    # Docker Compose development environment
│   ├── docker-compose.yml      # 7 services (PostgreSQL, Redis, n8n, etc.)
│   ├── Makefile               # 20+ helpful commands
│   ├── quick-start.sh         # Interactive setup script
│   └── README.md              # Homelab documentation
├── docs/                      # Product documentation
│   ├── PRD.md                 # Product Requirements Document
│   ├── Implementation-Guide.md # Technical implementation details
│   └── User-Stories.md        # User stories
├── planning/                  # Project planning documents
│   ├── Product-Backlog-Review.md
│   ├── Product-Backlog.csv
│   ├── Sprint-Planning-Guide.md
│   ├── MVP-Roadmap.md
│   ├── Solo-Developer-Setup.md
│   └── Solo-Sprint-Plan.md
├── api-gateway/               # RUST API Gateway (TBD)
├── services/                  # Go Microservices (TBD)
│   ├── user-service/
│   ├── billing-service/
│   ├── provisioning-service/
│   └── email-service/
├── frontend/                  # Next.js 16 Frontend (TBD)
└── README.md                  # This file
```

---

## 🎓 Learning Resources

### Next.js & React
- [Next.js 15 Documentation](https://nextjs.org/docs)
- [React 19 Documentation](https://react.dev)
- [Server Components Guide](https://nextjs.org/docs/app/building-your-application/rendering/server-components)

### RUST
- [The Rust Book](https://doc.rust-lang.org/book/)
- [Actix-web Documentation](https://actix.rs)
- [Axum Documentation](https://docs.rs/axum/latest/axum/)

### Go
- [Go Documentation](https://go.dev/doc/)
- [Fiber Framework](https://docs.gofiber.io)

### DevOps
- [Docker Documentation](https://docs.docker.com)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)

---

## 📝 License

This project is proprietary. All rights reserved.

---

## 📧 Contact

For questions or feedback:
- **GitHub Issues**: https://github.com/xerudro/next-js-panel/issues
- **Email**: [Your email here]

---

## 🙏 Acknowledgments

Built with:
- ☕ Coffee
- 🎵 Music
- 🤖 AI assistance (GitHub Copilot, Claude Code)
- 💪 Determination

---

**Last Updated**: 2025-11-11
**Status**: Pre-Sprint 0 - Setting up development environment
**Next Step**: Initialize project structure and begin Sprint 0
