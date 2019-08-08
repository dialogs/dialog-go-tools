# Golang tools

## protoc

use example:

```makefile
.PHONY: proto
proto:
	$(eval $@_source := service/test)
	$(eval $@_target := service/test)

	rm -f ${$@_target}/*.pb.go

	docker run -it --rm \
	-v "$(shell pwd):/go/src/github.com/dialogs/dialog-go-lib" \
	-w "/go/src/github.com/dialogs/dialog-go-lib" \
	go-tools-protoc:1.0.0 \
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
	-v "$(shell pwd):/go/src/github.com/dialogs/dialog-go-lib" \
	-w "/go/src/github.com/dialogs/dialog-go-lib" \
	go-tools-linter:1.0.0 \
	golangci-lint run ./... --exclude "is deprecated"
```

## embedded

use example:

```makefile
.PHONY: embedded
embedded:
	$(eval $@_target := github.com/dialogs/dialog-go-lib/db/migrations/test)
	rm -f $($@_target)/static.go

	docker run -it --rm \
	-v "$(shell pwd):/go/src/github.com/dialogs/dialog-go-lib" \
	-w "/go/src/github.com/dialogs/dialog-go-lib" \
	go-tools-embedded:1.0.0 \
	go generate $($@_target)
```

## mock

use example:

```makefile
.PHONY: mock
mock:
	$(eval $@_source := kafka)
	$(eval $@_target := ${$@_source}/mocks)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/github.com/dialogs/dialog-go-lib" \
	-w "/go/src/github.com/dialogs/dialog-go-lib" \
	go-tools-mock:1.0.0 \
	mockery -name=IReader -dir=${$@_source} -recursive=false -output=$($@_target) && \
	mockery -name=IWriter -dir=${$@_source} -recursive=false -output=$($@_target)
```


## easyjson

use example:

```makefile
.PHONY: easyjson
easyjson:
	$(eval $@_target := pkg)

	docker run -it --rm \
	-v "$(shell pwd):/go/src/github.com/dialogs/dialog-go-lib" \
	-w "/go/src/github.com/dialogs/dialog-go-lib" \
	go-tools-easyjson:1.0.0 \
	easyjson -all ${$@_target}/request.go
```