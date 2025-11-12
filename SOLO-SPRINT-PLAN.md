# Solo Developer Sprint Plan (8-9 Months to MVP)

**Timeline**: 36 weeks (9 months) | **Velocity**: 10-15 points/sprint | **Total**: 152 story points for MVP

---

## 📊 Sprint Overview

| Sprint | Weeks | Theme | Points | Key Stories | Status |
|--------|-------|-------|--------|-------------|--------|
| 0 | 1-2 | Infrastructure Foundation | 21 | TECH-001, TECH-002, TECH-003 | 🔴 Not Started |
| 1 | 3-4 | Authentication & Security | 13 | TECH-004 | 🔴 Not Started |
| 2 | 5-6 | Core APIs & Monitoring | 13 | TECH-005, TECH-007 | 🔴 Not Started |
| 3 | 7-8 | Super Admin Dashboard | 16 | SA-001, SA-008 | 🔴 Not Started |
| 4 | 9-10 | User Management | 13 | SA-002 | 🔴 Not Started |
| 5 | 11-12 | Package & Billing Config | 21 | SA-006, SA-004 | 🔴 Not Started |
| 6 | 13-14 | Reseller Portal Foundation | 8 | RE-001 | 🔴 Not Started |
| 7 | 15-16 | Reseller Customer Mgmt | 13 | RE-002 | 🔴 Not Started |
| 8 | 17-18 | Reseller Billing | 13 | RE-005 | 🔴 Not Started |
| 9 | 19-20 | Customer Portal Foundation | 8 | CU-001 | 🔴 Not Started |
| 10 | 21-22 | Website Management Core | 13 | CU-002 | 🔴 Not Started |
| 11 | 23-24 | Backup & Restore | 13 | CU-008 | 🔴 Not Started |
| 12 | 25-26 | Customer Billing | 13 | CU-009 | 🔴 Not Started |
| 13 | 27-28 | SSH & Developer Tools | 13 | TU-001, TU-002 | 🔴 Not Started |
| 14 | 29-30 | PHP Config & Cron Jobs | 16 | TU-003, TU-004 | 🔴 Not Started |
| 15 | 31-32 | Testing & Bug Fixes | 8 | TECH-006 | 🔴 Not Started |
| 16 | 33-34 | Integration Testing | 8 | Testing, Documentation | 🔴 Not Started |
| 17 | 35-36 | MVP Polish & Launch Prep | 8 | Performance, Security Audit | 🔴 Not Started |

**Total Story Points**: 152 for MVP baseline (includes buffer)

---

## 🏗️ Deployment Architecture

**Development** (Homelab - Terra PC):
- Docker Compose for all services (PostgreSQL, Redis, n8n, Prometheus, Grafana)
- Run application code natively during development (`cargo run`, `go run`, `npm run dev`)

**Production** (Hetzner AX 43):
- **systemd services** for all application components (NOT Docker)
- Native PostgreSQL and Redis installations
- NGINX as reverse proxy
- systemd for service management
- Ansible for automated deployment
- See `infrastructure/PRODUCTION-DEPLOYMENT.md` for details

**Why systemd for production?**
- Better performance (no container overhead)
- Traditional Linux service management
- Customer websites run as NGINX vhosts + PHP-FPM (not containers)
- Easier resource control and debugging
- Standard hosting panel architecture

---

## 🎯 Solo Developer Strategy

### Weekly Work Pattern

**Backend Week (Week 1 of each sprint)**
- **Morning (9 AM - 12 PM)**: RUST/Go development
  - API endpoints
  - Database operations
  - Business logic
- **Afternoon (1 PM - 5 PM)**: Testing & integration
  - Unit tests
  - Integration tests
  - API documentation

**Frontend Week (Week 2 of each sprint)**
- **Morning (9 AM - 12 PM)**: Next.js development
  - Pages and layouts
  - React components
  - State management
- **Afternoon (1 PM - 5 PM)**: UI/UX & integration
  - Styling with Tailwind
  - API integration
  - E2E testing

### AI Tool Usage Strategy

**GitHub Copilot** (daily usage):
- ✅ Boilerplate code generation (30-40% time savings)
- ✅ Unit test generation
- ✅ TypeScript type definitions
- ✅ SQL queries and migrations
- ✅ API endpoint scaffolding

**Claude Code** (2-3 times per week):
- ✅ Architecture decisions and review
- ✅ Complex algorithm implementation
- ✅ Debugging difficult issues
- ✅ Code refactoring suggestions
- ✅ Documentation generation

**Expected Productivity Boost**: 30-40% faster than pure manual coding

---

## 📅 Detailed Sprint Breakdown

### **Sprint 0: Infrastructure Foundation (Weeks 1-2)** - 21 Points

**Goal**: Set up development environment, CI/CD, and database foundation

**Stories**:
- **TECH-001**: CI/CD Pipeline Setup (8 points)
- **TECH-002**: Database Schema & Migrations (13 points)

**Week 1 Tasks - Backend Focus**:
```
Day 1-2: GitHub Actions CI/CD Pipeline
  [ ] Set up GitHub Actions workflow for RUST
  [ ] Set up GitHub Actions workflow for Go services
  [ ] Configure automated testing pipeline
  [ ] Set up Docker builds

Day 3-5: Database Foundation
  [ ] Install PostgreSQL on homelab (Terra PC)
  [ ] Create database schema design
  [ ] Set up migration system (sqlx for RUST)
  [ ] Create initial migration scripts
```

