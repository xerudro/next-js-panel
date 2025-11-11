# Unified Hosting Platform - Enterprise Implementation Guide

**Version:** 1.0  
**Date:** November 4, 2025  
**Document Level:** Production-Ready  
**Status:** Enterprise Grade (ISO/IEC 27001 Aligned)

---

## Table of Contents

1. [Executive Overview](#executive-overview)
2. [Architecture & Technology Stack](#architecture--technology-stack)
3. [systemd-Based Service Management](#systemd-based-service-management)
4. [Backend Implementation Patterns](#backend-implementation-patterns)
5. [Security Best Practices](#security-best-practices)
6. [Database Design & Optimization](#database-design--optimization)
7. [API Development Guidelines](#api-development-guidelines)
8. [Frontend Implementation (HTMX)](#frontend-implementation-htmx)
9. [Automation & Orchestration](#automation--orchestration)
10. [Monitoring & Observability](#monitoring--observability)
11. [Deployment & DevOps](#deployment--devops)
12. [Performance Optimization](#performance-optimization)
13. [Common Pitfalls & Solutions](#common-pitfalls--solutions)

---

## Executive Overview

The Unified Hosting Platform is an enterprise-grade hosting control panel built on modern, high-performance technology. This guide provides production-ready code examples, detailed architectural patterns, and best practices for implementation.

### Key Technical Pillars

- **Core Engine**: RUST 1.75+ with Actix-web 4.x / Axum 0.7+ for high-performance HTTP services
- **Microservices**: Go 1.22+ with Fiber v2 / Gin for API services and business logic
- **Orchestration**: systemd (primary) with optional Docker support
- **Frontend**: HTMX 1.9+ with Tailwind CSS 3.x for server-side rendering
- **Database**: PostgreSQL 16+, Redis 7.2+, TimescaleDB for metrics
- **Automation**: n8n 1.x, Ansible 2.15+, Bash 5.x, Python 3.11+

### When to Use Each Technology

| Use Case | Technology | Why |
|----------|-----------|-----|
| High-performance HTTP server | RUST + Actix-web | Zero-cost abstractions, minimal memory footprint, thread-safe concurrency |
| Business logic APIs | Go + Fiber | Fast development, excellent goroutine efficiency, great for I/O-bound services |
| Server provisioning | Bash + Ansible | System integration, idempotency, declarative configuration |
| Workflow automation | n8n | Visual builder, extensive integrations, self-hosted alternative to Zapier |
| Server process management | systemd | Native Linux integration, automatic restarts, resource limits, dependency management |
| Frontend rendering | Next.js 14+ (React) + Tailwind | SSR/SSG, modern React, API routes, TypeScript support, excellent performance |

---

## Architecture & Technology Stack

### Microservice Breakdown

The platform is designed as independent microservices with clear separation of concerns. Each service is responsible for a specific business domain and communicates via REST APIs or message queues.

#### Service Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│           Frontend Layer (Next.js 14 + React + Tailwind)    │
│  ├─ Admin Panel      ├─ Client Portal      ├─ API Docs      │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTPS/WSS/API
┌────────────────────┴────────────────────────────────────────┐
│           API Gateway (RUST - Actix/Axum)                   │
│  ├─ Authentication  ├─ Rate Limiting  ├─ Load Balancing     │
└────────────────────┬────────────────────────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
   ┌────▼────┐  ┌───▼────┐  ┌──▼────┐
   │  RUST   │  │   Go   │  │  Auto-│
   │  Core   │  │Services│  │ mation│
   └────┬────┘  └───┬────┘  └──┬────┘
        │           │           │
        └───────────┼───────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
   ┌────▼─────┐          ┌─────▼──┐
   │ PostgreSQL│          │ Redis  │
   │    16+    │          │ 7.2+   │
   └──────────┘          └────────┘
```

### Core Responsibilities

**RUST Services (High-Performance)**
- API Gateway: Authentication, rate limiting, request validation
- Security Engine: WAF, firewall rule management, threat detection
- Monitoring Service: Metrics collection, health checks, performance analytics
- Provisioning Service: Server provisioning orchestration
- Backup Service: Incremental backups, restoration, retention policies

**Go Microservices (Business Logic)**
- Billing Service: Invoicing, payments, subscriptions, tax calculations
- DNS Service: Zone management, DNSSEC, record CRUD operations
- Email Service: Mailbox management, SMTP/IMAP/POP3 configuration
- Support Service: Ticket management, knowledge base, live chat
- Domain Service: Registrar integration, domain lifecycle management

**Automation Layer**
- n8n: Visual workflow automation for complex business processes
- Ansible: Infrastructure provisioning and configuration management
- Bash/Python: System maintenance, backup automation, custom integrations

---

## systemd-Based Service Management

### Why systemd Over Docker (Primary Choice)

systemd offers several advantages for this use case:

1. **Direct System Integration**: No container overhead, faster startup
2. **Resource Limits**: cgroups v2 native support without virtualization
3. **Automatic Restarts**: Built-in restart policies and health checks
4. **Dependency Management**: Services can declare dependencies on each other
5. **Socket Activation**: Lazy-start services when first accessed
6. **Reduced Complexity**: No need for orchestration frameworks like Kubernetes
7. **Cost Efficiency**: Lower system overhead, 20-40% faster on Hetzner hardware

### systemd Service Units: Complete Examples

#### 1. RUST Core API Gateway Service

**File:** `/etc/systemd/system/hcc-api-gateway.service`

```ini
[Unit]
Description=Unified Hosting Platform - API Gateway (RUST)
Documentation=https://docs.example.com/api-gateway
After=network-online.target postgresql.service redis.service
Wants=network-online.target

[Service]
# Process Management
Type=simple
ExecStart=/usr/local/bin/hcc-api-gateway
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=5
StartLimitInterval=60
StartLimitBurst=5

# User & Group
User=hcc-gateway
Group=hcc-gateway

# Security Context
PrivateTmp=yes
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/hcc /var/log/hcc
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
ProtectClock=yes
ProtectHostname=yes
LockPersonality=yes
RemoveIPC=yes
RestrictRealtime=yes
RestrictSUIDSGID=yes
RestrictNamespaces=yes
SystemCallArchitectures=native

# Resource Limits (cgroups v2)
MemoryLimit=512M
MemoryAccounting=true
TasksMax=500
CPUQuota=50%
CPUAccounting=true
IOAccounting=true

# Environment
Environment="RUST_LOG=info,hcc_api_gateway=debug"
Environment="DATABASE_URL=postgresql://hcc_user:${HCC_DB_PASSWORD}@localhost/hcc_prod"
Environment="REDIS_URL=redis://localhost:6379/0"
Environment="API_LISTEN_ADDR=127.0.0.1:8000"
EnvironmentFile=/etc/hcc/api-gateway.env

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=hcc-api-gateway
# Preserve stdout/stderr in journal
StandardOutputMaxMSize=500M
StandardErrorMaxMSize=500M

# Health Check
ExecHealthCheck=/usr/local/bin/hcc-health-check api-gateway

[Install]
WantedBy=multi-user.target
```

**Creation and Management:**

```bash
# Create hcc-gateway user (unprivileged)
sudo useradd --system --no-create-home --shell /usr/sbin/nologin hcc-gateway

# Copy service file
sudo cp hcc-api-gateway.service /etc/systemd/system/

# Create environment file with secrets (restricted permissions)
sudo tee /etc/hcc/api-gateway.env > /dev/null <<EOF
HCC_DB_PASSWORD=SecurePassword123!@#
HCC_JWT_SECRET=$(openssl rand -base64 32)
HCC_ENCRYPTION_KEY=$(openssl rand -base64 32)
EOF
sudo chmod 600 /etc/hcc/api-gateway.env
sudo chown hcc-gateway:hcc-gateway /etc/hcc/api-gateway.env

# Create log directory
sudo mkdir -p /var/log/hcc
sudo chown hcc-gateway:hcc-gateway /var/log/hcc

# Reload systemd daemon
sudo systemctl daemon-reload

# Enable and start service
sudo systemctl enable hcc-api-gateway
sudo systemctl start hcc-api-gateway

# Check status
sudo systemctl status hcc-api-gateway
sudo journalctl -u hcc-api-gateway -f --lines=50
```

#### 2. Go Microservice (Billing Service)

**File:** `/etc/systemd/system/hcc-billing-service.service`

```ini
[Unit]
Description=Unified Hosting Platform - Billing Service (Go)
Documentation=https://docs.example.com/billing
After=network-online.target postgresql.service redis.service
Wants=network-online.target
PartOf=hcc-services.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hcc-billing-service
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=3
StartLimitInterval=60
StartLimitBurst=10

User=hcc-services
Group=hcc-services

PrivateTmp=yes
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/hcc /var/log/hcc

MemoryLimit=256M
MemoryAccounting=true
TasksMax=200
CPUQuota=25%

Environment="GO_ENV=production"
Environment="DATABASE_URL=postgresql://hcc_user:${HCC_DB_PASSWORD}@localhost/hcc_prod"
Environment="REDIS_URL=redis://localhost:6379/1"
Environment="BILLING_LISTEN_ADDR=127.0.0.1:8001"
Environment="STRIPE_API_KEY=${STRIPE_SECRET_KEY}"
EnvironmentFile=/etc/hcc/billing-service.env

StandardOutput=journal
StandardError=journal
SyslogIdentifier=hcc-billing

[Install]
WantedBy=hcc-services.target
```

#### 3. PostgreSQL Database Service

**File:** `/etc/systemd/system/postgresql.service` (customized)

```ini
[Unit]
Description=PostgreSQL Database Server
Documentation=https://www.postgresql.org
After=network-online.target syslog.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/lib/postgresql/16/bin/postgres -D /var/lib/postgresql/16/main \
          -c config_file=/etc/postgresql/16/main/postgresql.conf

ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=5

User=postgres
Group=postgres

# Performance tuning
# Note: These values should be tuned based on server resources
Environment="LD_LIBRARY_PATH=/usr/lib/postgresql/16/lib"

MemoryLimit=4G
MemoryAccounting=true
TasksMax=4096
CPUAccounting=true

PrivateTmp=yes
NoNewPrivileges=true
ProtectSystem=full
ProtectHome=yes
ReadWritePaths=/var/lib/postgresql /var/run/postgresql

StandardOutput=journal
StandardError=journal
SyslogIdentifier=postgresql

[Install]
WantedBy=multi-user.target
```

#### 4. Redis Service (Caching & Sessions)

**File:** `/etc/systemd/system/redis.service`

```ini
[Unit]
Description=Redis In-Memory Data Store
Documentation=https://redis.io
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/redis-server /etc/redis/redis.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=always
RestartSec=3

User=redis
Group=redis

MemoryLimit=512M
MemoryAccounting=true
TasksMax=256
CPUQuota=25%

PrivateTmp=yes
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/redis /var/run/redis

StandardOutput=journal
StandardError=journal
SyslogIdentifier=redis

[Install]
WantedBy=multi-user.target
```

### systemd Service Orchestration Target

**File:** `/etc/systemd/system/hcc-services.target`

```ini
[Unit]
Description=Unified Hosting Platform Services
Documentation=https://docs.example.com
Wants=hcc-api-gateway.service \
      hcc-billing-service.service \
      hcc-dns-service.service \
      hcc-email-service.service \
      hcc-support-service.service \
      hcc-monitoring-service.service

[Install]
WantedBy=multi-user.target
```

### Service Management Commands

```bash
# View all HCC services
sudo systemctl list-units --type=service --all | grep hcc

# Start all HCC services
sudo systemctl start hcc-services.target

# Stop all HCC services
sudo systemctl stop hcc-services.target

# Restart a specific service
sudo systemctl restart hcc-billing-service

# View real-time logs
sudo journalctl -u hcc-api-gateway -f --lines=100

# View logs for last hour
sudo journalctl -u hcc-api-gateway --since "1 hour ago"

# View service status with dependencies
systemctl status hcc-services.target -l

# Check if service is enabled on boot
sudo systemctl is-enabled hcc-api-gateway

# View systemd resource usage
sudo systemd-cgtop
```

### Automatic Service Restart Policy

```bash
# Create restart check script
cat > /usr/local/bin/hcc-service-monitor.sh << 'EOF'
#!/bin/bash

SERVICES=("hcc-api-gateway" "hcc-billing-service" "hcc-dns-service")
ALERT_EMAIL="ops@example.com"

for service in "${SERVICES[@]}"; do
  if ! systemctl is-active --quiet $service; then
    echo "WARNING: $service is not running" | mail -s "HCC Service Alert" $ALERT_EMAIL
    systemctl restart $service
  fi
done
EOF

chmod +x /usr/local/bin/hcc-service-monitor.sh

# Add to crontab (check every 5 minutes)
echo "*/5 * * * * /usr/local/bin/hcc-service-monitor.sh" | sudo tee -a /etc/crontab
```

---

## Backend Implementation Patterns

### RUST: Actix-web API Gateway

#### Project Structure

```
hcc-api-gateway/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── config.rs
│   ├── middleware/
│   │   ├── auth.rs
│   │   ├── rate_limit.rs
│   │   └── logging.rs
│   ├── handlers/
│   │   ├── health.rs
│   │   ├── auth.rs
│   │   └── users.rs
│   ├── models/
│   │   ├── user.rs
│   │   └── error.rs
│   ├── db/
│   │   └── pool.rs
│   └── lib.rs
└── tests/
```

#### Cargo.toml Configuration

```toml
[package]
name = "hcc-api-gateway"
version = "1.0.0"
edition = "2021"

[dependencies]
actix-web = "4.4"
actix-rt = "2.9"
tokio = { version = "1.35", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
sqlx = { version = "0.7", features = ["runtime-tokio-rustls", "postgres"] }
redis = { version = "0.24", features = ["tokio-comp", "connection-manager"] }
jsonwebtoken = "9.2"
bcrypt = "0.15"
uuid = { version = "1.6", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
tracing = "0.1"
tracing-subscriber = { version = "0.3", features = ["env-filter", "json"] }
dotenv = "0.15"
anyhow = "1.0"
thiserror = "1.0"
rand = "0.8"

[profile.release]
opt-level = 3
lto = true
codegen-units = 1
strip = true

[profile.dev]
opt-level = 0
```

#### Main Application Setup

```rust
// src/main.rs
use actix_web::{web, App, HttpServer, middleware as actix_middleware};
use sqlx::postgres::PgPoolOptions;
use redis::aio::ConnectionManager;
use std::sync::Arc;
use tracing_subscriber::EnvFilter;

mod config;
mod middleware;
mod handlers;
mod models;
mod db;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    // Initialize tracing
    tracing_subscriber::fmt()
        .with_env_filter(
            EnvFilter::from_default_env()
                .add_directive("hcc_api_gateway=debug".parse().unwrap())
        )
        .with_target(true)
        .with_thread_ids(true)
        .with_file(true)
        .with_line_number(true)
        .init();

    // Load configuration
    let config = config::Config::from_env().expect("Failed to load configuration");

    // Create database pool with connection pooling
    let pg_pool = PgPoolOptions::new()
        .max_connections(config.db_max_connections)
        .min_connections(config.db_min_connections)
        .connect_timeout(std::time::Duration::from_secs(10))
        .acquire_timeout(std::time::Duration::from_secs(30))
        .idle_timeout(std::time::Duration::from_secs(600))
        .max_lifetime(std::time::Duration::from_secs(1800))
        .connect(&config.database_url)
        .await
        .expect("Failed to create pool");

    // Create Redis connection manager
    let redis_client = redis::Client::open(config.redis_url.as_str())
        .expect("Failed to create Redis client");
    let redis_manager = ConnectionManager::new(redis_client)
        .await
        .expect("Failed to create Redis connection manager");

    let pool_data = web::Data::new(pg_pool);
    let redis_data = web::Data::new(redis_manager);

    tracing::info!(
        "Starting HTTP server on {}",
        config.api_listen_addr
    );

    HttpServer::new(move || {
        App::new()
            // Global middleware - ordered from outermost to innermost
            .wrap(actix_middleware::Logger::default())
            .wrap(middleware::RequestId::new())
            .wrap(middleware::RateLimit::new())
            .wrap(middleware::CompressMiddleware)
            .wrap(actix_web::middleware::DefaultHeaders::new()
                .add(("X-Version", "1.0.0"))
                .add(("X-API-Gateway", "true"))
            )
            
            // Share data
            .app_data(pool_data.clone())
            .app_data(redis_data.clone())
            
            // Health check endpoint
            .route("/health", web::get().to(handlers::health::health_check))
            
            // Auth routes
            .service(
                web::scope("/v1/auth")
                    .route("/login", web::post().to(handlers::auth::login))
                    .route("/refresh", web::post().to(handlers::auth::refresh_token))
                    .route("/logout", web::post().to(handlers::auth::logout))
            )
            
            // Protected routes
            .service(
                web::scope("/v1/users")
                    .wrap(middleware::Auth::new())
                    .route("", web::get().to(handlers::users::list_users))
                    .route("/{id}", web::get().to(handlers::users::get_user))
                    .route("", web::post().to(handlers::users::create_user))
            )
            
            // 404 handler
            .default_service(web::to(handlers::not_found))
    })
    .bind(&config.api_listen_addr)?
    .workers(4) // Use 4 worker threads for CPU-bound work
    .keep_alive(std::time::Duration::from_secs(75))
    .run()
    .await
}
```

#### Authentication Middleware (JWT)

```rust
// src/middleware/auth.rs
use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpMessage, body::EitherBody, HttpResponse,
};
use futures::future::LocalBoxFuture;
use jsonwebtoken::{decode, DecodingKey, Validation, Algorithm};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub sub: uuid::Uuid,      // User ID
    pub user_type: String,    // "admin", "reseller", "customer"
    pub org_id: uuid::Uuid,   // Organization ID
    pub iat: i64,             // Issued at
    pub exp: i64,             // Expiration
    pub roles: Vec<String>,   // User roles
}

pub struct Auth {
    secret: String,
}

impl Auth {
    pub fn new(secret: &str) -> Self {
        Self {
            secret: secret.to_string(),
        }
    }
}

impl<S, B> Transform<S, ServiceRequest> for Auth
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type InitError = ();
    type Transform = AuthMiddleware<S>;
    type Future = std::future::Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        let secret = self.secret.clone();
        std::future::ok(AuthMiddleware { service, secret })
    }
}

pub struct AuthMiddleware<S> {
    service: S,
    secret: String,
}

impl<S, B> Service<ServiceRequest> for AuthMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let secret = self.secret.clone();
        let service = self.service.call(req);

        Box::pin(async move {
            let req_data = service.await.unwrap();
            let (req, _) = req_data.into_parts();

            // Extract token from Authorization header
            let token = req
                .headers()
                .get("Authorization")
                .and_then(|h| h.to_str().ok())
                .and_then(|h| {
                    if h.starts_with("Bearer ") {
                        Some(&h[7..])
                    } else {
                        None
                    }
                })
                .ok_or_else(|| {
                    actix_web::error::ErrorUnauthorized("Missing authorization header")
                })?;

            // Validate JWT
            let claims = decode::<Claims>(
                token,
                &DecodingKey::from_secret(secret.as_ref()),
                &Validation::new(Algorithm::HS256),
            )
            .map_err(|_| {
                actix_web::error::ErrorUnauthorized("Invalid token")
            })?
            .claims;

            // Store claims in request extensions
            req.extensions_mut().insert(claims);

            Ok(req_data.map_into_left_body())
        })
    }
}
```

#### Database Connection Pooling

```rust
// src/db/pool.rs
use sqlx::{postgres::PgPoolOptions, PgPool};
use std::time::Duration;

pub async fn create_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
    PgPoolOptions::new()
        .max_connections(20)              // Adjust based on workload
        .min_connections(5)               // Keep minimum connections warm
        .acquire_timeout(Duration::from_secs(30))
        .connect_timeout(Duration::from_secs(10))
        .idle_timeout(Duration::from_secs(600))
        .max_lifetime(Duration::from_secs(1800))  // 30 minutes
        .connect(database_url)
        .await
}

// Usage example with query optimization
pub async fn get_user(
    pool: &PgPool,
    user_id: uuid::Uuid,
) -> Result<User, sqlx::Error> {
    sqlx::query_as::<_, User>(
        "SELECT id, email, username, created_at FROM users WHERE id = $1 LIMIT 1"
    )
    .bind(user_id)
    .fetch_one(pool)
    .await
}
```

#### Rate Limiting Middleware

```rust
// src/middleware/rate_limit.rs
use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpResponse, body::EitherBody,
};
use futures::future::LocalBoxFuture;
use redis::aio::ConnectionManager;
use std::net::IpAddr;

pub struct RateLimit {
    redis: ConnectionManager,
}

impl RateLimit {
    pub fn new(redis: ConnectionManager) -> Self {
        Self { redis }
    }
}

impl<S, B> Transform<S, ServiceRequest> for RateLimit
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type InitError = ();
    type Transform = RateLimitMiddleware<S>;
    type Future = std::future::Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        let redis = self.redis.clone();
        std::future::ok(RateLimitMiddleware { service, redis })
    }
}

pub struct RateLimitMiddleware<S> {
    service: S,
    redis: ConnectionManager,
}

impl<S, B> Service<ServiceRequest> for RateLimitMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let mut redis = self.redis.clone();

        // Get client IP (consider X-Forwarded-For for proxies)
        let ip = req
            .connection_info()
            .peer_addr()
            .map(|addr| addr.to_string())
            .unwrap_or_else(|| "unknown".to_string());

        let path = req.path().to_string();
        let fut = self.service.call(req);

        Box::pin(async move {
            // Rate limit: 100 requests per minute per IP
            let key = format!("rate_limit:{}:{}", ip, chrono::Utc::now().timestamp() / 60);
            
            let count: u32 = redis.incr(&key, 1).await.unwrap_or(0);
            if count == 1 {
                // Set expiration on first increment
                let _ = redis.expire(&key, 60).await;
            }

            if count > 100 {
                return Ok(req.into_response(
                    HttpResponse::TooManyRequests()
                        .json(serde_json::json!({
                            "error": "Rate limit exceeded",
                            "retry_after": 60
                        }))
                        .map_into_right_body()
                ));
            }

            let resp = fut.await?;
            Ok(resp.map_into_left_body())
        })
    }
}
```

### Go: Fiber Microservice Example (Billing Service)

#### Project Structure & Initialization

```go
// main.go
package main

import (
    "context"
    "fmt"
    "log"
    "os"
    "time"

    "github.com/gofiber/fiber/v2"
    "github.com/gofiber/fiber/v2/middleware/cors"
    "github.com/gofiber/fiber/v2/middleware/recover"
    "github.com/gofiber/fiber/v2/middleware/helmet"
    "github.com/gofiber/fiber/v2/middleware/logger"
    "github.com/jackc/pgx/v5"
    "github.com/jackc/pgx/v5/pgxpool"
)

func main() {
    // Load configuration
    config := loadConfig()

    // Initialize database connection pool
    dbPool, err := initDB(config.DatabaseURL)
    if err != nil {
        log.Fatal("Failed to initialize database:", err)
    }
    defer dbPool.Close()

    // Initialize Fiber app
    app := fiber.New(fiber.Config{
        AppName:      "HCC Billing Service v1.0.0",
        ServerHeader: "HCC-Billing",
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
        BodyLimit:    50 * 1024 * 1024, // 50MB max body
        JSONEncoder:  fiber.DefaultJSONEncoder,
        JSONDecoder:  fiber.DefaultJSONDecoder,
        Prefork:      false, // Set to true for production scaling
    })

    // Global middleware
    app.Use(recover.New())                                    // Panic recovery
    app.Use(logger.New(logger.Config{
        Format: "[${time}] ${status} - ${method} ${path}\n",
    }))
    app.Use(helmet.New())                                     // Security headers
    app.Use(cors.New(cors.Config{
        AllowOrigins: "https://example.com",
        AllowMethods: "GET,POST,PUT,DELETE",
        AllowHeaders: "Content-Type,Authorization",
    }))

    // Create request context with database pool
    app.Use(func(c *fiber.Ctx) error {
        c.Locals("db", dbPool)
        return c.Next()
    })

    // Health check
    app.Get("/health", func(c *fiber.Ctx) error {
        return c.JSON(fiber.Map{"status": "ok"})
    })

    // API routes
    v1 := app.Group("/v1")
    {
        // Invoice endpoints
        invoices := v1.Group("/invoices")
        invoices.Post("/", createInvoice)
        invoices.Get("/:id", getInvoice)
        invoices.Get("/", listInvoices)
        invoices.Put("/:id", updateInvoice)
        invoices.Delete("/:id", deleteInvoice)

        // Payment endpoints
        payments := v1.Group("/payments")
        payments.Post("/", processPayment)
        payments.Get("/:id", getPayment)
        payments.Get("/invoice/:invoice_id", getPaymentsByInvoice)

        // Subscription endpoints
        subscriptions := v1.Group("/subscriptions")
        subscriptions.Post("/", createSubscription)
        subscriptions.Get("/:id", getSubscription)
        subscriptions.Put("/:id", updateSubscription)
        subscriptions.Delete("/:id", cancelSubscription)
    }

    // Start server on port 8001 (systemd will manage it)
    port := os.Getenv("BILLING_LISTEN_PORT")
    if port == "" {
        port = "8001"
    }

    log.Printf("Starting Billing Service on port %s", port)
    if err := app.Listen(":" + port); err != nil {
        log.Fatal("Failed to start server:", err)
    }
}

// Database initialization with connection pooling
func initDB(dsn string) (*pgxpool.Pool, error) {
    config, err := pgxpool.ParseConfig(dsn)
    if err != nil {
        return nil, err
    }

    // Connection pool configuration
    config.MaxConns = 25
    config.MinConns = 5
    config.MaxConnLifetime = 30 * time.Minute
    config.MaxConnIdleTime = 10 * time.Minute
    config.HealthCheckPeriod = 1 * time.Minute
    config.ConnConfig.ConnectTimeout = 10 * time.Second

    pool, err := pgxpool.NewWithConfig(context.Background(), config)
    if err != nil {
        return nil, err
    }

    // Test connection
    if err := pool.Ping(context.Background()); err != nil {
        return nil, err
    }

    return pool, nil
}

type Config struct {
    DatabaseURL string
    RedisURL    string
    Port        string
}

func loadConfig() Config {
    return Config{
        DatabaseURL: os.Getenv("DATABASE_URL"),
        RedisURL:    os.Getenv("REDIS_URL"),
        Port:        os.Getenv("BILLING_LISTEN_PORT"),
    }
}
```

#### Invoice Handler with Best Practices

```go
// handlers/invoice.go
package handlers

import (
    "context"
    "database/sql"
    "time"

    "github.com/gofiber/fiber/v2"
    "github.com/jackc/pgx/v5/pgxpool"
    "github.com/shopspring/decimal"
)

type Invoice struct {
    ID            string          `json:"id"`
    OrganizationID string          `json:"organization_id"`
    CustomerID    string          `json:"customer_id"`
    InvoiceNumber string          `json:"invoice_number"`
    Amount        decimal.Decimal `json:"amount"`
    Tax           decimal.Decimal `json:"tax"`
    Total         decimal.Decimal `json:"total"`
    Status        string          `json:"status"` // draft, sent, paid, overdue, cancelled
    DueDate       time.Time       `json:"due_date"`
    IssuedAt      time.Time       `json:"issued_at"`
    PaidAt        *time.Time      `json:"paid_at,omitempty"`
    CreatedAt     time.Time       `json:"created_at"`
    UpdatedAt     time.Time       `json:"updated_at"`
}

// createInvoice handles invoice creation with transaction support
func createInvoice(c *fiber.Ctx) error {
    db := c.Locals("db").(*pgxpool.Pool)

    var req struct {
        CustomerID string                    `json:"customer_id" validate:"required"`
        Items      []map[string]interface{}  `json:"items" validate:"required,min=1"`
        DueDate    time.Time                 `json:"due_date"`
    }

    if err := c.BodyParser(&req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error": "Invalid request body",
        })
    }

    // Validate request
    if err := validate.Struct(req); err != nil {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "error": err.Error(),
        })
    }

    // Start transaction
    tx, err := db.Begin(context.Background())
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": "Failed to start transaction",
        })
    }
    defer tx.Rollback(context.Background())

    // Calculate totals
    var subtotal decimal.Decimal
    for _, item := range req.Items {
        // Process items and calculate subtotal
    }

    // Determine tax (simplified)
    tax := subtotal.Mul(decimal.NewFromFloat(0.19)) // 19% VAT example
    total := subtotal.Add(tax)

    // Create invoice
    var invoiceID string
    err = tx.QueryRow(context.Background(),
        `INSERT INTO invoices 
         (organization_id, customer_id, amount, tax, total, status, due_date, issued_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
         RETURNING id`,
        c.Locals("org_id"), req.CustomerID, subtotal, tax, total, "draft", req.DueDate, time.Now(),
    ).Scan(&invoiceID)

    if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": "Failed to create invoice",
        })
    }

    // Insert line items
    for i, item := range req.Items {
        _, err = tx.Exec(context.Background(),
            `INSERT INTO invoice_items (invoice_id, description, quantity, unit_price, line_total)
             VALUES ($1, $2, $3, $4, $5)`,
            invoiceID, item["description"], item["quantity"], item["unit_price"], item["line_total"],
        )
        if err != nil {
            return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
                "error": "Failed to insert invoice items",
            })
        }
    }

    // Commit transaction
    if err := tx.Commit(context.Background()); err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": "Failed to commit transaction",
        })
    }

    return c.Status(fiber.StatusCreated).JSON(fiber.Map{
        "id":      invoiceID,
        "message": "Invoice created successfully",
    })
}

