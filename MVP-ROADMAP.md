# MVP Roadmap - Unified Hosting Platform
## 3-Month Development Plan (Sprint 0-6)

**Version:** 1.0
**Timeline:** Weeks 1-14 (3.5 months)
**Team Size:** 4-6 developers
**Target:** Minimum Viable Product (MVP) Launch

---

## Overview

This roadmap outlines the critical path to launch the **Minimum Viable Product (MVP)** of the Unified Hosting Platform. The MVP includes core features needed for customers to:
- Create an account
- Purchase a hosting package
- Deploy a website
- Manage basic hosting features
- Pay invoices

---

## Visual Timeline

```
Week    1    2    3    4    5    6    7    8    9   10   11   12   13   14
Sprint  [---0---][---1---][---2---][---3---][---4---][---5---][---6---]
        Infrastructure  Auth+API  UserMgmt  Frontend WebHosting Billing  Polish
        └─ CI/CD       └─ JWT    └─ CRUD   └─ React └─ NGINX   └─ Stripe └─ Backup
        └─ Database    └─ RBAC   └─ Packages  Dashboard  Provision  Invoice  Monitor
```

---

## Sprint Breakdown

### Sprint 0: Infrastructure (Weeks 1-2) - 21 points
**Goal:** Foundation is ready for development

```
┌─────────────────────────────────────┐
│  TECH-001: CI/CD Pipeline (8 pts)  │
│  - GitHub Actions                   │
│  - Automated testing                │
│  - Deployment automation            │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  TECH-002: Database Schema (13 pts)│
│  - PostgreSQL tables                │
│  - Migrations                       │
│  - Seed data                        │
└─────────────────────────────────────┘
```

**Key Deliverables:**
- ✅ All code changes trigger automated tests
- ✅ Database schema complete with migrations
- ✅ Development environment ready

---

### Sprint 1: Authentication & API Gateway (Weeks 3-4) - 26 points
**Goal:** Users can register and log in securely

```
┌─────────────────────────────────────┐
│  TECH-003: API Gateway (13 pts)    │
│  - RUST (Actix-web)                 │
│  - Routing, Rate Limiting           │
│  - JWT Middleware                   │
└─────────────────────────────────────┘
              │
              ├──────────────────────┐
              ▼                      ▼
┌──────────────────────┐  ┌─────────────────────┐
│ TECH-004: Auth (13)  │  │  Health Check       │
│ - Registration       │  │  /health endpoint   │
│ - Login/Logout       │  │  Prometheus metrics │
│ - JWT tokens         │  └─────────────────────┘
│ - Password reset     │
│ - 2FA (TOTP)         │
└──────────────────────┘
```

**Key Deliverables:**
- ✅ API Gateway accepting requests
- ✅ Users can register and log in
- ✅ JWT authentication working

**Risk Mitigation:**
- This is a stretch sprint (26 points)
- If behind, move 2FA to Sprint 2

---

### Sprint 2: User Management & Packages (Weeks 5-6) - 21 points
**Goal:** Admins can manage users and create hosting packages

```
    ┌──────────────────────┐
    │ TECH-004: Auth       │ (from Sprint 1)
    └──────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  SA-002: User Management (13 pts)  │
│  - CRUD API for users               │
│  - Search & filtering               │
│  - Suspend/unsuspend                │
│  - RBAC (roles & permissions)       │
│  - Impersonation                    │
└─────────────────────────────────────┘
              │
              ├──────────────────────┐
              ▼                      ▼
┌──────────────────────┐  ┌─────────────────────┐
│ SA-006: Packages (8) │  │  Audit Logging      │
│ - Create packages    │  │  Track all actions  │
│ - Resource limits    │  └─────────────────────┘
│ - Pricing            │
│ - Features config    │
└──────────────────────┘
```

**Key Deliverables:**
- ✅ User management fully functional
- ✅ RBAC implemented
- ✅ Hosting packages can be created

---

### Sprint 3: Frontend Foundation (Weeks 7-8) - 21 points
**Goal:** Users can log in and see their dashboard

```
┌─────────────────────────────────────┐
│  NEXT-001: Next.js Setup (5 pts)   │
│  - Next.js 16 + TypeScript          │
│  - Tailwind CSS                     │
│  - React Query, Zustand             │
│  - Authentication integration       │
└─────────────────────────────────────┘
              │
              ├──────────────────────┬──────────────────────┐
              ▼                      ▼                      ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ CU-001: Customer │  │ RE-001: Reseller │  │ SA-001: Admin    │
│ Dashboard (8)    │  │ Dashboard (8)    │  │ Dashboard (Next) │
│ - Services view  │  │ - Customer list  │  │                  │
│ - Resource usage │  │ - Revenue stats  │  │ (Future Sprint)  │
│ - Invoices       │  │ - Tickets        │  └──────────────────┘
└──────────────────┘  └──────────────────┘
```

