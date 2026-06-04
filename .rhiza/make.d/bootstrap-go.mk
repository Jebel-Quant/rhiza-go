## .rhiza/make.d/bootstrap-go.mk - Go Bootstrap and Installation
# This file provides Go-specific targets for setting up the development environment,
# installing Go dependencies, building binaries, and related tasks.

# Declare phony targets (they don't produce files)
.PHONY: install-go install build

# Read Go version from .go-version (single source of truth)
GO_VERSION ?= $(shell cat .go-version 2>/dev/null || echo "1.23")
export GO_VERSION

# Go binary location
GO_BIN ?= $(shell command -v go 2>/dev/null || echo "go")

# GOPROXY: primary proxy with direct VCS fallback for transient failures or VPN environments.
# Override with an internal proxy if needed: make install GOPROXY=https://my.proxy.internal,direct
GOPROXY ?= https://proxy.golang.org,direct
export GOPROXY

##@ Bootstrap
install-go: ## ensure Go is installed at the required version
	@printf "${BLUE}[INFO] Checking Go installation...${RESET}\n"
	@if command -v go >/dev/null 2>&1; then \
	  INSTALLED_VERSION=$$(go version | awk '{print $$3}' | sed 's/go//'); \
	  REQUIRED_VERSION=$$(cat .go-version); \
	  if [ "$$INSTALLED_VERSION" != "$$REQUIRED_VERSION" ]; then \
	    printf "${YELLOW}[WARN] Go version mismatch: installed=$$INSTALLED_VERSION, required=$$REQUIRED_VERSION${RESET}\n"; \
	    printf "${YELLOW}[INFO] Please install Go $$REQUIRED_VERSION from https://go.dev/dl/${RESET}\n"; \
	  else \
	    printf "${BLUE}[INFO] Go $$INSTALLED_VERSION is installed${RESET}\n"; \
	  fi; \
	else \
	  printf "${RED}[ERROR] Go is not installed${RESET}\n"; \
	  printf "${YELLOW}[INFO] Please install Go from https://go.dev/dl/${RESET}\n"; \
	  exit 1; \
	fi

install: pre-install install-go install-uv ## install Go dependencies
	@printf "${BLUE}[INFO] Installing Go dependencies...${RESET}\n"

	# Download dependencies
	@if [ -f "go.mod" ]; then \
	  $(GO_BIN) mod download || { printf "${RED}[ERROR] Failed to download dependencies${RESET}\n"; exit 1; }; \
	  $(GO_BIN) mod tidy || { printf "${RED}[ERROR] Failed to tidy dependencies${RESET}\n"; exit 1; }; \
	  printf "${BLUE}[INFO] Dependencies installed successfully${RESET}\n"; \
	else \
	  printf "${YELLOW}[WARN] No go.mod found, skipping install${RESET}\n"; \
	fi

	# Install development tools (run outside module dir to avoid go.mod/go.sum interaction)
	@printf "${BLUE}[INFO] Installing development tools...${RESET}\n"
	@cd /tmp && $(GO_BIN) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest || true
	@cd /tmp && $(GO_BIN) install golang.org/x/tools/cmd/goimports@latest || true
	@cd /tmp && $(GO_BIN) install golang.org/x/vuln/cmd/govulncheck@latest || true
	@cd /tmp && $(GO_BIN) install github.com/securego/gosec/v2/cmd/gosec@latest || true
	@cd /tmp && $(GO_BIN) install gotest.tools/gotestsum@latest || true
	@cd /tmp && $(GO_BIN) install github.com/princjef/gomarkdoc/cmd/gomarkdoc@latest || true
	@cd /tmp && $(GO_BIN) install github.com/goreleaser/goreleaser/v2@latest || true
	@curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b "$$($(GO_BIN) env GOPATH)/bin" || true

	# Install pre-commit hooks if config exists (uses uvx, installed above)
	@if [ -f .pre-commit-config.yaml ]; then \
	  printf "${BLUE}[INFO] Installing pre-commit hooks...${RESET}\n"; \
	  $(UVX_BIN) pre-commit install; \
	fi

	@$(MAKE) post-install

build: install ## build Go binaries
	@printf "${BLUE}[INFO] Building Go binaries...${RESET}\n"
	@$(GO_BIN) build -v ./...
	@mkdir -p bin
	@$(GO_BIN) build -o bin/ ./cmd/...
	@printf "${GREEN}[PASS] Binaries built to bin/${RESET}\n"