// getInvoice retrieves invoice with caching
func getInvoice(c *fiber.Ctx) error {
    db := c.Locals("db").(*pgxpool.Pool)
    invoiceID := c.Params("id")

    // Try to get from cache (Redis would be used here)
    // cacheKey := fmt.Sprintf("invoice:%s", invoiceID)

    var invoice Invoice

    err := db.QueryRow(context.Background(),
        `SELECT id, organization_id, customer_id, invoice_number, amount, tax, total, 
                status, due_date, issued_at, paid_at, created_at, updated_at
         FROM invoices
         WHERE id = $1 AND organization_id = $2
         LIMIT 1`,
        invoiceID, c.Locals("org_id"),
    ).Scan(
        &invoice.ID, &invoice.OrganizationID, &invoice.CustomerID,
        &invoice.InvoiceNumber, &invoice.Amount, &invoice.Tax, &invoice.Total,
        &invoice.Status, &invoice.DueDate, &invoice.IssuedAt, &invoice.PaidAt,
        &invoice.CreatedAt, &invoice.UpdatedAt,
    )

    if err == sql.ErrNoRows {
        return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
            "error": "Invoice not found",
        })
    } else if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": "Database error",
        })
    }

    return c.JSON(invoice)
}

// listInvoices with pagination and filtering
func listInvoices(c *fiber.Ctx) error {
    db := c.Locals("db").(*pgxpool.Pool)

    page := c.QueryInt("page", 1)
    limit := c.QueryInt("limit", 20)
    status := c.Query("status", "")

    if limit > 100 {
        limit = 100 // Max 100 items per page
    }

    offset := (page - 1) * limit

    var query string
    var args []interface{}

    query = `SELECT id, organization_id, customer_id, invoice_number, amount, tax, total,
                    status, due_date, issued_at, paid_at, created_at, updated_at
             FROM invoices
             WHERE organization_id = $1`
    args = append(args, c.Locals("org_id"))

    if status != "" {
        query += ` AND status = $` + string(rune(len(args)+1))
        args = append(args, status)
    }

    query += ` ORDER BY created_at DESC LIMIT $` + string(rune(len(args)+1)) +
             ` OFFSET $` + string(rune(len(args)+2))
    args = append(args, limit, offset)

    rows, err := db.Query(context.Background(), query, args...)
    if err != nil {
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": "Database error",
        })
    }
    defer rows.Close()

    invoices := make([]Invoice, 0)
    for rows.Next() {
        var inv Invoice
        if err := rows.Scan(
            &inv.ID, &inv.OrganizationID, &inv.CustomerID,
            &inv.InvoiceNumber, &inv.Amount, &inv.Tax, &inv.Total,
            &inv.Status, &inv.DueDate, &inv.IssuedAt, &inv.PaidAt,
            &inv.CreatedAt, &inv.UpdatedAt,
        ); err != nil {
            return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
                "error": "Error scanning results",
            })
        }
        invoices = append(invoices, inv)
    }

    return c.JSON(fiber.Map{
        "data":       invoices,
        "page":       page,
        "limit":      limit,
        "total":      len(invoices), // Should get actual count for production
    })
}
```

---

## Security Best Practices

### 1. Authentication & Authorization

#### JWT Implementation with Refresh Tokens

```rust
// src/handlers/auth.rs (RUST Actix-web)
use actix_web::{web, HttpResponse};
use jsonwebtoken::{encode, decode, Header, EncodingKey, DecodingKey, Validation, Algorithm};
use serde::{Deserialize, Serialize};
use chrono::{Utc, Duration};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Claims {
    pub sub: uuid::Uuid,
    pub user_type: String,
    pub org_id: uuid::Uuid,
    pub iat: i64,
    pub exp: i64,
    pub roles: Vec<String>,
}

