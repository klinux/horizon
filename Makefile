VERSION=1.0.0

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
.DEFAULT_GOAL := help

# DOCKER TASKS
dev: ## build image
	docker build -t horizon-dev -f Dockerfile-dev .
	docker-compose -f docker-compose-dev.yaml up

stopd: ## stop dev
	docker-compose -f docker-compose-dev.yaml down

hom: ## execute hom
	docker-compose up

stoph: ## stop hom
	docker-compose down

image: ## horizon prod
	docker build --rm -t horizon-cloudwise:${VERSION} .

tag: ## create tag
	docker tag horizon-cloudwise:${VERSION} klinux/horizon:${VERSION}

push: ## push image
	docker push klinux/horizon:${VERSION}

git: # create tag
	#git push --delete origin 15.3.2
	git add .
	git commit -m "Final release cloudwise"
	git push
	git tag -a 15.3.2 -m "Update theme"
	git push origin 15.3.2
	git tag -d 15.3.2