**Week 2 Tasks - Integration**:
```
Day 6-7: Database Migrations
  [ ] Create users table and relations
  [ ] Create customers/resellers tables
  [ ] Create packages/pricing tables
  [ ] Create billing/invoices tables

Day 8-10: Database Testing & Documentation
  [ ] Write database integration tests
  [ ] Set up seed data for development
  [ ] Document database schema
  [ ] Test migrations on VPS 1
```

**Deliverables**:
- ✅ GitHub Actions pipeline running
- ✅ PostgreSQL schema deployed to homelab
- ✅ Migration system working
- ✅ Seed data for testing

**AI Tool Usage**:
- Copilot: Generate migration scripts, SQL queries
- Claude Code: Review database schema design for normalization

---

### **Sprint 1: Authentication & Security (Weeks 3-4)** - 13 Points

**Goal**: Implement JWT authentication, 2FA, and session management

**Stories**:
- **TECH-004**: Authentication System (13 points)

**Week 3 Tasks - Backend Focus**:
```
Day 1-3: JWT Authentication (RUST)
  [ ] Implement JWT token generation (actix-web-httpauth)
  [ ] Create /auth/login endpoint
  [ ] Create /auth/logout endpoint
  [ ] Create /auth/refresh endpoint
  [ ] Implement password hashing (argon2)

Day 4-5: 2FA Implementation
  [ ] Generate TOTP secrets (google-authenticator)
  [ ] Create /auth/2fa/setup endpoint
  [ ] Create /auth/2fa/verify endpoint
  [ ] Implement account lockout (5 failed attempts)
```

**Week 4 Tasks - Frontend Focus**:
```
Day 6-7: Next.js Login UI
  [ ] Create login page (/app/login/page.tsx)
  [ ] Implement login form with React Hook Form + Zod
  [ ] Add 2FA input component
  [ ] Create session context with Zustand

Day 8-10: Testing & Integration
  [ ] Write auth integration tests
  [ ] Test 2FA flow end-to-end
  [ ] Add forgot password flow
  [ ] Document authentication API
```

**Deliverables**:
- ✅ JWT authentication working
- ✅ 2FA enabled for all users
- ✅ Login UI complete
- ✅ Session management working

**AI Tool Usage**:
- Copilot: Generate JWT middleware, TOTP validation
- Claude Code: Security review of authentication flow

---

### **Sprint 2: Core APIs & Monitoring (Weeks 5-6)** - 13 Points

**Goal**: Set up API Gateway and monitoring infrastructure

**Stories**:
- **TECH-003**: API Gateway Architecture (13 points) - *Partial implementation*
- **TECH-005**: Monitoring & Observability (8 points) - *Partial implementation*
- **TECH-007**: API Documentation (5 points) - *Partial implementation*

**Week 5 Tasks - Backend Focus**:
```
Day 1-3: API Gateway (RUST)
  [ ] Set up Actix-web API gateway
  [ ] Implement rate limiting middleware
  [ ] Create health check endpoints (/health, /ready)
  [ ] Set up CORS configuration
  [ ] Implement request logging

Day 4-5: Monitoring Setup
  [ ] Install Prometheus on homelab
  [ ] Set up metrics collection (actix-web-prom)
  [ ] Create basic dashboards
  [ ] Set up error logging
```

**Week 6 Tasks - Documentation & Testing**:
```
Day 6-8: API Documentation
  [ ] Set up OpenAPI/Swagger specs
  [ ] Document authentication endpoints
  [ ] Generate API documentation site
  [ ] Create Postman collection

Day 9-10: Integration Testing
  [ ] Write API gateway tests
  [ ] Test rate limiting
  [ ] Load test with k6 (100 req/s baseline)
  [ ] Document API gateway configuration
```

**Deliverables**:
- ✅ API Gateway deployed on VPS 1
- ✅ Rate limiting working (100 req/min per IP)
- ✅ Basic monitoring dashboard
- ✅ API documentation published

**AI Tool Usage**:
- Copilot: Generate OpenAPI specs, middleware code
- Claude Code: Review API architecture for scalability

---

### **Sprint 3: Super Admin Dashboard (Weeks 7-8)** - 16 Points

**Goal**: Build Super Admin portal with platform metrics

**Stories**:
- **SA-001**: Platform Dashboard Overview (8 points)
- **SA-008**: System Configuration (8 points)

**Week 7 Tasks - Backend Focus**:
```
Day 1-3: Dashboard APIs (Go Fiber)
  [ ] Create /v1/dashboard/metrics endpoint
  [ ] Implement customer count aggregation
  [ ] Implement reseller count aggregation
  [ ] Calculate MRR/ARR
  [ ] Create server resource monitoring API

Day 4-5: System Configuration APIs
  [ ] Create /v1/config/billing endpoint (GET/PUT)
  [ ] Create /v1/config/email endpoint
  [ ] Create /v1/config/security endpoint
  [ ] Implement configuration validation
```

