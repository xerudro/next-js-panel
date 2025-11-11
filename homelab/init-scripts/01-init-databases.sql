-- Initial database setup for Hosting Platform
-- This script runs automatically when PostgreSQL container starts for the first time

-- Create n8n database for workflow automation
CREATE DATABASE n8n;

-- Create test database for development
CREATE DATABASE hosting_platform_test;

-- Grant all privileges to the hosting_dev user
GRANT ALL PRIVILEGES ON DATABASE n8n TO hosting_dev;
GRANT ALL PRIVILEGES ON DATABASE hosting_platform_test TO hosting_dev;

-- Enable required PostgreSQL extensions
\c hosting_platform;

-- UUID extension for generating UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- pgcrypto for password hashing and encryption
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- pg_trgm for full-text search and similarity
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Create initial schema version tracking table
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Log the initialization
INSERT INTO schema_migrations (version) VALUES ('00000000000000_init');

-- Create audit log function for tracking changes
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO audit_log (table_name, operation, old_data, timestamp)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), NOW());
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO audit_log (table_name, operation, old_data, new_data, timestamp)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(OLD), row_to_json(NEW), NOW());
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO audit_log (table_name, operation, new_data, timestamp)
        VALUES (TG_TABLE_NAME, TG_OP, row_to_json(NEW), NOW());
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create audit_log table (initially)
CREATE TABLE IF NOT EXISTS audit_log (
    id SERIAL PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    operation VARCHAR(10) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_id UUID
);

-- Create index for faster audit log queries
CREATE INDEX IF NOT EXISTS idx_audit_log_table_name ON audit_log(table_name);
CREATE INDEX IF NOT EXISTS idx_audit_log_timestamp ON audit_log(timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_log_user_id ON audit_log(user_id);

-- Output success message
\echo 'Database initialization completed successfully!'
\echo 'Extensions enabled: uuid-ossp, pgcrypto, pg_trgm'
\echo 'Additional databases created: n8n, hosting_platform_test'
