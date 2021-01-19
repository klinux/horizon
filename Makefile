.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

# DOCKER TASKS
build: ## build image
	docker build -t horizon .

up: ## execute container
	docker-compose up

stop: ## stop container
	docker-compose down

cli: ## horizon cli
	docker build -t horizon-cli -f Dockerfile-cli .