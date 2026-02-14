## .rhiza/make.d/go-docs.mk - Documentation generation for Go
# This file provides targets for generating Go documentation.

# Declare phony targets (they don't produce files)
.PHONY: docs docs-serve

##@ Documentation

docs: install-go ## generate Go documentation
	@printf "${BLUE}[INFO] Generating Go documentation...${RESET}\n"
	@mkdir -p docs
	@$(GO_BIN) doc -all > docs/package-docs.txt
	@printf "${BLUE}[INFO] Documentation saved to docs/package-docs.txt${RESET}\n"
	@printf "${YELLOW}[INFO] To view documentation in browser, run 'make docs-serve'${RESET}\n"

docs-serve: install-go ## serve Go documentation on localhost:6060
	@printf "${BLUE}[INFO] Starting documentation server on http://localhost:6060${RESET}\n"
	@printf "${YELLOW}[INFO] Press Ctrl+C to stop${RESET}\n"
	@if command -v godoc >/dev/null 2>&1; then \
	  godoc -http=:6060; \
	else \
	  printf "${YELLOW}[WARN] godoc not found, installing...${RESET}\n"; \
	  $(GO_BIN) install golang.org/x/tools/cmd/godoc@latest; \
	  godoc -http=:6060; \
	fi
