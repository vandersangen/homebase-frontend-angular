# Executables (local)
DOCKER = docker
DOCKER_COMPOSE = docker compose

# Docker containers
PHP_CONTAINER = $(DOCKER_COMPOSE) exec -it phpfpm
ANGULAR_CONTAINER = $(DOCKER_COMPOSE) exec frontend

# Executables
COMPOSER =$(PHP_CONTAINER) composer
CONSOLE = $(PHP_CONTAINER) bin/console
PHPUNIT = $(PHP_CONTAINER) vendor/bin/phpunit

NPM = $(DOCKER_COMPOSE) run frontend npm

# Misc
.DEFAULT_GOAL = help
.PHONY        = help build up start down logs sh composer vendor
MAKEFLAGS     += --no-print-directory

# Environment
ENV ?= dev

## —— 🎵 🐳 The Makefile 🐳 🎵 —————————————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

setup: build start seed logs

## —— Docker 🐳 ————————————————————————————————————————————————————————————————
build: ## Builds the Docker images
	@$(DOCKER_COMPOSE) -f ./docker-compose-dev.yaml build

up: ## Start the docker hub in detached mode (no logs)
	@$(DOCKER_COMPOSE) -f ./docker-compose-dev.yaml up --detach

up-phpfpm:
	@$(DOCKER_COMPOSE) up phpfpm nginx --build --force-recreate --detach

up-phpfpm-test:
	@$(DOCKER_COMPOSE) -f ./docker-compose-test.yaml up phpfpm nginx --build --force-recreate --detach

up-phpfpm-dev:
	@$(DOCKER_COMPOSE) -f ./docker-compose-dev.yaml up phpfpm nginx --build --force-recreate --detach

up-frontend:
	@$(DOCKER_COMPOSE) -f ./docker-compose-dev.yaml up frontend --build --force-recreate --detach

up-frontend-test:
	@$(DOCKER_COMPOSE) -f ./docker-compose-test.yaml up frontend --build --force-recreate --detach

up-frontend-dev:
	@$(DOCKER_COMPOSE) -f ./docker-compose-dev.yaml up frontend --build --force-recreate --detach

up-rebuild: ## Start; --force rebuild
	@$(DOCKER_COMPOSE) -f ./docker-compose-dev.yaml up --build --force-recreate --detach

start: up install build-db ## Start the docker hub in detached mode (no logs)

install: ../homebase-backend/vendor/composer/installed.json install-frontend ## Install project

install-frontend:
	$(ANGULAR_CONTAINER) npm install

down: ## Stop the docker hub
	@$(DOCKER_COMPOSE) down --remove-orphans

logs: ## Show live logs
	@$(DOCKER_COMPOSE) logs --follow

ps: ## Show the running containers
	@$(DOCKER_COMPOSE) ps

ps-dev: ## Show the running containers
	@$(DOCKER_COMPOSE) -f ./docker-compose-dev.yaml ps

phpfpm-login: ## Connect to the PHP container with bash
	@$(PHP_CONTAINER) sh

angular-login: ## Connect to the frontend container with bash
	@$(ANGULAR_CONTAINER) sh

../homebase-backend/vendor/composer/installed.json: ../homebase-backend/composer.lock
	$(COMPOSER) install
	$(PHP_CONTAINER) touch $@

## —— Composer 🧙 ———————————————————————————————————————————————————————————————
composer: ## Run composer, pass the parameter "c=" to run a given command
	@$(eval c ?=)
	@$(COMPOSER) $(c)

console:
	@$(eval c ?=)
	@$(CONSOLE) $(c) --env=$(ENV)

build-db: ## Build database
#	@$(CONSOLE) doctrine:database:create --if-not-exists --env=$(ENV)
#	@$(CONSOLE) doctrine:migrations:migrate -n --env=$(ENV)
#	@$(CONSOLE) messenger:setup-transports -n --env=$(ENV)