**Week 8 Tasks - Frontend Focus**:
```
Day 6-7: Dashboard UI (Next.js)
  [ ] Create /app/admin/dashboard/page.tsx
  [ ] Implement metrics cards (customers, revenue, servers)
  [ ] Create revenue chart (Recharts)
  [ ] Add recent activity feed
  [ ] Create alert notification component

Day 8-10: System Config UI
  [ ] Create /app/admin/settings/page.tsx
  [ ] Build configuration forms
  [ ] Add real-time validation
  [ ] Test configuration updates
```

**Deliverables**:
- ✅ Super Admin dashboard functional
- ✅ Platform metrics displaying correctly
- ✅ System configuration working
- ✅ Responsive UI for mobile

**AI Tool Usage**:
- Copilot: Generate chart components, form validation
- Claude Code: Review dashboard performance and optimization

---

### **Sprint 4: User Management (Weeks 9-10)** - 13 Points

**Goal**: Implement user/reseller/customer management

**Stories**:
- **SA-002**: User Management (13 points)

**Week 9 Tasks - Backend Focus**:
```
Day 1-3: User Management APIs (Go Fiber)
  [ ] Create /v1/users endpoint (CRUD)
  [ ] Implement role management (Super Admin, Reseller, Customer)
  [ ] Create /v1/users/:id/suspend endpoint
  [ ] Create /v1/users/:id/activate endpoint
  [ ] Implement user search and filtering

Day 4-5: Reseller Management
  [ ] Create /v1/resellers endpoint
  [ ] Implement reseller commission settings
  [ ] Create reseller limits (max customers, resources)
  [ ] Add reseller billing configuration
```

**Week 10 Tasks - Frontend Focus**:
```
Day 6-7: User Management UI
  [ ] Create /app/admin/users/page.tsx
  [ ] Build user table with sorting/filtering
  [ ] Create user creation modal
  [ ] Add user edit/suspend actions
  [ ] Implement bulk operations

Day 8-10: Reseller Management UI
  [ ] Create /app/admin/resellers/page.tsx
  [ ] Build reseller creation wizard
  [ ] Add commission configuration UI
  [ ] Test user management flows
```

**Deliverables**:
- ✅ User CRUD operations working
- ✅ Role-based access control implemented
- ✅ Reseller management complete
- ✅ User search and filtering working

**AI Tool Usage**:
- Copilot: Generate CRUD endpoints, table components
- Claude Code: Review RBAC implementation

---

### **Sprint 5: Package & Billing Config (Weeks 11-12)** - 21 Points

**Goal**: Set up hosting packages and billing configuration

**Stories**:
- **SA-006**: Package Management (13 points)
- **SA-004**: Billing Configuration (8 points)

**Week 11 Tasks - Backend Focus**:
```
Day 1-3: Package Management APIs (Go Fiber)
  [ ] Create /v1/packages endpoint (CRUD)
  [ ] Implement package pricing (monthly/yearly)
  [ ] Create package features (disk, bandwidth, databases)
  [ ] Add package visibility (public/private)
  [ ] Implement package ordering

Day 4-5: Billing Configuration APIs
  [ ] Create /v1/billing/settings endpoint
  [ ] Implement payment gateway config (Stripe/PayPal)
  [ ] Create tax settings API
  [ ] Add invoice numbering configuration
  [ ] Set up currency and locale settings
```

**Week 12 Tasks - Frontend Focus**:
```
Day 6-7: Package Management UI
  [ ] Create /app/admin/packages/page.tsx
  [ ] Build package creation form
  [ ] Add feature builder (disk, bandwidth, etc.)
  [ ] Create pricing editor (monthly/yearly)
  [ ] Implement package preview

Day 8-10: Billing Config UI
  [ ] Create /app/admin/billing/settings/page.tsx
  [ ] Build payment gateway configuration
  [ ] Add tax settings form
  [ ] Test billing configuration
```

**Deliverables**:
- ✅ Package management complete
- ✅ Billing configuration working
- ✅ Payment gateway integrated (Stripe sandbox)
- ✅ Tax calculation implemented

**AI Tool Usage**:
- Copilot: Generate package pricing calculations
- Claude Code: Review billing logic for accuracy

---

### **Sprint 6: Reseller Portal Foundation (Weeks 13-14)** - 8 Points

**Goal**: Build reseller dashboard and navigation

**Stories**:
- **RE-001**: Reseller Dashboard (8 points)

**Week 13 Tasks - Backend Focus**:
```
Day 1-3: Reseller Dashboard APIs (Go Fiber)
  [ ] Create /v1/reseller/dashboard endpoint
  [ ] Implement customer count for reseller
  [ ] Calculate reseller revenue and commissions
  [ ] Create resource usage aggregation
  [ ] Add recent activity feed

Day 4-5: Reseller Session Management
  [ ] Implement reseller-specific authentication
  [ ] Create reseller context middleware
  [ ] Add reseller data isolation
  [ ] Test reseller access control
```

**Week 14 Tasks - Frontend Focus**:
```
Day 6-7: Reseller Dashboard UI
  [ ] Create /app/reseller/dashboard/page.tsx
  [ ] Build reseller metrics cards
  [ ] Create revenue/commission chart
  [ ] Add customer list preview
  [ ] Implement navigation sidebar

Day 8-10: Reseller Layout & Testing
  [ ] Create /app/reseller/layout.tsx
  [ ] Add reseller-specific navigation
  [ ] Test reseller isolation
  [ ] Document reseller portal
```

