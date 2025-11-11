#!/bin/bash

# Homelab Quick Start Script
# This script helps set up the development environment quickly

set -e

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}  Homelab Development Environment${NC}"
echo -e "${CYAN}  Quick Start Setup${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Check Docker
echo -e "${CYAN}Checking prerequisites...${NC}"
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed${NC}"
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo -e "${GREEN}✓ Docker found: $(docker --version)${NC}"
echo -e "${GREEN}✓ Docker Compose found: $(docker compose version)${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}⚠ Please edit .env and update passwords before continuing!${NC}"
    echo ""
    read -p "Press Enter to edit .env file now, or Ctrl+C to exit..."
    ${EDITOR:-nano} .env
    echo ""
fi

echo -e "${GREEN}✓ .env file exists${NC}"
echo ""

# Start services
echo -e "${CYAN}Starting services...${NC}"
docker compose up -d

echo ""
echo -e "${GREEN}Services started!${NC}"
echo ""

# Wait for services to be healthy
echo -e "${CYAN}Waiting for services to be ready...${NC}"
sleep 5

# Check PostgreSQL
echo -n "PostgreSQL: "
if docker compose exec -T postgres pg_isready -U hosting_dev > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Ready${NC}"
else
    echo -e "${YELLOW}⚠ Not ready yet (may need more time)${NC}"
fi

# Check Redis
echo -n "Redis: "
if docker compose exec -T redis redis-cli -a dev_redis_password PING > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Ready${NC}"
else
    echo -e "${YELLOW}⚠ Not ready yet (may need more time)${NC}"
fi

echo ""

# Show service status
echo -e "${CYAN}Service Status:${NC}"
docker compose ps
echo ""

# Show access URLs
echo -e "${CYAN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${CYAN}Access your services:${NC}"
echo ""
echo -e "  📊 ${GREEN}Grafana${NC}         http://localhost:3001"
echo -e "     Username: admin | Password: admin"
echo ""
echo -e "  🔄 ${GREEN}n8n${NC}             http://localhost:5678"
echo -e "     Username: admin | Password: admin"
echo ""
echo -e "  📈 ${GREEN}Prometheus${NC}      http://localhost:9090"
echo ""
echo -e "  🗄️  ${GREEN}Adminer${NC}         http://localhost:8081"
echo -e "     Server: postgres | User: hosting_dev"
echo ""
echo -e "  🔴 ${GREEN}Redis Commander${NC} http://localhost:8082"
echo ""
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${CYAN}Database Connection:${NC}"
echo -e "  Host: localhost"
echo -e "  Port: 5432"
echo -e "  Database: hosting_platform"
echo -e "  User: hosting_dev"
echo -e "  Password: (from .env file)"
echo ""
echo -e "${CYAN}Redis Connection:${NC}"
echo -e "  Host: localhost"
echo -e "  Port: 6379"
echo -e "  Password: (from .env file)"
echo ""
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${CYAN}Useful commands:${NC}"
echo -e "  make help          - Show all available commands"
echo -e "  make ps            - Show service status"
echo -e "  make logs          - Show all logs"
echo -e "  make health        - Check service health"
echo -e "  make test          - Run connectivity tests"
echo -e "  make backup        - Backup PostgreSQL"
echo -e "  make down          - Stop all services"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"
echo ""