**Key Deliverables:**
- ✅ Next.js app deployed to staging
- ✅ Customer dashboard functional
- ✅ Reseller dashboard functional
- ✅ Responsive design

---

### Sprint 4: Website Hosting Core (Weeks 9-10) - 21 points
**Goal:** Customers can create and access websites

```
    ┌──────────────────────┐
    │ SA-006: Packages     │ (from Sprint 2)
    └──────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  CU-002: Website Management (13)   │
│  - Create website form              │
│  - Select PHP version               │
│  - Website list view                │
│  - Website status                   │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  PROV-001: Provisioning (8 pts)    │
│  - Create directory structure       │
│  - Configure NGINX vhost            │
│  - PHP-FPM pool                     │
│  - Set permissions                  │
│  - DNS configuration                │
└─────────────────────────────────────┘
              │
              ▼
        [Website Accessible]
        http://customer-domain.com
```

**Key Deliverables:**
- ✅ Customers can create websites
- ✅ Websites provisioned in < 60 seconds
- ✅ Websites accessible via browser
- ✅ PHP version selection works

**Critical Success Factor:**
- Website provisioning must be reliable
- Test with various domain configurations

---

### Sprint 5: Billing Foundation (Weeks 11-12) - 21 points
**Goal:** Customers can pay for services

```
┌─────────────────────────────────────┐
│  SA-004: Billing Config (8 pts)    │
│  - Stripe API integration           │
│  - Invoice generation               │
│  - Payment webhooks                 │
│  - Recurring billing cron           │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  CU-009: Billing & Invoices (13)   │
│  - Invoice list view                │
│  - Invoice details                  │
│  - Payment form (Stripe Checkout)   │
│  - Payment history                  │
│  - Download PDF invoice             │
└─────────────────────────────────────┘
              │
              ▼
        [Customer Pays Invoice]
        [$$$] → Stripe → [Invoice Paid]
```

**Key Deliverables:**
- ✅ Invoices generated automatically
- ✅ Customers can pay via credit card
- ✅ Stripe webhooks handled correctly
- ✅ Invoice PDFs generated

**Risk Mitigation:**
- Test payment flows extensively
- Handle payment failures gracefully
- Ensure idempotency for webhook events

---

### Sprint 6: MVP Polish & Launch Prep (Weeks 13-14) - 21 points
**Goal:** MVP is production-ready

```
┌─────────────────────────────────────┐
│  TECH-005: Monitoring (8 pts)      │
│  - Prometheus + Grafana             │
│  - Loki for logs                    │
│  - Alerting rules                   │
│  - Dashboards                       │
└─────────────────────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│  CU-008: Backup & Restore (13 pts) │
│  - Automatic daily backups          │
│  - Restic integration               │
│  - Backup to Hetzner Object Storage │
│  - Restore functionality            │
└─────────────────────────────────────┘
              │
              ▼
        [Bug Fixes & Polish]
        - Security audit
        - Performance optimization
        - UAT with beta users
        - Documentation
```

**Key Deliverables:**
- ✅ Monitoring dashboards live
- ✅ Backups running automatically
- ✅ All critical bugs fixed
- ✅ Security vulnerabilities addressed
- ✅ Beta users testing platform

---

## Dependency Graph

### Critical Path (Must complete in order)

```
1. TECH-002 (Database)
          │
          ▼
2. TECH-003 (API Gateway)
          │
          ▼
3. TECH-004 (Authentication)
          │
          ├────────────────┬────────────────┐
          ▼                ▼                ▼
4. SA-002 (Users)   CU-001 (Dashboard)  RE-001 (Dashboard)
          │
          ▼
5. SA-006 (Packages)
          │
          ▼
6. CU-002 (Websites)
          │
          ▼
7. CU-009 (Billing)
          │
          ▼
8. LAUNCH 🚀
```

### Parallel Work Streams

**Backend Team:**
- Sprint 1: TECH-003 + TECH-004
- Sprint 2: SA-002 + SA-006
- Sprint 4: CU-002 (API) + PROV-001

**Frontend Team:**
- Sprint 3: NEXT-001 + CU-001 + RE-001
- Sprint 4: CU-002 (UI)
- Sprint 5: CU-009 (UI)

**DevOps Team:**
- Sprint 0: TECH-001 + TECH-002
- Sprint 6: TECH-005 + CU-008

---

## Risk Register

### HIGH RISK

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Website provisioning fails | Critical | Medium | Extensive testing, rollback capability |
| Payment processing errors | Critical | Low | Use Stripe test mode extensively, manual QA |
| Database migration fails | Critical | Low | Test migrations thoroughly, backup before migrate |
| RUST expertise limited | High | Medium | Pair programming, code reviews, consider Go alternative |

