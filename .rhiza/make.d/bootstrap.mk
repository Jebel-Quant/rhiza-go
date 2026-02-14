## .rhiza/make.d/bootstrap.mk - Bootstrap and Installation
# This file provides targets for setting up the development environment,
# installing dependencies, and cleaning project artifacts.

# Declare phony targets (they don't produce files)
.PHONY: install-go install clean pre-install post-install

# Hook targets (double-colon rules allow multiple definitions)
pre-install:: ; @:
post-install:: ; @:

# Read Go version from .go-version (single source of truth)
GO_VERSION ?= $(shell cat .go-version 2>/dev/null || echo "1.23")
export GO_VERSION

# Go binary location
GO_BIN ?= $(shell command -v go 2>/dev/null || echo "go")

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

install: pre-install install-go ## install Go dependencies
	@printf "${BLUE}[INFO] Installing Go dependencies...${RESET}\n"
	
	# Download dependencies
	@if [ -f "go.mod" ]; then \
	  $(GO_BIN) mod download || { printf "${RED}[ERROR] Failed to download dependencies${RESET}\n"; exit 1; }; \
	  $(GO_BIN) mod tidy || { printf "${RED}[ERROR] Failed to tidy dependencies${RESET}\n"; exit 1; }; \
	  printf "${BLUE}[INFO] Dependencies installed successfully${RESET}\n"; \
	else \
	  printf "${YELLOW}[WARN] No go.mod found, skipping install${RESET}\n"; \
	fi
	
	# Install development tools
	@printf "${BLUE}[INFO] Installing development tools...${RESET}\n"
	@$(GO_BIN) install github.com/golangci/golangci-lint/cmd/golangci-lint@latest || true
	@$(GO_BIN) install golang.org/x/tools/cmd/goimports@latest || true
	@$(GO_BIN) install golang.org/x/vuln/cmd/govulncheck@latest || true
	@$(GO_BIN) install github.com/securego/gosec/v2/cmd/gosec@latest || true
	
	@$(MAKE) post-install

clean: ## Clean project artifacts and stale local branches
	@printf "%bCleaning project...%b\n" "$(BLUE)" "$(RESET)"
	
	# Clean Go build cache and test cache
	@$(GO_BIN) clean -cache -testcache -modcache || true
	
	# Remove build artifacts
	@rm -rf \
		dist \
		build \
		coverage.out \
		coverage.html \
		*.test \
		*.prof
	
	@printf "%bRemoving local branches with no remote counterpart...%b\n" "$(BLUE)" "$(RESET)"
	
	@git fetch --prune
	
	@git branch -vv | awk '/: gone]/{print $$1}' | xargs -r git branch -D
