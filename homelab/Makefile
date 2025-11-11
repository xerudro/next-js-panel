.PHONY: help up down restart logs ps clean backup restore health test

# Default target
.DEFAULT_GOAL := help

# Color output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m

help: ## Show this help message
	@echo "$(CYAN)Homelab Development Environment$(NC)"
	@echo ""
	@echo "$(GREEN)Available commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""

up: ## Start all services
	@echo "$(GREEN)Starting all services...$(NC)"
	docker compose up -d
	@echo "$(GREEN)Services started!$(NC)"
	@make ps

down: ## Stop all services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	docker compose down
	@echo "$(GREEN)Services stopped!$(NC)"

restart: ## Restart all services
	@echo "$(YELLOW)Restarting all services...$(NC)"
	docker compose restart
	@echo "$(GREEN)Services restarted!$(NC)"

logs: ## Show logs from all services (follow mode)
	docker compose logs -f

logs-postgres: ## Show PostgreSQL logs
	docker compose logs -f postgres

logs-redis: ## Show Redis logs
	docker compose logs -f redis

logs-n8n: ## Show n8n logs
	docker compose logs -f n8n

ps: ## Show status of all services
	@docker compose ps

clean: ## Stop and remove all containers, networks, and volumes (WARNING: deletes data!)
	@echo "$(RED)WARNING: This will delete all data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		echo "$(GREEN)Cleanup complete!$(NC)"; \
	else \
		echo "$(YELLOW)Cleanup cancelled.$(NC)"; \
	fi

health: ## Check health of all services
	@echo "$(CYAN)Checking service health...$(NC)"
	@docker compose ps
	@echo ""
	@echo "$(CYAN)PostgreSQL:$(NC)"
	@docker compose exec postgres pg_isready -U hosting_dev || echo "$(RED)PostgreSQL is not ready$(NC)"
	@echo "$(CYAN)Redis:$(NC)"
	@docker compose exec redis redis-cli -a dev_redis_password PING || echo "$(RED)Redis is not ready$(NC)"
	@echo ""
	@echo "$(GREEN)Health check complete!$(NC)"

test: ## Run basic connectivity tests
	@echo "$(CYAN)Running connectivity tests...$(NC)"
	@echo ""
	@echo "$(CYAN)Testing PostgreSQL...$(NC)"
	@docker compose exec postgres psql -U hosting_dev -d hosting_platform -c "SELECT 'PostgreSQL OK' as status;" || echo "$(RED)PostgreSQL test failed$(NC)"
	@echo ""
	@echo "$(CYAN)Testing Redis...$(NC)"
	@docker compose exec redis redis-cli -a dev_redis_password SET test_key "test_value" > /dev/null && \
	docker compose exec redis redis-cli -a dev_redis_password GET test_key || echo "$(RED)Redis test failed$(NC)"
	@echo ""
	@echo "$(GREEN)Tests complete!$(NC)"

backup: ## Create backup of PostgreSQL database
	@echo "$(CYAN)Creating database backup...$(NC)"
	@mkdir -p backups
	@docker compose exec postgres pg_dump -U hosting_dev hosting_platform > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "$(GREEN)Backup created in backups/ directory$(NC)"

restore: ## Restore PostgreSQL database from backup (Usage: make restore BACKUP=backups/backup_20250111_120000.sql)
	@if [ -z "$(BACKUP)" ]; then \
		echo "$(RED)Error: Please specify BACKUP file$(NC)"; \
		echo "Usage: make restore BACKUP=backups/backup_20250111_120000.sql"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restoring database from $(BACKUP)...$(NC)"
	@docker compose exec -T postgres psql -U hosting_dev hosting_platform < $(BACKUP)
	@echo "$(GREEN)Database restored!$(NC)"

pull: ## Pull latest Docker images
	@echo "$(CYAN)Pulling latest images...$(NC)"
	docker compose pull
	@echo "$(GREEN)Images updated!$(NC)"

update: pull ## Update and restart services with latest images
	@echo "$(CYAN)Updating services...$(NC)"
	docker compose up -d --force-recreate
	@echo "$(GREEN)Services updated!$(NC)"

shell-postgres: ## Open PostgreSQL shell
	docker compose exec postgres psql -U hosting_dev -d hosting_platform

shell-redis: ## Open Redis CLI
	docker compose exec redis redis-cli -a dev_redis_password

stats: ## Show resource usage statistics
	docker stats --no-stream

prune: ## Remove unused Docker resources
	@echo "$(YELLOW)Removing unused Docker resources...$(NC)"
	docker system prune -f
	@echo "$(GREEN)Cleanup complete!$(NC)"

init: ## Initialize environment (first-time setup)
	@echo "$(CYAN)Initializing homelab environment...$(NC)"
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(YELLOW)Created .env file. Please edit it with your passwords!$(NC)"; \
	else \
		echo "$(GREEN).env file already exists.$(NC)"; \
	fi
	@make up
	@sleep 5
	@make health
	@echo ""
	@echo "$(GREEN)Initialization complete!$(NC)"
	@echo "$(CYAN)Next steps:$(NC)"
	@echo "  1. Edit .env with secure passwords"
	@echo "  2. Access services:"
	@echo "     - n8n: http://localhost:5678"
	@echo "     - Grafana: http://localhost:3001"
	@echo "     - Prometheus: http://localhost:9090"
	@echo "     - Adminer: http://localhost:8081"
	@echo "     - Redis Commander: http://localhost:8082"

web: ## Open all web UIs in browser
	@echo "$(CYAN)Opening web UIs...$(NC)"
	@command -v xdg-open > /dev/null && xdg-open http://localhost:5678 || true
	@command -v xdg-open > /dev/null && xdg-open http://localhost:3001 || true
	@command -v xdg-open > /dev/null && xdg-open http://localhost:9090 || true
	@command -v open > /dev/null && open http://localhost:5678 || true
	@command -v open > /dev/null && open http://localhost:3001 || true
	@command -v open > /dev/null && open http://localhost:9090 || true
