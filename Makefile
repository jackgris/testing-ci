# Colors for help output
BOLD := \033[1m
GREEN := \033[32m
BLUE := \033[34m
CYAN := \033[36m
RESET := \033[0m

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=golangci-lint fmt
GOLINT=golangci-lint

# Binary name
BINARY_NAME=main
BINARY_PATH=./cmd/api

# Docker
DOCKER_IMAGE=testing-ci
DOCKER_TAG=latest

.PHONY: all build clean test coverage deps lint fmt vet docker docker-build docker-run docker-compose-up docker-compose-down help

all: deps fmt lint vet test build

## Build the binary
build:
	@echo -e "$(BOLD)$(BLUE)Building binary...$(RESET)"
	$(GOBUILD) -o $(BINARY_NAME) $(BINARY_PATH)
	@echo -e "$(GREEN)✓ Binary built successfully$(RESET)"

## Clean build artifacts
clean:
	@echo -e "$(BOLD)$(BLUE)Cleaning build artifacts...$(RESET)"
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	@echo -e "$(GREEN)✓ Clean completed$(RESET)"

## Run tests
test:
	@echo -e "$(BOLD)$(BLUE)Running tests...$(RESET)"
	$(GOTEST) -v -race -coverprofile=coverage.out ./...
	@echo -e "$(GREEN)✓ Tests completed$(RESET)"

## Run tests with coverage
coverage: test
	@echo -e "$(BOLD)$(BLUE)Generating coverage report...$(RESET)"
	$(GOCMD) tool cover -html=coverage.out -o coverage.html
	@echo -e "$(GREEN)✓ Coverage report generated$(RESET)"

## Download dependencies
deps:
	@echo -e "$(BOLD)$(BLUE)Downloading dependencies...$(RESET)"
	$(GOMOD) download
	$(GOMOD) tidy
	@echo -e "$(GREEN)✓ Dependencies updated$(RESET)"

## Run linter
lint:
	@echo -e "$(BOLD)$(BLUE)Running linter...$(RESET)"
	$(GOLINT) run --timeout=5m
	@echo -e "$(GREEN)✓ Linting completed$(RESET)"

## Format code
fmt:
	@echo -e "$(BOLD)$(BLUE)Formatting code...$(RESET)"
	$(GOFMT)
	gofumpt -w .
	goimports -w -local github.com/jackgris/testing-ci .
	@echo -e "$(GREEN)✓ Code formatted$(RESET)"

## Run go vet
vet:
	@echo -e "$(BOLD)$(BLUE)Running go vet...$(RESET)"
	$(GOCMD) vet ./...
	@echo -e "$(GREEN)✓ Vet completed$(RESET)"

## Run security check
security:
	@echo -e "$(BOLD)$(BLUE)Running security check...$(RESET)"
	$(GOCMD) run golang.org/x/vuln/cmd/govulncheck@latest ./...
	@echo -e "$(GREEN)✓ Security check completed$(RESET)"

## Build Docker image
docker-build:
	@echo -e "$(BOLD)$(BLUE)Building Docker image...$(RESET)"
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	@echo -e "$(GREEN)✓ Docker image built$(RESET)"

## Run Docker container
docker-run:
	@echo -e "$(BOLD)$(BLUE)Running Docker container...$(RESET)"
	docker run --rm -p 8080:8080 $(DOCKER_IMAGE):$(DOCKER_TAG)

## Start services with docker-compose
docker-compose-up:
	@echo -e "$(BOLD)$(BLUE)Starting services with docker-compose...$(RESET)"
	docker-compose up -d
	@echo -e "$(GREEN)✓ Services started$(RESET)"

## Stop services with docker-compose
docker-compose-down:
	@echo -e "$(BOLD)$(BLUE)Stopping services...$(RESET)"
	docker-compose down
	@echo -e "$(GREEN)✓ Services stopped$(RESET)"

## Start services with docker-compose and view logs
docker-compose-logs:
	@echo -e "$(BOLD)$(BLUE)Starting services with logs...$(RESET)"
	docker-compose up

## Rebuild and start services
docker-compose-rebuild:
	@echo -e "$(BOLD)$(BLUE)Rebuilding and starting services...$(RESET)"
	docker-compose up --build

## Run the application locally
run:
	@echo -e "$(BOLD)$(BLUE)Running application...$(RESET)"
	$(GOBUILD) -o $(BINARY_NAME) $(BINARY_PATH) && ./$(BINARY_NAME)

## Install development tools
tools:
	@echo -e "$(BOLD)$(BLUE)Installing development tools...$(RESET)"
	$(GOCMD) install golang.org/x/tools/cmd/goimports@latest
	$(GOCMD) install golang.org/x/vuln/cmd/govulncheck@latest
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(shell $(GOCMD) env GOPATH)/bin v1.54.2
	@echo -e "$(GREEN)✓ Development tools installed$(RESET)"


## Show help
help:
	@echo ''
	@echo -e '\033[1;34mUsage:\033[0m'
	@echo -e '  \033[1;32mmake\033[0m \033[36m[target]\033[0m'
	@echo ''
	@echo -e '\033[1;34mTargets:\033[0m'
	@awk ' /^[a-zA-Z0-9_.-]+:/ { \
		if (match(lastLine, /^## (.*)/)) { \
			helpCommand = $$1; \
			sub(":", "", helpCommand); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  \033[1;32m%-20s\033[0m %s\n", helpCommand, helpMessage; \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)
