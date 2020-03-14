include .env

SHELL := /bin/bash
DOCKER_COMPOSE_FILE := docker-compose.yml
PROJECT_DIRECTORY := $(shell pwd)
PROJECT_NAME := $(if $(PROJECT_NAME),$(PROJECT_NAME),docker-letsencrypt-nginx-proxy-companion)

define DOCKER_COMPOSE_ARGS
	--file ${DOCKER_COMPOSE_FILE} \
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

network: ## create network
	docker network create $(NETWORK) $(NETWORK_OPTIONS)

pull: ## pull images
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		pull \
			--ignore-pull-failures

restart: ## restart a service
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
	restart \
		$(service)

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
	pull \
	restart \
	stop \
	up