**Deliverables**:
- ✅ Reseller dashboard functional
- ✅ Reseller metrics displaying
- ✅ Data isolation verified
- ✅ Navigation working

**AI Tool Usage**:
- Copilot: Generate dashboard components
- Claude Code: Review multi-tenancy implementation

---

### **Sprint 7: Reseller Customer Management (Weeks 15-16)** - 13 Points

**Goal**: Enable resellers to create and manage customers

**Stories**:
- **RE-002**: Customer Management (13 points)

**Week 15 Tasks - Backend Focus**:
```
Day 1-3: Customer Management APIs (Go Fiber)
  [ ] Create /v1/reseller/customers endpoint (CRUD)
  [ ] Implement customer creation by reseller
  [ ] Add customer package assignment
  [ ] Create customer suspension/activation
  [ ] Implement customer search and filtering

Day 4-5: Customer Limits & Validation
  [ ] Enforce reseller customer limits
  [ ] Validate customer package availability
  [ ] Add customer resource allocation
  [ ] Test customer isolation
```

**Week 16 Tasks - Frontend Focus**:
```
Day 6-7: Customer Management UI
  [ ] Create /app/reseller/customers/page.tsx
  [ ] Build customer table with actions
  [ ] Create customer creation wizard
  [ ] Add package assignment UI
  [ ] Implement customer detail view

Day 8-10: Testing & Polish
  [ ] Test customer CRUD operations
  [ ] Verify package assignments
  [ ] Test customer limits enforcement
  [ ] Document customer management
```

**Deliverables**:
- ✅ Reseller can create customers
- ✅ Package assignment working
- ✅ Customer limits enforced
- ✅ Customer search and filtering

**AI Tool Usage**:
- Copilot: Generate customer forms and tables
- Claude Code: Review customer isolation logic

---

### **Sprint 8: Reseller Billing (Weeks 17-18)** - 13 Points

**Goal**: Implement invoice management for resellers

**Stories**:
- **RE-005**: Invoice Management (13 points)

**Week 17 Tasks - Backend Focus**:
```
Day 1-3: Invoice APIs (Go Fiber)
  [ ] Create /v1/reseller/invoices endpoint
  [ ] Implement invoice generation for customers
  [ ] Add invoice sending (email)
  [ ] Create invoice payment recording
  [ ] Implement invoice status tracking

Day 4-5: Commission Calculation
  [ ] Calculate reseller commission on payments
  [ ] Create commission tracking system
  [ ] Generate reseller payout reports
  [ ] Test invoice generation
```

**Week 18 Tasks - Frontend Focus**:
```
Day 6-7: Invoice Management UI
  [ ] Create /app/reseller/invoices/page.tsx
  [ ] Build invoice table with filters
  [ ] Create invoice detail view
  [ ] Add manual invoice creation
  [ ] Implement invoice PDF generation

Day 8-10: Testing & Integration
  [ ] Test invoice email sending
  [ ] Verify commission calculations
  [ ] Test payment recording
  [ ] Document billing flows
```

**Deliverables**:
- ✅ Invoice generation working
- ✅ Email sending functional
- ✅ Commission tracking implemented
- ✅ PDF generation working

**AI Tool Usage**:
- Copilot: Generate invoice PDF templates
- Claude Code: Review commission calculation logic

---

### **Sprint 9: Customer Portal Foundation (Weeks 19-20)** - 8 Points

**Goal**: Build customer dashboard

**Stories**:
- **CU-001**: Customer Dashboard (8 points)

**Week 19 Tasks - Backend Focus**:
```
Day 1-3: Customer Dashboard APIs (Go Fiber)
  [ ] Create /v1/customer/dashboard endpoint
  [ ] Implement website list for customer
  [ ] Add resource usage metrics
  [ ] Create recent activity feed
  [ ] Add billing summary

Day 4-5: Customer Session Management
  [ ] Implement customer authentication
  [ ] Create customer context middleware
  [ ] Add customer data isolation
  [ ] Test customer access control
```

**Week 20 Tasks - Frontend Focus**:
```
Day 6-7: Customer Dashboard UI
  [ ] Create /app/customer/dashboard/page.tsx
  [ ] Build website cards
  [ ] Create resource usage indicators
  [ ] Add billing summary widget
  [ ] Implement quick actions

Day 8-10: Customer Layout & Testing
  [ ] Create /app/customer/layout.tsx
  [ ] Add customer navigation
  [ ] Test customer isolation
  [ ] Document customer portal
```

**Deliverables**:
- ✅ Customer dashboard functional
- ✅ Website list displaying
- ✅ Resource usage visible
- ✅ Navigation working

**AI Tool Usage**:
- Copilot: Generate dashboard widgets
- Claude Code: Review customer portal architecture

---

### **Sprint 10: Website Management Core (Weeks 21-22)** - 13 Points

**Goal**: Enable customers to create and manage websites

**Stories**:
- **CU-002**: Website Management (13 points)

