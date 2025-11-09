# Tarot Reader Application Makefile
# Provides convenient commands for development and deployment

.PHONY: help
help: ## Show this help message
	@echo "Tarot Reader Application - Available Commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Development Commands
.PHONY: dev
dev: ## Start development environment with Docker Compose
	docker compose up --build

.PHONY: dev-bg
dev-bg: ## Start development environment in background
	docker compose up --build -d

.PHONY: dev-stop
dev-stop: ## Stop development environment
	docker compose down

.PHONY: dev-clean
dev-clean: ## Stop and remove all dev containers, volumes, and images
	docker compose down -v --rmi all

.PHONY: dev-logs
dev-logs: ## Show logs from development containers
	docker compose logs -f

.PHONY: dev-backend-logs
dev-backend-logs: ## Show backend logs only
	docker compose logs -f backend

.PHONY: dev-frontend-logs
dev-frontend-logs: ## Show frontend logs only
	docker compose logs -f frontend

# Production Commands
.PHONY: prod
prod: ## Start production environment
	docker compose -f compose.yaml up --build -d

.PHONY: prod-stop
prod-stop: ## Stop production environment
	docker compose -f compose.yaml down

.PHONY: prod-logs
prod-logs: ## Show production logs
	docker compose -f compose.yaml logs -f

# Backend Commands
.PHONY: backend-build
backend-build: ## Build backend Docker image
	docker build -t tarotreader-backend ./backend

.PHONY: backend-run
backend-run: ## Run backend locally (without Docker)
	cd backend && cargo run

.PHONY: backend-test
backend-test: ## Run backend tests
	cd backend && cargo test

.PHONY: backend-check
backend-check: ## Check backend code
	cd backend && cargo check

.PHONY: backend-fmt
backend-fmt: ## Format backend code
	cd backend && cargo fmt

.PHONY: backend-clippy
backend-clippy: ## Run clippy linter on backend
	cd backend && cargo clippy -- -D warnings

# Frontend Commands
.PHONY: frontend-build
frontend-build: ## Build frontend Docker image
	docker build -t tarotreader-frontend ./frontend

.PHONY: frontend-dev
frontend-dev: ## Run frontend development server locally
	cd frontend && pnpm dev

.PHONY: frontend-install
frontend-install: ## Install frontend dependencies
	cd frontend && pnpm install

.PHONY: frontend-build-local
frontend-build-local: ## Build frontend locally
	cd frontend && pnpm build

.PHONY: frontend-preview
frontend-preview: ## Preview production build locally
	cd frontend && pnpm preview

.PHONY: frontend-lint
frontend-lint: ## Lint frontend code
	cd frontend && pnpm lint

# Docker Commands
.PHONY: docker-prune
docker-prune: ## Remove unused Docker resources
	docker system prune -af --volumes

.PHONY: docker-stats
docker-stats: ## Show Docker container statistics
	docker compose stats

.PHONY: docker-clean-build
docker-clean-build: ## Clean Docker build cache and rebuild
	docker builder prune -af
	docker compose build --no-cache

# Testing Commands
.PHONY: test
test: ## Run all tests
	@echo "Running backend tests..."
	cd backend && cargo test
	@echo "Running frontend tests (if available)..."
	cd frontend && pnpm test 2>/dev/null || echo "No frontend tests configured"

.PHONY: test-backend
test-backend: ## Run backend tests only
	cd backend && cargo test

# Utility Commands
.PHONY: install
install: ## Install all dependencies
	@echo "Installing backend dependencies..."
	cd backend && cargo fetch
	@echo "Installing frontend dependencies..."
	cd frontend && pnpm install

.PHONY: clean
clean: ## Clean all build artifacts
	@echo "Cleaning backend..."
	cd backend && cargo clean
	@echo "Cleaning frontend..."
	cd frontend && rm -rf dist node_modules .vite
	@echo "Cleaning Docker..."
	docker compose down -v

.PHONY: env
env: ## Create .env file from example
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo ".env file created from .env.example"; \
		echo "Please update the values in .env for your environment"; \
	else \
		echo ".env file already exists"; \
	fi

.PHONY: check-env
check-env: ## Check if required environment variables are set
	@echo "Checking environment variables..."
	@test -f .env || (echo "Error: .env file not found. Run 'make env' first." && exit 1)
	@echo "✓ .env file exists"
	@grep -q "BACKEND_HOST=" .env || echo "⚠ BACKEND_HOST not set (required for production)"
	@grep -q "FRONTEND_HOST=" .env || echo "⚠ FRONTEND_HOST not set (required for production)"
	@grep -q "VITE_API_URL=" .env || echo "⚠ VITE_API_URL not set"

.PHONY: health
health: ## Check health of all services
	@echo "Checking service health..."
	@curl -sf http://localhost:8000/health 2>/dev/null && echo "✓ Backend is healthy" || echo "✗ Backend is not responding"
	@curl -sf http://localhost:3000 2>/dev/null && echo "✓ Frontend is healthy" || echo "✗ Frontend is not responding"

# Deployment Commands
.PHONY: deploy-synology
deploy-synology: ## Deploy to Synology NAS
	@echo "Deploying to Synology..."
	@echo "1. Build images: make prod-build"
	@echo "2. Push to registry or transfer images"
	@echo "3. SSH to Synology and pull/load images"
	@echo "4. Run docker compose -f compose.yaml up -d on Synology"

.PHONY: prod-build
prod-build: ## Build production images
	docker build -t tarotreader-backend:latest ./backend
	docker build -t tarotreader-frontend:latest ./frontend
	@echo "Production images built successfully"

.PHONY: save-images
save-images: ## Save Docker images to tar files for transfer
	@mkdir -p ./docker-images
	docker save -o ./docker-images/tarotreader-backend.tar tarotreader-backend:latest
	docker save -o ./docker-images/tarotreader-frontend.tar tarotreader-frontend:latest
	@echo "Images saved to ./docker-images/"

.PHONY: load-images
load-images: ## Load Docker images from tar files
	docker load -i ./docker-images/tarotreader-backend.tar
	docker load -i ./docker-images/tarotreader-frontend.tar
	@echo "Images loaded successfully"

# Quick Start
.PHONY: quickstart
quickstart: install dev ## Quick start for new developers
	@echo ""
	@echo "🚀 Tarot Reader is starting up!"
	@echo ""
	@echo "Frontend: http://localhost:3000"
	@echo "Backend:  http://localhost:8000"
	@echo ""
	@echo "Run 'make help' to see all available commands"

# Development with rebuilding
.PHONY: rebuild
rebuild: ## Rebuild and restart all containers
	docker compose down
	docker compose up --build

.PHONY: rebuild-backend
rebuild-backend: ## Rebuild backend only
	docker compose stop backend
	docker compose build backend
	docker compose start backend

.PHONY: rebuild-frontend
rebuild-frontend: ## Rebuild frontend only
	docker compose stop frontend
	docker compose build frontend
	docker compose start frontend

# Status commands
.PHONY: status
status: ## Show status of all containers
	@docker compose ps

.PHONY: ports
ports: ## Show exposed ports
	@echo "Service ports:"
	@echo "  Frontend: http://localhost:3000"
	@echo "  Backend:  http://localhost:8000"
	@echo ""
	@docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