seed:
	@#$(CONSOLE) doctrine:fixtures:load -n --env=$(ENV)

clear-cache:
	@$(CONSOLE) cache:clear --env=$(ENV)

rebuild-db: remove-db build-db seed

remove-db:
	@#$(CONSOLE) doctrine:database:drop --force --if-exists --env=$(ENV)

test-%: ENV=ci

test:
	$(ANGULAR_CONTAINER) ng test

test-rebuild-db: rebuild-db

## —— Codestyle 🔍  ————————————————————————————————————————————————————————————————
codestyle: ## Fix codestyle issues
	$(PHP_LAMBDA_CONTAINER) vendor/bin/phpcbf

codestyle-check: ## Check codestyle issues
	$(PHP_CONTAINER) vendor/bin/phpcs

## —— Debugging 🐞  ————————————————————————————————————————————————————————————————
xdebug-toggle:
	$(PHP_CONTAINER) sh ./docker/script/toggle-xdebug.sh
	$(DOCKER_COMPOSE) restart nginx phpfpm

xdebug-enable:
	$(PHP_CONTAINER) sh ./docker/script/enable-xdebug.sh
	$(DOCKER_COMPOSE) restart nginx phpfpm

xdebug-disable:
	$(PHP_CONTAINER) sh ./docker/script/disable-xdebug.sh
	$(DOCKER_COMPOSE) restart nginx phpfpm

## —— Docker compose push 📦  ————————————————————————————————————————————————————————————————
docker-push:
	$(DOCKER) push larsvandersangen/homebase-frontend
	$(DOCKER) push larsvandersangen/homebase-backend

docker-push-dev:
	$(DOCKER) push larsvandersangen/homebase-backend:dev-latest
	$(DOCKER) push larsvandersangen/homebase-fontend:dev-latest

docker-push-test:
	$(DOCKER) push larsvandersangen/homebase-backend:test-latest
	$(DOCKER) push larsvandersangen/homebase-fontend:test-latest

docker-push-phpfpm:
	$(DOCKER) push larsvandersangen/homebase-backend

docker-push-phpfpm-test:
	$(DOCKER) push larsvandersangen/homebase-backend:test-latest

docker-push-phpfpm-dev:
	$(DOCKER) push larsvandersangen/homebase-backend:dev-latest

docker-push-frontend:
	$(DOCKER) push larsvandersangen/homebase-frontend

docker-push-frontend-test:
	$(DOCKER) push larsvandersangen/homebase-frontend:test-latest

docker-push-frontend-dev:
	$(DOCKER) push larsvandersangen/homebase-frontend:dev-latest

## —— Kubernetes  🐙  ————————————————————————————————————————————————————————————————
k8s-deploy-dev:
	kubectl apply -f ./k8s/ingress-dev
	kubectl apply -f ./k8s/homebase-backend-frontend

k8s-deploy-test:
	kubectl apply -f ./k8s/homebase-backend-frontend-test -n $(K8S_NAMESPACE)
	# Enforce restart for the pods
	kubectl rollout restart -f ./k8s/homebase-backend-frontend-test/homebase-backend-deployment.yaml -n $(K8S_NAMESPACE)
	kubectl apply -f ./k8s/ingress-test -n $(K8S_NAMESPACE)
	kubectl apply -f ./k8s/certmanager-test -n $(K8S_NAMESPACE)

k8s-deploy-prod:
	kubectl apply -f ./k8s/homebase-backend-frontend-prod -n $(K8S_NAMESPACE)
	# Enforce restart for the pods
	kubectl rollout restart -f ./k8s/homebase-backend-frontend-prod/homebase-backend-deployment.yaml -n $(K8S_NAMESPACE)
	kubectl apply -f ./k8s/ingress-prod -n $(K8S_NAMESPACE)
	kubectl apply -f ./k8s/certmanager-prod -n $(K8S_NAMESPACE)
