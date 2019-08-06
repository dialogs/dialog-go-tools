.DEFAULT_GOAL=all

TAG            :=1.0.0
NAME_PREFIX    :=go-tools
DOCKER_REGISTRY?=
IMAGE          ?=

.PHONY: all
all: docker-protoc-build \
	 docker-linter-build \
	 docker-embedded-build

.PHONY: docker-protoc-build
docker-protoc-build:
	$(eval $@_image := ${DOCKER_REGISTRY}${NAME_PREFIX}-protoc:${TAG})
	IMAGE=${$@_image} $(MAKE) clear

	docker build -f ./Dockerfile-protoc --tag ${$@_image} .

.PHONY: docker-linter-build
docker-linter-build:
	$(eval $@_image := ${DOCKER_REGISTRY}${NAME_PREFIX}-linter:${TAG})
	IMAGE=${$@_image} $(MAKE) clear

	docker build -f ./Dockerfile-linter --tag ${$@_image} .

.PHONY: docker-embedded-build
docker-embedded-build:
	$(eval $@_image := ${DOCKER_REGISTRY}${NAME_PREFIX}-embedded:${TAG})
	IMAGE=${$@_image} $(MAKE) clear

	docker build -f ./Dockerfile-embedded --tag ${$@_image} .

.PHONY: clear
clear:
ifneq (${IMAGE},)
	@echo "clear image: " ${IMAGE}
	-docker rm -f `docker ps -a -q --filter=ancestor=${IMAGE}`
	-docker rmi -f `docker images -q ${IMAGE}`
	-docker rmi $(docker images -f "dangling=true" -q)
endif