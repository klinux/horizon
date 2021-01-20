.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

# DOCKER TASKS
dev: ## build image
	docker build -t horizon -f Dockerfile-dev .
	docker-compose -f docker-compose-dev.yaml up

stopd: ## stop dev
	docker-compose -f docker-compose-dev.yaml down

hom: ## execute hom
	docker-compose up

stoph: ## stop hom
	docker-compose down

image: ## horizon prod
	docker build --no-cache --rm -t horizon-cloudwise .

