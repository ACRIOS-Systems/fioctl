COMMIT:=$(shell git log -1 --pretty=format:%h)$(shell git diff --quiet || echo '_')

# Use linker flags to provide commit info
LDFLAGS=-ldflags "-X=github.com/foundriesio/fioctl/subcommands/version.Commit=$(COMMIT)"

linter:=$(shell which golangci-lint 2>/dev/null || echo $(HOME)/go/bin/golangci-lint)

build: fioctl-linux-amd64 fioctl-windows-amd64 fioctl-darwin-amd64
	@true

fioctl-linux-amd64:
fioctl-linux-armv7:
fioctl-windows-amd64:
fioctl-darwin-amd64:
fioctl-%:
	GOOS=$(shell echo $* | cut -f1 -d\- ) \
	GOARCH=$(shell echo $* | cut -f2 -d\-) \
		go build $(LDFLAGS) -o bin/$@ main.go

format:
	@gofmt -l  -w ./
check:
	@test -z $(shell gofmt -l ./ | tee /dev/stderr) || echo "[WARN] Fix formatting issues with 'make fmt'"
	@test -x $(linter) || (echo "Please install linter from https://github.com/golangci/golangci-lint/releases/tag/v1.25.1 to $(HOME)/go/bin")
	$(linter) run

# Use the image for Dockerfile.build to build and install the tool.
container-init:
	docker build -t fioctl-build -f Dockerfile.build .

container-build:
	docker run --rm -ti -v $(shell pwd):/fioctl fioctl-build make build

