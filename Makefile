.DEFAULT_GOAL:=help
.PHONY: all help clean build test docker docker-push release version lint fmt vet
SHELL:=/bin/bash

# Binary name
BINARY_NAME:=openvpn_exporter

# Version information
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT_SHA1?=$(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE?=$(shell date -u '+%Y-%m-%dT%H:%M:%SZ')

# Docker settings
DOCKER_IMAGE?=MaxTyutyunnikov/openvpn-exporter
DOCKER_TAG?=$(VERSION)

# Go settings
GOOS?=$(shell go env GOOS)
GOARCH?=$(shell go env GOARCH)
CGO_ENABLED?=0

# Build directories
BUILD_DIR:=build
BIN_DIR:=bin

# All supported platforms
PLATFORMS:=linux/amd64 linux/arm64 darwin/amd64 windows/amd64

help:
	@echo -e "\033[33mUsage:\033[0m\n  make TARGET\n\n\033[33mTargets:\033[0m"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-15s\033[0m %s\n", $$1, $$2}'

## Build:
build: ## Build binary for current platform
	@echo "Building $(BINARY_NAME) for $(GOOS)/$(GOARCH)..."
	@CGO_ENABLED=$(CGO_ENABLED) GOOS=$(GOOS) GOARCH=$(GOARCH) go build \
		-ldflags "-s -w -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.VERSION=$(VERSION) -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.COMMIT_SHA1=$(COMMIT_SHA1) -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.BUILD_DATE=$(BUILD_DATE)" \
		-o $(BIN_DIR)/$(BINARY_NAME)-$(GOOS)-$(GOARCH) .
	@echo "Binary created: $(BIN_DIR)/$(BINARY_NAME)-$(GOOS)-$(GOARCH)"

build-all: ## Build binaries for all supported platforms
	@mkdir -p $(BIN_DIR)
	@for platform in $(PLATFORMS); do \
		GOOS=$$(echo $$platform | cut -d'/' -f1); \
		GOARCH=$$(echo $$platform | cut -d'/' -f2); \
		EXT=""; \
		if [ "$$GOOS" = "windows" ]; then EXT=".exe"; fi; \
		echo "Building for $$GOOS/$$GOARCH..."; \
		CGO_ENABLED=$(CGO_ENABLED) GOOS=$$GOOS GOARCH=$$GOARCH go build \
			-ldflags "-s -w -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.VERSION=$(VERSION) -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.COMMIT_SHA1=$(COMMIT_SHA1) -X github.com/MaxTyutyunnikov/openvpn_exporter/pkg/version.BUILD_DATE=$(BUILD_DATE)" \
			-o $(BIN_DIR)/$(BINARY_NAME)-$$GOOS-$$GOARCH$$EXT .; \
	done
	@echo "All binaries created in $(BIN_DIR)/"

build-linux: ## Build binary for Linux amd64
	@$(MAKE) build GOOS=linux GOARCH=amd64

build-arm: ## Build binary for Linux arm64
	@$(MAKE) build GOOS=linux GOARCH=arm64

## Test:
test: ## Run tests
	@echo "Running tests..."
	@go test -v -race ./...

test-coverage: ## Run tests with coverage report
	@echo "Running tests with coverage..."
	@go test -v -race -coverprofile=$(BUILD_DIR)/coverage.txt -covermode=atomic ./...
	@go tool cover -html=$(BUILD_DIR)/coverage.txt -o $(BUILD_DIR)/coverage.html
	@echo "Coverage report: $(BUILD_DIR)/coverage.html"

## Lint:
lint: ## Run linters
	@echo "Running linters..."
	@golangci-lint run --timeout=5m

fmt: ## Format code
	@echo "Formatting code..."
	@go fmt ./...

vet: ## Run go vet
	@echo "Running go vet..."
	@go vet ./...

## Docker:
docker-build: ## Build Docker image
	@echo "Building Docker image $(DOCKER_IMAGE):$(DOCKER_TAG)..."
	@docker build \
		--build-arg VERSION=$(VERSION) \
		--build-arg COMMIT_SHA1=$(COMMIT_SHA1) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		-t $(DOCKER_IMAGE):latest \
		.

docker-push: ## Push Docker image to registry
	@echo "Pushing Docker image..."
	@docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	@docker push $(DOCKER_IMAGE):latest

docker-multiarch: ## Build and push multi-architecture Docker image
	@echo "Building multi-architecture Docker image..."
	@docker buildx build \
		--build-arg VERSION=$(VERSION) \
		--build-arg COMMIT_SHA1=$(COMMIT_SHA1) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--platform linux/amd64,linux/arm64 \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		-t $(DOCKER_IMAGE):latest \
		--push \
		.

docker-run: ## Run Docker container locally
	@echo "Running Docker container..."
	@docker run -d --rm \
		-p 9176:9176 \
		-v $(PWD)/examples:/etc/openvpn:ro \
		--name openvpn_exporter \
		$(DOCKER_IMAGE):latest \
		-openvpn.status_paths /etc/openvpn/client.status,/etc/openvpn/server2.status

docker-stop: ## Stop running Docker container
	@echo "Stopping Docker container..."
	@docker stop openvpn_exporter 2>/dev/null || true

docker-compose-up: ## Start with docker-compose
	@docker-compose up -d

docker-compose-down: ## Stop docker-compose
	@docker-compose down

## Release:
release: build-all ## Create a release (build all binaries)
	@echo "Creating release $(VERSION)..."
	@mkdir -p $(BUILD_DIR)/release
	@cp $(BIN_DIR)/* $(BUILD_DIR)/release/
	@echo "Release binaries in $(BUILD_DIR)/release/"

version: ## Print version information
	@echo "Version: $(VERSION)"
	@echo "Commit: $(COMMIT_SHA1)"
	@echo "Build Date: $(BUILD_DATE)"
	@echo "Go Version: $(shell go version)"

clean: ## Clean build artifacts
	@echo "Cleaning..."
	@rm -rf $(BIN_DIR) $(BUILD_DIR)
	@go clean -cache
	@echo "Clean complete"

## Development:
deps: ## Download dependencies
	@echo "Downloading dependencies..."
	@go mod download
	@go mod tidy

run: ## Run the exporter locally
	@echo "Running $(BINARY_NAME)..."
	@go run . -openvpn.status_paths examples/client.status,examples/server2.status,examples/server3.status
