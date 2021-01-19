.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

# DOCKER TASKS
dev: ## build image
	docker build -t horizon .
	docker-compose -f docker-file-dev up

up: ## execute dev
	docker-compose up

down: ## stop dev
	docker-compose down
	docker-compose -f docker-file-dev down

prod: ## horizon prod
	docker build --rm -t horizon-cloudwise -f Dockerfile-prod .

