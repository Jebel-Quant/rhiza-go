## .rhiza/make.d/bootstrap.mk - Bootstrap and Installation
# This file provides targets for setting up the development environment,
# installing dependencies, and cleaning project artifacts.

# Declare phony targets (they don't produce files)
.PHONY: install-go install-uv install build clean pre-install post-install

# Hook targets (double-colon rules allow multiple definitions)
pre-install:: ; @:
post-install:: ; @:

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
install-uv: ## ensure uv/uvx is installed
	# Ensure the ${INSTALL_DIR} folder exists
	@mkdir -p ${INSTALL_DIR}

	# Install uv/uvx only if they are not already present in PATH or in the install dir
	@if command -v uv >/dev/null 2>&1 && command -v uvx >/dev/null 2>&1; then \
	  :; \
	elif [ -x "${INSTALL_DIR}/uv" ] && [ -x "${INSTALL_DIR}/uvx" ]; then \
	  printf "${BLUE}[INFO] uv and uvx already installed in ${INSTALL_DIR}, skipping.${RESET}\n"; \
	else \
	  printf "${BLUE}[INFO] Installing uv and uvx into ${INSTALL_DIR}...${RESET}\n"; \
	  if ! curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR="${INSTALL_DIR}" sh >/dev/null 2>&1; then \
	    printf "${RED}[ERROR] Failed to install uv${RESET}\n"; \
	    exit 1; \
	  fi; \
	fi


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
	
	@$(MAKE) post-install

build: install ## build Go binaries
	@printf "${BLUE}[INFO] Building Go binaries...${RESET}\n"
	@$(GO_BIN) build -v ./...
	@mkdir -p bin
	@$(GO_BIN) build -o bin/ ./cmd/...
	@printf "${GREEN}[PASS] Binaries built to bin/${RESET}\n"

clean: ## Clean project artifacts and stale local branches
	@printf "%bCleaning project...%b\n" "$(BLUE)" "$(RESET)"
	
	# Clean Go build cache and test cache
	@$(GO_BIN) clean -cache -testcache -modcache || true

	# Remove ignored files/directories, but keep .env files, tested with futures project
	@git clean -d -X -f \
		-e '!.env' \
		-e '!.env.*'
	
	# Remove build artifacts
	@rm -rf \
		dist \
		build \
		coverage.out \
		coverage.html \
		test-output.json \
		test-report.xml \
		test-report.html \
		*.test \
		*.prof
	
	@printf "%bRemoving local branches with no remote counterpart...%b\n" "$(BLUE)" "$(RESET)"
	
	@git fetch --prune
	
	@git branch -vv | awk '/: gone]/{print $$1}' | xargs -r git branch -D