pub struct AuthService {
    jwt_secret: String,
    jwt_secret_refresh: String,
}

impl AuthService {
    pub fn new(secret: &str, refresh_secret: &str) -> Self {
        Self {
            jwt_secret: secret.to_string(),
            jwt_secret_refresh: refresh_secret.to_string(),
        }
    }

    pub fn generate_tokens(
        &self,
        user_id: uuid::Uuid,
        org_id: uuid::Uuid,
        user_type: String,
        roles: Vec<String>,
    ) -> Result<(String, String), jsonwebtoken::errors::Error> {
        // Access token (15 minutes)
        let access_claims = Claims {
            sub: user_id,
            user_type: user_type.clone(),
            org_id,
            iat: Utc::now().timestamp(),
            exp: (Utc::now() + Duration::minutes(15)).timestamp(),
            roles: roles.clone(),
        };

        let access_token = encode(
            &Header::new(Algorithm::HS256),
            &access_claims,
            &EncodingKey::from_secret(self.jwt_secret.as_ref()),
        )?;

        // Refresh token (7 days)
        let refresh_claims = Claims {
            sub: user_id,
            user_type,
            org_id,
            iat: Utc::now().timestamp(),
            exp: (Utc::now() + Duration::days(7)).timestamp(),
            roles,
        };

        let refresh_token = encode(
            &Header::new(Algorithm::HS256),
            &refresh_claims,
            &EncodingKey::from_secret(self.jwt_secret_refresh.as_ref()),
        )?;

        Ok((access_token, refresh_token))
    }

