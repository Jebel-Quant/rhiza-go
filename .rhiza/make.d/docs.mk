## .rhiza/make.d/docs.mk - Documentation generation
# This file provides targets for generating documentation.
# Uses gomarkdoc to generate proper Markdown from Go doc comments.
# See: https://github.com/princjef/gomarkdoc

# Declare phony targets (they don't produce files)
.PHONY: docs docs-serve

# gomarkdoc binary
GOMARKDOC_BIN ?= $(shell command -v gomarkdoc 2>/dev/null || echo "$$($(GO_BIN) env GOPATH)/bin/gomarkdoc")

##@ Documentation

docs: build ## generate API documentation as Markdown
	@printf "${BLUE}[INFO] Generating API documentation...${RESET}\n"
	@mkdir -p docs
	@if command -v gomarkdoc >/dev/null 2>&1 || [ -x "$(GOMARKDOC_BIN)" ]; then \
	  $(GOMARKDOC_BIN) --output docs/API.md ./... 2>/dev/null; \
	  printf "${BLUE}[INFO] API docs saved to docs/API.md${RESET}\n"; \
	else \
	  printf "${YELLOW}[WARN] gomarkdoc not found, installing...${RESET}\n"; \
	  $(GO_BIN) install github.com/princjef/gomarkdoc/cmd/gomarkdoc@latest; \
	  "$$($(GO_BIN) env GOPATH)/bin/gomarkdoc" --output docs/API.md ./... 2>/dev/null; \
	  printf "${BLUE}[INFO] API docs saved to docs/API.md${RESET}\n"; \
	fi
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
