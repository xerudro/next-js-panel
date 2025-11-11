# Project Structure - Complete Directory Layout

**Unified Hosting Control Panel - Repository Organization**

This document outlines the complete directory structure for all components of the hosting platform.

---

## 🗂️ Repository Overview

```
next-js-panel/
├── README.md                           # Main project README
├── PROJECT-STRUCTURE.md                # This file
├── .gitignore                          # Global gitignore
├── .github/                            # GitHub configuration
│   ├── workflows/                      # GitHub Actions CI/CD
│   │   ├── api-gateway.yml             # RUST API Gateway pipeline
│   │   ├── microservices.yml           # Go services pipeline
│   │   ├── frontend.yml                # Next.js frontend pipeline
│   │   └── deploy.yml                  # Deployment workflow
│   └── PULL_REQUEST_TEMPLATE.md        # PR template
│
├── docs/                               # Product documentation
│   ├── Unified_Hosting_Platform_PRD.md
│   ├── Unified-Hosting-Platform-Implementation-Guide.md
│   ├── USER-STORIES.md
│   ├── PRODUCT-BACKLOG-REVIEW.md
│   ├── PRODUCT-BACKLOG.csv
│   ├── SPRINT-PLANNING-GUIDE.md
│   ├── MVP-ROADMAP.md
│   ├── SOLO-DEVELOPER-SETUP.md
│   └── SOLO-SPRINT-PLAN.md
│
├── homelab/                            # Development environment
│   ├── docker-compose.yml              # All dev services
│   ├── Makefile                        # Helper commands
│   ├── quick-start.sh                  # Setup script
│   ├── .env.example                    # Environment template
│   ├── prometheus.yml                  # Metrics config
│   ├── init-scripts/                   # PostgreSQL init
│   ├── n8n-workflows/                  # Workflow automation
│   ├── grafana-datasources/            # Grafana config
│   ├── grafana-dashboards/             # Custom dashboards
│   └── README.md
│
├── api-gateway/                        # RUST API Gateway
│   ├── Cargo.toml                      # RUST dependencies
│   ├── Cargo.lock
│   ├── Dockerfile                      # Production image
│   ├── .env.example
│   ├── src/
│   │   ├── main.rs                     # Entry point
│   │   ├── config.rs                   # Configuration
│   │   ├── routes/                     # Route definitions
│   │   │   ├── mod.rs
│   │   │   ├── auth.rs                 # Auth routes
│   │   │   ├── users.rs                # User routes
│   │   │   ├── health.rs               # Health checks
│   │   │   └── metrics.rs              # Prometheus metrics
│   │   ├── middleware/                 # Middleware
│   │   │   ├── mod.rs
│   │   │   ├── auth.rs                 # JWT validation
│   │   │   ├── rate_limit.rs           # Rate limiting
│   │   │   ├── cors.rs                 # CORS handling
│   │   │   └── logging.rs              # Request logging
│   │   ├── services/                   # Business logic
│   │   │   ├── mod.rs
│   │   │   ├── auth_service.rs
│   │   │   ├── user_service.rs
│   │   │   └── token_service.rs
│   │   ├── models/                     # Data models
│   │   │   ├── mod.rs
│   │   │   ├── user.rs
│   │   │   ├── token.rs
│   │   │   └── error.rs
│   │   ├── db/                         # Database
│   │   │   ├── mod.rs
│   │   │   ├── pool.rs                 # Connection pool
│   │   │   └── schema.rs               # Schema definitions
│   │   └── utils/                      # Utilities
│   │       ├── mod.rs
│   │       ├── jwt.rs                  # JWT helpers
│   │       ├── hash.rs                 # Password hashing
│   │       └── validation.rs           # Input validation
│   ├── migrations/                     # Database migrations
│   │   ├── 20250101000000_init.sql
│   │   ├── 20250101000001_users.sql
│   │   └── 20250101000002_auth.sql
│   ├── tests/                          # Integration tests
│   │   ├── health_test.rs
│   │   ├── auth_test.rs
│   │   └── common/
│   └── README.md
│
├── services/                           # Go Microservices
│   ├── shared/                         # Shared code
│   │   ├── go.mod
│   │   ├── go.sum
│   │   ├── config/                     # Shared config
│   │   ├── models/                     # Shared models
│   │   ├── middleware/                 # Shared middleware
│   │   ├── utils/                      # Shared utilities
│   │   └── proto/                      # gRPC protobuf (if used)
│   │
│   ├── user-service/                   # User Management Service
│   │   ├── go.mod
│   │   ├── go.sum
│   │   ├── Dockerfile
│   │   ├── .env.example
│   │   ├── cmd/
│   │   │   └── main.go                 # Entry point
│   │   ├── internal/
│   │   │   ├── handlers/               # HTTP handlers
│   │   │   │   ├── user.go
│   │   │   │   ├── customer.go
│   │   │   │   └── reseller.go
│   │   │   ├── services/               # Business logic
│   │   │   │   ├── user_service.go
│   │   │   │   └── role_service.go
│   │   │   ├── repositories/           # Database access
│   │   │   │   └── user_repository.go
│   │   │   ├── models/                 # Data models
│   │   │   │   └── user.go
│   │   │   └── middleware/
│   │   │       └── auth.go
│   │   ├── pkg/                        # Public packages
│   │   ├── migrations/                 # DB migrations
│   │   ├── tests/
│   │   └── README.md
│   │
│   ├── billing-service/                # Billing & Payment Service
│   │   ├── go.mod
│   │   ├── Dockerfile
│   │   ├── cmd/
│   │   │   └── main.go
│   │   ├── internal/
│   │   │   ├── handlers/
│   │   │   │   ├── invoice.go
│   │   │   │   ├── payment.go
│   │   │   │   ├── subscription.go
│   │   │   │   └── stripe.go
│   │   │   ├── services/
│   │   │   │   ├── billing_service.go
│   │   │   │   ├── invoice_service.go
│   │   │   │   ├── payment_service.go
│   │   │   │   └── stripe_service.go
│   │   │   ├── repositories/
│   │   │   │   ├── invoice_repository.go
│   │   │   │   └── payment_repository.go
│   │   │   └── models/
│   │   │       ├── invoice.go
│   │   │       ├── payment.go
│   │   │       └── subscription.go
│   │   ├── migrations/
│   │   ├── tests/
│   │   └── README.md
│   │
│   ├── provisioning-service/           # Server Provisioning Service
│   │   ├── go.mod
│   │   ├── Dockerfile
│   │   ├── cmd/
│   │   │   └── main.go
│   │   ├── internal/
│   │   │   ├── handlers/
│   │   │   │   ├── website.go
│   │   │   │   ├── domain.go
│   │   │   │   ├── database.go
│   │   │   │   └── ssh.go
│   │   │   ├── services/
│   │   │   │   ├── provisioning_service.go
│   │   │   │   ├── nginx_service.go
│   │   │   │   ├── php_service.go
│   │   │   │   ├── mysql_service.go
│   │   │   │   └── ssh_service.go
│   │   │   ├── repositories/
│   │   │   │   └── website_repository.go
│   │   │   └── models/
│   │   │       ├── website.go
│   │   │       └── server.go
│   │   ├── templates/                  # NGINX, PHP-FPM configs
│   │   │   ├── nginx-vhost.tmpl
│   │   │   ├── php-fpm-pool.tmpl
│   │   │   └── crontab.tmpl
│   │   ├── migrations/
│   │   ├── tests/
│   │   └── README.md
│   │
│   ├── email-service/                  # Email Service
│   │   ├── go.mod
│   │   ├── Dockerfile
│   │   ├── cmd/
│   │   │   └── main.go
│   │   ├── internal/
│   │   │   ├── handlers/
│   │   │   │   └── email.go
│   │   │   ├── services/
│   │   │   │   ├── email_service.go
│   │   │   │   └── smtp_service.go
│   │   │   ├── models/
│   │   │   │   └── email.go
│   │   │   └── templates/              # Email templates
│   │   │       ├── welcome.html
│   │   │       ├── invoice.html
│   │   │       ├── password_reset.html
│   │   │       └── payment_reminder.html
│   │   ├── tests/
│   │   └── README.md
│   │
│   └── support-service/                # Support Ticket Service (Phase 2)
│       ├── go.mod
│       ├── Dockerfile
│       ├── cmd/
│       ├── internal/
│       └── README.md
│
├── frontend/                           # Next.js 16 Frontend
│   ├── package.json
│   ├── package-lock.json
│   ├── tsconfig.json                   # TypeScript config
│   ├── next.config.js                  # Next.js config
│   ├── tailwind.config.js              # Tailwind config
│   ├── postcss.config.js
│   ├── .env.example
│   ├── .env.local                      # Local env (gitignored)
│   ├── Dockerfile                      # Production image
│   ├── .dockerignore
│   ├── public/                         # Static assets
│   │   ├── favicon.ico
│   │   ├── logo.svg
│   │   └── images/
│   ├── src/
│   │   ├── app/                        # Next.js App Router
│   │   │   ├── layout.tsx              # Root layout
│   │   │   ├── page.tsx                # Landing page
│   │   │   ├── globals.css             # Global styles
│   │   │   ├── error.tsx               # Error page
│   │   │   ├── not-found.tsx           # 404 page
│   │   │   ├── loading.tsx             # Loading UI
│   │   │   │
│   │   │   ├── (auth)/                 # Auth routes
│   │   │   │   ├── layout.tsx
│   │   │   │   ├── login/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── register/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── forgot-password/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── reset-password/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   ├── admin/                  # Super Admin portal
│   │   │   │   ├── layout.tsx
│   │   │   │   ├── dashboard/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── users/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx
│   │   │   │   ├── resellers/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx
│   │   │   │   ├── packages/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx
│   │   │   │   ├── billing/
│   │   │   │   │   ├── settings/
│   │   │   │   │   │   └── page.tsx
│   │   │   │   │   └── transactions/
│   │   │   │   │       └── page.tsx
│   │   │   │   ├── servers/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── settings/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   ├── reseller/               # Reseller portal
│   │   │   │   ├── layout.tsx
│   │   │   │   ├── dashboard/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── customers/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   ├── new/
│   │   │   │   │   │   └── page.tsx
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx
│   │   │   │   ├── invoices/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   └── [id]/
│   │   │   │   │       └── page.tsx
│   │   │   │   ├── branding/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── settings/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   ├── customer/               # Customer portal
│   │   │   │   ├── layout.tsx
│   │   │   │   ├── dashboard/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── websites/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   ├── new/
│   │   │   │   │   │   └── page.tsx
│   │   │   │   │   └── [id]/
│   │   │   │   │       ├── page.tsx
│   │   │   │   │       ├── files/
│   │   │   │   │       │   └── page.tsx
│   │   │   │   │       ├── databases/
│   │   │   │   │       │   └── page.tsx
│   │   │   │   │       ├── email/
│   │   │   │   │       │   └── page.tsx
│   │   │   │   │       ├── ssl/
│   │   │   │   │       │   └── page.tsx
│   │   │   │   │       └── settings/
│   │   │   │   │           └── page.tsx
│   │   │   │   ├── backups/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── billing/
│   │   │   │   │   ├── page.tsx
│   │   │   │   │   ├── invoices/
│   │   │   │   │   │   └── [id]/
│   │   │   │   │   │       └── page.tsx
│   │   │   │   │   └── payment-methods/
│   │   │   │   │       └── page.tsx
│   │   │   │   ├── developer/
│   │   │   │   │   ├── ssh/
│   │   │   │   │   │   └── page.tsx
│   │   │   │   │   ├── cron/
│   │   │   │   │   │   └── page.tsx
│   │   │   │   │   └── logs/
│   │   │   │   │       └── page.tsx
│   │   │   │   └── settings/
│   │   │   │       └── page.tsx
│   │   │   │
│   │   │   └── api/                    # API routes (Next.js)
│   │   │       ├── auth/
│   │   │       │   └── [...nextauth]/
│   │   │       │       └── route.ts
│   │   │       └── health/
│   │   │           └── route.ts
│   │   │
│   │   ├── components/                 # React components
│   │   │   ├── ui/                     # UI components
│   │   │   │   ├── Button.tsx
│   │   │   │   ├── Input.tsx
│   │   │   │   ├── Card.tsx
│   │   │   │   ├── Table.tsx
│   │   │   │   ├── Modal.tsx
│   │   │   │   ├── Dropdown.tsx
│   │   │   │   └── LoadingSpinner.tsx
│   │   │   ├── layout/                 # Layout components
│   │   │   │   ├── Header.tsx
│   │   │   │   ├── Sidebar.tsx
│   │   │   │   ├── Footer.tsx
│   │   │   │   └── Navigation.tsx
│   │   │   ├── dashboard/              # Dashboard components
│   │   │   │   ├── MetricCard.tsx
│   │   │   │   ├── RevenueChart.tsx
│   │   │   │   ├── ActivityFeed.tsx
│   │   │   │   └── QuickActions.tsx
│   │   │   ├── forms/                  # Form components
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   ├── UserForm.tsx
│   │   │   │   ├── PackageForm.tsx
│   │   │   │   └── InvoiceForm.tsx
│   │   │   ├── tables/                 # Table components
│   │   │   │   ├── UserTable.tsx
│   │   │   │   ├── InvoiceTable.tsx
│   │   │   │   └── PackageTable.tsx
│   │   │   └── Providers.tsx           # Context providers
│   │   │
│   │   ├── lib/                        # Library code
│   │   │   ├── api/                    # API client
│   │   │   │   ├── client.ts           # Axios/fetch wrapper
│   │   │   │   ├── auth.ts             # Auth endpoints
│   │   │   │   ├── users.ts            # User endpoints
│   │   │   │   ├── billing.ts          # Billing endpoints
│   │   │   │   └── websites.ts         # Website endpoints
│   │   │   ├── hooks/                  # React hooks
│   │   │   │   ├── useAuth.ts
│   │   │   │   ├── useUsers.ts
│   │   │   │   ├── useInvoices.ts
│   │   │   │   └── useWebsites.ts
│   │   │   ├── stores/                 # Zustand stores
│   │   │   │   ├── authStore.ts
│   │   │   │   ├── userStore.ts
│   │   │   │   └── notificationStore.ts
│   │   │   ├── utils/                  # Utilities
│   │   │   │   ├── format.ts           # Formatting helpers
│   │   │   │   ├── validation.ts       # Validation schemas
│   │   │   │   ├── constants.ts        # Constants
│   │   │   │   └── helpers.ts          # Helper functions
│   │   │   └── types/                  # TypeScript types
│   │   │       ├── auth.ts
│   │   │       ├── user.ts
│   │   │       ├── billing.ts
│   │   │       └── website.ts
│   │   │
│   │   └── middleware.ts               # Next.js middleware
│   │
│   ├── tests/                          # Tests
│   │   ├── unit/                       # Unit tests
│   │   ├── integration/                # Integration tests
│   │   └── e2e/                        # E2E tests (Playwright)
│   │       ├── auth.spec.ts
│   │       ├── dashboard.spec.ts
│   │       └── website.spec.ts
│   └── README.md
│
├── infrastructure/                     # Infrastructure as Code
│   ├── ansible/                        # Ansible playbooks
│   │   ├── inventory/
│   │   │   ├── development.ini
│   │   │   └── production.ini
│   │   ├── playbooks/
│   │   │   ├── setup-ax43.yml          # AX 43 setup
│   │   │   ├── deploy-api.yml          # API deployment
│   │   │   ├── deploy-frontend.yml     # Frontend deployment
│   │   │   └── backup.yml              # Backup automation
│   │   ├── roles/
│   │   │   ├── nginx/
│   │   │   ├── postgresql/
│   │   │   ├── redis/
│   │   │   └── monitoring/
│   │   └── README.md
│   │
│   ├── terraform/                      # Terraform (if used)
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── docker/                         # Docker configs
│       ├── production/
│       │   └── docker-compose.yml      # Production compose
│       └── nginx/
│           ├── nginx.conf              # Main NGINX config
│           └── sites/                  # Site configs
│
├── scripts/                            # Utility scripts
│   ├── backup.sh                       # Backup script
│   ├── restore.sh                      # Restore script
│   ├── deploy.sh                       # Deployment script
│   ├── test.sh                         # Test runner
│   └── setup-dev.sh                    # Dev environment setup
│
└── .vscode/                            # VS Code settings (optional)
    ├── settings.json
    ├── extensions.json
    └── launch.json
```