    pub fn verify_token(&self, token: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
        decode::<Claims>(
            token,
            &DecodingKey::from_secret(self.jwt_secret.as_ref()),
            &Validation::new(Algorithm::HS256),
        )
        .map(|data| data.claims)
    }

    pub fn verify_refresh_token(&self, token: &str) -> Result<Claims, jsonwebtoken::errors::Error> {
        decode::<Claims>(
            token,
            &DecodingKey::from_secret(self.jwt_secret_refresh.as_ref()),
            &Validation::new(Algorithm::HS256),
        )
        .map(|data| data.claims)
    }
}

#[derive(Deserialize)]
pub struct LoginRequest {
    pub email: String,
    pub password: String,
    pub totp_code: Option<String>,
}

#[derive(Serialize)]
pub struct LoginResponse {
    pub access_token: String,
    pub refresh_token: String,
    pub user_id: uuid::Uuid,
    pub expires_in: i64,
}

pub async fn login(
    req: web::Json<LoginRequest>,
    db: web::Data<PgPool>,
    auth: web::Data<AuthService>,
) -> actix_web::Result<HttpResponse> {
    // 1. Validate email format
    if !req.email.contains('@') {
        return Ok(HttpResponse::BadRequest().json(serde_json::json!({
            "error": "Invalid email format"
        })));
    }

    // 2. Query user from database
    let user = sqlx::query!(
        "SELECT id, email, password_hash, user_type, organization_id, is_active, totp_secret FROM users WHERE email = $1 AND is_active = true",
        req.email
    )
    .fetch_optional(db.as_ref())
    .await
    .map_err(|_| actix_web::error::ErrorInternalServerError("Database error"))?
    .ok_or_else(|| {
        // Don't reveal if user exists (security)
        actix_web::error::ErrorUnauthorized("Invalid credentials")
    })?;

    // 3. Verify password using bcrypt
    let password_valid = bcrypt::verify(&req.password, &user.password_hash)
        .map_err(|_| actix_web::error::ErrorInternalServerError("Crypto error"))?;

    if !password_valid {
        // Log failed attempt for security monitoring
        tracing::warn!(email = %req.email, "Failed login attempt");
        return Err(actix_web::error::ErrorUnauthorized("Invalid credentials").into());
    }

    // 4. Verify TOTP if enabled
    if let Some(totp_secret) = user.totp_secret {
        match &req.totp_code {
            Some(code) => {
                let totp = totp_light::TOTP::new(
                    totp_light::Sha1::new(),
                    6,
                    30,
                    totp_secret.as_bytes(),
                );
                if !totp.is_valid(code) {
                    return Err(actix_web::error::ErrorUnauthorized("Invalid TOTP code").into());
                }
            }
            None => {
                return Ok(HttpResponse::Unauthorized().json(serde_json::json!({
                    "error": "TOTP required",
                    "requires_2fa": true
                })));
            }
        }
    }

    // 5. Get user roles
    let roles: Vec<String> = sqlx::query_scalar(
        "SELECT role FROM user_roles WHERE user_id = $1"
    )
    .bind(user.id)
    .fetch_all(db.as_ref())
    .await
    .map_err(|_| actix_web::error::ErrorInternalServerError("Database error"))?;

    // 6. Generate tokens
    let (access_token, refresh_token) = auth.generate_tokens(
        user.id,
        user.organization_id,
        user.user_type,
        roles,
    )
    .map_err(|_| actix_web::error::ErrorInternalServerError("Token generation failed"))?;

    // 7. Store refresh token in Redis with expiry
    // In production, also log this for audit trail

    tracing::info!(user_id = %user.id, "Successful login");

    Ok(HttpResponse::Ok().json(LoginResponse {
        access_token,
        refresh_token,
        user_id: user.id,
        expires_in: 900, // 15 minutes in seconds
    }))
}
```

### 2. Password Security

```rust
// src/utils/password.rs
use bcrypt::{hash, verify, DEFAULT_COST};
use rand::Rng;

pub fn hash_password(password: &str) -> Result<String, bcrypt::BcryptError> {
    // Validate password strength before hashing
    if password.len() < 12 {
        return Err(bcrypt::BcryptError::InvalidPassword);
    }

    // Use bcrypt with high cost factor (14+ for production)
    hash(password, 14)
}

