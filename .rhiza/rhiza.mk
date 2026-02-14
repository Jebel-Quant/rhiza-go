## Makefile for jebel-quant/rhiza-go
# (https://github.com/jebel-quant/rhiza-go)
#
# Purpose: Developer tasks for Go projects (install, test, docs, lint).
# Lines with `##` after a target are parsed into help text,
# and lines starting with `##@` create section headers in the help output.
#
# Colours for pretty output in help messages
BLUE := \033[36m
BOLD := \033[1m
GREEN := \033[32m
RED := \033[31m
YELLOW := \033[33m
RESET := \033[0m

# Default goal when running `make` with no target
.DEFAULT_GOAL := help

# Declare phony targets (they don't produce files)
.PHONY: \
	help \
	post-bump \
	post-install \
	post-release \
	post-sync \
	post-validate \
	pre-bump \
	pre-install \
	pre-release \
	pre-sync \
	pre-validate \
	print-logo \
	readme \
	summarise-sync \
	sync \
	validate \
	version-matrix

# we need absolute paths!
INSTALL_DIR ?= $(abspath ./bin)

# Read Go version from .go-version (single source of truth)
GO_VERSION ?= $(shell cat .go-version 2>/dev/null || echo "1.23")
export GO_VERSION

# Read Rhiza version from .rhiza/.rhiza-version (single source of truth for rhiza-tools)
RHIZA_VERSION ?= $(shell cat .rhiza/.rhiza-version 2>/dev/null || echo "0.10.2")
export RHIZA_VERSION

# Go binary
GO_BIN ?= $(shell command -v go 2>/dev/null || echo "go")

# Load .rhiza/.env (if present) and export its variables so recipes see them.
-include .rhiza/.env

# ==============================================================================
# Rhiza Core
# ==============================================================================

# RHIZA_LOGO definition
define RHIZA_LOGO
  ____  _     _
 |  _ \| |__ (_)______ _
 | |_) | '_ \| |_  / _\`|
 |  _ <| | | | |/ / (_| |
 |_| \_\_| |_|_/___\__,_|

endef
export RHIZA_LOGO

# Declare phony targets for Rhiza Core
.PHONY: print-logo sync validate readme pre-sync post-sync pre-validate post-validate

# Hook targets (double-colon rules allow multiple definitions)
# Note: pre-install/post-install are defined in bootstrap.mk
# Note: pre-bump/post-bump/pre-release/post-release are defined in releasing.mk
pre-sync:: ; @:
post-sync:: ; @:
pre-validate:: ; @:
post-validate:: ; @:

##@ Rhiza Workflows

print-logo:
	@printf "${BLUE}$$RHIZA_LOGO${RESET}\n"


sync: pre-sync ## sync with template repository as defined in .rhiza/template.yml
	@if git remote get-url origin 2>/dev/null | grep -iqE 'jebel-quant/rhiza-go(\.git)?$$'; then \
		printf "${BLUE}[INFO] Skipping sync in rhiza-go repository (no template.yml by design)${RESET}\n"; \
	else \
		printf "${YELLOW}[WARN] Sync functionality requires rhiza CLI tool${RESET}\n"; \
		printf "${YELLOW}[INFO] Install with: go install github.com/Jebel-Quant/rhiza@latest${RESET}\n"; \
	fi
	@$(MAKE) post-sync

summarise-sync: ## summarise differences created by sync with template repository
	@if git remote get-url origin 2>/dev/null | grep -iqE 'jebel-quant/rhiza-go(\.git)?$$'; then \
		printf "${BLUE}[INFO] Skipping summarise-sync in rhiza-go repository (no template.yml by design)${RESET}\n"; \
	else \
		printf "${YELLOW}[WARN] Sync functionality requires rhiza CLI tool${RESET}\n"; \
	fi

rhiza-test: install ## run rhiza's own tests (if any)
	@if [ -d ".rhiza/tests" ] && find .rhiza/tests -name "*_test.go" | grep -q .; then \
		$(GO_BIN) test ./.rhiza/tests/...; \
	else \
		printf "${YELLOW}[WARN] No Go tests found in .rhiza/tests directory, skipping rhiza-tests${RESET}\n"; \
	fi

validate: pre-validate rhiza-test ## validate project structure against template repository as defined in .rhiza/template.yml
	@printf "${BLUE}[INFO] Running local template validation...${RESET}\n"
	@# Check all bundled files exist
	@$(GO_BIN) test ./.rhiza/tests/... -run TestBundleFilesExist -count=1 > /dev/null 2>&1 && \
		printf "${GREEN}[PASS] All bundle files validated${RESET}\n" || \
		printf "${RED}[FAIL] Some bundle files are missing${RESET}\n"
	@# Check Makefile targets resolve
	@$(GO_BIN) test ./.rhiza/tests/... -run TestMakefileTargetsExist -count=1 > /dev/null 2>&1 && \
		printf "${GREEN}[PASS] All required Makefile targets exist${RESET}\n" || \
		printf "${RED}[FAIL] Some Makefile targets are missing${RESET}\n"
	@# Check Go code compiles (via build target)
	@$(MAKE) build > /dev/null 2>&1 && \
		printf "${GREEN}[PASS] Go code compiles successfully${RESET}\n" || \
		printf "${RED}[FAIL] Go code compilation failed${RESET}\n"
	@if git remote get-url origin 2>/dev/null | grep -iqE 'jebel-quant/rhiza-go(\.git)?$$'; then \
		printf "${BLUE}[INFO] Skipping remote validation in rhiza-go repository (no template.yml by design)${RESET}\n"; \
	else \
		printf "${YELLOW}[WARN] Remote validation requires rhiza CLI tool${RESET}\n"; \
	fi
	@$(MAKE) post-validate

readme: ## update README.md with current Makefile help output
	@printf "${YELLOW}[WARN] README update functionality requires rhiza-tools${RESET}\n"

##@ Meta

help: print-logo ## Display this help message
	+@printf "$(BOLD)Usage:$(RESET)\n"
	+@printf "  make $(BLUE)<target>$(RESET)\n\n"
	+@printf "$(BOLD)Targets:$(RESET)\n"
	+@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(BLUE)%-20s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(BOLD)%s$(RESET)\n", substr($$0, 5) }' $(MAKEFILE_LIST)
	+@printf "\n"

version-matrix: ## Emit the list of supported Go versions from .go-version
	@printf "${BLUE}[INFO] Supported Go version: $(GO_VERSION)${RESET}\n"

print-% : ## print the value of a variable (usage: make print-VARIABLE)
	@printf "${BLUE}[INFO] Printing value of variable '$*':${RESET}\n"
	@printf "${BOLD}Value of $*:${RESET}\n"
	@printf "${GREEN}"
	@printf "%s\n" "$($*)"
	@printf "${RESET}"
	@printf "${BLUE}[INFO] End of value for '$*'${RESET}\n"

# Optional: repo extensions (committed)
-include .rhiza/make.d/*.mk