### MEDIUM RISK

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Sprint velocity lower than expected | Medium | Medium | Leave 20% buffer, reduce scope if needed |
| Third-party API downtime (Stripe) | Medium | Low | Graceful degradation, retry logic, status page |
| Security vulnerability found | High | Medium | Regular security audits, penetration testing |
| Performance issues at scale | Medium | Low | Load testing, database indexing, caching |

### LOW RISK

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| UI/UX not meeting expectations | Low | Medium | User testing, iterate based on feedback |
| Documentation incomplete | Low | Medium | Document as you build, allocate time in Sprint 6 |

---

## MVP Feature Scope

### ✅ IN SCOPE (Must Have)

**Authentication & Users:**
- ✅ User registration and login
- ✅ Password reset
- ✅ Basic RBAC (admin, reseller, customer)

**Website Hosting:**
- ✅ Create website (PHP-based)
- ✅ PHP version selection (8.1, 8.2, 8.3)
- ✅ NGINX web server
- ✅ Basic file management (upload/download)

**Billing:**
- ✅ Package pricing
- ✅ Invoice generation
- ✅ Stripe payment processing
- ✅ Invoice PDF download

**Infrastructure:**
- ✅ Automated backups (daily)
- ✅ Basic monitoring (uptime, errors)
- ✅ SSL certificates (Let's Encrypt)

---

### ⏸️ DEFERRED (Post-MVP)

**Advanced Features:**
- ⏸️ Email hosting (Postfix/Dovecot)
- ⏸️ Database management UI (phpMyAdmin)
- ⏸️ File Manager (web-based)
- ⏸️ Git integration
- ⏸️ Staging environments
- ⏸️ One-click app installers
- ⏸️ Multi-server management
- ⏸️ Advanced WAF rules
- ⏸️ Custom DNS management
- ⏸️ Support ticket system

**Technical Debt (Address Later):**
- ⏸️ Comprehensive E2E tests
- ⏸️ Load balancing
- ⏸️ CDN integration
- ⏸️ Advanced analytics
- ⏸️ API versioning (v2)

---

### ❌ OUT OF SCOPE (Future Versions)

- ❌ Windows hosting support
- ❌ VPS provisioning
- ❌ Dedicated server management
- ❌ Domain registrar integration (WHMCS-style)
- ❌ WHMCS billing import
- ❌ cPanel migration tool
- ❌ Affiliate program
- ❌ Marketplace for themes/plugins

---

## Launch Criteria

Before launching MVP to production, the following must be true:

### Functional Requirements
- [ ] All critical user stories completed
- [ ] User can register, log in, create website, pay invoice
- [ ] Website provisioning success rate > 95%
- [ ] Payment processing works correctly
- [ ] Backups running daily without errors

### Quality Requirements
- [ ] No critical or high-severity bugs in production
- [ ] Test coverage > 80% for critical paths
- [ ] Security audit completed (no high/critical vulnerabilities)
- [ ] Performance benchmarks met:
  - [ ] API response time < 500ms (p95)
  - [ ] Website provisioning < 60 seconds
  - [ ] Dashboard load time < 2 seconds

### Operational Requirements
- [ ] Monitoring dashboards configured
- [ ] Alerting rules set up (PagerDuty/email)
- [ ] Backup restore tested successfully
- [ ] Runbook for common operations
- [ ] On-call rotation established

### Business Requirements
- [ ] 5-10 beta customers recruited
- [ ] Beta testing completed (1 week minimum)
- [ ] Pricing finalized
- [ ] Terms of Service & Privacy Policy published
- [ ] Support email configured
- [ ] Payment gateway in live mode (Stripe)

### Documentation Requirements
- [ ] User documentation (knowledge base)
- [ ] API documentation (OpenAPI)
- [ ] Admin documentation (operations)
- [ ] Deployment guide
- [ ] Disaster recovery plan

---

## Post-Launch Plan (Weeks 15-20)

### Week 15-16: Stabilization
- Monitor for production issues
- Fix critical bugs immediately
- Gather user feedback
- Iterate on UX pain points

### Week 17-18: Phase 2 Features
- Email hosting (CU-005)
- Database management (CU-004)
- File Manager (CU-003)
- SSL management improvements (CU-006)

### Week 19-20: Growth Features
- Support ticket system (CU-010, RE-006)
- One-click WordPress installer (CU-012)
- Staging environments (CU-014)
- Performance metrics dashboard (CU-013)

---

## Success Metrics (First 3 Months Post-Launch)

### User Acquisition
- **Goal:** 50 paying customers
- **Metric:** New customer signups per week
- **Target:** 4-5 signups/week

### Retention
- **Goal:** 90% customer retention
- **Metric:** Churn rate
- **Target:** <10% monthly churn

### Revenue
- **Goal:** $2,500 MRR (Monthly Recurring Revenue)
- **Metric:** MRR growth
- **Target:** 20% MoM growth

### Platform Health
- **Goal:** 99.9% uptime
- **Metric:** Uptime percentage
- **Target:** <4 hours downtime per month

### Support
- **Goal:** Excellent customer support
- **Metric:** Average ticket response time
- **Target:** <2 hours (business hours)

---

## Team Roles & Responsibilities

### Product Owner
- Define and prioritize backlog
- Accept/reject completed stories
- Stakeholder communication
- Sprint planning participation

### Scrum Master / Tech Lead
- Facilitate sprint ceremonies
- Remove blockers
- Track team velocity
- Technical decision-making

### Backend Developers (2)
- **Dev 1:** RUST (API Gateway, core services)
- **Dev 2:** Go (Billing, user management, provisioning)
- Both: API design, database modeling

### Frontend Developers (2)
- **Dev 1:** Next.js setup, customer dashboard
- **Dev 2:** Reseller dashboard, admin features
- Both: UI components, API integration

### DevOps Engineer (Part-time)
- Infrastructure setup (Hetzner Cloud)
- CI/CD pipeline
- Monitoring & logging
- Backup systems
- Security hardening

### QA / Manual Tester (Part-time, optional)
- Manual testing
- User acceptance testing
- Bug reporting
- Regression testing

---

## Communication Plan

### Daily Standup
- **Time:** 9:30 AM daily
- **Duration:** 15 minutes
- **Platform:** Zoom/Slack

### Sprint Planning
- **Time:** Monday 10:00 AM (start of sprint)
- **Duration:** 2 hours
- **Platform:** Zoom

### Sprint Review
- **Time:** Friday 3:00 PM (end of sprint)
- **Duration:** 1 hour
- **Platform:** Zoom

### Sprint Retrospective
- **Time:** Friday 4:00 PM (end of sprint)
- **Duration:** 1 hour
- **Platform:** Zoom (team only)

### Backlog Refinement
- **Time:** Wednesday 2:00 PM (mid-sprint)
- **Duration:** 1 hour
- **Platform:** Zoom

---

## Tools & Infrastructure

### Development
- **Version Control:** GitHub
- **CI/CD:** GitHub Actions
- **Code Review:** GitHub Pull Requests
- **Project Management:** GitHub Projects / JIRA / Linear

### Communication
- **Chat:** Slack
- **Video Calls:** Zoom / Google Meet
- **Documentation:** Notion / Confluence

### Infrastructure
- **Cloud Provider:** Hetzner Cloud
- **Container Registry:** GitHub Container Registry
- **Monitoring:** Prometheus + Grafana
- **Logging:** Loki
- **Alerting:** PagerDuty / Email

### Testing
- **Unit Tests:** Jest (Next.js), Cargo test (RUST), Go test
- **E2E Tests:** Playwright / Cypress
- **Load Testing:** k6 / Locust
- **Security Scanning:** Snyk / Dependabot

---

## Budget Estimate

### Infrastructure Costs (Monthly)

| Item | Cost (€) | Notes |
|------|----------|-------|
| Hetzner Servers (3x CPX31) | 90 | Dev, Staging, Production |
| Hetzner Object Storage (500GB) | 5 | Backups |
| Hetzner Firewall | 0 | Free |
| Domain (panel.example.com) | 1 | Annual ÷ 12 |
| SSL Certificates | 0 | Let's Encrypt (free) |
| **Total Infrastructure** | **96/month** | **$105/month** |

### SaaS / Tools (Monthly)

| Item | Cost (€) | Notes |
|------|----------|-------|
| GitHub (Team Plan) | 35 | 5 users |
| Monitoring (Grafana Cloud - optional) | 0 | Self-hosted |
| Error Tracking (Sentry) | 0 | Free tier |
| Stripe | 0 | Pay per transaction (2.9% + 30¢) |
| **Total SaaS** | **35/month** | **$38/month** |

### Total Monthly Costs
- **Infrastructure:** €96 ($105)
- **SaaS:** €35 ($38)
- **Total:** €131 ($143)

**Note:** Personnel costs not included (depends on team structure: full-time, contractors, etc.)

---

## Next Steps

1. ✅ **Review this roadmap** with stakeholders
2. 📅 **Confirm sprint start date** for Sprint 0
3. 👥 **Finalize team assignments**
4. 🛠️ **Set up development environment**
5. 📊 **Import backlog into project management tool**
6. 🚀 **Kick off Sprint 0!**

---

**Document Version:** 1.0
**Last Updated:** November 11, 2025
**Next Review:** After Sprint 2
**Owner:** Product Owner