pub fn verify_password(password: &str, hash: &str) -> Result<bool, bcrypt::BcryptError> {
    verify(password, hash)
}

pub fn generate_secure_password() -> String {
    const CHARSET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
    let mut rng = rand::thread_rng();
    
    (0..24)
        .map(|_| {
            let idx = rng.gen_range(0..CHARSET.len());
            CHARSET[idx] as char
        })
        .collect()
}

// Database schema for password history (prevent reuse)
pub async fn check_password_history(
    user_id: uuid::Uuid,
    new_password: &str,
    pool: &PgPool,
) -> Result<bool, sqlx::Error> {
    let previous_hashes: Vec<String> = sqlx::query_scalar(
        "SELECT password_hash FROM password_history WHERE user_id = $1 ORDER BY created_at DESC LIMIT 5"
    )
    .bind(user_id)
    .fetch_all(pool)
    .await?;

    // Check if new password matches any previous password
    for old_hash in previous_hashes {
        if verify(new_password, &old_hash).unwrap_or(false) {
            return Ok(false); // Password was used before
        }
    }

    Ok(true)
}
```

### 3. Encryption for Sensitive Data

```rust
// src/utils/encryption.rs
use aes_gcm::{
    aead::{Aead, KeyInit, Payload},
    Aes256Gcm, Nonce,
};
use rand::Rng;
use base64::{engine::general_purpose, Engine};

pub struct EncryptionService {
    cipher: Aes256Gcm,
}

impl EncryptionService {
    pub fn new(key: &[u8; 32]) -> Self {
        Self {
            cipher: Aes256Gcm::new(key.into()),
        }
    }

    pub fn encrypt(&self, plaintext: &str) -> Result<String, aes_gcm::aead::Error> {
        let mut rng = rand::thread_rng();
        let mut nonce_array = [0u8; 12];
        rng.fill(&mut nonce_array);
        
        let nonce = Nonce::from_slice(&nonce_array);
        let ciphertext = self.cipher.encrypt(nonce, plaintext.as_bytes())?;
        
        // Combine nonce + ciphertext and encode as base64
        let mut encrypted = nonce_array.to_vec();
        encrypted.extend_from_slice(&ciphertext);
        
        Ok(general_purpose::STANDARD.encode(encrypted))
    }

    pub fn decrypt(&self, encrypted: &str) -> Result<String, Box<dyn std::error::Error>> {
        let encrypted_bytes = general_purpose::STANDARD.decode(encrypted)?;
        
        if encrypted_bytes.len() < 12 {
            return Err("Invalid encrypted data".into());
        }

        let (nonce_array, ciphertext) = encrypted_bytes.split_at(12);
        let nonce = Nonce::from_slice(nonce_array);
        
        let plaintext = self.cipher.decrypt(nonce, ciphertext)?;
        Ok(String::from_utf8(plaintext)?)
    }
}

// Use for: API keys, payment tokens, customer SSNs, encryption keys, etc.
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_encryption_decryption() {
        let key = [42u8; 32];
        let service = EncryptionService::new(&key);
        
        let plaintext = "sensitive-data-12345";
        let encrypted = service.encrypt(plaintext).unwrap();
        let decrypted = service.decrypt(&encrypted).unwrap();
        
        assert_eq!(plaintext, decrypted);
    }
}
```

### 4. SQL Injection Prevention

```rust
// ALWAYS use parameterized queries

// ❌ NEVER DO THIS (vulnerable)
let query = format!("SELECT * FROM users WHERE email = '{}'", email);

// ✅ DO THIS (safe)
let user = sqlx::query_as::<_, User>(
    "SELECT * FROM users WHERE email = $1"
)
.bind(email)
.fetch_one(pool)
.await?;

// Go example with pgx
// ❌ NEVER
query := fmt.Sprintf("SELECT * FROM users WHERE email = '%s'", email)

// ✅ DO THIS
err := db.QueryRow(context.Background(),
    "SELECT * FROM users WHERE email = $1",
    email,
).Scan(&user)
```

### 5. CSRF Protection

```rust
// src/middleware/csrf.rs
use actix_web::{
    dev::{forward_ready, Service, ServiceRequest, ServiceResponse, Transform},
    Error, HttpResponse, body::EitherBody,
};
use futures::future::LocalBoxFuture;
use uuid::Uuid;

pub struct CSRFProtection;

impl<S, B> Transform<S, ServiceRequest> for CSRFProtection
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type InitError = ();
    type Transform = CSRFMiddleware<S>;
    type Future = std::future::Ready<Result<Self::Transform, Self::InitError>>;

    fn new_transform(&self, service: S) -> Self::Future {
        std::future::ok(CSRFMiddleware { service })
    }
}

pub struct CSRFMiddleware<S> {
    service: S,
}

impl<S, B> Service<ServiceRequest> for CSRFMiddleware<S>
where
    S: Service<ServiceRequest, Response = ServiceResponse<B>, Error = Error>,
    S::Future: 'static,
    B: 'static,
{
    type Response = ServiceResponse<EitherBody<B>>;
    type Error = Error;
    type Future = LocalBoxFuture<'static, Result<Self::Response, Self::Error>>;

    forward_ready!(service);

    fn call(&self, req: ServiceRequest) -> Self::Future {
        let method = req.method().clone();

        // Only check CSRF for state-changing requests
        if matches!(method, actix_web::http::Method::POST | actix_web::http::Method::PUT | actix_web::http::Method::DELETE) {
            let csrf_token = req
                .headers()
                .get("X-CSRF-Token")
                .and_then(|h| h.to_str().ok())
                .or_else(|| {
                    req.form_data()
                        .get("csrf_token")
                        .and_then(|v| v.as_str())
                })
                .map(|s| s.to_string());

            let session_token = req
                .cookie("csrf_token")
                .map(|c| c.value().to_string());

            if csrf_token != session_token {
                return Box::pin(async move {
                    Ok(req.into_response(
                        HttpResponse::Forbidden()
                            .json(serde_json::json!({
                                "error": "CSRF token mismatch"
                            }))
                            .map_into_right_body()
                    ))
                });
            }
        }

        let fut = self.service.call(req);
        Box::pin(async move {
            let resp = fut.await?;
            Ok(resp.map_into_left_body())
        })
    }
}
```

---

## Database Design & Optimization

### PostgreSQL Connection Pooling

```go
// Go example with pgx connection pooling
config, err := pgxpool.ParseConfig(dsn)
if err != nil {
    log.Fatal(err)
}

// Connection pool tuning
config.MaxConns = 25                              // Max connections
config.MinConns = 5                               // Keep minimum warm
config.MaxConnLifetime = 30 * time.Minute         // Recycle old connections
config.MaxConnIdleTime = 10 * time.Minute         // Close idle connections
config.HealthCheckPeriod = 1 * time.Minute        // Health check interval
config.ConnConfig.ConnectTimeout = 10 * time.Second

pool, err := pgxpool.NewWithConfig(context.Background(), config)
if err != nil {
    log.Fatal(err)
}
```

### Multi-Tenant Database Schema

```sql
-- Organizations (tenants)
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    plan VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

-- Row-Level Security (RLS) policies
ALTER TABLE organizations ENABLE ROW LEVEL SECURITY;