**Week 21 Tasks - Backend Focus**:
```
Day 1-3: Website Management APIs (Go Fiber)
  [ ] Create /v1/customer/websites endpoint (CRUD)
  [ ] Implement website creation
  [ ] Add domain assignment
  [ ] Create website suspension/activation
  [ ] Implement resource allocation

Day 4-5: Website Provisioning
  [ ] Create NGINX vhost configuration
  [ ] Set up directory structure on AX 43
  [ ] Create PHP-FPM pool
  [ ] Add MySQL database creation
  [ ] Test website provisioning
```

**Week 22 Tasks - Frontend Focus**:
```
Day 6-7: Website Management UI
  [ ] Create /app/customer/websites/page.tsx
  [ ] Build website creation wizard
  [ ] Add domain configuration form
  [ ] Create website settings page
  [ ] Implement website preview

Day 8-10: Testing & Integration
  [ ] Test website creation end-to-end
  [ ] Verify NGINX configuration
  [ ] Test domain resolution
  [ ] Document website management
```

**Deliverables**:
- ✅ Website creation working
- ✅ NGINX vhosts generated
- ✅ Domain assignment functional
- ✅ Resource allocation implemented

**AI Tool Usage**:
- Copilot: Generate NGINX configuration templates
- Claude Code: Review website provisioning logic

---

### **Sprint 11: Backup & Restore (Weeks 23-24)** - 13 Points

**Goal**: Implement backup and restore functionality

**Stories**:
- **CU-008**: Backup & Restore (13 points)

**Week 23 Tasks - Backend Focus**:
```
Day 1-3: Backup APIs (Go Fiber)
  [ ] Create /v1/customer/backups endpoint
  [ ] Implement manual backup creation
  [ ] Add scheduled backup configuration
  [ ] Create backup to object storage (Hetzner)
  [ ] Implement backup rotation (7 daily, 4 weekly)

Day 4-5: Restore Functionality
  [ ] Create /v1/customer/backups/:id/restore endpoint
  [ ] Implement file restore
  [ ] Add database restore
  [ ] Test backup integrity
```

**Week 24 Tasks - Frontend Focus**:
```
Day 6-7: Backup Management UI
  [ ] Create /app/customer/backups/page.tsx
  [ ] Build backup list with details
  [ ] Add manual backup button
  [ ] Create restore confirmation modal
  [ ] Implement backup schedule configuration

Day 8-10: Testing & Integration
  [ ] Test backup creation
  [ ] Verify restore functionality
  [ ] Test scheduled backups
  [ ] Document backup procedures
```

**Deliverables**:
- ✅ Manual backups working
- ✅ Scheduled backups running
- ✅ Restore functionality tested
- ✅ Backup rotation implemented

**AI Tool Usage**:
- Copilot: Generate backup scripts
- Claude Code: Review backup strategy and data integrity

---

### **Sprint 12: Customer Billing (Weeks 25-26)** - 13 Points

**Goal**: Enable customers to view invoices and make payments

**Stories**:
- **CU-009**: Billing & Invoices (13 points)

**Week 25 Tasks - Backend Focus**:
```
Day 1-3: Customer Billing APIs (Go Fiber)
  [ ] Create /v1/customer/invoices endpoint
  [ ] Implement invoice viewing
  [ ] Add payment method management
  [ ] Create payment processing (Stripe)
  [ ] Implement payment confirmation

Day 4-5: Subscription Management
  [ ] Create subscription renewal logic
  [ ] Add auto-payment configuration
  [ ] Implement payment retry logic
  [ ] Test payment flows
```

**Week 26 Tasks - Frontend Focus**:
```
Day 6-7: Billing UI
  [ ] Create /app/customer/billing/page.tsx
  [ ] Build invoice table
  [ ] Add payment method form (Stripe Elements)
  [ ] Create payment confirmation page
  [ ] Implement invoice PDF download

Day 8-10: Testing & Integration
  [ ] Test Stripe payment flow
  [ ] Verify invoice generation
  [ ] Test auto-renewal
  [ ] Document billing procedures
```

**Deliverables**:
- ✅ Customer can view invoices
- ✅ Payment processing working (Stripe)
- ✅ Auto-renewal implemented
- ✅ Payment confirmations sent

**AI Tool Usage**:
- Copilot: Generate Stripe integration code
- Claude Code: Review payment security and PCI compliance

---

### **Sprint 13: SSH & Developer Tools (Weeks 27-28)** - 13 Points

**Goal**: Provide SSH and SFTP access for technical users

**Stories**:
- **TU-001**: SSH Access (8 points)
- **TU-002**: SFTP Access (5 points)

**Week 27 Tasks - Backend Focus**:
```
Day 1-3: SSH Access Implementation (Go)
  [ ] Set up SSH key management
  [ ] Create /v1/customer/ssh/keys endpoint
  [ ] Implement SSH user creation on AX 43
  [ ] Add SSH key injection to authorized_keys
  [ ] Configure jailed SSH environment

Day 4-5: SFTP Access
  [ ] Enable SFTP for SSH users
  [ ] Create SFTP chroot jail
  [ ] Add SFTP logging
  [ ] Test SSH/SFTP access
```

**Week 28 Tasks - Frontend Focus**:
```
Day 6-7: SSH Key Management UI
  [ ] Create /app/customer/developer/ssh/page.tsx
  [ ] Build SSH key upload form
  [ ] Add SSH key list with actions
  [ ] Create SSH connection instructions
  [ ] Add SFTP configuration guide

Day 8-10: Testing & Documentation
  [ ] Test SSH key authentication
  [ ] Verify SFTP access
  [ ] Test SSH jail security
  [ ] Document SSH setup procedures
```

