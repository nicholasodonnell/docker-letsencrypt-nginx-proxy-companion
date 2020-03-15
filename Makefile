include .env

SHELL := /bin/bash
DOCKER_COMPOSE_NETWORKS_FILE := docker-compose.networks.yml
DOCKER_COMPOSE_NGINX_GEN_FILE := ./nginx-gen/docker-compose.nginx-gen.yml
DOCKER_COMPOSE_NGINX_LETSENCRYPT_FILE := ./nginx-letsencrypt/docker-compose.nginx-letsencrypt.yml
DOCKER_COMPOSE_NGINX_WEB_FILE := ./nginx-web/docker-compose.nginx-web.yml
PROJECT_DIRECTORY := $(shell pwd)
PROJECT_NAME := $(if $(PROJECT_NAME),$(PROJECT_NAME),docker-letsencrypt-nginx-proxy-companion)

define DOCKER_COMPOSE_ARGS
	--file ${DOCKER_COMPOSE_NETWORKS_FILE} \
	--file ${DOCKER_COMPOSE_NGINX_GEN_FILE} \
	--file ${DOCKER_COMPOSE_NGINX_LETSENCRYPT_FILE} \
	--file ${DOCKER_COMPOSE_NGINX_WEB_FILE} \
	--log-level ERROR \
	--project-directory $(PROJECT_DIRECTORY) \
	--project-name $(PROJECT_NAME)
endef

help: ## usage
	@cat Makefile | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean: ## remove images & containers
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--rmi all \
			--volumes

down: ## bring down
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--volumes

exec: ## run a command against a running service
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		exec \
			$(service) \
				$(cmd)

logs: ## view the logs of one or more running services
ifndef file
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service)
else
	@echo "logging output to $(file)";
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service) > $(file)
endif

network: ## create external network
	docker network create $(EXTERNAL_NETWORK) $(EXTERNAL_NETWORK_OPTIONS)

ps: ## lists running services
	@docker ps \
		--format {{.Names}}

pull: ## pull images
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		pull \
			--ignore-pull-failures

restart: ## restart a service
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		restart \
			$(service)

restart-nginx: ## restart nginx
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		exec \
			nginx-web \
				nginx -s reload

stop: ## stop a service
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		stop \
			$(service)

up: ## bring up
ifndef service
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans
else
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			$(service)
endif

.PHONY: \
	help \
	clean \
	down \
	exec \
	logs \
	ps \
	pull \
	restart \
	restart-nginx \
	stop \
	up
