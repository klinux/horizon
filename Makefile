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
	docker build --rm -t horizon-cloudwise .

push: ## push image
	docker tag horizon-cloudwise klinux/horizon
	docker push klinux/horizon

git: # create tag
	git add .
	git commit -m "Final release cloudwise"
	git push
	#git push --delete origin 15.3.2
	#git tag -d 15.3.2
	git tag -a 15.3.2 -m "Update theme"
	git push origin 15.3.2