**Deliverables**:
- ✅ SSH access working
- ✅ SFTP access functional
- ✅ SSH keys managed via UI
- ✅ Security jailing implemented

**AI Tool Usage**:
- Copilot: Generate SSH configuration templates
- Claude Code: Review SSH security hardening

---

### **Sprint 14: PHP Config & Cron Jobs (Weeks 29-30)** - 16 Points

**Goal**: Enable PHP configuration and cron job management

**Stories**:
- **TU-003**: PHP Configuration (8 points)
- **TU-004**: Cron Jobs (8 points)

**Week 29 Tasks - Backend Focus**:
```
Day 1-3: PHP Configuration APIs (Go)
  [ ] Create /v1/customer/websites/:id/php endpoint
  [ ] Implement PHP version selection (7.4, 8.0, 8.1, 8.2, 8.3)
  [ ] Add php.ini customization
  [ ] Create PHP-FPM pool reconfiguration
  [ ] Test PHP version switching

Day 4-5: Cron Job Management
  [ ] Create /v1/customer/cron endpoint (CRUD)
  [ ] Implement cron job creation
  [ ] Add cron schedule validation
  [ ] Create crontab updates on AX 43
  [ ] Test cron execution
```

**Week 30 Tasks - Frontend Focus**:
```
Day 6-7: PHP Configuration UI
  [ ] Create /app/customer/websites/[id]/php/page.tsx
  [ ] Build PHP version selector
  [ ] Add php.ini editor
  [ ] Create PHP extension toggles
  [ ] Test PHP configuration changes

Day 8-10: Cron Job UI
  [ ] Create /app/customer/developer/cron/page.tsx
  [ ] Build cron job form
  [ ] Add cron schedule builder (visual)
  [ ] Implement cron job list with actions
  [ ] Test cron job execution
```

**Deliverables**:
- ✅ PHP version switching working
- ✅ php.ini customization functional
- ✅ Cron jobs manageable via UI
- ✅ Cron execution verified

**AI Tool Usage**:
- Copilot: Generate cron schedule validation
- Claude Code: Review PHP configuration security

---

### **Sprint 15: Testing Infrastructure (Weeks 31-32)** - 8 Points

**Goal**: Set up comprehensive testing infrastructure

**Stories**:
- **TECH-006**: Testing Infrastructure (8 points)

**Week 31 Tasks - Testing Setup**:
```
Day 1-3: Unit & Integration Tests
  [ ] Set up RUST testing framework (cargo test)
  [ ] Create integration test suite for APIs
  [ ] Add database test fixtures
  [ ] Write tests for authentication
  [ ] Write tests for user management

Day 4-5: Frontend Testing
  [ ] Set up Vitest for Next.js
  [ ] Create component tests (React Testing Library)
  [ ] Add E2E tests (Playwright)
  [ ] Test critical user flows
```

**Week 32 Tasks - Test Coverage & CI**:
```
Day 6-8: Test Coverage
  [ ] Add coverage reporting (>80% target)
  [ ] Write missing tests
  [ ] Fix failing tests
  [ ] Document testing procedures

Day 9-10: CI Integration
  [ ] Add tests to GitHub Actions
  [ ] Set up test databases in CI
  [ ] Configure E2E tests in CI
  [ ] Review test results
```

**Deliverables**:
- ✅ Unit test coverage >80%
- ✅ Integration tests passing
- ✅ E2E tests for critical flows
- ✅ CI running all tests

**AI Tool Usage**:
- Copilot: Generate test cases and fixtures
- Claude Code: Review test coverage and identify gaps

---

### **Sprint 16: Integration Testing (Weeks 33-34)** - 8 Points

**Goal**: End-to-end integration testing and bug fixes

**Week 33 Tasks - Integration Testing**:
```
Day 1-3: Full Platform Testing
  [ ] Test Super Admin flows (user creation → package assignment)
  [ ] Test Reseller flows (customer creation → invoice)
  [ ] Test Customer flows (website creation → backup)
  [ ] Test Technical User flows (SSH → cron jobs)
  [ ] Identify and log bugs

Day 4-5: Bug Prioritization
  [ ] Create bug tracking list
  [ ] Prioritize critical/high bugs
  [ ] Assign bug fixes to sprint backlog
  [ ] Begin critical bug fixes
```

**Week 34 Tasks - Bug Fixes**:
```
Day 6-10: Bug Fix Sprint
  [ ] Fix all critical bugs
  [ ] Fix high-priority bugs
  [ ] Re-test fixed features
  [ ] Update documentation with fixes
  [ ] Verify no regressions
```

**Deliverables**:
- ✅ All critical bugs fixed
- ✅ Full platform integration tested
- ✅ No major regressions
- ✅ Updated bug tracking

**AI Tool Usage**:
- Copilot: Generate test scenarios
- Claude Code: Debug complex issues and suggest fixes

---

### **Sprint 17: MVP Polish & Launch Prep (Weeks 35-36)** - 8 Points

**Goal**: Final polish, performance optimization, security audit

