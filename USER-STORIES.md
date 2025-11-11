# Unified Hosting Platform - User Stories

**Version:** 1.0
**Date:** November 11, 2025
**Status:** Complete Specification

---

## Table of Contents

1. [Introduction](#introduction)
2. [User Personas](#user-personas)
3. [Super Admin Stories](#super-admin-stories)
4. [Reseller Stories](#reseller-stories)
5. [Customer/End User Stories](#customerend-user-stories)
6. [Technical User Stories](#technical-user-stories)
7. [Story Mapping & Priorities](#story-mapping--priorities)

---

## Introduction

This document provides comprehensive user stories for the **Unified Hosting Platform**, covering all user roles and their interactions with the system. Each story follows the standard format:

```
As a [user type],
I want to [action],
So that [benefit/value].
```

Each story includes:
- **Acceptance Criteria**: Measurable conditions that must be met
- **Priority**: Critical, High, Medium, or Low
- **Estimated Effort**: Story points (1, 2, 3, 5, 8, 13)
- **Dependencies**: Other stories or features required

---

## User Personas

### Persona 1: Sarah - Super Admin
**Role**: Platform Owner/Administrator
**Technical Level**: Expert
**Goals**:
- Maintain platform stability and security
- Monitor revenue and business metrics
- Manage all customers and resellers
- Configure system-wide settings

**Pain Points**:
- Manual server provisioning takes too long
- Difficult to track security incidents across all accounts
- Limited visibility into resource usage trends

---

### Persona 2: Mike - Reseller
**Role**: Hosting Reseller Business Owner
**Technical Level**: Intermediate
**Goals**:
- Grow customer base with minimal overhead
- White-label the platform with his branding
- Automate billing and provisioning
- Provide excellent customer support

**Pain Points**:
- Customer onboarding is tedious
- Manual invoice generation is error-prone
- Difficult to set custom pricing per customer
- No visibility into which customers need attention

---

### Persona 3: Emily - Customer/End User
**Role**: Small Business Owner
**Technical Level**: Beginner to Intermediate
**Goals**:
- Host her e-commerce website reliably
- Manage email accounts for her team
- Keep costs predictable
- Get help when things go wrong

**Pain Points**:
- Control panels are too complex
- Unsure how to manage SSL certificates
- Worried about security and backups
- Invoices are confusing

---

### Persona 4: David - Technical User
**Role**: Web Developer
**Technical Level**: Expert
**Goals**:
- Deploy applications quickly
- Have SSH/SFTP access
- Use Git for deployments
- Configure custom environments

**Pain Points**:
- Limited control over PHP versions
- Can't install custom dependencies
- Slow file upload speeds
- No staging environments

---

## Super Admin Stories

### SA-001: Platform Dashboard Overview
**As a** Super Admin,
**I want to** see a comprehensive dashboard with key platform metrics,
**So that** I can quickly assess the health and performance of the entire platform.

**Acceptance Criteria:**
- [ ] Dashboard displays total number of customers (active, suspended, cancelled)
- [ ] Shows total number of resellers and their status
- [ ] Displays MRR (Monthly Recurring Revenue) and ARR
- [ ] Shows server resource usage (CPU, RAM, Disk) across all servers
- [ ] Displays recent security alerts with severity levels
- [ ] Shows top 10 resource-consuming accounts
- [ ] Includes real-time system status indicators
- [ ] Graphs show 30-day trends for revenue and resource usage
- [ ] Dashboard updates automatically every 30 seconds

**Priority:** Critical
**Effort:** 8 points
**Dependencies:** Authentication system, metrics collection service

---

### SA-002: User Management
**As a** Super Admin,
**I want to** create, edit, suspend, and delete any user account (including resellers and customers),
**So that** I can manage all platform users from a central location.

**Acceptance Criteria:**
- [ ] Can search users by email, name, or ID
- [ ] Can filter users by type (Admin, Reseller, Customer)
- [ ] Can view complete user profile with all services
- [ ] Can edit user details (email, name, password)
- [ ] Can suspend user account (blocks login, preserves data)
- [ ] Can permanently delete user (with confirmation + 30-day grace period)
- [ ] Can impersonate any user (logs impersonation action)
- [ ] Can see user's login history and IP addresses
- [ ] Can force password reset
- [ ] Can enable/disable 2FA for any user

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Authentication system, audit logging

---

### SA-003: Server Provisioning
**As a** Super Admin,
**I want to** provision new servers automatically through the Hetzner Cloud API,
**So that** I can scale the platform quickly as demand grows.

**Acceptance Criteria:**
- [ ] Can select server type (Application, Database, Email, DNS, Backup)
- [ ] Can choose Hetzner instance type (CPX21, CPX31, CPX41, etc.)
- [ ] Can select datacenter location (Falkenstein, Helsinki, Ashburn)
- [ ] Server is provisioned automatically via Ansible playbooks
- [ ] Server is configured with all required software based on its role
- [ ] Server is added to private network automatically
- [ ] Firewall rules are configured automatically
- [ ] Monitoring is enabled for the new server
- [ ] Backups are configured automatically
- [ ] Entire process completes in under 10 minutes
- [ ] Receives notification when provisioning completes or fails

**Priority:** High
**Effort:** 13 points
**Dependencies:** Hetzner API integration, Ansible playbooks, monitoring setup

---

### SA-004: Billing Configuration
**As a** Super Admin,
**I want to** configure global billing settings including payment gateways, tax rates, and invoice templates,
**So that** the platform can handle payments correctly for all customers.

**Acceptance Criteria:**
- [ ] Can configure Stripe API keys (test and live mode)
- [ ] Can configure PayPal credentials
- [ ] Can add multiple payment gateways
- [ ] Can set default currency (with support for 40+ currencies)
- [ ] Can configure tax rates by country/region
- [ ] Can enable/disable VAT/GST collection
- [ ] Can customize invoice PDF template (logo, colors, footer text)
- [ ] Can set invoice numbering format (prefix, suffix, padding)
- [ ] Can configure payment reminder schedule (7 days, 3 days, 1 day overdue)
- [ ] Can set grace period before service suspension
- [ ] Changes apply to new invoices only (not retroactive)

**Priority:** Critical
**Effort:** 8 points
**Dependencies:** Billing service, payment gateway integrations

---

### SA-005: Security Monitoring & Alerts
**As a** Super Admin,
**I want to** monitor security events across the entire platform and receive alerts for critical issues,
**So that** I can respond quickly to security threats.

**Acceptance Criteria:**
- [ ] Dashboard shows total security events (last 24h, 7d, 30d)
- [ ] Can view WAF blocked requests with details (IP, country, attack type)
- [ ] Can view failed login attempts across all accounts
- [ ] Can see list of banned IPs with reason and duration
- [ ] Can manually ban/unban IP addresses
- [ ] Receives email alert for critical security events
- [ ] Receives SMS alert for suspected breaches
- [ ] Can view malware scan results for all websites
- [ ] Can see SSL certificate expiration warnings (30, 14, 7 days)
- [ ] Can export security logs for compliance auditing

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Security service, WAF, malware scanner, logging system

---

### SA-006: Package Management
**As a** Super Admin,
**I want to** create and manage hosting packages with specific resource allocations and features,
**So that** resellers and customers can purchase standardized service tiers.

**Acceptance Criteria:**
- [ ] Can create new hosting package with name and description
- [ ] Can set resource limits (disk, bandwidth, domains, databases, email accounts)
- [ ] Can configure PHP versions available for the package
- [ ] Can enable/disable features (SSH access, Git, staging, WP-CLI, etc.)
- [ ] Can set security features (ModSecurity, firewall, malware scanning)
- [ ] Can configure cgroups resource limits (CPU, RAM, I/O, processes)
- [ ] Can set one-time setup fee
- [ ] Can set recurring price (monthly, quarterly, annually)
- [ ] Can define upgrade/downgrade paths to other packages
- [ ] Can set package visibility (Public, Hidden, Reseller-only, Private)
- [ ] Can clone existing package as starting point
- [ ] Can assign package to specific servers or server groups

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Billing service, provisioning service

---

### SA-007: Revenue Analytics
**As a** Super Admin,
**I want to** view detailed revenue analytics and financial reports,
**So that** I can track business performance and make data-driven decisions.

**Acceptance Criteria:**
- [ ] Dashboard shows MRR (Monthly Recurring Revenue)
- [ ] Shows ARR (Annual Recurring Revenue)
- [ ] Displays revenue growth rate (MoM and YoY)
- [ ] Shows churn rate (customer and revenue churn)
- [ ] Displays average revenue per user (ARPU)
- [ ] Shows revenue by package type
- [ ] Shows revenue by reseller
- [ ] Displays payment success/failure rates
- [ ] Shows outstanding invoices total
- [ ] Can filter reports by date range
- [ ] Can export reports as CSV, PDF
- [ ] Graphs display trends over last 12 months

**Priority:** High
**Effort:** 8 points
**Dependencies:** Billing service, analytics service

---

### SA-008: System Configuration
**As a** Super Admin,
**I want to** configure system-wide settings and branding,
**So that** the platform operates according to my business requirements.

**Acceptance Criteria:**
- [ ] Can set platform name and tagline
- [ ] Can upload company logo (multiple sizes for different uses)
- [ ] Can set primary and secondary brand colors
- [ ] Can configure SMTP settings for system emails
- [ ] Can customize email templates (welcome, invoice, suspension, etc.)
- [ ] Can set default language and timezone
- [ ] Can configure support email and phone number
- [ ] Can set terms of service and privacy policy URLs
- [ ] Can enable/disable customer registration
- [ ] Can set minimum password requirements
- [ ] Can configure session timeout duration
- [ ] Can enable/disable maintenance mode with custom message

**Priority:** High
**Effort:** 8 points
**Dependencies:** Configuration service

---

### SA-009: Backup Management
**As a** Super Admin,
**I want to** configure and monitor backups for all servers and customer data,
**So that** data can be recovered in case of failure or data loss.

**Acceptance Criteria:**
- [ ] Can configure backup schedule (daily, weekly, monthly)
- [ ] Can set retention policy (days, weeks, months)
- [ ] Can configure backup storage location (Hetzner Object Storage)
- [ ] Can set backup encryption key
- [ ] Dashboard shows total backup size and storage used
- [ ] Shows last successful backup time for each server
- [ ] Shows failed backups with error details
- [ ] Can manually trigger backup for any server
- [ ] Can verify backup integrity
- [ ] Can download backup files
- [ ] Receives alert if backup fails
- [ ] Can restore from backup (with confirmation)

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Backup service, Hetzner Object Storage

---

### SA-010: Multi-Server Management
**As a** Super Admin,
**I want to** manage multiple servers from a central interface,
**So that** I can efficiently operate the platform infrastructure.

**Acceptance Criteria:**
- [ ] Can view list of all servers with status indicators
- [ ] Can see server role (Application, Database, Email, DNS)
- [ ] Can view server resources (CPU, RAM, Disk, Network usage)
- [ ] Can see number of accounts/websites per server
- [ ] Can manually assign websites to specific servers
- [ ] Can migrate websites between servers
- [ ] Can reboot server (with confirmation)
- [ ] Can put server in maintenance mode (no new provisioning)
- [ ] Can update server software (rolling updates)
- [ ] Can decommission server (after draining all websites)
- [ ] Can configure load balancing between servers
- [ ] Can set server resource allocation policies

**Priority:** High
**Effort:** 13 points
**Dependencies:** Server management service, migration tools

---

## Reseller Stories

### RE-001: Reseller Dashboard
**As a** Reseller,
**I want to** see a dashboard with my business metrics and customer overview,
**So that** I can monitor my hosting business performance.

**Acceptance Criteria:**
- [ ] Dashboard shows total number of my customers (active, suspended)
- [ ] Displays my monthly recurring revenue
- [ ] Shows my customer growth trend (last 6 months)
- [ ] Displays my resource usage vs. allocated quota
- [ ] Shows recent customer signups
- [ ] Displays customers with overdue invoices
- [ ] Shows pending support tickets from my customers
- [ ] Lists customers approaching resource limits
- [ ] Displays my commission earnings (if applicable)
- [ ] Can quick-navigate to common actions (add customer, create invoice)

**Priority:** Critical
**Effort:** 8 points
**Dependencies:** Authentication, billing service

---

### RE-002: Customer Management
**As a** Reseller,
**I want to** create and manage my customer accounts,
**So that** I can onboard new clients and manage existing ones.

**Acceptance Criteria:**
- [ ] Can create new customer account with email and details
- [ ] Can assign hosting package to customer
- [ ] Can set custom pricing (override default package price)
- [ ] Can edit customer information
- [ ] Can view customer's complete profile and services
- [ ] Can suspend customer account
- [ ] Can unsuspend customer account
- [ ] Can delete customer account (with confirmation)
- [ ] Can reset customer password
- [ ] Can log in as customer (impersonation with audit trail)
- [ ] Can add notes to customer account (private to reseller)
- [ ] Can assign tags to customers for organization

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** User management, audit logging

---

### RE-003: White-Label Branding
**As a** Reseller,
**I want to** customize the control panel with my branding,
**So that** my customers see my brand instead of the platform owner's.

**Acceptance Criteria:**
- [ ] Can upload my company logo
- [ ] Can set my brand colors (primary, secondary)
- [ ] Can set my company name (displays in UI)
- [ ] Can set my support email (customers see this)
- [ ] Can set my support phone number
- [ ] Can set custom domain for customer portal (customers.myhosting.com)
- [ ] Can set terms of service URL
- [ ] Can set privacy policy URL
- [ ] Customers see my branding when they log in
- [ ] Invoices include my branding
- [ ] Email notifications include my branding
- [ ] Can preview branding before applying

**Priority:** High
**Effort:** 8 points
**Dependencies:** Multi-tenancy, email templating

---

### RE-004: Custom Pricing
**As a** Reseller,
**I want to** set custom pricing for my customers,
**So that** I can offer competitive rates and maximize my profit margin.

**Acceptance Criteria:**
- [ ] Can override package prices per customer
- [ ] Can set percentage markup or fixed price
- [ ] Can set different prices for different billing cycles
- [ ] Can offer discounts (percentage or fixed amount)
- [ ] Can set promotional pricing with expiry date
- [ ] Can set custom setup fees
- [ ] Can preview pricing before applying
- [ ] Pricing changes apply to next invoice only
- [ ] Can view pricing history for each customer
- [ ] Can apply bulk pricing changes to multiple customers

**Priority:** High
**Effort:** 8 points
**Dependencies:** Billing service

---

### RE-005: Invoice Management
**As a** Reseller,
**I want to** manage invoices for my customers,
**So that** I can ensure timely payments and track receivables.

**Acceptance Criteria:**
- [ ] Can view all invoices for my customers
- [ ] Can filter invoices by status (draft, sent, paid, overdue)
- [ ] Can manually create invoice for a customer
- [ ] Can add line items to invoice
- [ ] Can apply tax based on customer location
- [ ] Can send invoice to customer via email
- [ ] Can download invoice as PDF
- [ ] Can mark invoice as paid (manual payment)
- [ ] Can void/cancel invoice
- [ ] Can add notes to invoice
- [ ] Can resend invoice reminder
- [ ] Can view payment history for customer

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Billing service

---

### RE-006: Support Ticket System
**As a** Reseller,
**I want to** manage support tickets from my customers,
**So that** I can provide excellent customer support.

**Acceptance Criteria:**
- [ ] Can view all tickets from my customers
- [ ] Can filter tickets by status, priority, department
- [ ] Can view ticket details and conversation history
- [ ] Can reply to tickets
- [ ] Can assign tickets to myself (if multiple staff)
- [ ] Can change ticket status (open, in progress, waiting on customer, resolved)
- [ ] Can change ticket priority
- [ ] Can add internal notes (not visible to customer)
- [ ] Can merge duplicate tickets
- [ ] Can use canned responses (templates)
- [ ] Receive email notification for new tickets
- [ ] Can set auto-response for new tickets
- [ ] Can see SLA timer for each ticket

**Priority:** High
**Effort:** 13 points
**Dependencies:** Support service, email service

---

### RE-007: Resource Allocation
**As a** Reseller,
**I want to** monitor my resource usage and quota,
**So that** I can manage my allocation efficiently and request increases when needed.

**Acceptance Criteria:**
- [ ] Dashboard shows total disk space allocated vs. used
- [ ] Shows total bandwidth allocated vs. used
- [ ] Shows number of customer accounts vs. maximum allowed
- [ ] Displays resource usage trends (last 30 days)
- [ ] Shows which customers are using most resources
- [ ] Receive alert when approaching 80% of any limit
- [ ] Can request quota increase from platform owner
- [ ] Can view quota increase request status
- [ ] Can see pricing for additional resources
- [ ] Can purchase additional resources (if enabled)

**Priority:** High
**Effort:** 5 points
**Dependencies:** Resource monitoring, quota management

---

### RE-008: Commission Tracking
**As a** Reseller,
**I want to** track my commission earnings (if applicable),
**So that** I can understand my revenue from the platform.

**Acceptance Criteria:**
- [ ] Dashboard shows total commission earned (lifetime)
- [ ] Shows commission for current month
- [ ] Shows commission by customer
- [ ] Displays commission rate percentage
- [ ] Shows pending commission (not yet paid out)
- [ ] Shows paid commission history
- [ ] Can filter commission by date range
- [ ] Can export commission report as CSV
- [ ] Receives monthly commission statement via email

**Priority:** Medium
**Effort:** 5 points
**Dependencies:** Billing service, reporting

---

### RE-009: Bulk Operations
**As a** Reseller,
**I want to** perform bulk operations on multiple customers,
**So that** I can manage my customer base efficiently.

**Acceptance Criteria:**
- [ ] Can select multiple customers via checkboxes
- [ ] Can suspend selected customers
- [ ] Can send mass email to selected customers
- [ ] Can apply price change to selected customers
- [ ] Can change package for selected customers
- [ ] Can add tag to selected customers
- [ ] Can export selected customers as CSV
- [ ] Confirmation required before bulk action
- [ ] Progress indicator during bulk operation
- [ ] Summary report after bulk operation completes

**Priority:** Medium
**Effort:** 5 points
**Dependencies:** User management, email service

---

### RE-010: Reports & Analytics
**As a** Reseller,
**I want to** view detailed reports about my business,
**So that** I can make informed decisions about pricing, marketing, and support.

**Acceptance Criteria:**
- [ ] Can view revenue report (by month, package, customer)
- [ ] Can view customer growth report
- [ ] Can view churn report (cancelled customers)
- [ ] Can view support ticket metrics (response time, resolution time)
- [ ] Can view resource usage report
- [ ] Can view most popular packages
- [ ] Can filter reports by date range
- [ ] Can export reports as CSV, PDF
- [ ] Reports include visualizations (charts, graphs)
- [ ] Can schedule automatic report delivery via email

**Priority:** Medium
**Effort:** 8 points
**Dependencies:** Reporting service, analytics

---

## Customer/End User Stories

### CU-001: Customer Dashboard
**As a** Customer,
**I want to** see an overview of my hosting services and account status,
**So that** I can quickly understand what I'm paying for and if there are any issues.

**Acceptance Criteria:**
- [ ] Dashboard shows all my active services (websites, domains, email)
- [ ] Displays account status (active, suspended, overdue)
- [ ] Shows next invoice amount and due date
- [ ] Displays current resource usage (disk, bandwidth)
- [ ] Shows website uptime status
- [ ] Lists recent activity/changes
- [ ] Displays unpaid invoices with amount
- [ ] Shows support ticket status
- [ ] Provides quick links to common actions (add website, pay invoice)
- [ ] Displays announcements from hosting provider

**Priority:** Critical
**Effort:** 8 points
**Dependencies:** Authentication, billing service, monitoring

---

### CU-002: Website Management
**As a** Customer,
**I want to** create and manage my websites,
**So that** I can host my web applications without technical complexity.

**Acceptance Criteria:**
- [ ] Can create new website by entering domain name
- [ ] Can select application type (WordPress, PHP, Node.js, Static HTML)
- [ ] Can choose PHP version (7.4 - 8.4)
- [ ] Website is provisioned automatically in under 60 seconds
- [ ] Receive email confirmation when website is ready
- [ ] Can view list of all my websites
- [ ] Can view website details (domain, PHP version, SSL status, disk usage)
- [ ] Can delete website (with confirmation)
- [ ] Can see website uptime and performance metrics
- [ ] Can access website via temporary URL before DNS propagation

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Provisioning service, DNS service

---

### CU-003: File Manager
**As a** Customer,
**I want to** manage my website files through a web-based file manager,
**So that** I can edit files without needing FTP software.

**Acceptance Criteria:**
- [ ] Can browse directory tree
- [ ] Can upload files (drag & drop supported)
- [ ] Can upload multiple files at once
- [ ] Progress bar shows upload progress
- [ ] Can download files
- [ ] Can create new files and folders
- [ ] Can rename files and folders
- [ ] Can delete files and folders (with confirmation)
- [ ] Can move/copy files between folders
- [ ] Can edit text files with syntax highlighting
- [ ] Can change file permissions (chmod)
- [ ] Can extract ZIP/TAR archives
- [ ] Can create ZIP archives
- [ ] Can preview images
- [ ] File manager is responsive (works on mobile)

**Priority:** High
**Effort:** 13 points
**Dependencies:** File manager service

---

### CU-004: Database Management
**As a** Customer,
**I want to** create and manage databases for my websites,
**So that** my web applications can store data.

**Acceptance Criteria:**
- [ ] Can create new MySQL database
- [ ] Can create new PostgreSQL database
- [ ] Database credentials are auto-generated (secure)
- [ ] Can view database connection details (host, port, username, password)
- [ ] Can change database password
- [ ] Can delete database (with confirmation)
- [ ] Can view database size
- [ ] Can access phpMyAdmin for MySQL databases
- [ ] Can access pgAdmin for PostgreSQL databases
- [ ] Can export database as SQL file
- [ ] Can import database from SQL file
- [ ] Can create database backup on-demand
- [ ] Can view list of database users and their permissions

**Priority:** High
**Effort:** 8 points
**Dependencies:** Database service, phpMyAdmin, pgAdmin

---

### CU-005: Email Account Management
**As a** Customer,
**I want to** create and manage email accounts for my domain,
**So that** I can have professional email addresses.

**Acceptance Criteria:**
- [ ] Can create new email account (user@mydomain.com)
- [ ] Can set email quota (storage limit)
- [ ] Can view list of all email accounts
- [ ] Can change email password
- [ ] Can delete email account (with confirmation)
- [ ] Can view email account disk usage
- [ ] Can set up email forwarding
- [ ] Can set up autoresponder (vacation message)
- [ ] Can access webmail interface (Roundcube)
- [ ] Can view email account settings (IMAP, SMTP, POP3 details)
- [ ] Can create email aliases
- [ ] Can configure spam filter settings
- [ ] Receive notification when mailbox is 80% full

**Priority:** High
**Effort:** 13 points
**Dependencies:** Email service, Dovecot, Postfix, Roundcube

---

### CU-006: SSL Certificate Management
**As a** Customer,
**I want to** install and manage SSL certificates for my websites,
**So that** my websites are secure and trusted by browsers.

**Acceptance Criteria:**
- [ ] Can request free SSL certificate (Let's Encrypt) with one click
- [ ] SSL certificate is issued automatically in under 5 minutes
- [ ] HTTPS is enabled automatically after certificate installation
- [ ] Certificate auto-renews 30 days before expiry
- [ ] Receive email notification 14 days before expiry (if auto-renew fails)
- [ ] Can view SSL certificate details (issuer, expiry date)
- [ ] Can force HTTPS redirect (HTTP → HTTPS)
- [ ] Can upload custom SSL certificate
- [ ] Can install wildcard certificate
- [ ] Can view SSL certificate status (valid, expired, invalid)
- [ ] Wizard guides through certificate installation process

**Priority:** High
**Effort:** 8 points
**Dependencies:** SSL service, Let's Encrypt integration

---

### CU-007: Domain Management
**As a** Customer,
**I want to** manage DNS records for my domains,
**So that** I can point my domain to my website and configure email properly.

**Acceptance Criteria:**
- [ ] Can view list of all my domains
- [ ] Can add new domain
- [ ] Can view DNS records for domain (A, AAAA, CNAME, MX, TXT, SRV, etc.)
- [ ] Can add new DNS record
- [ ] Can edit existing DNS record
- [ ] Can delete DNS record
- [ ] Can use DNS templates (e.g., "WordPress on this server")
- [ ] Can point domain to external service (e.g., Shopify, WooCommerce)
- [ ] Changes propagate within 5 minutes
- [ ] Can view DNS propagation status
- [ ] Validation prevents invalid DNS records
- [ ] Can enable DNSSEC (if supported)

**Priority:** High
**Effort:** 8 points
**Dependencies:** DNS service, PowerDNS

---

### CU-008: Backup & Restore
**As a** Customer,
**I want to** backup and restore my website data,
**So that** I can recover from mistakes or data loss.

**Acceptance Criteria:**
- [ ] Automatic daily backups are enabled by default
- [ ] Can view list of available backups with dates
- [ ] Can see backup size for each backup
- [ ] Can download backup as ZIP file
- [ ] Can restore website from backup (with confirmation)
- [ ] Restore process shows progress indicator
- [ ] Can restore individual files from backup (file browser)
- [ ] Can create manual backup on-demand
- [ ] Backups retained for 30 days (or per package)
- [ ] Receive email notification if backup fails
- [ ] Can see last successful backup date on dashboard

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Backup service, Restic

---

### CU-009: Billing & Invoices
**As a** Customer,
**I want to** view and pay my invoices,
**So that** I can keep my services active and avoid suspension.

**Acceptance Criteria:**
- [ ] Can view list of all invoices (paid, unpaid, overdue)
- [ ] Can filter invoices by status and date
- [ ] Can view invoice details with line items
- [ ] Can download invoice as PDF
- [ ] Can pay invoice via credit card (Stripe)
- [ ] Can pay invoice via PayPal
- [ ] Can set up automatic payments (save card on file)
- [ ] Receive email reminder 7 days before invoice due
- [ ] Receive email reminder 3 days before invoice due
- [ ] Receive email on invoice due date
- [ ] Can view payment history
- [ ] Can add credits to account (prepaid balance)
- [ ] Credits are applied automatically to new invoices

**Priority:** Critical
**Effort:** 13 points
**Dependencies:** Billing service, Stripe, PayPal

---

### CU-010: Support Tickets
**As a** Customer,
**I want to** create and manage support tickets,
**So that** I can get help when I have issues or questions.

**Acceptance Criteria:**
- [ ] Can create new support ticket
- [ ] Can select department (Technical, Billing, Sales)
- [ ] Can set priority (Low, Normal, High)
- [ ] Can attach files to ticket (up to 10MB)
- [ ] Can view list of my tickets
- [ ] Can filter tickets by status (Open, In Progress, Resolved)
- [ ] Can view ticket conversation history
- [ ] Can reply to ticket
- [ ] Receive email notification when staff replies
- [ ] Can rate support experience after ticket is resolved
- [ ] Can reopen closed ticket
- [ ] Can browse knowledge base for self-help articles
- [ ] Can search knowledge base

**Priority:** High
**Effort:** 13 points
**Dependencies:** Support service, email service, knowledge base

---

### CU-011: Account Settings
**As a** Customer,
**I want to** manage my account settings and security,
**So that** I can keep my account secure and update my information.

**Acceptance Criteria:**
- [ ] Can update personal information (name, email, phone)
- [ ] Can update billing address
- [ ] Can change account password
- [ ] Can enable two-factor authentication (2FA)
- [ ] Can disable 2FA (requires password confirmation)
- [ ] Can view login history (date, time, IP address)
- [ ] Can manage active sessions (log out other devices)
- [ ] Can generate API keys (if enabled)
- [ ] Can revoke API keys
- [ ] Can set communication preferences (email notifications)
- [ ] Can change account language
- [ ] Can change timezone
- [ ] Can delete account (with confirmation + data export)

**Priority:** High
**Effort:** 8 points
**Dependencies:** User management, authentication

---

### CU-012: One-Click App Installer
**As a** Customer,
**I want to** install popular web applications with one click,
**So that** I can quickly set up my website without technical knowledge.

**Acceptance Criteria:**
- [ ] Can browse available applications (WordPress, Joomla, Drupal, PrestaShop, etc.)
- [ ] Can filter applications by category (CMS, E-commerce, Forum, etc.)
- [ ] Can search for applications
- [ ] Can view application details (description, version, requirements)
- [ ] Can install application with one click
- [ ] Installation wizard asks for basic settings (admin email, site title)
- [ ] Application is installed in under 2 minutes
- [ ] Receive email with login credentials after installation
- [ ] Can view list of installed applications
- [ ] Can update installed applications
- [ ] Can uninstall application (with confirmation)
- [ ] Automatic security updates (optional, enabled by default)

**Priority:** High
**Effort:** 13 points
**Dependencies:** Application installer service, Softaculous integration

---

### CU-013: Website Performance Metrics
**As a** Customer,
**I want to** view performance metrics for my website,
**So that** I can understand how my website is performing and identify issues.

**Acceptance Criteria:**
- [ ] Dashboard shows website uptime percentage (last 30 days)
- [ ] Shows average response time
- [ ] Shows number of visitors (last 7 days)
- [ ] Shows bandwidth usage (last 30 days)
- [ ] Shows disk space usage
- [ ] Displays graph of traffic over time
- [ ] Shows top pages by visits
- [ ] Shows top referring websites
- [ ] Shows geographic distribution of visitors
- [ ] Can export metrics as CSV
- [ ] Metrics update every hour

**Priority:** Medium
**Effort:** 8 points
**Dependencies:** Monitoring service, analytics

---

### CU-014: Staging Environment
**As a** Customer,
**I want to** create a staging copy of my website,
**So that** I can test changes before applying them to my live site.

**Acceptance Criteria:**
- [ ] Can create staging environment with one click
- [ ] Staging environment is exact copy of production (files + database)
- [ ] Staging uses subdomain (staging.mydomain.com or domain.staging.host)
- [ ] Staging environment is password-protected
- [ ] Can edit files in staging without affecting production
- [ ] Can test changes in staging
- [ ] Can push changes from staging to production
- [ ] Push wizard shows what will be changed
- [ ] Can sync database from production to staging
- [ ] Can delete staging environment
- [ ] Staging environment does not count towards resource quota

**Priority:** Medium
**Effort:** 13 points
**Dependencies:** Provisioning service, sync tools

---

### CU-015: Git Integration
**As a** Customer,
**I want to** deploy my website from Git repository,
**So that** I can use modern development workflows and version control.

**Acceptance Criteria:**
- [ ] Can connect GitHub, GitLab, or Bitbucket repository
- [ ] Can select repository and branch to deploy
- [ ] Can configure deployment path
- [ ] Can set up automatic deployments on push
- [ ] Can trigger manual deployment
- [ ] Deployment runs build commands (npm install, composer install)
- [ ] Deployment logs are available for review
- [ ] Failed deployments don't affect live site
- [ ] Can roll back to previous deployment
- [ ] Can set environment variables for application
- [ ] Can configure deployment hooks (pre-deploy, post-deploy)

**Priority:** Medium
**Effort:** 13 points
**Dependencies:** Git integration service, deployment pipeline

---

## Technical User Stories

### TU-001: SSH Access
**As a** Technical User,
**I want to** access my hosting account via SSH,
**So that** I can use command-line tools and deploy applications efficiently.

**Acceptance Criteria:**
- [ ] Can generate SSH key pair or use existing public key
- [ ] Can upload SSH public key to account
- [ ] SSH access is enabled immediately
- [ ] Can connect via SSH on port 22
- [ ] SSH session is chrooted to my home directory
- [ ] Can use standard Linux commands (ls, cd, cp, mv, rm, etc.)
- [ ] Bash shell is available
- [ ] WP-CLI is pre-installed (for WordPress sites)
- [ ] Composer is pre-installed (for PHP sites)
- [ ] Node.js and npm are available
- [ ] Git is available
- [ ] Can run cron jobs
- [ ] SSH session timeout is 1 hour
- [ ] Can have up to 5 concurrent SSH sessions

**Priority:** High
**Effort:** 8 points
**Dependencies:** SSH service, jailkit, security policies

---

### TU-002: SFTP Access
**As a** Technical User,
**I want to** access my files via SFTP,
**So that** I can securely upload and download files using my preferred FTP client.

**Acceptance Criteria:**
- [ ] Can connect via SFTP using same SSH credentials
- [ ] SFTP connection is chrooted to home directory
- [ ] Can upload files via SFTP
- [ ] Can download files via SFTP
- [ ] Can create, rename, delete folders via SFTP
- [ ] Can change file permissions via SFTP
- [ ] SFTP works with popular clients (FileZilla, Cyberduck, WinSCP)
- [ ] Upload speed is at least 10 MB/s (network dependent)
- [ ] Download speed is at least 10 MB/s (network dependent)
- [ ] Can resume interrupted transfers

**Priority:** High
**Effort:** 5 points
**Dependencies:** SSH service, SFTP configuration

---

### TU-003: PHP Configuration
**As a** Technical User,
**I want to** customize PHP settings for my website,
**So that** I can configure PHP according to my application's requirements.

**Acceptance Criteria:**
- [ ] Can select PHP version (7.4, 8.0, 8.1, 8.2, 8.3, 8.4)
- [ ] Can enable/disable PHP extensions (gd, imagick, redis, memcached, etc.)
- [ ] Can set PHP memory limit (within package limits)
- [ ] Can set PHP max execution time
- [ ] Can set PHP upload max filesize
- [ ] Can set PHP post max size
- [ ] Can enable/disable specific PHP functions
- [ ] Can create custom php.ini directives
- [ ] Changes apply within 30 seconds
- [ ] Can reset PHP settings to default
- [ ] Current PHP configuration is displayed in control panel
- [ ] Can view phpinfo() output

**Priority:** High
**Effort:** 8 points
**Dependencies:** PHP-FPM, provisioning service

---

### TU-004: Cron Jobs
**As a** Technical User,
**I want to** create and manage cron jobs,
**So that** I can run scheduled tasks for my applications.

**Acceptance Criteria:**
- [ ] Can create new cron job
- [ ] Can set cron schedule (minute, hour, day, month, day of week)
- [ ] Can use common presets (every hour, daily, weekly, monthly)
- [ ] Can set command to execute
- [ ] Can enable/disable cron job without deleting
- [ ] Can view list of all cron jobs
- [ ] Can edit existing cron job
- [ ] Can delete cron job
- [ ] Can view cron job execution logs
- [ ] Receives email if cron job fails
- [ ] Can set notification email address
- [ ] Cron jobs are limited by package (e.g., max 10 cron jobs)

**Priority:** High
**Effort:** 8 points
**Dependencies:** Cron service

---

### TU-005: Environment Variables
**As a** Technical User,
**I want to** set environment variables for my application,
**So that** I can configure my application without hardcoding sensitive data.

**Acceptance Criteria:**
- [ ] Can add new environment variable (key-value pair)
- [ ] Can edit environment variable value
- [ ] Can delete environment variable
- [ ] Environment variables are available to my application
- [ ] Environment variables are encrypted at rest
- [ ] Can mark variable as sensitive (hidden in UI)
- [ ] Can copy environment variable to staging environment
- [ ] Can import environment variables from .env file
- [ ] Can export environment variables to .env file
- [ ] Changes apply after application restart

**Priority:** Medium
**Effort:** 5 points
**Dependencies:** Application configuration

---

### TU-006: Application Logs
**As a** Technical User,
**I want to** view application and server logs,
**So that** I can debug issues and monitor my application.

**Acceptance Criteria:**
- [ ] Can view Apache/NGINX access logs
- [ ] Can view Apache/NGINX error logs
- [ ] Can view PHP error logs
- [ ] Can view application-specific logs (if configured)
- [ ] Can filter logs by date range
- [ ] Can search logs by keyword
- [ ] Can download logs as text file
- [ ] Logs are retained for 30 days
- [ ] Logs are rotated daily
- [ ] Real-time log viewer (last 100 lines)
- [ ] Can view slow query logs (MySQL/PostgreSQL)

**Priority:** High
**Effort:** 8 points
**Dependencies:** Logging service, log aggregation

---

### TU-007: Database CLI Access
**As a** Technical User,
**I want to** access my databases via command-line interface,
**So that** I can perform advanced database operations.

**Acceptance Criteria:**
- [ ] Can connect to MySQL database via SSH using mysql command
- [ ] Can connect to PostgreSQL database via SSH using psql command
- [ ] Can execute SQL queries from command line
- [ ] Can import database from SQL file via CLI
- [ ] Can export database to SQL file via CLI
- [ ] Can use mysqldump and pg_dump commands
- [ ] Can use mysql and psql interactive shells
- [ ] Connection details are pre-configured in environment

**Priority:** Medium
**Effort:** 5 points
**Dependencies:** SSH access, database service

---

### TU-008: Node.js Application Deployment
**As a** Technical User,
**I want to** deploy and manage Node.js applications,
**So that** I can host modern JavaScript applications.

**Acceptance Criteria:**
- [ ] Can select Node.js version (16, 18, 20, 22)
- [ ] Can deploy Node.js application from Git repository
- [ ] Can run npm install during deployment
- [ ] Can set custom start command
- [ ] Application runs via PM2 process manager
- [ ] Application restarts automatically if it crashes
- [ ] Can view application logs in real-time
- [ ] Can set environment variables for application
- [ ] Can access application via configured domain
- [ ] Can configure reverse proxy (NGINX) automatically
- [ ] Can enable SSL certificate for Node.js app

**Priority:** Medium
**Effort:** 13 points
**Dependencies:** Node.js runtime, PM2, NGINX configuration

---

### TU-009: Python Application Deployment
**As a** Technical User,
**I want to** deploy and manage Python applications,
**So that** I can host Python web frameworks like Django and Flask.

**Acceptance Criteria:**
- [ ] Can select Python version (3.9, 3.10, 3.11, 3.12)
- [ ] Can deploy Python application from Git repository
- [ ] Can create virtual environment (venv) automatically
- [ ] Can run pip install -r requirements.txt during deployment
- [ ] Can configure WSGI/ASGI server (Gunicorn, uWSGI)
- [ ] Application runs via process manager
- [ ] Application restarts automatically if it crashes
- [ ] Can view application logs
- [ ] Can set environment variables
- [ ] Can configure reverse proxy (NGINX) automatically
- [ ] Can run Django management commands (migrate, collectstatic)

**Priority:** Medium
**Effort:** 13 points
**Dependencies:** Python runtime, process management, NGINX

---

### TU-010: Custom Domain with Subdomain
**As a** Technical User,
**I want to** configure multiple subdomains for my main domain,
**So that** I can host multiple applications under one domain.

**Acceptance Criteria:**
- [ ] Can add unlimited subdomains (within package limits)
- [ ] Can point subdomain to different directory
- [ ] Can point subdomain to different application
- [ ] Can configure SSL certificate for subdomain
- [ ] Can use wildcard subdomain (*.domain.com)
- [ ] DNS records are created automatically
- [ ] Can configure subdomain via control panel
- [ ] Can access subdomain immediately after creation
- [ ] Can delete subdomain

**Priority:** Medium
**Effort:** 8 points
**Dependencies:** DNS service, NGINX configuration

---

## Story Mapping & Priorities

### Phase 1: MVP (Months 1-4)
**Critical Stories (Must Have for Launch):**
- SA-001: Platform Dashboard
- SA-002: User Management
- SA-006: Package Management
- RE-001: Reseller Dashboard
- RE-002: Customer Management
- CU-001: Customer Dashboard
- CU-002: Website Management
- CU-008: Backup & Restore
- CU-009: Billing & Invoices

**Total Estimated Effort:** 105 story points

---

### Phase 2: Core Features (Months 5-7)
**High Priority Stories:**
- SA-003: Server Provisioning
- SA-005: Security Monitoring
- RE-003: White-Label Branding
- RE-005: Invoice Management
- CU-003: File Manager
- CU-004: Database Management
- CU-005: Email Management
- CU-006: SSL Certificate Management
- CU-007: Domain Management
- CU-010: Support Tickets
- TU-001: SSH Access
- TU-003: PHP Configuration

**Total Estimated Effort:** 142 story points

---

### Phase 3: Advanced Features (Months 8-10)
**Medium Priority Stories:**
- SA-007: Revenue Analytics
- SA-009: Backup Management
- RE-006: Support Ticket System
- RE-008: Commission Tracking
- CU-012: One-Click App Installer
- CU-013: Performance Metrics
- CU-014: Staging Environment
- TU-006: Application Logs
- TU-008: Node.js Deployment
- TU-009: Python Deployment

**Total Estimated Effort:** 117 story points

---

### Phase 4: Polish & Optimization (Months 11-12)
**Low Priority / Nice-to-Have:**
- SA-010: Multi-Server Management
- RE-009: Bulk Operations
- RE-010: Reports & Analytics
- CU-015: Git Integration
- TU-005: Environment Variables
- TU-010: Custom Subdomains

**Total Estimated Effort:** 73 story points

---

## Acceptance Testing Guidelines

For each user story, acceptance testing should validate:

1. **Functional Requirements**: All acceptance criteria are met
2. **Performance**: Operations complete within acceptable time limits
3. **Security**: Proper authorization and data protection
4. **Usability**: Interface is intuitive and accessible
5. **Error Handling**: Appropriate error messages and recovery options
6. **Cross-Browser Compatibility**: Works on Chrome, Firefox, Safari, Edge
7. **Responsive Design**: Works on desktop, tablet, and mobile
8. **Accessibility**: WCAG 2.1 AA compliance

---

## Success Metrics

### Platform-Wide Metrics
- **Time to Value**: New customer can deploy first website in < 10 minutes
- **User Satisfaction**: NPS score > 50
- **Support Efficiency**: Average ticket resolution time < 4 hours
- **Platform Reliability**: 99.95% uptime
- **Security**: Zero critical security incidents per quarter

### Per-User-Type Metrics
**Super Admin:**
- Server provisioning time < 10 minutes
- Can manage 1000+ customers without performance degradation
- Security alerts responded to within 15 minutes

**Reseller:**
- Customer onboarding time < 5 minutes
- Can manage 100+ customers efficiently
- Invoice generation is 100% automated

**Customer:**
- Can deploy WordPress in < 2 minutes
- Website uptime > 99.9%
- Support response time < 1 hour (business hours)

**Technical User:**
- Can deploy application via Git in < 5 minutes
- SSH/SFTP performance: 10+ MB/s
- Have full control over application environment

---

## Glossary of Story Terms

- **Story Points**: Relative measure of effort (Fibonacci: 1, 2, 3, 5, 8, 13, 21)
- **Sprint**: 2-week development cycle
- **Epic**: Large feature comprising multiple user stories
- **Acceptance Criteria**: Specific, measurable conditions that must be met
- **MVP**: Minimum Viable Product - core features for initial launch
- **Technical Debt**: Shortcuts taken that need to be addressed later
- **Spike**: Research/investigation story to reduce uncertainty

---

**End of User Stories Document**

*This document should be reviewed and updated regularly as requirements evolve and new features are identified.*
