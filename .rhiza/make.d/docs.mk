## .rhiza/make.d/docs.mk - Documentation generation
# This file provides targets for generating documentation.

# Declare phony targets (they don't produce files)
.PHONY: docs docs-serve

##@ Documentation

docs: build ## generate documentation
	@printf "${BLUE}[INFO] Generating documentation...${RESET}\n"
	@mkdir -p docs
	@for pkg in $$($(GO_BIN) list ./... 2>/dev/null); do \
	  printf "=== $$pkg ===\n"; \
	  $(GO_BIN) doc -all $$pkg 2>/dev/null; \
	  printf "\n"; \
	done > docs/package-docs.txt
	@printf "${BLUE}[INFO] Documentation saved to docs/package-docs.txt${RESET}\n"
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
