## .rhiza/make.d/security.mk - Security Scanning
# This file provides targets for running security tools:
# - govulncheck: Go's official vulnerability scanner
# - gosec: Inspects Go source code for security problems

# Declare phony targets (they don't produce files)
.PHONY: security govulncheck gosec

##@ Security

security: govulncheck gosec ## run all security checks (govulncheck + gosec)

govulncheck: build ## run Go vulnerability scanner
	@printf "${BLUE}[INFO] Running govulncheck...${RESET}\n"
	@if command -v govulncheck >/dev/null 2>&1; then \
	  govulncheck ./...; \
	elif [ -x "$$($(GO_BIN) env GOPATH)/bin/govulncheck" ]; then \
	  "$$($(GO_BIN) env GOPATH)/bin/govulncheck" ./...; \
	else \
	  printf "${YELLOW}[WARN] govulncheck not found, installing...${RESET}\n"; \
	  $(GO_BIN) install golang.org/x/vuln/cmd/govulncheck@latest; \
	  "$$($(GO_BIN) env GOPATH)/bin/govulncheck" ./...; \
	fi

gosec: install-go ## run Go security checker
	@printf "${BLUE}[INFO] Running gosec...${RESET}\n"
	@if command -v gosec >/dev/null 2>&1; then \
	  gosec ./...; \
	elif [ -x "$$($(GO_BIN) env GOPATH)/bin/gosec" ]; then \
	  "$$($(GO_BIN) env GOPATH)/bin/gosec" ./...; \
	else \
	  printf "${YELLOW}[WARN] gosec not found, installing...${RESET}\n"; \
	  $(GO_BIN) install github.com/securego/gosec/v2/cmd/gosec@latest; \
	  "$$($(GO_BIN) env GOPATH)/bin/gosec" ./...; \
	fi
