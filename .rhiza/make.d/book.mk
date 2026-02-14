## book.mk - Documentation book targets
# This file is included by the main Makefile.
# For Go projects, the book target compiles documentation from
# Go doc output, test coverage reports, and test results.

# Declare phony targets (they don't produce files)
.PHONY: book

##@ Book

# The 'book' target assembles documentation from available sources.
# 1. Aggregates Go documentation, coverage reports, and test results into _book.
# 2. Creates an index page linking to all available sections.
book:: test docs ## compile the companion documentation book
	@printf "${BLUE}[INFO] Building combined documentation...${RESET}\n"
	@rm -rf _book && mkdir -p _book

	@# Copy Go documentation if available
	@if [ -f "docs/package-docs.txt" ]; then \
	  printf "${BLUE}[INFO] Adding Go documentation...${RESET}\n"; \
	  mkdir -p _book/docs; \
	  cp docs/package-docs.txt _book/docs/; \
	fi

	@# Copy test coverage report if available
	@if [ -f "coverage.html" ]; then \
	  printf "${BLUE}[INFO] Adding coverage report...${RESET}\n"; \
	  mkdir -p _book/coverage; \
	  cp coverage.html _book/coverage/index.html; \
	fi

	@# Generate a simple index page
	@printf '<html><head><title>Project Documentation</title></head>\n' > _book/index.html
	@printf '<body><h1>Project Documentation</h1><ul>\n' >> _book/index.html
	@if [ -f "_book/docs/package-docs.txt" ]; then \
	  printf '<li><a href="docs/package-docs.txt">API Documentation</a></li>\n' >> _book/index.html; \
	fi
	@if [ -f "_book/coverage/index.html" ]; then \
	  printf '<li><a href="coverage/index.html">Coverage Report</a></li>\n' >> _book/index.html; \
	fi
	@printf '</ul></body></html>\n' >> _book/index.html
	@touch "_book/.nojekyll"
	@printf "${BLUE}[INFO] Documentation book generated in _book/${RESET}\n"
