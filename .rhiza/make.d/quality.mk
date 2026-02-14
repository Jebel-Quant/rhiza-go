## .rhiza/make.d/quality.mk - Quality and Formatting
# This file provides targets for code quality checks, linting, and formatting.

# Declare phony targets (they don't produce files)
.PHONY: fmt lint vet tidy check-fmt

##@ Quality and Formatting

fmt: install-go ## format Go code
	@printf "${BLUE}[INFO] Formatting Go code...${RESET}\n"
	@$(GO_BIN) fmt ./...
	@gofmt -s -w .
	@if command -v goimports >/dev/null 2>&1; then \
	  goimports -w .; \
	else \
	  printf "${YELLOW}[WARN] goimports not found, skipping import formatting${RESET}\n"; \
	fi

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

lint: install-go ## run golangci-lint
	@printf "${BLUE}[INFO] Running golangci-lint...${RESET}\n"
	@if command -v golangci-lint >/dev/null 2>&1; then \
	  golangci-lint run ./...; \
	else \
	  printf "${YELLOW}[WARN] golangci-lint not found, attempting to install...${RESET}\n"; \
	  $(GO_BIN) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest; \
	  golangci-lint run ./...; \
	fi

vet: install-go ## run go vet
	@printf "${BLUE}[INFO] Running go vet...${RESET}\n"
	@$(GO_BIN) vet ./...

tidy: install-go ## tidy go.mod and go.sum
	@printf "${BLUE}[INFO] Tidying go.mod...${RESET}\n"
	@$(GO_BIN) mod tidy

all: fmt vet lint test ## run all quality checks and tests