-- Users with organization isolation
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    user_type VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email_org ON users(email, organization_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_organization_id ON users(organization_id);

-- RLS: Users can only see their own organization's data
CREATE POLICY users_org_policy ON users
    USING (organization_id = current_setting('app.current_org_id')::uuid);

-- Invoices
CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL,
    invoice_number VARCHAR(50) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    tax DECIMAL(12, 2) NOT NULL,
    total DECIMAL(12, 2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    due_date DATE NOT NULL,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    paid_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_invoices_org_status ON invoices(organization_id, status) WHERE deleted_at IS NULL;
CREATE INDEX idx_invoices_customer ON invoices(customer_id, organization_id);
CREATE INDEX idx_invoices_due_date ON invoices(due_date) WHERE status != 'paid';
```

### Query Optimization Examples

```go
// Good: Use prepared statements
const getInvoiceQuery = `
    SELECT id, organization_id, customer_id, invoice_number, amount, tax, total,
           status, due_date, issued_at, paid_at, created_at, updated_at
    FROM invoices
    WHERE id = $1 AND organization_id = $2
`

err := pool.QueryRow(context.Background(), getInvoiceQuery, invoiceID, orgID).Scan(...)

// Good: Batch queries for multiple records
rows, err := pool.Query(context.Background(), `
    SELECT id, email, username FROM users WHERE organization_id = $1
    ORDER BY created_at DESC LIMIT $2 OFFSET $3
`, orgID, limit, offset)

// Good: Use aggregation at database level
var count int
err := pool.QueryRow(context.Background(), `
    SELECT COUNT(*) FROM invoices 
    WHERE organization_id = $1 AND status = 'paid'
    AND paid_at > NOW() - INTERVAL '30 days'
`, orgID).Scan(&count)

// Bad: N+1 queries (AVOID)
invoices, _ := getInvoiceList(orgID)
for _, inv := range invoices {
    customer, _ := getCustomer(inv.CustomerID) // Query inside loop - SLOW!
}

// Good: Use JOIN
rows, _ := pool.Query(context.Background(), `
    SELECT i.id, i.invoice_number, c.name, c.email
    FROM invoices i
    JOIN customers c ON i.customer_id = c.id
    WHERE i.organization_id = $1
`, orgID)
```

---

## API Development Guidelines

### REST API Standards

```rust
// src/api/routes.rs

// URL Structure: /v1/{resource}/{action}
// GOOD URLs:
// GET    /v1/invoices              - List invoices
// GET    /v1/invoices/:id          - Get single invoice  
// POST   /v1/invoices              - Create invoice
// PUT    /v1/invoices/:id          - Update invoice
// DELETE /v1/invoices/:id          - Delete invoice
// POST   /v1/invoices/:id/send     - Custom action

// Status Codes:
// 200 OK - Successful GET, PUT, PATCH
// 201 Created - Successful POST
// 202 Accepted - Async operation started
// 204 No Content - Successful DELETE
// 400 Bad Request - Invalid parameters
// 401 Unauthorized - Missing/invalid auth
// 403 Forbidden - Authenticated but not permitted
// 404 Not Found - Resource doesn't exist
// 409 Conflict - Resource conflict (duplicate)
// 422 Unprocessable Entity - Validation failed
// 429 Too Many Requests - Rate limited
// 500 Internal Server Error - Server error

#[derive(Serialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub data: Option<T>,
    pub error: Option<ApiError>,
    pub timestamp: chrono::DateTime<chrono::Utc>,
    pub request_id: String,
}

#[derive(Serialize)]
pub struct ApiError {
    pub code: String,
    pub message: String,
    pub details: Option<serde_json::Value>,
}

// Pagination standard
#[derive(Deserialize)]
pub struct PaginationParams {
    pub page: Option<i64>,      // 1-indexed
    pub limit: Option<i64>,     // Max 100
    pub sort_by: Option<String>,
    pub sort_order: Option<String>, // asc, desc
}

#[derive(Serialize)]
pub struct PaginatedResponse<T> {
    pub data: Vec<T>,
    pub pagination: Pagination,
}

#[derive(Serialize)]
pub struct Pagination {
    pub page: i64,
    pub limit: i64,
    pub total: i64,
    pub total_pages: i64,
    pub has_next: bool,
    pub has_prev: bool,
}
```

### Error Handling Pattern

```go
// handlers/errors.go
package handlers

import (
    "fmt"
    "log"
)

type ErrorCode string

const (
    ErrValidation      ErrorCode = "VALIDATION_ERROR"
    ErrNotFound        ErrorCode = "NOT_FOUND"
    ErrUnauthorized    ErrorCode = "UNAUTHORIZED"
    ErrForbidden       ErrorCode = "FORBIDDEN"
    ErrInternal        ErrorCode = "INTERNAL_ERROR"
    ErrConflict        ErrorCode = "CONFLICT"
    ErrRateLimit       ErrorCode = "RATE_LIMITED"
)

type ApiError struct {
    Code    ErrorCode   `json:"code"`
    Message string      `json:"message"`
    Details interface{} `json:"details,omitempty"`
    StatusCode int      `json:"-"`
}

func (e ApiError) Error() string {
    return fmt.Sprintf("[%s] %s", e.Code, e.Message)
}

func NewApiError(code ErrorCode, message string, statusCode int) ApiError {
    return ApiError{
        Code:       code,
        Message:    message,
        StatusCode: statusCode,
    }
}

// HTTP Status Mapping
func (e ApiError) HTTPStatus() int {
    switch e.Code {
    case ErrValidation:
        return 422
    case ErrNotFound:
        return 404
    case ErrUnauthorized:
        return 401
    case ErrForbidden:
        return 403
    case ErrConflict:
        return 409
    case ErrRateLimit:
        return 429
    default:
        return e.StatusCode
    }
}

// Usage
func handleError(c *fiber.Ctx, err error) error {
    switch err := err.(type) {
    case ApiError:
        return c.Status(err.HTTPStatus()).JSON(err)
    default:
        log.Printf("Unhandled error: %v", err)
        return c.Status(500).JSON(ApiError{
            Code:    ErrInternal,
            Message: "Internal server error",
        })
    }
}
```

---

## Frontend Implementation (Next.js 16 + React 19 + TypeScript)

### Next.js Project Structure & Setup

```bash
# Initialize Next.js project with TypeScript and Tailwind
npx create-next-app@latest hcc-hosting-panel \
  --typescript \
  --tailwind \
  --app \
  --src-dir \
  --import-alias "@/*"

cd hcc-hosting-panel

# Install additional dependencies
npm install \
  @tanstack/react-query \
  axios \
  zustand \
  react-hot-toast \
  lucide-react \
  @headlessui/react \
  date-fns \
  zod \
  react-hook-form \
  @hookform/resolvers
```

**Project Structure:**

```
hcc-hosting-panel/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   └── layout.tsx
│   │   ├── (dashboard)/
│   │   │   ├── admin/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── users/page.tsx
│   │   │   │   ├── servers/page.tsx
│   │   │   │   └── billing/page.tsx
│   │   │   ├── client/
│   │   │   │   ├── page.tsx
│   │   │   │   ├── websites/page.tsx
│   │   │   │   └── invoices/page.tsx
│   │   │   └── layout.tsx
│   │   ├── api/
│   │   │   ├── auth/[...nextauth]/route.ts
│   │   │   └── proxy/[...path]/route.ts
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   ├── Card.tsx
│   │   │   └── Table.tsx
│   │   ├── layout/
│   │   │   ├── Sidebar.tsx
│   │   │   ├── Header.tsx
│   │   │   └── Footer.tsx
│   │   └── features/
│   │       ├── InvoiceList.tsx
│   │       ├── ServerStatus.tsx
│   │       └── WebsiteCard.tsx
│   ├── lib/
│   │   ├── api/
│   │   │   ├── client.ts
│   │   │   └── endpoints.ts
│   │   ├── hooks/
│   │   │   ├── useAuth.ts
│   │   │   ├── useInvoices.ts
│   │   │   └── useWebsites.ts
│   │   └── utils/
│   │       ├── cn.ts
│   │       └── formatters.ts
│   ├── types/
│   │   ├── api.ts
│   │   ├── user.ts
│   │   └── invoice.ts
│   └── styles/
│       └── globals.css
├── public/
├── package.json
├── tsconfig.json
├── tailwind.config.ts
└── next.config.js
```

**Root Layout (src/app/layout.tsx):**

```typescript
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Providers } from '@/components/Providers';
import { Toaster } from 'react-hot-toast';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'HCC Hosting Platform - Enterprise Control Panel',
  description: 'Advanced hosting control panel with billing automation',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="h-full">
      <body className={`${inter.className} h-full bg-gray-50`}>
        <Providers>
          {children}
          <Toaster position="bottom-right" />
        </Providers>
      </body>
    </html>
  );
}
```

**Dashboard Layout (src/app/(dashboard)/layout.tsx):**

```typescript
'use client';

import { useAuth } from '@/lib/hooks/useAuth';
import { Sidebar } from '@/components/layout/Sidebar';
import { Header } from '@/components/layout/Header';
import { redirect } from 'next/navigation';
import { useEffect } from 'react';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { user, isLoading } = useAuth();

  useEffect(() => {
    if (!isLoading && !user) {
      redirect('/login');
    }
  }, [user, isLoading]);

  if (isLoading) {
    return <div className="flex items-center justify-center h-screen">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
    </div>;
  }

  return (
    <div className="h-full flex">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        <main className="flex-1 overflow-y-auto p-6">
          <div className="max-w-7xl mx-auto">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
}
```

### Invoice List Component with Pagination (Next.js + React)

**Type Definitions (src/types/invoice.ts):**

```typescript
export interface Invoice {
  id: string;
  invoiceNumber: string;
  customerId: string;
  customerName: string;
  amount: number;
  tax: number;
  total: number;
  status: 'draft' | 'sent' | 'paid' | 'overdue' | 'cancelled';
  dueDate: string;
  issuedAt: string;
  paidAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface PaginationData {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface InvoiceListResponse {
  data: Invoice[];
  pagination: PaginationData;
}
```

**API Hook (src/lib/hooks/useInvoices.ts):**

```typescript
'use client';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { apiClient } from '@/lib/api/client';
import type { Invoice, InvoiceListResponse } from '@/types/invoice';
import toast from 'react-hot-toast';

interface InvoiceFilters {
  status?: string;
  search?: string;
  page?: number;
  limit?: number;
}

export function useInvoices(filters: InvoiceFilters = {}) {
  return useQuery<InvoiceListResponse>({
    queryKey: ['invoices', filters],
    queryFn: async () => {
      const params = new URLSearchParams();
      if (filters.status) params.set('status', filters.status);
      if (filters.search) params.set('search', filters.search);
      if (filters.page) params.set('page', filters.page.toString());
      if (filters.limit) params.set('limit', filters.limit.toString());

      const response = await apiClient.get(`/v1/invoices?${params}`);
      return response.data;
    },
  });
}

export function useSendInvoice() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (invoiceId: string) => {
      const response = await apiClient.post(`/v1/invoices/${invoiceId}/send`);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['invoices'] });
      toast.success('Invoice sent successfully');
    },
    onError: (error: any) => {
      toast.error(error.response?.data?.message || 'Failed to send invoice');
    },
  });
}

export function useDownloadInvoice() {
  return useMutation({
    mutationFn: async (invoiceId: string) => {
      const response = await apiClient.get(`/v1/invoices/${invoiceId}/download`, {
        responseType: 'blob',
      });

      // Create download link
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', `invoice-${invoiceId}.pdf`);
      document.body.appendChild(link);
      link.click();
      link.remove();
    },
    onError: (error: any) => {
      toast.error('Failed to download invoice');
    },
  });
}
```

**Invoice List Component (src/components/features/InvoiceList.tsx):**

```typescript
'use client';

import { useState, useMemo } from 'react';
import { useInvoices, useSendInvoice, useDownloadInvoice } from '@/lib/hooks/useInvoices';
import { Download, Send, Loader2 } from 'lucide-react';
import Link from 'next/link';
import { format } from 'date-fns';
import { useDebounce } from '@/lib/hooks/useDebounce';

const statusColors = {
  draft: 'bg-gray-100 text-gray-800',
  sent: 'bg-blue-100 text-blue-800',
  paid: 'bg-green-100 text-green-800',
  overdue: 'bg-red-100 text-red-800',
  cancelled: 'bg-gray-100 text-gray-500',
};