---

## 📦 Key Directories Explained

### `/homelab` - Development Environment
Complete Docker Compose setup for local development on Terra PC. Includes PostgreSQL, Redis, n8n, Prometheus, and Grafana.

**Usage**: `cd homelab && make init`

### `/api-gateway` - RUST API Gateway
Central API gateway handling authentication, rate limiting, and routing to microservices. Built with Actix-web or Axum.

**Tech**: RUST, PostgreSQL, JWT, Redis

### `/services` - Go Microservices
Five microservices handling different domains:
1. **user-service**: User, customer, and reseller management
2. **billing-service**: Invoicing, payments, subscriptions
3. **provisioning-service**: Website, database, server provisioning
4. **email-service**: Email sending via SMTP
5. **support-service**: Support tickets (Phase 2)

**Tech**: Go (Fiber), PostgreSQL, NATS

### `/frontend` - Next.js Frontend
Modern Next.js 16 application with App Router, Server Components, and TypeScript. Four portals: Auth, Super Admin, Reseller, and Customer.

**Tech**: Next.js 16, React 19, TypeScript, Tailwind, Zustand

### `/infrastructure` - Infrastructure as Code
Ansible playbooks for server provisioning, deployments, and automation. Includes AX 43 production setup.

**Tech**: Ansible, Docker, NGINX

