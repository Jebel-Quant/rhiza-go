## .rhiza/make.d/docs.mk - Documentation generation
# This file provides targets for generating documentation.
# API docs link to pkg.go.dev for the canonical Go documentation.

# Declare phony targets (they don't produce files)
.PHONY: docs docs-serve

# Module path from go.mod
GO_MODULE ?= $(shell grep '^module ' go.mod | awk '{print $$2}')

##@ Documentation

docs: build ## generate API documentation as Markdown
	@printf "${BLUE}[INFO] Generating API documentation...${RESET}\n"
	@mkdir -p docs
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
	@printf "${BLUE}[INFO] API docs saved to docs/API.md${RESET}\n"
	@printf "${YELLOW}[INFO] To view documentation in browser, run 'make docs-serve'${RESET}\n"

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
