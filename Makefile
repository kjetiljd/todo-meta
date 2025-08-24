.PHONY: $(shell sed -n -e '/^$$/ { n ; /^[^ .\#][^ ]*:/ { s/:.*$$// ; p ; } ; }' $(MAKEFILE_LIST))

root_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
meta_project := $(notdir $(patsubst %/,%,$(root_dir)))

help: # Extracts make targets with doble-hash comments and prints them
	@grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/ : /' | while IFS=' : ' read -r cmd desc; do \
		printf "\033[36m%-20s\033[0m %s\n" "$$cmd" "$$desc"; \
	done

meta-update: ## Clone any repos that exist in your .meta file but aren't cloned locally
	@meta git update

pull: ## Run git pull --all --rebase --autostash on all repos
	@meta exec "git pull --all --rebase --autostash" --parallel

build: ## Build all sub-projects with make build
	@meta exec "make build" --exclude "$(meta_project)"

test: ## Test all sub-projects with make test
	@meta exec "make test" --exclude "$(meta_project)"

list-local-commits: ## shows local, unpushed, commits
	@meta exec "git log --oneline origin/HEAD..HEAD | cat"

up: ## Start all services in background
	docker-compose up -dma
	$(MAKE) urls

up-build: ## Build and start all services in background
	docker-compose up --build -d
	$(MAKE) urls

down: ## Stop all services
	docker-compose down

restart: down up ## Restart all services

rebuild: down up-build ## Restart all services with rebuild

logs: ## View service logs
	docker-compose logs -f

status: ## Show service status
	docker-compose ps

urls: ## Show service URLs and ports
	@echo "Service URLs:"
	@docker-compose ps --format "table {{.Name}}\t{{.Ports}}" | grep -E "(meta-todo-|Name)" | \
	sed 's/meta-todo-frontend.*0.0.0.0:\([0-9]*\)->80.*/  Frontend: http:\/\/localhost:\1/' | \
	sed 's/meta-todo-backend.*0.0.0.0:\([0-9]*\)->8080.*/  Backend:  http:\/\/localhost:\1/' | \
	sed 's/meta-todo-sorter.*0.0.0.0:\([0-9]*\)->3001.*/  Sorter:   http:\/\/localhost:\1/' | \
	grep -v "Name\|Ports"
