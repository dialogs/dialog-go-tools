.DEFAULT_GOAL=all

TAG            :=1.0.0
NAME_PREFIX    :=go-tools
DOCKER_REGISTRY?=

.PHONY: all
all: docker-protoc-build

.PHONY: docker-protoc-build
docker-protoc-build:
	$(eval $@_image := ${DOCKER_REGISTRY}${NAME_PREFIX}-protoc:${TAG})
	-docker rm -f `docker ps -a -q --filter=ancestor=${$@_image}`
	-docker rmi -f `docker images -q ${$@_image}`
	-docker rmi $(docker images -f "dangling=true" -q)

	docker build -f ./Dockerfile-protoc --tag ${$@_image} .