---

## 🚀 Creating the Structure

### Sprint 0, Week 1 Tasks

Follow [SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md) for detailed instructions.

**Day 1-2: Initialize Repositories**

1. **API Gateway (RUST)**:
   ```bash
   cargo new api-gateway --bin
   cd api-gateway
   cargo add actix-web actix-rt tokio sqlx
   cargo add serde serde_json
   cargo add jsonwebtoken argon2
   ```

2. **Microservices (Go)**:
   ```bash
   mkdir -p services/{shared,user-service,billing-service,provisioning-service,email-service}
   cd services/user-service
   go mod init github.com/xerudro/next-js-panel/services/user-service
   go get github.com/gofiber/fiber/v2
   ```

3. **Frontend (Next.js)**:
   ```bash
   npx create-next-app@latest frontend \
     --typescript \
     --tailwind \
     --app \
     --src-dir \
     --import-alias "@/*"
   ```

**Day 3-5: Set Up CI/CD**

Create GitHub Actions workflows in `.github/workflows/`:
- `api-gateway.yml`: RUST build, test, Docker push
- `microservices.yml`: Go build, test, Docker push
- `frontend.yml`: Next.js build, test, deploy

---

## 📝 Naming Conventions

### Files
- **Go**: `snake_case.go` (e.g., `user_service.go`)
- **RUST**: `snake_case.rs` (e.g., `auth_service.rs`)
- **TypeScript/React**: `PascalCase.tsx` for components, `camelCase.ts` for utilities

