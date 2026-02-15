## .rhiza/make.d/quality.mk - Quality and Formatting
# This file provides targets for code quality checks, linting, and formatting.

# Declare phony targets (they don't produce files)
.PHONY: fmt lint vet tidy check-fmt

##@ Quality and Formatting

fmt: install-uv ## run pre-commit hooks for formatting and linting
	@${UVX_BIN} pre-commit run --all-files

check-fmt: install-go ## check if Go code is formatted
	@printf "${BLUE}[INFO] Checking Go code formatting...${RESET}\n"
	@UNFORMATTED=$$(gofmt -l .); \
	if [ -n "$$UNFORMATTED" ]; then \
	  printf "${RED}[ERROR] The following files are not formatted:${RESET}\n"; \
	  echo "$$UNFORMATTED"; \
	  printf "${YELLOW}[INFO] Run 'make fmt' to format them${RESET}\n"; \
	  exit 1; \
	else \
	  printf "${GREEN}[PASS] All Go files are properly formatted${RESET}\n"; \
	fi

lint: build ## run golangci-lint
	@printf "${BLUE}[INFO] Running golangci-lint...${RESET}\n"
	@if command -v golangci-lint >/dev/null 2>&1; then \
	  golangci-lint run ./...; \
	elif [ -x "$(shell go env GOPATH)/bin/golangci-lint" ]; then \
	  $(shell go env GOPATH)/bin/golangci-lint run ./...; \
	else \
	  printf "${YELLOW}[WARN] golangci-lint not found, attempting to install...${RESET}\n"; \
	  $(GO_BIN) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
	  $(shell go env GOPATH)/bin/golangci-lint run ./...; \
	fi

vet: build ## run go vet
	@printf "${BLUE}[INFO] Running go vet...${RESET}\n"
	@$(GO_BIN) vet ./...

tidy: install-go ## tidy go.mod and go.sum
	@printf "${BLUE}[INFO] Tidying go.mod...${RESET}\n"
	@$(GO_BIN) mod tidy

all: build fmt vet lint test ## run all quality checks and tests
