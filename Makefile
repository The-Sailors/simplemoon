image_name:="golang-docker"
GO_VERSION=1.20.2
version:=$(shell git rev-parse --short HEAD)
image := registry.heroku.com/ondehoje/web:$(version)

## build simplemon binary
.PHONY: simplemon
simplemon:
	@echo "Building simplemon..."
	@go build -o ./cmd/simplemon/simplemon ./cmd/simplemon

## Start containers
.PHONY: dev/start
dev/start:
	@echo "Starting development server..."
	GO_VERSION=$(GO_VERSION) docker-compose up -d

## Stop containers
.PHONY: dev/stop
dev/stop:
	@echo "Stopping development server..."
	@docker-compose down

.PHONY: dev/logs
dev/logs:
	@echo "Showing logs..."
	@docker-compose logs -f api

#(TODO-jojo) automate this
.PHONY: dev/test
dev/test:
	@echo "Running tests..."


#rebuild golang binary
.PHONY: dev/app
dev/app:
	@echo "Building app..."
	GO_VERSION=$(GO_VERSION) docker api make simplemon

## Build image service
.PHONY: image
image:
	docker build . \
	--build-arg GO_VERSION=$(GO_VERSION) \
	-t $(image)

## Display help for all targets
.PHONY: help
help:
	@awk '/^.PHONY: / { \
		msg = match(lastLine, /^## /); \
			if (msg) { \
				cmd = substr($$0, 9, 100); \
				msg = substr(lastLine, 4, 1000); \
				printf "  ${GREEN}%-30s${RESET} %s\n", cmd, msg; \
			} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)