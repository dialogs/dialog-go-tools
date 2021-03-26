# Golang tools

## hub.docker.com

Push to https://hub.docker.com/

```bash
docker login -u <login>
DOCKER_REGISTRY=<login>/ DOCKER_PUSH=true make
```

## How to use docker images in Makefile

Required variables:

```makefile
PROJECT:=$(subst ${GOPATH}/src/,,$(shell pwd))
GOPRIVATE?=
```

Use examples:

## protoc

```makefile
.PHONY: proto
proto:
	target=api/golang && \
	rm -rf $$target && \
	rm -f api/api.swagger.json && \
	mkdir -p $$target && \
	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-v "${GOPATH}/pkg:/go/pkg" \
	-e "GOPRIVATE=${GOPRIVATE}" \
	-e "GOFLAGS=" \
	-w "/go/src/${PROJECT}" \
	--user $(shell id -u):$(shell id -g) \
	dialogs/go-tools-protoc:latest \
	protoc \
	-I=${$@_source} \
	-I=vendor \
	--grpc-gateway_out=logtostderr=true:$$target \
	--openapiv2_out=allow_merge=true,merge_file_name=api:api \
	--go_out=plugins=grpc,\
	Mgoogle/protobuf/empty.proto=github.com/gogo/protobuf/types,\
	:$$target api/proto/*/*.proto
```

## linter

```makefile
.PHONY: lint
lint:
	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-v "${GOPATH}/pkg:/go/pkg" \
	-e "GOPRIVATE=${GOPRIVATE}" \
	-e "GOFLAGS=" \
	-w "/go/src/${PROJECT}" \
	--user $(shell id -u):$(shell id -g) \
	dialogs/go-tools-linter:latest \
	golangci-lint run ./... \
	--config .golangci.yml \
	--color always \
	--verbose
```

## embedded

```makefile
.PHONY: embedded
embedded:
	$(eval $@_target := ${PROJECT}/db/migrations/test)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-v "${GOPATH}/pkg:/go/pkg" \
	-e "GOPRIVATE=${GOPRIVATE}" \
	-e "GOFLAGS=" \
	-w "/go/src/${PROJECT}" \
	dialogs/go-tools-embedded:latest \
	sh -c '\
	rm -fv $($@_target)/static.go && \
	go generate $($@_target)'
```

## mock

```makefile
.PHONY: mock
mock:
	$(eval $@_source := kafka)
	$(eval $@_target := ${$@_source}/mocks)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-v "${GOPATH}/pkg:/go/pkg" \
	-e "GOPRIVATE=${GOPRIVATE}" \
	-e "GOFLAGS=" \
	-w "/go/src/${PROJECT}" \
	dialogs/go-tools-mock:latest \
	sh -c '\
	mockery -name=IReader -dir=${$@_source} -recursive=false -output=$($@_target) && \
	mockery -name=IWriter -dir=${$@_source} -recursive=false -output=$($@_target)'
```


## easyjson

```makefile
.PHONY: easyjson
easyjson:
	$(eval $@_target := pkg)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-v "${GOPATH}/pkg:/go/pkg" \
	-e "GOPRIVATE=${GOPRIVATE}" \
	-e "GOFLAGS=" \
	-w "/go/src/${PROJECT}" \
	dialogs/go-tools-easyjson:latest \
	sh -c '\
	rm -fv ${$@_target}/*_easyjson.go && \
	easyjson -all ${$@_target}/request.go'
```

## avro

```makefile
.PHONY: avro
avro:
	$(eval $@_target := pkg/schemas)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-v "${GOPATH}/pkg:/go/pkg" \
	-e "GOPRIVATE=${GOPRIVATE}" \
	-e "GOFLAGS=" \
	-w "/go/src/${PROJECT}" \
	dialogs/go-tools-avro:latest \
	sh -c '\
	rm -fv ${$@_target}/*.go && \
	gogen-avro --package=schemas ${$@_target} ${$@_target}/*.avsc'
```

## graphql

```makefile
.PHONY: graphql
graphql:
	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-v "${GOPATH}/pkg:/go/pkg" \
	-w "/go/src/${PROJECT}" \
	-e "GOPRIVATE=${GOPRIVATE}" \
	dialogs/go-tools-graphql:latest \
	sh -c '\
	rm -frv ${$@_target}/generated && \
	rm -frv ${$@_target}/model && \
	gqlgen generate --verbose --config=./gqlgen.yml'
```