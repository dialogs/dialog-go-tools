.DEFAULT_GOAL=build-all

DOCKER_REGISTRY?=
DOCKER_PUSH    ?=

TAG_LIST    := 1.0.6 latest
IMG_LIST    := graphql protoc linter embedded mock easyjson avro
NAME_PREFIX := go-tools

# Do not set. Used for target
NAME  ?=
IMAGE ?=
TAG   ?=

.PHONY: build-all
build-all:
	$(foreach tag,$(TAG_LIST), \
	TAG=${tag} \
	$(MAKE) -j 1 build-tag;)

.PHONY: build-tag
build-tag:
	$(foreach name,$(IMG_LIST), \
	NAME=${name} \
	IMAGE=${DOCKER_REGISTRY}${NAME_PREFIX}-${name}:${TAG} \
	$(MAKE) -j 1 build-image;)

.PHONY: build-image
build-image:
	@echo "clear image: " ${IMAGE}
	-docker rm -f $(shell docker ps -a -q --filter=ancestor=${IMAGE})
	-docker rmi -f $(shell docker images -q ${IMAGE})
	-docker rmi $(shell docker images -f "dangling=true" -q)

	docker build -f ./Dockerfile-${NAME} --tag ${IMAGE} .

ifneq (${DOCKER_PUSH},)
	docker push ${IMAGE}
endif