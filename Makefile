.PHONY: help up down logs restart clean plugin-dev plugin-build grafana mongodb grafana-logs mongodb-logs

# Default target
help:
	@echo "PingTower Development Commands:"
	@echo "  make up              - Start all services"
	@echo "  make down            - Stop all services"
	@echo "  make logs            - Show logs"
	@echo "  make restart         - Restart all services"
	@echo "  make grafana         - Start only Grafana"
	@echo "  make mongodb         - Start only MongoDB"
	@echo "  make grafana-logs    - Show Grafana logs"
	@echo "  make mongodb-logs    - Show MongoDB logs"
	@echo "  make plugin-dev      - Start plugin development mode"
	@echo "  make plugin-build    - Build plugin for production"
	@echo "  make clean           - Clean all data"

# Docker commands
up:
	cd infrastructure/docker && docker compose up -d

down:
	cd infrastructure/docker && docker compose down

logs:
	cd infrastructure/docker && docker compose logs -f

restart: down up

# Grafana specific
grafana:
	cd infrastructure/docker && docker compose up -d grafana

grafana-logs:
	cd infrastructure/docker && docker compose logs -f grafana

# MongoDB specific
mongodb:
	cd infrastructure/docker && docker compose up -d mongodb

mongodb-logs:
	cd infrastructure/docker && docker compose logs -f mongodb

# Plugin development
plugin-dev:
	cd plugin && pnpm install && pnpm run dev

plugin-build:
	cd plugin && pnpm install && pnpm run build

plugin-restart: plugin-build
	cd infrastructure/docker && docker compose restart grafana

# Cleanup
clean:
	cd infrastructure/docker && docker compose down -v
	rm -rf plugin/dist plugin/node_modules

# Quick access URLs
urls:
	@echo "Grafana:    http://localhost:3000 (admin/admin)"
	@echo "MongoDB:    mongodb://localhost:27017 (admin/admin)"
