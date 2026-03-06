# WordPress Vulnerability Testing Lab
# ────────────────────────────────────

COMPOSE       = docker-compose
COMPOSE_FPM   = docker-compose -f docker-compose.fpm.yml

.PHONY: help build up down restart logs ps shell db-shell reset \
        fpm-build fpm-up fpm-down wp

# ── Default ─────────────────────────────────────
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# ── Apache Stack (primary) ──────────────────────
build: ## Build the WordPress+XDebug image
	$(COMPOSE) build

up: ## Start the stack (Apache mode)
	$(COMPOSE) up -d

down: ## Stop and remove containers
	$(COMPOSE) down

restart: down up ## Restart the stack

logs: ## Tail logs for all services
	$(COMPOSE) logs -f

ps: ## Show running containers
	$(COMPOSE) ps

shell: ## Open a bash shell inside WordPress
	docker exec -it wordpress-wpd bash

db-shell: ## Open a MySQL shell
	docker exec -it mysql-wpd mysql -u root -proot wordpress

reset: ## Nuke everything (containers + volumes) for a fresh start
	$(COMPOSE) down -v
	@echo "All volumes removed. Run 'make up' for a clean install."

# ── FPM + Nginx Stack (secondary) ──────────────
fpm-build: ## Build the FPM variant
	$(COMPOSE_FPM) build

fpm-up: ## Start the FPM+Nginx stack
	$(COMPOSE_FPM) up -d

fpm-down: ## Stop the FPM+Nginx stack
	$(COMPOSE_FPM) down

# ── WP-CLI shortcut ────────────────────────────
wp: ## Run a WP-CLI command (usage: make wp CMD="plugin list")
	$(COMPOSE) run --rm wpcli $(CMD)