**Week 35 Tasks - Polish & Optimization**:
```
Day 1-3: Performance Optimization
  [ ] Profile backend APIs (find slow queries)
  [ ] Optimize database queries
  [ ] Add database indexes
  [ ] Optimize Next.js bundle size
  [ ] Test page load times (<2s target)

Day 4-5: Security Audit
  [ ] Review authentication security
  [ ] Test authorization boundaries
  [ ] Check for SQL injection vulnerabilities
  [ ] Review input validation
  [ ] Test rate limiting
```

**Week 36 Tasks - Launch Preparation**:
```
Day 6-7: Documentation
  [ ] Complete user documentation
  [ ] Create admin guides
  [ ] Document API endpoints
  [ ] Write deployment guide
  [ ] Create troubleshooting guide

Day 8-10: Production Deployment (systemd)
  [ ] Build production binaries (RUST, Go, Next.js)
  [ ] Run Ansible playbook for AX 43 setup
  [ ] Deploy binaries using systemd services
  [ ] Configure NGINX reverse proxy
  [ ] Obtain SSL certificates (Let's Encrypt)
  [ ] Set up monitoring (Prometheus Node Exporter)
  [ ] Configure automated backups
  [ ] Perform final smoke tests
  [ ] 🚀 Launch MVP!
```

**Deliverables**:
- ✅ Performance targets met (<2s page load)
- ✅ Security audit passed
- ✅ Documentation complete
- ✅ MVP deployed to production
- ✅ **Platform ready for first customers**

**AI Tool Usage**:
- Copilot: Generate documentation
- Claude Code: Security audit and optimization suggestions

---

## 🎯 Success Criteria

### MVP Launch Criteria (Week 36)

**Technical Requirements**:
- [ ] All authentication flows working (login, 2FA, password reset)
- [ ] Super Admin can create resellers and packages
- [ ] Resellers can create and manage customers
- [ ] Customers can create websites and manage hosting
- [ ] Billing system generates invoices automatically
- [ ] Backup system running daily
- [ ] SSH/SFTP access functional
- [ ] All critical bugs fixed
- [ ] Test coverage >80%
- [ ] Performance <2s page load time
- [ ] Security audit passed

**Business Requirements**:
- [ ] Platform can support 10-20 customers at launch
- [ ] Billing automation working (Stripe integration)
- [ ] Email notifications sending (invoices, alerts)
- [ ] Support ticket system ready (if Phase 1)
- [ ] Documentation complete for users

