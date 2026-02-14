## .rhiza/make.d/releasing.mk - Releasing and Versioning
# This file provides targets for version bumping and release management.

# Declare phony targets (they don't produce files)
.PHONY: bump release pre-bump post-bump pre-release post-release

# Hook targets (double-colon rules allow multiple definitions)
pre-bump:: ; @:
post-bump:: ; @:
pre-release:: ; @:
post-release:: ; @:

##@ Releasing and Versioning
bump: pre-bump ## bump version
	@if [ -f "VERSION" ]; then \
		if command -v bump2version >/dev/null 2>&1; then \
			bump2version --config-file .rhiza/.cfg.toml patch; \
		else \
			printf "${RED}[ERROR] bump2version not found. Install with: pip install bump2version${RESET}\n"; \
			printf "${YELLOW}[INFO] Alternatively, manually edit VERSION file and commit${RESET}\n"; \
			exit 1; \
		fi; \
	else \
		printf "${YELLOW}[WARN] No VERSION file found, skipping bump${RESET}\n"; \
	fi
	@$(MAKE) post-bump

release: pre-release ## create tag and push to remote with prompts
	@/bin/sh ".rhiza/scripts/release.sh"
	@$(MAKE) post-release
