## .rhiza/make.d/docs.mk - Documentation generation
# This file provides targets for generating documentation.
#
# Repository visibility controls how API docs are generated:
#   GO_REPO_PRIVATE = false (default) — docs/API.md links to pkg.go.dev (works for public repos)
#   GO_REPO_PRIVATE = true            — docs/API.md contains full inline docs via gomarkdoc
#                                       (works for private repos and GitHub Pages)
#
# Set GO_REPO_PRIVATE in your root Makefile or local.mk. See docs/CUSTOMIZATION.md.

# Declare phony targets (they don't produce files)
.PHONY: docs docs-serve

# Module path from go.mod
GO_MODULE ?= $(shell grep '^module ' go.mod | awk '{print $$2}')

# Set to true for private repositories - generates inline API docs via gomarkdoc
# instead of linking to pkg.go.dev.
GO_REPO_PRIVATE ?= false

# gomarkdoc binary (installed via make install)
GOMARKDOC_BIN ?= $(shell command -v gomarkdoc 2>/dev/null || echo "$(shell $(GO_BIN) env GOPATH)/bin/gomarkdoc")

##@ Documentation

docs: build ## generate API documentation as Markdown
	@printf "${BLUE}[INFO] Generating API documentation...${RESET}\n"
	@mkdir -p docs
ifeq ($(GO_REPO_PRIVATE),true)
	@if ! command -v gomarkdoc >/dev/null 2>&1 && [ ! -x "$(GOMARKDOC_BIN)" ]; then \
	  printf "${YELLOW}[WARN] gomarkdoc not found, installing...${RESET}\n"; \
	  $(GO_BIN) install github.com/princjef/gomarkdoc/cmd/gomarkdoc@latest; \
	fi
	@PKGS=$$($(GO_BIN) list ./... 2>/dev/null | grep -v '/.rhiza/'); \
	"$(GOMARKDOC_BIN)" $$PKGS > docs/API.md 2>/dev/null || \
	  { printf "${RED}[ERROR] gomarkdoc failed${RESET}\n"; exit 1; }
	@printf "${BLUE}[INFO] Inline API docs (gomarkdoc) saved to docs/API.md${RESET}\n"
else
	@printf '%s\n' \
	  "# API Reference" \
	  "" \
	  "Full API documentation is available on pkg.go.dev:" \
	  "" \
	  "**[pkg.go.dev/$(GO_MODULE)](https://pkg.go.dev/$(GO_MODULE))**" \
	  "" \
	  "## Packages" \
	  "" \
	  "| Package | Description |" \
	  "|---------|-------------|" \
	  > docs/API.md
	@for pkg in $$($(GO_BIN) list ./... 2>/dev/null | grep -v '/.rhiza/'); do \
	  desc=$$($(GO_BIN) doc "$$pkg" 2>/dev/null | awk '/^(Package|Command) /{sub(/^[^ ]+ [^ ]+ /,""); print; exit}'); \
	  short=$${pkg#$(GO_MODULE)/}; \
	  printf '| [%s](https://pkg.go.dev/%s) | %s |\n' "$$short" "$$pkg" "$$desc" >> docs/API.md; \
	done
	@printf "${BLUE}[INFO] API docs (pkg.go.dev links) saved to docs/API.md${RESET}\n"
endif
	@printf "${YELLOW}[INFO] To browse interactively, run 'make docs-serve'${RESET}\n"

docs-serve: build ## serve documentation on localhost:6060
	@printf "${BLUE}[INFO] Starting documentation server on http://localhost:6060${RESET}\n"
	@printf "${YELLOW}[INFO] Press Ctrl+C to stop${RESET}\n"
	@if command -v pkgsite >/dev/null 2>&1; then \
	  pkgsite -http=:6060; \
	elif [ -x "$$($(GO_BIN) env GOPATH)/bin/pkgsite" ]; then \
	  "$$($(GO_BIN) env GOPATH)/bin/pkgsite" -http=:6060; \
	else \
	  printf "${YELLOW}[WARN] pkgsite not found, installing...${RESET}\n"; \
	  $(GO_BIN) install golang.org/x/pkgsite/cmd/pkgsite@latest; \
	  "$$($(GO_BIN) env GOPATH)/bin/pkgsite" -http=:6060; \
	fi