**Infrastructure Requirements**:
- [ ] AX 43 production server configured
- [ ] NGINX reverse proxy working
- [ ] SSL certificates installed (Let's Encrypt)
- [ ] Database backups automated
- [ ] Monitoring dashboards active
- [ ] CI/CD pipeline deploying to production

---

## 📊 Velocity Tracking

### Expected Sprint Velocity

**Base Velocity** (without AI tools): 8-10 points/sprint
**With AI Assistance**: 10-15 points/sprint (30-40% boost)

**Total Story Points for MVP**: 152 points
**Estimated Sprints**: 15-17 sprints (30-34 weeks)
**Actual Plan**: 18 sprints (36 weeks) with buffer

### Velocity Adjustment Factors

**Increase Velocity** (+20-30%):
- ✅ Using GitHub Copilot daily for boilerplate
- ✅ Using Claude Code for architecture review
- ✅ Focused weekly themes (less context switching)
- ✅ Clear acceptance criteria
- ✅ Well-defined API contracts

**Decrease Velocity** (-20-30%):
- ❌ Learning new technologies (RUST, Go)
- ❌ Complex infrastructure setup
- ❌ Debugging difficult issues
- ❌ Context switching between frontend/backend
- ❌ Unforeseen technical debt

### Monthly Review Checkpoints

**End of Month 1 (Week 4)**: Sprint 1 complete
- ✅ Verify infrastructure and authentication working
- 📊 Velocity check: Did we complete 13-21 points?
- 🔄 Adjust future sprint planning if needed

**End of Month 2 (Week 8)**: Sprint 3 complete
- ✅ Verify Super Admin portal functional
- 📊 Velocity check: Are we on track (50+ points)?
- 🔄 Adjust scope or timeline if behind

**End of Month 3 (Week 12)**: Sprint 5 complete
- ✅ Verify package and billing working
- 📊 Velocity check: Are we at 70+ points?
- 🔄 Consider cutting scope if significantly behind

**End of Month 4 (Week 16)**: Sprint 7 complete
- ✅ Verify reseller portal functional
- 📊 Velocity check: Are we at 90+ points?
- 🔄 Finalize MVP scope for remaining sprints

**End of Month 5 (Week 20)**: Sprint 9 complete
- ✅ Verify customer portal functional
- 📊 Velocity check: Are we at 110+ points?
- 🔄 Plan final polish sprint

**End of Month 6 (Week 24)**: Sprint 11 complete
- ✅ Verify backup system working
- 📊 Velocity check: Are we at 125+ points?
- 🔄 Adjust final sprints if needed

**End of Month 7 (Week 28)**: Sprint 13 complete
- ✅ Verify SSH and developer tools working
- 📊 Velocity check: Are we at 140+ points?
- 🔄 Plan testing and polish sprints

**End of Month 8 (Week 32)**: Sprint 15 complete
- ✅ Verify testing infrastructure complete
- 📊 Velocity check: Are we ready for integration testing?
- 🔄 Plan final bug fix and polish sprints

**End of Month 9 (Week 36)**: Sprint 17 complete
- ✅ MVP launched!
- 📊 Final retrospective and lessons learned
- 🎉 Celebrate and plan post-MVP features

---

## 🛠️ Development Environment Setup

### Homelab (Terra PC) - Development

**Services to Run**:
```yaml
PostgreSQL: Development database
Redis: Session storage
n8n: Workflow automation (billing, emails)
Prometheus: Metrics collection
Grafana: Monitoring dashboards
```

**Docker Compose Setup** (recommended):
```yaml
# ~/homelab/docker-compose.yml
version: '3.8'

services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: hosting_dev
      POSTGRES_PASSWORD: dev_password
      POSTGRES_DB: hosting_platform
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7.2-alpine
    ports:
      - "6379:6379"

  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=admin
    volumes:
      - n8n_data:/home/node/.n8n

  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

volumes:
  postgres_data:
  n8n_data:
```

### VPS 1 (Development Environment)

**Services**:
- RUST API Gateway (port 8080)
- Go Microservices (ports 8081-8085)
- Next.js Dev Server (port 3000)
- NGINX reverse proxy (port 80/443)

### VPS 2 (Staging Environment)

**Services**:
- Full production-like environment
- Used for testing before AX 43 deployment
- Smaller scale (1-5 test websites)

### AX 43 (Production - Deploy in Week 36)

**Services**:
- RUST API Gateway
- Go Microservices
- Next.js (production build)
- PostgreSQL
- Redis
- NGINX
- Website hosting (customer sites)

---

## 📈 Post-MVP Roadmap (Months 10-12)

After MVP launch in Month 9, continue with Phase 2 features:

**Month 10**: Phase 2 Core Features
- **SA-003**: Server Provisioning (13 points)
- **SA-005**: Security Monitoring (13 points)
- **RE-003**: White-Label Branding (8 points)
- **RE-004**: Custom Pricing (8 points)

**Month 11**: Phase 2 Customer Features
- **CU-003**: File Manager (13 points)
- **CU-004**: Database Management (8 points)
- **CU-005**: Email Account Management (13 points)
- **CU-006**: SSL Certificate Management (8 points)

**Month 12**: Phase 2 Polish
- **CU-007**: Domain Management (8 points)
- **RE-006**: Support Ticket System (13 points)
- **TU-006**: Application Logs (8 points)
- **Performance optimization**
- **Security hardening**

**Target**: 100 customers by end of Month 12

---

## 💰 Financial Milestones

### Break-Even Point

**Monthly Operating Costs**: €73-108/month

**Revenue Target** (€10/customer/month):
- 8-10 customers: Break even (€80-100/month)
- 20 customers: €200/month revenue (profitable)
- 50 customers: €500/month revenue
- 100 customers: €1,000/month revenue

### Customer Acquisition Timeline

**Month 9-10** (MVP launch): 5-10 pilot customers
**Month 11-12**: 20-30 customers
**Month 13-15**: 50-75 customers
**Month 16-18**: 100-150 customers

**Target**: Break even by Month 10 (8-10 customers)

---

## 🎯 Weekly Standup Template

### Monday Morning (Sprint Planning)

**Review Last Week**:
- [ ] What did I complete?
- [ ] What story points did I finish?
- [ ] What blockers did I encounter?

**Plan This Week**:
- [ ] What stories am I working on?
- [ ] What is my goal for the week?
- [ ] Do I need to learn anything new?

**Risk Check**:
- [ ] Am I on track with the sprint?
- [ ] Do I need to adjust scope?
- [ ] Are there any technical risks?

### Friday Evening (Sprint Review)

**Completed Work**:
- [ ] List all completed stories
- [ ] Demo to yourself (record if needed)
- [ ] Update sprint board

**Next Week Preview**:
- [ ] What's coming next?
- [ ] Any preparation needed?

**Retrospective**:
- [ ] What went well?
- [ ] What can be improved?
- [ ] What did I learn?

---

## 🚀 Ready to Start?

This plan provides a realistic roadmap for a solo developer to build an MVP in 8-9 months using modern AI tools.

**Key Success Factors**:
1. ✅ **Consistency**: Code daily, even if only 2-4 hours
2. ✅ **Focus**: Stick to weekly themes (Backend vs Frontend)
3. ✅ **AI Assistance**: Use Copilot and Claude Code extensively
4. ✅ **Scope Discipline**: Don't add features outside the plan
5. ✅ **Testing**: Write tests as you code (don't defer)
6. ✅ **Documentation**: Document as you build
7. ✅ **Review Velocity**: Monthly checkpoint reviews
8. ✅ **Celebrate Wins**: Acknowledge sprint completions

**Next Steps**:
1. Set up homelab development environment (Week 1, Day 1)
2. Create GitHub repository structure
3. Initialize RUST and Go projects
4. Initialize Next.js project
5. Start Sprint 0! 🎯

---

**Last Updated**: 2025-11-11
**Created for**: Solo Developer - 9 Month MVP Plan
**Status**: Ready to Execute 🚀