### Directories
- Use `kebab-case` for directories (e.g., `user-service`, `api-gateway`)
- Use descriptive names (e.g., `handlers` not `h`, `repositories` not `repos`)

### Branches
- Feature: `feature/description` (e.g., `feature/add-user-management`)
- Bug: `fix/description` (e.g., `fix/login-redirect`)
- Claude branches: `claude/task-name-sessionid`

### Commits
- Use conventional commits:
  - `feat: Add user authentication`
  - `fix: Resolve login redirect issue`
  - `docs: Update API documentation`
  - `refactor: Simplify auth middleware`
  - `test: Add user service tests`

---

## 🔒 Security Considerations

### Sensitive Files (Add to `.gitignore`)

```gitignore
# Environment files
.env
.env.local
.env.production

# Database files
*.sql (except migrations and init scripts)
*.db

# Secrets
secrets/
credentials/
*.pem
*.key

# Build artifacts
target/
dist/
.next/
node_modules/

# IDE
.vscode/
.idea/
*.swp
```

### Secret Management

- Use `.env.example` templates for all services
- Never commit actual `.env` files
- Use environment variables for all secrets
- Production: Use Docker secrets or Vault

---

## 📊 Size Estimates

**Total Project Size** (estimated):

```
api-gateway/        ~5,000 lines of RUST
services/           ~15,000 lines of Go
frontend/           ~20,000 lines of TypeScript/React
infrastructure/     ~2,000 lines of YAML/Shell
tests/              ~10,000 lines
docs/               ~5,000 lines of Markdown
-------------------------------------------
Total:              ~57,000 lines of code
```

**Repository Size**: ~200-300 MB (with dependencies)

---

## 🎯 Next Steps

1. **Review this structure** and make adjustments if needed
2. **Create initial directories** for Sprint 0
3. **Initialize Git submodules** (if separating repos)
4. **Set up GitHub Actions** for CI/CD
5. **Begin Sprint 0, Week 1**: CI/CD and database setup

See [SOLO-SPRINT-PLAN.md](SOLO-SPRINT-PLAN.md) for detailed sprint tasks.

---

**Last Updated**: 2025-11-11
**Status**: Pre-Sprint 0 - Planning Complete
**Next**: Initialize project structure
