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