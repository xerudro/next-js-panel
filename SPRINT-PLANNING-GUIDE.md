# Sprint Planning Guide
## Unified Hosting Platform Development

**Version:** 1.0
**Last Updated:** November 11, 2025
**Team Size:** 4-6 developers
**Sprint Duration:** 2 weeks

---

## Table of Contents

1. [Sprint 0: Infrastructure Setup](#sprint-0-infrastructure-setup)
2. [Sprint 1: Authentication & API Gateway](#sprint-1-authentication--api-gateway)
3. [Sprint 2: User Management & Packages](#sprint-2-user-management--packages)
4. [Sprint 3: Frontend Foundation](#sprint-3-frontend-foundation)
5. [Sprint 4: Website Hosting Core](#sprint-4-website-hosting-core)
6. [Sprint 5: Billing Foundation](#sprint-5-billing-foundation)
7. [Sprint 6: MVP Polish & Launch Prep](#sprint-6-mvp-polish--launch-prep)
8. [Sprint Ceremonies](#sprint-ceremonies)
9. [Definition of Ready](#definition-of-ready)
10. [Definition of Done](#definition-of-done)

---

## Sprint 0: Infrastructure Setup
**Duration:** Weeks 1-2
**Goal:** Set up development infrastructure and tooling
**Target Points:** 21 points

### Stories for Sprint 0

| Story ID | Title | Points | Assignee | Priority |
|----------|-------|--------|----------|----------|
| TECH-001 | CI/CD Pipeline Setup | 8 | DevOps | Critical |
| TECH-002 | Database Schema & Migrations | 13 | Backend Lead | Critical |

**Total:** 21 points

---

### Detailed Tasks: TECH-001 (CI/CD Pipeline)

**Week 1:**
- [ ] Set up GitHub Actions workflows
  - [ ] Create `.github/workflows/ci.yml`
  - [ ] Configure linting (ESLint, Prettier)
  - [ ] Configure TypeScript type checking
  - [ ] Set up unit test runner
- [ ] Configure testing infrastructure
  - [ ] Jest for Next.js frontend
  - [ ] Cargo test for RUST backend
  - [ ] Go test for Go services
- [ ] Set up code coverage reporting
  - [ ] Codecov integration
  - [ ] Coverage thresholds (80%+)

**Week 2:**
- [ ] Set up deployment pipeline
  - [ ] Staging environment (Hetzner Cloud)
  - [ ] Production environment setup
  - [ ] Automated deployment on merge to main
  - [ ] Rollback capability
- [ ] Configure monitoring for CI/CD
  - [ ] GitHub Actions success/failure notifications
  - [ ] Slack integration for alerts

**Success Criteria:**
- ✅ All code changes trigger automated tests
- ✅ Test coverage report available for every PR
- ✅ Successful merge to main deploys to staging automatically
- ✅ Team receives notifications for build failures

---

### Detailed Tasks: TECH-002 (Database Schema)

**Week 1:**
- [ ] Design database schema
  - [ ] Entity-Relationship Diagram (ERD)
  - [ ] Tables: users, packages, websites, invoices, tickets, etc.
  - [ ] Foreign keys and relationships
  - [ ] Indexes for performance
- [ ] Set up migration tooling
  - [ ] Choose migration tool (golang-migrate or Atlas)
  - [ ] Configure migration directory structure
  - [ ] Create initial migration files

**Week 2:**
- [ ] Implement initial migrations
  - [ ] Create all tables
  - [ ] Add indexes
  - [ ] Add constraints (foreign keys, unique, not null)
- [ ] Create seed data for development
  - [ ] Sample users (admin, reseller, customer)
  - [ ] Sample packages
  - [ ] Sample websites
- [ ] Test migrations
  - [ ] Up/down migrations work correctly
  - [ ] Data integrity validated
  - [ ] Performance tested with sample data

**Success Criteria:**
- ✅ Database schema documented with ERD
- ✅ All migrations run successfully
- ✅ Seed data populates development database
- ✅ Rollback migrations work without errors

---

### Sprint 0 Deliverables

**By End of Week 2:**
1. ✅ CI/CD pipeline running for all code changes
2. ✅ Database schema fully designed and implemented
3. ✅ Development environment ready for coding
4. ✅ Team has access to staging environment
5. ✅ Project documentation updated

**Sprint 0 Retrospective:**
- What went well?
- What could be improved?
- Action items for Sprint 1

---

## Sprint 1: Authentication & API Gateway
**Duration:** Weeks 3-4
**Goal:** Build core authentication system and API gateway
**Target Points:** 26 points (stretch sprint)

### Stories for Sprint 1

| Story ID | Title | Points | Assignee | Priority |
|----------|-------|--------|----------|----------|
| TECH-003 | API Gateway Architecture | 13 | Backend Lead (RUST) | Critical |
| TECH-004 | Authentication System | 13 | Backend Dev (Go) | Critical |

**Total:** 26 points

**⚠️ Note:** This is a stretch sprint. If velocity is lower, move some tasks to Sprint 2.

---

### Detailed Tasks: TECH-003 (API Gateway - RUST)

**Week 1:**
- [ ] Set up Actix-web or Axum project
  - [ ] Create new RUST project
  - [ ] Configure dependencies (tokio, serde, etc.)
  - [ ] Set up project structure
- [ ] Implement basic routing
  - [ ] Health check endpoint (`GET /health`)
  - [ ] API versioning (`/v1/`)
  - [ ] Routing to backend services
- [ ] Add request/response logging
  - [ ] Structured logging (tracing crate)
  - [ ] Request ID generation
  - [ ] Access logs

**Week 2:**
- [ ] Implement authentication middleware
  - [ ] JWT token validation
  - [ ] Extract user from token
  - [ ] Protected route examples
- [ ] Add rate limiting
  - [ ] Per-IP rate limiting
  - [ ] Per-user rate limiting
  - [ ] Rate limit headers
- [ ] Configure CORS
  - [ ] Allow Next.js origin
  - [ ] Preflight requests
- [ ] Add metrics endpoint
  - [ ] Prometheus metrics
  - [ ] Request count, latency, errors

**Success Criteria:**
- ✅ API Gateway accepts requests and routes to services
- ✅ Health check endpoint returns 200 OK
- ✅ JWT tokens are validated correctly
- ✅ Rate limiting prevents abuse
- ✅ Metrics available for Prometheus

---

### Detailed Tasks: TECH-004 (Authentication System - Go)

**Week 1:**
- [ ] Implement user registration
  - [ ] POST `/v1/auth/register` endpoint
  - [ ] Email validation
  - [ ] Password hashing (bcrypt)
  - [ ] Save user to database
  - [ ] Send verification email
- [ ] Implement login
  - [ ] POST `/v1/auth/login` endpoint
  - [ ] Validate credentials
  - [ ] Generate JWT tokens
  - [ ] Return access + refresh tokens

**Week 2:**
- [ ] Implement token refresh
  - [ ] POST `/v1/auth/refresh` endpoint
  - [ ] Validate refresh token
  - [ ] Generate new access token
- [ ] Implement logout
  - [ ] POST `/v1/auth/logout` endpoint
  - [ ] Invalidate tokens (blacklist)
- [ ] Implement password reset
  - [ ] POST `/v1/auth/forgot-password`
  - [ ] Send reset email with token
  - [ ] POST `/v1/auth/reset-password`
- [ ] Add 2FA setup
  - [ ] Generate TOTP secret
  - [ ] QR code generation
  - [ ] Verify TOTP code

**Success Criteria:**
- ✅ Users can register with email and password
- ✅ Users can log in and receive JWT tokens
- ✅ Tokens expire after configured time (15 min access, 7 days refresh)
- ✅ Password reset flow works end-to-end
- ✅ 2FA can be enabled and validated

---

### Sprint 1 Deliverables

**By End of Week 4:**
1. ✅ API Gateway running and accepting requests
2. ✅ Users can register, log in, and log out
3. ✅ JWT authentication working
4. ✅ Rate limiting prevents abuse
5. ✅ API documentation updated (OpenAPI)

**Testing Requirements:**
- Unit tests for all authentication functions (>80% coverage)
- Integration tests for auth flow
- Security review completed

---

## Sprint 2: User Management & Packages
**Duration:** Weeks 5-6
**Goal:** Enable user management and package creation
**Target Points:** 21 points

### Stories for Sprint 2

| Story ID | Title | Points | Assignee | Priority |
|----------|-------|--------|----------|----------|
| SA-002 | User Management | 13 | Backend Dev | Critical |
| SA-006 | Package Management (MVP) | 8 | Backend Dev | Critical |

**Total:** 21 points

---

### Detailed Tasks: SA-002 (User Management)

**Week 1:**
- [ ] Implement user CRUD API
  - [ ] GET `/v1/users` - List users (paginated)
  - [ ] GET `/v1/users/:id` - Get user details
  - [ ] POST `/v1/users` - Create user (admin only)
  - [ ] PUT `/v1/users/:id` - Update user
  - [ ] DELETE `/v1/users/:id` - Soft delete user
- [ ] Add user search and filtering
  - [ ] Search by email, name
  - [ ] Filter by role (admin, reseller, customer)
  - [ ] Filter by status (active, suspended)

**Week 2:**
- [ ] Implement user actions
  - [ ] Suspend user account
  - [ ] Unsuspend user account
  - [ ] Force password reset
  - [ ] View login history
  - [ ] Impersonate user (with audit log)
- [ ] Add role-based access control (RBAC)
  - [ ] Define roles (super_admin, reseller, customer, technical_user)
  - [ ] Check permissions in middleware
  - [ ] Restrict API endpoints by role

**Success Criteria:**
- ✅ Admins can manage all users
- ✅ Users cannot access other users' data
- ✅ User actions are logged for audit
- ✅ Search and filtering works correctly

---

### Detailed Tasks: SA-006 (Package Management)

**Week 1:**
- [ ] Design package data model
  - [ ] Package schema (name, price, resources)
  - [ ] Resource limits (disk, bandwidth, domains, etc.)
- [ ] Implement package CRUD API
  - [ ] GET `/v1/packages` - List packages
  - [ ] GET `/v1/packages/:id` - Get package details
  - [ ] POST `/v1/packages` - Create package (admin only)
  - [ ] PUT `/v1/packages/:id` - Update package
  - [ ] DELETE `/v1/packages/:id` - Delete package

**Week 2:**
- [ ] Add package features configuration
  - [ ] Enable/disable features (SSH, Git, staging)
  - [ ] PHP versions available
  - [ ] Security features (WAF, malware scanning)
- [ ] Package visibility settings
  - [ ] Public, hidden, reseller-only

**Success Criteria:**
- ✅ Packages can be created with resource limits
- ✅ Packages can be assigned to users
- ✅ Package pricing is configurable

---

### Sprint 2 Deliverables

**By End of Week 6:**
1. ✅ User management fully functional
2. ✅ RBAC implemented and tested
3. ✅ Packages can be created and managed
4. ✅ API documentation updated

---

## Sprint 3: Frontend Foundation
**Duration:** Weeks 7-8
**Goal:** Build Next.js frontend with dashboards
**Target Points:** 21 points

### Stories for Sprint 3

| Story ID | Title | Points | Assignee | Priority |
|----------|-------|--------|----------|----------|
| NEXT-001 | Next.js Project Setup | 5 | Frontend Lead | Critical |
| CU-001 | Customer Dashboard | 8 | Frontend Dev 1 | Critical |
| RE-001 | Reseller Dashboard | 8 | Frontend Dev 2 | Critical |

**Total:** 21 points

---

### Detailed Tasks: NEXT-001 (Next.js Setup)

**Week 1:**
- [ ] Initialize Next.js 16 project
  - [ ] `npx create-next-app@latest`
  - [ ] Configure TypeScript
  - [ ] Set up Tailwind CSS
- [ ] Install dependencies
  - [ ] React Query, Zustand, React Hook Form
  - [ ] Lucide Icons, date-fns
  - [ ] Zod validation
- [ ] Project structure
  - [ ] Set up app router structure
  - [ ] Create layout components
  - [ ] Configure API client (axios)

**Week 2:**
- [ ] Authentication integration
  - [ ] Login page
  - [ ] Protected route wrapper
  - [ ] Token storage (httpOnly cookies)
  - [ ] Logout functionality
- [ ] Global components
  - [ ] Header, Sidebar, Footer
  - [ ] Button, Input, Card, Table components
  - [ ] Toast notifications

**Success Criteria:**
- ✅ Next.js app runs locally
- ✅ Users can log in and log out
- ✅ Protected routes redirect unauthenticated users

---

### Sprint 3 Deliverables

**By End of Week 8:**
1. ✅ Next.js app deployed to staging
2. ✅ Customer and Reseller dashboards functional
3. ✅ Users can log in and see their dashboard
4. ✅ UI is responsive and accessible

---

## Sprint 4: Website Hosting Core
**Duration:** Weeks 9-10
**Goal:** Enable customers to create and manage websites
**Target Points:** 21 points

### Stories for Sprint 4

| Story ID | Title | Points | Assignee | Priority |
|----------|-------|--------|----------|----------|
| CU-002 | Website Management | 13 | Full Stack Dev | Critical |
| PROV-001 | Website Provisioning Automation | 8 | DevOps + Backend | Critical |

**Total:** 21 points

---

### Detailed Tasks: CU-002 (Website Management)

**Frontend (Week 1):**
- [ ] Website creation form
  - [ ] Domain name input
  - [ ] Application type selector (WordPress, PHP, Node.js)
  - [ ] PHP version selector
- [ ] Website list view
  - [ ] Show all user's websites
  - [ ] Status indicators (active, provisioning, error)
  - [ ] Quick actions (visit, manage, delete)

**Backend (Week 1-2):**
- [ ] Website CRUD API
  - [ ] POST `/v1/websites` - Create website
  - [ ] GET `/v1/websites` - List websites
  - [ ] GET `/v1/websites/:id` - Get website details
  - [ ] DELETE `/v1/websites/:id` - Delete website
- [ ] Website provisioning logic
  - [ ] Create directory structure
  - [ ] Configure NGINX vhost
  - [ ] Create PHP-FPM pool
  - [ ] Set file permissions
  - [ ] Configure DNS (if managed)

**Success Criteria:**
- ✅ Customers can create websites
- ✅ Websites are accessible via browser
- ✅ PHP version selection works

---

### Sprint 4 Deliverables

**By End of Week 10:**
1. ✅ Customers can create websites
2. ✅ Websites are provisioned automatically
3. ✅ Websites are accessible via domain
4. ✅ Basic website management (view, delete)

---

## Sprint 5: Billing Foundation
**Duration:** Weeks 11-12
**Goal:** Enable billing and payments
**Target Points:** 21 points

### Stories for Sprint 5

| Story ID | Title | Points | Assignee | Priority |
|----------|-------|--------|----------|----------|
| SA-004 | Billing Configuration | 8 | Backend Dev | Critical |
| CU-009 | Billing & Invoices | 13 | Full Stack Dev | Critical |

**Total:** 21 points

---

### Detailed Tasks: SA-004 (Billing Configuration)

**Week 1:**
- [ ] Stripe integration
  - [ ] Create Stripe account
  - [ ] Configure API keys (test mode)
  - [ ] Set up webhook endpoint
- [ ] Invoice generation logic
  - [ ] Recurring billing cron job
  - [ ] Invoice PDF generation
  - [ ] Email invoice to customer

**Week 2:**
- [ ] Payment processing
  - [ ] Accept credit card payments
  - [ ] Update invoice status (paid/unpaid)
  - [ ] Handle payment failures
  - [ ] Retry failed payments

**Success Criteria:**
- ✅ Invoices generated automatically
- ✅ Customers can pay via Stripe
- ✅ Payment success updates invoice status

---

### Detailed Tasks: CU-009 (Billing & Invoices)

**Frontend (Week 1):**
- [ ] Invoice list view
  - [ ] Show all invoices (paid, unpaid, overdue)
  - [ ] Filter by status
  - [ ] Download PDF
- [ ] Invoice detail view
  - [ ] Line items
  - [ ] Tax breakdown
  - [ ] Payment button

**Backend (Week 1-2):**
- [ ] Invoice API
  - [ ] GET `/v1/invoices` - List invoices
  - [ ] GET `/v1/invoices/:id` - Get invoice
  - [ ] POST `/v1/invoices/:id/pay` - Pay invoice
  - [ ] GET `/v1/invoices/:id/download` - Download PDF

**Success Criteria:**
- ✅ Customers can view invoices
- ✅ Customers can pay invoices
- ✅ PDF invoices can be downloaded

---

### Sprint 5 Deliverables

**By End of Week 12:**
1. ✅ Billing system functional
2. ✅ Customers can pay invoices
3. ✅ Stripe webhooks handled correctly
4. ✅ Invoice emails sent automatically

---

## Sprint 6: MVP Polish & Launch Prep
**Duration:** Weeks 13-14
**Goal:** Polish MVP and prepare for launch
**Target Points:** 21 points

### Stories for Sprint 6

| Story ID | Title | Points | Assignee | Priority |
|----------|-------|--------|----------|----------|
| TECH-005 | Monitoring & Observability | 8 | DevOps | High |
| CU-008 | Backup & Restore | 13 | Backend Dev | Critical |

**Total:** 21 points

---

### Additional Sprint 6 Tasks

**Week 1:**
- [ ] Bug fixes from previous sprints
- [ ] Performance optimization
- [ ] Security review
- [ ] Accessibility audit (WCAG 2.1 AA)

**Week 2:**
- [ ] User acceptance testing (UAT)
- [ ] Documentation updates
- [ ] Deployment runbook
- [ ] Launch checklist

**Launch Checklist:**
- [ ] All critical features tested
- [ ] Security vulnerabilities addressed
- [ ] Performance benchmarks met
- [ ] Monitoring and alerting configured
- [ ] Backup system tested
- [ ] Support documentation ready
- [ ] Marketing materials prepared
- [ ] Beta users recruited (5-10 customers)

---

## Sprint Ceremonies

### Sprint Planning (2 hours, start of sprint)
**Participants:** Entire team
**Agenda:**
1. Review sprint goal
2. Select stories from backlog
3. Break down stories into tasks
4. Estimate effort and assign owners
5. Commit to sprint goal

**Outputs:**
- Sprint backlog
- Sprint goal statement
- Task assignments

---

### Daily Standup (15 minutes, daily)
**Participants:** Development team
**Format:** Each person answers:
1. What did I complete yesterday?
2. What will I work on today?
3. Any blockers or impediments?

**Rules:**
- Keep it brief (max 2 min per person)
- Discuss blockers offline (parking lot)
- Update task board during standup

---

### Sprint Review (1 hour, end of sprint)
**Participants:** Team + stakeholders
**Agenda:**
1. Demo completed stories
2. Gather feedback
3. Update product backlog
4. Review sprint metrics (velocity, burndown)

**Outputs:**
- Stakeholder feedback
- Backlog refinements
- Velocity calculation

---

### Sprint Retrospective (1 hour, end of sprint)
**Participants:** Development team
**Agenda:**
1. What went well?
2. What could be improved?
3. Action items for next sprint

**Format:** (Choose one)
- Start/Stop/Continue
- Mad/Sad/Glad
- 4Ls (Liked/Learned/Lacked/Longed for)

**Outputs:**
- Action items
- Process improvements

---

### Backlog Refinement (1 hour, mid-sprint)
**Participants:** Product Owner + Tech Lead
**Agenda:**
1. Review upcoming stories
2. Add missing details
3. Break down large stories
4. Re-prioritize based on learnings

**Outputs:**
- Refined stories for next 2-3 sprints
- Updated estimates

---

## Definition of Ready

Before a story can be pulled into a sprint, it must meet these criteria:

- [ ] Story is written in user story format (As a... I want... So that...)
- [ ] Acceptance criteria are clear and testable (minimum 5)
- [ ] Story is estimated in story points
- [ ] Story is prioritized (Critical/High/Medium/Low)
- [ ] Dependencies are identified
- [ ] UI/UX mockups available (if applicable)
- [ ] API contract defined (if backend)
- [ ] Test scenarios documented
- [ ] Story is small enough (<13 points, ideally <8)
- [ ] Technical approach discussed and agreed
- [ ] Product Owner has reviewed and approved

---

## Definition of Done

For a story to be considered "Done", it must meet these criteria:

### Code Quality
- [ ] All acceptance criteria met
- [ ] Code reviewed and approved by 1+ team members
- [ ] No merge conflicts with main branch
- [ ] Code follows style guide (ESLint, Prettier)
- [ ] No critical or high-severity bugs

### Testing
- [ ] Unit tests written and passing (>80% coverage)
- [ ] Integration tests passing
- [ ] E2E tests passing (if applicable)
- [ ] Manual QA completed
- [ ] Accessibility tested (WCAG 2.1 AA)
- [ ] Cross-browser tested (Chrome, Firefox, Safari)
- [ ] Mobile responsive tested

### Documentation
- [ ] API documentation updated (OpenAPI)
- [ ] User documentation updated
- [ ] Code comments for complex logic
- [ ] README updated (if applicable)

### Performance & Security
- [ ] Performance tested (meets metrics)
- [ ] Security reviewed (no vulnerabilities)
- [ ] No sensitive data logged
- [ ] SQL injection prevented (parameterized queries)
- [ ] XSS prevention implemented

### Deployment
- [ ] Deployed to staging environment
- [ ] Smoke tests passing in staging
- [ ] Product Owner acceptance obtained
- [ ] Ready for production deployment

---

## Sprint Metrics to Track

### Velocity
- **Definition:** Story points completed per sprint
- **Target:** Establish baseline in first 3 sprints, then maintain +/- 20%
- **Frequency:** Calculated at end of each sprint

### Burndown
- **Definition:** Points remaining in sprint over time
- **Target:** Steady downward trend
- **Frequency:** Updated daily

### Cycle Time
- **Definition:** Days from "In Progress" to "Done"
- **Target:** <5 days for average story
- **Frequency:** Tracked per story

### Quality Metrics
- **Bug Rate:** Bugs found per story (<2 per story)
- **Test Coverage:** >80% code coverage
- **Build Success Rate:** >95% CI builds passing

---

## Tips for Successful Sprints

### 1. **Keep Sprints Focused**
- Don't overcommit (leave 20% buffer for unexpected work)
- Limit work-in-progress (WIP) to 2 stories per developer
- Finish stories before starting new ones

### 2. **Communicate Early & Often**
- Raise blockers immediately
- Update task status daily
- Ask for help when stuck

### 3. **Embrace Change**
- Sprint goal is fixed, but tasks can adapt
- Re-prioritize within sprint if needed
- Learn from retrospectives and adjust

### 4. **Celebrate Wins**
- Demo completed work to team
- Recognize individual contributions
- Track team velocity improvements

---

## Next Steps

1. ✅ **Review this guide** with the team
2. 📅 **Schedule Sprint 0 kickoff** meeting
3. 🎯 **Set up project tracking tool** (JIRA, Linear, GitHub Projects)
4. 📊 **Import PRODUCT-BACKLOG.csv** into tracking tool
5. 👥 **Assign roles** (Scrum Master, Product Owner, Tech Lead)
6. 🚀 **Start Sprint 0!**

---

**Document Version:** 1.0
**Next Review:** After Sprint 2
**Maintained by:** Product Owner & Scrum Master
