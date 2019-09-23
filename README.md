# Golang tools

```makefile
PROJECT:= $(subst ${GOPATH}/src/,,$(shell pwd))
```

## protoc

use example:

```makefile
.PHONY: proto
proto:
	$(eval $@_source := service/test)
	$(eval $@_target := service/test)

	rm -f ${$@_target}/*.pb.go

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-w "/go/src/${PROJECT}" \
	go-tools-protoc:latest \
	protoc \
	-I=${$@_source} \
	-I=vendor \
	--gogofaster_out=plugins=grpc,\
	Mgoogle/protobuf/empty.proto=github.com/gogo/protobuf/types,\
	:${$@_target} \
	${$@_source}/*.proto
```

## linter

use example:

```makefile
.PHONY: linter
linter:
	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-w "/go/src/${PROJECT}" \
	go-tools-linter:latest \
	golangci-lint run ./... --exclude "is deprecated"
```

## embedded

use example:

```makefile
.PHONY: embedded
embedded:
	$(eval $@_target := ${PROJECT}/db/migrations/test)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-w "/go/src/${PROJECT}" \
	go-tools-embedded:latest \
	sh -c '\
	rm -fv $($@_target)/static.go && \
	go generate $($@_target)'
```

## mock

use example:

```makefile
.PHONY: mock
mock:
	$(eval $@_source := kafka)
	$(eval $@_target := ${$@_source}/mocks)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-w "/go/src/${PROJECT}" \
	go-tools-mock:latest \
	sh -c '\
	mockery -name=IReader -dir=${$@_source} -recursive=false -output=$($@_target) && \
	mockery -name=IWriter -dir=${$@_source} -recursive=false -output=$($@_target)'
```


## easyjson

use example:

```makefile
.PHONY: easyjson
easyjson:
	$(eval $@_target := pkg)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-w "/go/src/${PROJECT}" \
	go-tools-easyjson:latest \
	sh -c '\
	rm -fv ${$@_target}/*_easyjson.go && \
	easyjson -all ${$@_target}/request.go'
```

## avro

use example:

```makefile
.PHONY: avro
avro:
	$(eval $@_target := pkg/schemas)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/${PROJECT}" \
	-w "/go/src/${PROJECT}" \
	go-tools-avro:latest \
	sh -c '\
	rm -fv ${$@_target}/*.go && \
	gogen-avro --package=schemas ${$@_target} ${$@_target}/*.avsc'
```