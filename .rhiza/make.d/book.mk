## book.mk - Documentation book targets
# This file is included by the main Makefile.
# For Go projects, the book target compiles documentation from
# Go doc output, test coverage reports, and test results.

# Declare phony targets (they don't produce files)
.PHONY: book mkdocs-build

# Default output directory for MkDocs
MKDOCS_OUTPUT ?= _mkdocs

# Book configuration
BOOK_TITLE ?= $(shell basename $(PWD))
BOOK_SUBTITLE ?= Go Project Documentation

##@ Book

# Build MkDocs documentation site
mkdocs-build:: install-uv ## build mkdocs documentation site
	@if [ -f "mkdocs.yml" ]; then \
	  printf "${BLUE}[INFO] Building MkDocs site...${RESET}\n"; \
	  $(UVX_BIN) --from mkdocs-material mkdocs build -d "$(MKDOCS_OUTPUT)"; \
	  printf "${BLUE}[INFO] MkDocs site built to $(MKDOCS_OUTPUT)/${RESET}\n"; \
	else \
	  printf "${YELLOW}[WARN] No mkdocs.yml found, skipping MkDocs${RESET}\n"; \
	fi

# ----------------------------
# Book sections (declarative)
# ----------------------------
# format:
#   name | source index | book-relative index | source dir | book dir

BOOK_SECTIONS := \
  "API Docs|docs/package-docs.txt|docs/package-docs.txt|docs|go-docs" \
  "Documentation|$(MKDOCS_OUTPUT)/index.html|docs/index.html|$(MKDOCS_OUTPUT)|docs" \
  "Coverage|coverage.html|coverage/index.html|.|coverage"

# The 'book' target assembles documentation from available sources.
# 1. Aggregates Go documentation, coverage reports, and test results into _book.
# 2. Uses minibook to create a unified documentation site.
book:: test docs mkdocs-build ## compile the companion documentation book
	@printf "${BLUE}[INFO] Building combined documentation...${RESET}\n"
	@rm -rf _book && mkdir -p _book

	@printf "{\n" > _book/links.json
	@first=1; \
	for entry in $(BOOK_SECTIONS); do \
	  name=$${entry%%|*}; \
	  rest=$${entry#*|}; \
	  src_index=$${rest%%|*}; rest=$${rest#*|}; \
	  book_index=$${rest%%|*}; rest=$${rest#*|}; \
	  src_dir=$${rest%%|*}; book_dir=$${rest#*|}; \
	  if [ -f "$$src_index" ]; then \
	    printf "${BLUE}[INFO] Adding $$name...${RESET}\n"; \
	    mkdir -p "_book/$$book_dir"; \
	    if [ -d "$$src_dir" ]; then \
	      cp -r "$$src_dir/"* "_book/$$book_dir/"; \
	    else \
	      cp "$$src_index" "_book/$$book_index"; \
	    fi; \
	    if [ $$first -eq 0 ]; then \
	      printf ",\n" >> _book/links.json; \
	    fi; \
	    printf "  \"%s\": \"./%s\"" "$$name" "$$book_index" >> _book/links.json; \
	    first=0; \
	  else \
	    printf "${YELLOW}[WARN] Missing $$name ($$src_index), skipping${RESET}\n"; \
	  fi; \
	done; \
	printf "\n}\n" >> _book/links.json

	@printf "${BLUE}[INFO] Generated links.json:${RESET}\n"
	@cat _book/links.json

	@TEMPLATE_ARG=""; \
	if [ -n "$(LOGO_FILE)" ]; then \
	  if [ -f "$(LOGO_FILE)" ]; then \
	    cp "$(LOGO_FILE)" "_book/logo$$(echo $(LOGO_FILE) | sed 's/.*\./\./')"; \
	    printf "${BLUE}[INFO] Copying logo: $(LOGO_FILE)${RESET}\n"; \
	  else \
	    printf "${YELLOW}[WARN] Logo file $(LOGO_FILE) not found, skipping${RESET}\n"; \
	  fi; \
	fi; \
	$(UVX_BIN) minibook \
	  --title "$(BOOK_TITLE)" \
	  --subtitle "$(BOOK_SUBTITLE)" \
	  $$TEMPLATE_ARG \
	  --links "$$(python3 -c 'import json;print(json.dumps(json.load(open("_book/links.json"))))')" \
	  --output "_book"

	@touch "_book/.nojekyll"
	@printf "${BLUE}[INFO] Documentation book generated in _book/${RESET}\n"