export function InvoiceList() {
  const [status, setStatus] = useState<string>('');
  const [searchInput, setSearchInput] = useState<string>('');
  const [page, setPage] = useState<number>(1);

  // Debounce search input
  const debouncedSearch = useDebounce(searchInput, 500);

  // Fetch invoices with filters
  const { data, isLoading, error } = useInvoices({
    status,
    search: debouncedSearch,
    page,
    limit: 20,
  });

  const sendInvoice = useSendInvoice();
  const downloadInvoice = useDownloadInvoice();

  const handleSendInvoice = (invoiceId: string) => {
    if (confirm('Are you sure you want to send this invoice?')) {
      sendInvoice.mutate(invoiceId);
    }
  };

  const handleDownloadInvoice = (invoiceId: string) => {
    downloadInvoice.mutate(invoiceId);
  };

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: 'USD',
    }).format(amount);
  };

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-4">
        <p className="text-red-800">Failed to load invoices. Please try again.</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      {/* Filters */}
      <div className="bg-white rounded-lg shadow p-4 space-y-4">
        <h2 className="text-lg font-semibold text-gray-900">Filters</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Status
            </label>
            <select
              value={status}
              onChange={(e) => {
                setStatus(e.target.value);
                setPage(1);
              }}
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            >
              <option value="">All Statuses</option>
              <option value="draft">Draft</option>
              <option value="sent">Sent</option>
              <option value="paid">Paid</option>
              <option value="overdue">Overdue</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Search
            </label>
            <input
              type="text"
              value={searchInput}
              onChange={(e) => {
                setSearchInput(e.target.value);
                setPage(1);
              }}
              placeholder="Invoice number or customer..."
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
        </div>
      </div>

      {/* Invoices Table */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        {isLoading ? (
          <div className="flex items-center justify-center py-12">
            <Loader2 className="w-8 h-8 animate-spin text-blue-600" />
          </div>
        ) : data && data.data.length > 0 ? (
          <>
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50 border-b">
                  <tr>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                      Invoice #
                    </th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                      Customer
                    </th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                      Amount
                    </th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                      Status
                    </th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                      Due Date
                    </th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-900">
                      Actions
                    </th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200">
                  {data.data.map((invoice) => (
                    <tr key={invoice.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 text-sm font-medium">
                        <Link
                          href={`/invoices/${invoice.id}`}
                          className="text-blue-600 hover:text-blue-900 hover:underline"
                        >
                          {invoice.invoiceNumber}
                        </Link>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {invoice.customerName}
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {formatCurrency(invoice.total)}
                      </td>
                      <td className="px-6 py-4 text-sm">
                        <span
                          className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-medium ${
                            statusColors[invoice.status]
                          }`}
                        >
                          {invoice.status.charAt(0).toUpperCase() + invoice.status.slice(1)}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-gray-900">
                        {format(new Date(invoice.dueDate), 'MMM dd, yyyy')}
                      </td>
                      <td className="px-6 py-4 text-sm space-x-2">
                        <button
                          onClick={() => handleDownloadInvoice(invoice.id)}
                          disabled={downloadInvoice.isPending}
                          className="inline-flex items-center text-blue-600 hover:text-blue-900 disabled:opacity-50"
                          title="Download PDF"
                        >
                          <Download className="w-4 h-4" />
                        </button>
                        {invoice.status === 'draft' && (
                          <button
                            onClick={() => handleSendInvoice(invoice.id)}
                            disabled={sendInvoice.isPending}
                            className="inline-flex items-center text-green-600 hover:text-green-900 disabled:opacity-50"
                            title="Send Invoice"
                          >
                            <Send className="w-4 h-4" />
                          </button>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            {/* Pagination */}
            <div className="px-6 py-4 border-t border-gray-200 flex items-center justify-between">
              <button
                onClick={() => setPage((p) => Math.max(1, p - 1))}
                disabled={!data.pagination.hasPrev}
                className="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Previous
              </button>

              <span className="text-sm text-gray-600">
                Page {data.pagination.page} of {data.pagination.totalPages}
              </span>

              <button
                onClick={() => setPage((p) => p + 1)}
                disabled={!data.pagination.hasNext}
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Next
              </button>
            </div>
          </>
        ) : (
          <div className="text-center py-12">
            <p className="text-gray-500">No invoices found</p>
          </div>
        )}
      </div>
    </div>
  );
}
```

**Page Component (src/app/(dashboard)/admin/billing/page.tsx):**

```typescript
import { InvoiceList } from '@/components/features/InvoiceList';

export default function BillingPage() {
  return (
    <div>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">Invoices</h1>
        <p className="text-gray-600 mt-1">
          Manage and track all customer invoices
        </p>
      </div>

      <InvoiceList />
    </div>
  );
}
```

---

## Automation & Orchestration

### Ansible Playbook for Server Provisioning

```yaml
# roles/hosting-server/tasks/main.yml
---
- name: Update system packages
  apt:
    update_cache: yes
    cache_valid_time: 3600
    upgrade: dist
  tags: [system, packages]

- name: Install base packages
  apt:
    name:
      - curl
      - wget
      - git
      - build-essential
      - libssl-dev
      - libffi-dev
      - python3-pip
      - jq
      - htop
      - iotop
      - netcat-traditional
      - telnet
    state: present
  tags: [system, packages]

- name: Configure SSH hardening
  block:
    - name: Disable root SSH login
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PermitRootLogin'
        line: 'PermitRootLogin no'
        state: present
      notify: restart ssh

    - name: Disable password authentication
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PasswordAuthentication'
        line: 'PasswordAuthentication no'
        state: present
      notify: restart ssh

    - name: Disable X11 forwarding
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?X11Forwarding'
        line: 'X11Forwarding no'
        state: present
      notify: restart ssh

  tags: [security, ssh]

- name: Configure firewall (nftables)
  block:
    - name: Install nftables
      apt:
        name: nftables
        state: present

    - name: Create nftables configuration
      template:
        src: nftables.conf.j2
        dest: /etc/nftables.conf
        owner: root
        group: root
        mode: '0644'
      notify: reload nftables

    - name: Enable nftables service
      systemd:
        name: nftables
        enabled: yes
        state: started

  tags: [security, firewall]

- name: Install and configure PostgreSQL 16
  block:
    - name: Add PostgreSQL repository
      shell: |
        echo "deb http://apt.postgresql.org/pub/repos/apt jammy-pgdg main" | \
        tee /etc/apt/sources.list.d/pgdg.list
        wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
        apt-key add -

    - name: Install PostgreSQL
      apt:
        name:
          - postgresql-16
          - postgresql-contrib-16
          - postgresql-16-postgis
        state: present
        update_cache: yes

    - name: Configure PostgreSQL performance
      template:
        src: postgresql.conf.j2
        dest: /etc/postgresql/16/main/postgresql.conf
        owner: postgres
        group: postgres
        mode: '0644'
      notify: restart postgresql

    - name: Enable PostgreSQL service
      systemd:
        name: postgresql
        enabled: yes
        state: started

  tags: [database, postgresql]

- name: Install Redis 7.2
  block:
    - name: Install Redis from APT
      apt:
        name: redis-server
        state: present

    - name: Configure Redis performance
      template:
        src: redis.conf.j2
        dest: /etc/redis/redis.conf
        owner: redis
        group: redis
        mode: '0644'
      notify: restart redis

    - name: Enable Redis service
      systemd:
        name: redis-server
        enabled: yes
        state: started

  tags: [cache, redis]

- name: Install NGINX 1.26
  block:
    - name: Add NGINX repository
      shell: |
        curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | \
        tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
        echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
        http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | \
        tee /etc/apt/sources.list.d/nginx.list

    - name: Install NGINX
      apt:
        name: nginx
        state: present
        update_cache: yes

    - name: Configure NGINX
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/nginx.conf
        owner: root
        group: root
        mode: '0644'
      notify: reload nginx

    - name: Enable NGINX service
      systemd:
        name: nginx
        enabled: yes
        state: started

  tags: [webserver, nginx]

- name: Create HCC service users
  block:
    - name: Create hcc-gateway user
      user:
        name: hcc-gateway
        system: yes
        home: /nonexistent
        shell: /usr/sbin/nologin
        createhome: no

    - name: Create hcc-services user
      user:
        name: hcc-services
        system: yes
        home: /nonexistent
        shell: /usr/sbin/nologin
        createhome: no

    - name: Create /var/lib/hcc directory
      file:
        path: /var/lib/hcc
        state: directory
        owner: hcc-services
        group: hcc-services
        mode: '0755'

    - name: Create /var/log/hcc directory
      file:
        path: /var/log/hcc
        state: directory
        owner: hcc-services
        group: hcc-services
        mode: '0755'

  tags: [system, users]

- name: Deploy HCC services
  block:
    - name: Copy API gateway binary
      copy:
        src: binaries/hcc-api-gateway
        dest: /usr/local/bin/hcc-api-gateway
        owner: root
        group: root
        mode: '0755'
      notify: restart api gateway

    - name: Copy billing service binary
      copy:
        src: binaries/hcc-billing-service
        dest: /usr/local/bin/hcc-billing-service
        owner: root
        group: root
        mode: '0755'
      notify: restart billing service

    - name: Copy systemd service files
      copy:
        src: "systemd/{{ item }}"
        dest: "/etc/systemd/system/{{ item }}"
        owner: root
        group: root
        mode: '0644'
      loop:
        - hcc-api-gateway.service
        - hcc-billing-service.service
        - hcc-services.target
      notify: reload systemd

  tags: [deployment, services]

- name: Configure monitoring and logging
  block:
    - name: Install Prometheus node exporter
      shell: |
        wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
        tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
        cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/
        rm -rf node_exporter-1.6.1.linux-amd64*

    - name: Create node exporter systemd service
      copy:
        content: |
          [Unit]
          Description=Prometheus Node Exporter
          After=network-online.target

          [Service]
          Type=simple
          ExecStart=/usr/local/bin/node_exporter --collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)
          Restart=always
          RestartSec=5

          [Install]
          WantedBy=multi-user.target
        dest: /etc/systemd/system/node-exporter.service
        owner: root
        group: root
        mode: '0644'
      notify: reload systemd

    - name: Enable node exporter
      systemd:
        name: node-exporter
        enabled: yes
        state: started

  tags: [monitoring, logging]

handlers:
  - name: restart ssh
    systemd:
      name: ssh
      state: restarted

  - name: reload nftables
    systemd:
      name: nftables
      state: reloaded

  - name: restart postgresql
    systemd:
      name: postgresql
      state: restarted

  - name: restart redis
    systemd:
      name: redis-server
      state: restarted

  - name: reload nginx
    systemd:
      name: nginx
      state: reloaded

  - name: reload systemd
    shell: systemctl daemon-reload

  - name: restart api gateway
    systemd:
      name: hcc-api-gateway
      state: restarted

  - name: restart billing service
    systemd:
      name: hcc-billing-service
      state: restarted
```

---

## Monitoring & Observability

### Structured Logging with Tracing

```rust
// src/logging.rs
use tracing::{subscriber::FmtSubscriber, Level};
use tracing_subscriber::fmt::format::FmtSpan;

pub fn init_tracing() {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .with_target(true)
        .with_thread_ids(true)
        .with_thread_names(true)
        .with_file(true)
        .with_line_number(true)
        .with_span_events(FmtSpan::CLOSE)
        .json()
        .init();
}

// Usage in handlers
#[tracing::instrument(skip(db))]
pub async fn create_invoice(
    invoice_data: InvoiceRequest,
    db: web::Data<PgPool>,
) -> Result<HttpResponse> {
    tracing::info!(
        customer_id = %invoice_data.customer_id,
        amount = invoice_data.amount,
        "Creating invoice"
    );

    // ... invoice creation logic ...

    tracing::info!(invoice_id = %invoice_id, "Invoice created successfully");
    
    Ok(HttpResponse::Created().json(json!({"id": invoice_id})))
}
```

### Health Checks

```rust
// src/handlers/health.rs
#[derive(Serialize)]
pub struct HealthResponse {
    pub status: String,
    pub version: String,
    pub timestamp: DateTime<Utc>,
    pub checks: HealthChecks,
}

#[derive(Serialize)]
pub struct HealthChecks {
    pub database: CheckStatus,
    pub redis: CheckStatus,
    pub memory: CheckStatus,
}

#[derive(Serialize)]
pub struct CheckStatus {
    pub status: String,
    pub response_time_ms: u64,
}

pub async fn health_check(
    db: web::Data<PgPool>,
    redis: web::Data<ConnectionManager>,
) -> impl Responder {
    let mut checks = HealthChecks {
        database: CheckStatus {
            status: "unknown".to_string(),
            response_time_ms: 0,
        },
        redis: CheckStatus {
            status: "unknown".to_string(),
            response_time_ms: 0,
        },
        memory: CheckStatus {
            status: "ok".to_string(),
            response_time_ms: 0,
        },
    };

    // Check database
    let db_start = std::time::Instant::now();
    match db.acquire().await {
        Ok(_) => {
            checks.database.status = "ok".to_string();
            checks.database.response_time_ms = db_start.elapsed().as_millis() as u64;
        }
        Err(_) => {
            checks.database.status = "error".to_string();
        }
    }

    // Check Redis
    let redis_start = std::time::Instant::now();
    match redis.ping::<String>().await {
        Ok(_) => {
            checks.redis.status = "ok".to_string();
            checks.redis.response_time_ms = redis_start.elapsed().as_millis() as u64;
        }
        Err(_) => {
            checks.redis.status = "error".to_string();
        }
    }

    HttpResponse::Ok().json(HealthResponse {
        status: "ok".to_string(),
        version: env!("CARGO_PKG_VERSION").to_string(),
        timestamp: Utc::now(),
        checks,
    })
}
```

---

## Deployment & DevOps

### Systemd Service with Automatic Updates

```bash
#!/bin/bash
# /usr/local/bin/deploy-hcc.sh

set -e

SERVICE_NAME="hcc-api-gateway"
BINARY_PATH="/usr/local/bin/hcc-api-gateway"
SOURCE_BINARY="./target/release/hcc-api-gateway"

# Build
echo "Building RUST application..."
cargo build --release

# Verify binary exists
if [ ! -f "$SOURCE_BINARY" ]; then
    echo "ERROR: Binary not found at $SOURCE_BINARY"
    exit 1
fi

# Stop service
echo "Stopping $SERVICE_NAME..."
sudo systemctl stop $SERVICE_NAME

# Backup old binary
if [ -f "$BINARY_PATH" ]; then
    sudo cp "$BINARY_PATH" "${BINARY_PATH}.backup"
fi

# Deploy new binary
echo "Deploying new binary..."
sudo cp "$SOURCE_BINARY" "$BINARY_PATH"
sudo chown root:root "$BINARY_PATH"
sudo chmod 755 "$BINARY_PATH"

# Start service
echo "Starting $SERVICE_NAME..."
sudo systemctl start $SERVICE_NAME

# Check status
if sudo systemctl is-active --quiet $SERVICE_NAME; then
    echo "✓ Deployment successful"
    echo "Service status:"
    sudo systemctl status $SERVICE_NAME
else
    echo "✗ Deployment failed - service did not start"
    sudo systemctl status $SERVICE_NAME
    exit 1
fi
```

---

## Performance Optimization

### Database Query Optimization Checklist

- [ ] Use prepared statements and parameterized queries
- [ ] Add appropriate indexes on frequently queried columns
- [ ] Use EXPLAIN ANALYZE to understand query plans
- [ ] Limit SELECT columns to what's actually needed
- [ ] Use LIMIT to restrict result set sizes
- [ ] Cache frequently accessed data in Redis
- [ ] Use connection pooling with appropriate settings
- [ ] Batch operations when possible
- [ ] Avoid N+1 queries with proper JOINs
- [ ] Vacuum and analyze tables regularly

### RUST Binary Optimization

```toml
# Cargo.toml
[profile.release]
opt-level = 3              # Maximize optimization
lto = true                 # Enable Link Time Optimization
codegen-units = 1          # Single codegen unit for optimization
strip = true               # Strip debug symbols
panic = "abort"            # Reduce panic code size
```

### Go Binary Optimization

```bash
# Build flags for optimization
go build \
  -ldflags="-s -w" \       # Strip symbols and debug info
  -a \                     # Force rebuild
  -tags netgo \            # Compile DNS with pure Go
  -o hcc-billing-service
```

---

## Common Pitfalls & Solutions

### Pitfall 1: Not Using Connection Pooling

```rust
// ❌ WRONG: Creating new connection per request
async fn get_user(id: Uuid) -> Result<User> {
    let pool = PgPoolOptions::new().connect(&db_url).await?;
    // ... query ...
}

// ✅ CORRECT: Use shared pool
async fn get_user(id: Uuid, pool: web::Data<PgPool>) -> Result<User> {
    // ... query ...
}
```

### Pitfall 2: Blocking Operations in Async Context

```rust
// ❌ WRONG: Blocking in async function
async fn process_invoice(db: web::Data<PgPool>) {
    let start = std::time::Instant::now();
    while start.elapsed().as_secs() < 5 {
        // Blocks entire runtime!
    }
}

// ✅ CORRECT: Use async sleep
async fn process_invoice(db: web::Data<PgPool>) {
    tokio::time::sleep(std::time::Duration::from_secs(5)).await;
}
```

### Pitfall 3: Not Validating User Input

```rust
// ❌ WRONG: Trusting user input
pub async fn create_invoice(req: web::Json<InvoiceRequest>) {
    let amount = req.amount; // What if it's negative or zero?
}

// ✅ CORRECT: Validate input
pub async fn create_invoice(req: web::Json<InvoiceRequest>) {
    if req.amount <= 0.0 {
        return Err(ApiError::validation("Amount must be positive"));
    }
    if req.invoice_number.is_empty() {
        return Err(ApiError::validation("Invoice number is required"));
    }
}
```

### Pitfall 4: Missing CSRF Protection

```html
<!-- ❌ WRONG: No CSRF protection -->
<form method="POST" action="/invoices">
    <input type="text" name="amount">
</form>

<!-- ✅ CORRECT: Include CSRF token -->
<form method="POST" action="/invoices" hx-post="/invoices">
    <input type="hidden" name="csrf_token" value="{{ .CSRFToken }}">
    <input type="text" name="amount">
</form>
```

### Pitfall 5: Not Setting HTTP Security Headers

```rust
// ✅ CORRECT: Set security headers in middleware
app.wrap(
    actix_web::middleware::DefaultHeaders::new()
        .add(("X-Content-Type-Options", "nosniff"))
        .add(("X-Frame-Options", "DENY"))
        .add(("X-XSS-Protection", "1; mode=block"))
        .add(("Strict-Transport-Security", "max-age=31536000; includeSubDomains"))
        .add(("Content-Security-Policy", "default-src 'self'"))
)
```

---

## Conclusion

This guide provides enterprise-level patterns and best practices for implementing the Unified Hosting Platform. Key takeaways:

1. **Use systemd** for service management - it's native, efficient, and powerful
2. **Use RUST** for performance-critical services - especially HTTP servers
3. **Use Go** for business logic microservices - fast, simple, great concurrency
4. **Security first** - validation, encryption, authentication, authorization
5. **Database optimization** - connection pooling, query optimization, indexing
6. **Monitoring and observability** - structured logging, health checks, tracing
7. **Testing** - unit tests, integration tests, performance tests

For additional information, refer to:
- RUST Book: https://doc.rust-lang.org/book/
- Actix-web Docs: https://actix.rs/
- Go Documentation: https://golang.org/doc/
- PostgreSQL Documentation: https://www.postgresql.org/docs/
- systemd Manual Pages: https://www.freedesktop.org/software/systemd/man/

---

**Document Version:** 1.0  
**Last Updated:** November 4, 2025  
**Maintainer:** HCC Development Team