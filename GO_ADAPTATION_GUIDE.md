# Rhiza-Go Adaptation Guide

## Executive Summary

This document explains how the Rhiza template system works and provides a concrete roadmap for adapting it to Go projects.

---

## 1. What is Rhiza?

**Rhiza** is a "living template" system for software projects that provides **continuous synchronization** of configuration files, rather than one-time generation.

### Traditional Templates (cookiecutter, copier)
```
┌─────────┐    Generate Once    ┌─────────┐
│Template │ ────────────────> │ Project │
└─────────┘                     └─────────┘
                                     │
                                     ↓ (Drift over time)
                                Configuration becomes outdated
```

### Rhiza Approach
```
┌─────────┐    Initial Sync    ┌─────────┐
│Template │ ───────────────> │ Project │
└─────────┘                     └─────────┘
     │                               │
     │      Continuous Updates       │
     └──────────────────────────────┘
          (via `make sync` or CI workflow)
```

**Key Innovation**: Projects can pull updates from templates over time, staying current with best practices while maintaining control over what changes.

---

## 2. Key Components and Their Roles

### File Structure

```
project-root/
├── Makefile                    # 3-line file: variables + include .rhiza/rhiza.mk
├── pyproject.toml              # [Go: go.mod] - Project dependencies
├── .python-version             # [Go: .go-version] - Language version
├── ruff.toml                   # [Go: .golangci.yml] - Linter config
├── pytest.ini                  # [Go: removed, use Makefile] - Test config
├── .gitignore                  # Language-specific ignores
├── .editorconfig               # Editor settings (language-agnostic)
│
├── .rhiza/                     # Template-managed directory (synced from template repo)
│   ├── rhiza.mk                # Core Makefile logic (~150 lines)
│   ├── .rhiza-version          # Version of rhiza CLI tool (e.g., "0.11.0")
│   ├── template-bundles.yml    # Bundle definitions (core, github, tests, etc.)
│   ├── .cfg.toml               # Bumpversion configuration
│   │
│   ├── make.d/                 # Modular Makefile components (15 modules)
│   │   ├── bootstrap.mk        # install, clean targets
│   │   ├── test.mk             # test, benchmark targets
│   │   ├── docs.mk             # documentation generation
│   │   ├── github.mk           # GitHub CLI helpers
│   │   └── ...
│   │
│   ├── scripts/
│   │   └── release.sh          # Release automation
│   │
│   ├── requirements/           # [Go: not needed] - Python tool deps
│   │   ├── docs.txt
│   │   ├── tools.txt
│   │   └── tests.txt
│   │
│   ├── docs/                   # Template documentation
│   └── templates/              # Jinja2 templates for code generation
│
└── .github/
    └── workflows/              # CI/CD workflows (16 files)
        ├── rhiza_ci.yml        # [Go: go_ci.yml] - Test matrix
        ├── rhiza_sync.yml      # Template sync automation
        ├── rhiza_release.yml   # [Go: go_release.yml] - Release automation
        └── ...
```

### Component Roles

#### **Root `Makefile`** (User-Owned)
```makefile
## Minimal project-specific configuration
DOCFORMAT=google
DEFAULT_AI_MODEL=claude-sonnet-4.5
LOGO_FILE=.rhiza/assets/rhiza-logo.svg

# Pull in all template-managed targets
include .rhiza/rhiza.mk

# Optional: developer-local extensions (not committed)
-include local.mk
```

**Purpose**: 
- Define project-specific variables
- Include template logic
- Allow local overrides
- **Never modified by sync** (user controls it)

#### **`.rhiza/rhiza.mk`** (Template-Owned)
Contains ~150 lines of core logic:
- Environment setup (uv, Python version, colors)
- Core targets: `sync`, `validate`, `help`, `readme`
- Hook definitions: `pre-install::`, `post-sync::`, etc.
- Includes all `.rhiza/make.d/*.mk` modules

**Purpose**: Central orchestration of template functionality

#### **`.rhiza/make.d/*.mk`** (Template-Owned Modules)
15 modular files, each providing specific functionality:

| Module | Targets | Purpose |
|--------|---------|---------|
| `bootstrap.mk` | `install`, `clean` | Environment setup |
| `test.mk` | `test`, `benchmark` | Testing and coverage |
| `docs.mk` | `docs`, `book` | Documentation generation |
| `github.mk` | `view-prs`, `failed-workflows` | GitHub CLI helpers |
| `marimo.mk` | `marimo`, `marimo-validate` | Notebook server |
| `releasing.mk` | `bump`, `release` | Version management |
| `quality.mk` | `fmt`, `deptry` | Code quality |
| `docker.mk` | `docker-build`, `docker-run` | Containerization |
| `agentic.mk` | `analyse-repo`, `copilot` | AI assistants |

**Purpose**: Modular, focused functionality that can be independently updated

#### **`.rhiza/template-bundles.yml`** (Template-Owned)
Defines reusable file sets:

```yaml
version: "0.7.1"

bundles:
  core:                         # Required infrastructure
    required: true
    files:
      - .rhiza/rhiza.mk
      - Makefile
      - .gitignore
      - .editorconfig
      - ruff.toml               # [Go: .golangci.yml]
      - .python-version         # [Go: .go-version]

  github:                       # GitHub Actions workflows
    requires: [core]
    files:
      - .github/workflows/*.yml
      - .github/dependabot.yml

  tests:                        # Testing infrastructure
    standalone: true
    files:
      - .rhiza/make.d/test.mk
      - pytest.ini              # [Go: removed]
      - .github/workflows/rhiza_ci.yml  # [Go: go_ci.yml]

  docker:                       # Containerization
    standalone: true
    files:
      - docker/Dockerfile       # [Go: multi-stage build]
      - .rhiza/make.d/docker.mk
```

**Purpose**: Logical grouping of related files for easier adoption

#### **`.rhiza/.rhiza-version`** (Template-Owned)
```
0.11.0
```

**Purpose**: Pins the version of the `rhiza` CLI tool used by `make sync` and workflows. Allows template to control client version.

---

## 3. How Rhiza Works for Python Projects

### Initialization Workflow

```bash
# Step 1: Navigate to your project
cd my-python-project/

# Step 2: Initialize Rhiza configuration
uvx rhiza init
# Creates: .rhiza/template.yml

# Step 3: Customize what to sync (optional)
# Edit .rhiza/template.yml to select bundles or file patterns

# Step 4: Materialize templates
uvx rhiza materialize
# Fetches and copies files from template repository
```

### What Gets Created

After `uvx rhiza init`, you get `.rhiza/template.yml`:

```yaml
# Template source
repository: Jebel-Quant/rhiza
ref: v0.7.1                     # Version tag or branch

# Select bundles (predefined file sets)
templates:
  - core                        # Required: Makefile, configs
  - github                      # GitHub Actions workflows
  - tests                       # pytest, coverage, CI

# Or use granular file patterns
include: |
  .github/workflows/*.yml
  .pre-commit-config.yaml
  Makefile
  ruff.toml

# Exclude specific files to preserve customizations
exclude: |
  .rhiza/scripts/customisations/*
  docker/Dockerfile             # Using custom Dockerfile
```

### Sync Mechanism

**Manual Sync:**
```bash
make sync
# Equivalent to: uvx rhiza materialize --force .
```

**Automated Sync (Weekly):**
`.github/workflows/rhiza_sync.yml` runs on schedule:
1. Checks out repository
2. Runs `uvx rhiza materialize --force .`
3. Detects changes (`git diff --cached`)
4. Generates PR description (`uvx rhiza summarise`)
5. Creates pull request with template updates

**PR Description Auto-Generation:**
The `rhiza summarise` command analyzes `git diff --cached` and generates:
- List of changed files
- Categorization (Added/Modified/Deleted)
- Impact analysis
- Suggested review points

### Template Resolution

When you run `uvx rhiza materialize`:

1. **Load Config**: Read `.rhiza/template.yml`
2. **Resolve Bundles**: If `templates:` specified, expand bundles to file lists
3. **Fetch Files**: Download from `repository` at `ref` (GitHub API)
4. **Apply Filters**: 
   - Include only files matching `include:` patterns or bundle file lists
   - Exclude files matching `exclude:` patterns
5. **Copy Files**: Write to target directory
6. **Preserve Customizations**: Skip excluded files

### Makefile Execution Flow

```bash
make install
```

**What Happens:**
1. Root `Makefile` includes `.rhiza/rhiza.mk`
2. `.rhiza/rhiza.mk` includes `.rhiza/make.d/*.mk` (all modules)
3. `install` target from `.rhiza/make.d/bootstrap.mk` executes:
   ```makefile
   install: pre-install install-uv
       # Create venv
       uv venv --python $(PYTHON_VERSION) .venv
       # Install dependencies
       uv sync --all-extras --all-groups --frozen
       # Install dev tools from .rhiza/requirements/*.txt
       uv pip install -r .rhiza/requirements/tools.txt
       # Run customization hook
       $(MAKE) post-install
   ```
4. If root `Makefile` defines `post-install::`, it runs

### Hook System

Hooks allow customization without modifying template files:

```makefile
# In root Makefile (before include .rhiza/rhiza.mk)

# Run before sync
pre-sync::
	@echo "Backing up custom configs..."
	@cp config.yml config.yml.bak

# Run after install
post-install::
	@echo "Installing project-specific tools..."
	@./scripts/install-custom-deps.sh

# Run before release
pre-release::
	@./scripts/run-security-scan.sh
```

Available hooks:
- `pre-install::` / `post-install::`
- `pre-sync::` / `post-sync::`
- `pre-validate::` / `post-validate::`
- `pre-bump::` / `post-bump::`
- `pre-release::` / `post-release::`

---

## 4. Adapting for Go Projects

### High-Level Strategy

**Option 1: Go-Exclusive Fork** (Recommended for start)
- Keep `.rhiza/` structure
- Replace Python-specific files with Go equivalents
- Maintain same sync/bundle mechanism
- Simpler, faster to implement

**Option 2: Multi-Language Support**
- Namespace bundles by language (`python.core`, `go.core`)
- Conditional includes in `.rhiza/rhiza.mk`
- More complex but unified ecosystem

### Required File Changes

| Python File | Go Equivalent | Changes Needed |
|-------------|---------------|----------------|
| **Project Definition** | | |
| `pyproject.toml` | `go.mod` | Module name, Go version, dependencies |
| `uv.lock` | `go.sum` | Dependency checksums (auto-generated) |
| `.python-version` | `.go-version` | Go version (e.g., `1.24`) |
| **Linting/Formatting** | | |
| `ruff.toml` | `.golangci.yml` | golangci-lint configuration |
| `.pre-commit-config.yaml` | Update hooks | Replace ruff with gofmt, golangci-lint |
| **Testing** | | |
| `pytest.ini` | *Remove* | Go uses `go test` flags in Makefile |
| **Documentation** | | |
| `pdoc` in `docs.mk` | `godoc`/`pkgsite` | API documentation tool |
| **Dependencies** | | |
| `.rhiza/requirements/*.txt` | *Remove* | Go tools installed via `go install` |

### Makefile Module Adaptations

#### **`.rhiza/make.d/bootstrap.mk`** → **`go-bootstrap.mk`**

**Python Version:**
```makefile
install: pre-install install-uv
	# Create virtual environment
	${UV_BIN} venv --python $(PYTHON_VERSION) ${VENV}
	
	# Install dependencies
	${UV_BIN} sync --all-extras --all-groups --frozen
	
	# Install dev tools
	${UV_BIN} pip install -r .rhiza/requirements/tools.txt
	
	@$(MAKE) post-install
```

**Go Version:**
```makefile
GO_VERSION ?= $(shell cat .go-version 2>/dev/null || echo "1.24")

install: pre-install
	@printf "${BLUE}[INFO] Installing Go dependencies...${RESET}\n"
	
	# Download dependencies
	@go mod download
	
	# Verify checksums
	@go mod verify
	
	# Install dev tools
	@go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	@go install golang.org/x/pkgsite/cmd/pkgsite@latest
	@go install github.com/goreleaser/goreleaser@latest
	
	@$(MAKE) post-install

clean:
	@printf "${BLUE}[INFO] Cleaning Go artifacts...${RESET}\n"
	@go clean -cache -testcache -modcache
	@rm -rf coverage.out coverage.html
```

#### **`.rhiza/make.d/test.mk`** → **`go-test.mk`**

**Python Version:**
```makefile
test:
	${UV_BIN} run pytest \
		--cov=src \
		--cov-report=html \
		--cov-report=term \
		tests/

benchmark:
	${UV_BIN} run pytest --benchmark-only tests/benchmarks/
```

**Go Version:**
```makefile
test:
	@printf "${BLUE}[INFO] Running tests...${RESET}\n"
	@go test -v -race -coverprofile=coverage.out ./...
	@go tool cover -html=coverage.out -o coverage.html
	@go tool cover -func=coverage.out

test-short:
	@go test -short ./...

benchmark:
	@printf "${BLUE}[INFO] Running benchmarks...${RESET}\n"
	@go test -bench=. -benchmem -run=^Benchmark ./...

test-integration:
	@go test -v -tags=integration ./...
```

#### **`.rhiza/make.d/quality.mk`** → **`go-quality.mk`**

**Python Version:**
```makefile
fmt:
	${UV_BIN} run pre-commit run --all-files

deptry:
	${UV_BIN} run deptry src/
```

**Go Version:**
```makefile
fmt:
	@printf "${BLUE}[INFO] Formatting Go code...${RESET}\n"
	@gofmt -w .
	@goimports -w .

lint:
	@printf "${BLUE}[INFO] Running golangci-lint...${RESET}\n"
	@golangci-lint run --fix

lint-strict:
	@golangci-lint run --enable-all

vet:
	@go vet ./...

check-deps:
	@go mod tidy
	@git diff --exit-code go.mod go.sum || \
		(echo "go.mod or go.sum changed, run 'go mod tidy'" && exit 1)
```

#### **`.rhiza/make.d/docs.mk`** → **`go-docs.mk`**

**Python Version:**
```makefile
docs:
	${UV_BIN} run pdoc --html --output-dir docs/api src/
```

**Go Version:**
```makefile
docs:
	@printf "${BLUE}[INFO] Generating Go documentation...${RESET}\n"
	@godoc -http=:6060 &
	@printf "${GREEN}Documentation server running at http://localhost:6060${RESET}\n"

docs-static:
	@printf "${BLUE}[INFO] Building static documentation with pkgsite...${RESET}\n"
	@pkgsite -http=:6060
```

#### **`.rhiza/make.d/releasing.mk`** (minimal changes)

**Python Version:**
```makefile
release:
	@./scripts/release.sh
```

**Go Version (using goreleaser):**
```makefile
release:
	@printf "${BLUE}[INFO] Creating release with goreleaser...${RESET}\n"
	@goreleaser release --clean

release-snapshot:
	@goreleaser release --snapshot --clean --skip=publish
```

### Configuration File Changes

#### **`.golangci.yml`** (replaces `ruff.toml`)

```yaml
# .golangci.yml
run:
  timeout: 5m
  modules-download-mode: readonly

linters:
  enable:
    - errcheck      # Check for unchecked errors
    - gosimple      # Simplify code
    - govet         # Vet examines Go source code
    - ineffassign   # Detect ineffectual assignments
    - staticcheck   # Go static analysis
    - unused        # Check for unused code
    - gofmt         # Check formatting
    - goimports     # Check import organization
    - gocritic      # Go code critic
    - misspell      # Check spelling
    - revive        # Fast, configurable linter

linters-settings:
  errcheck:
    check-type-assertions: true
    check-blank: true
  
  gocritic:
    enabled-tags:
      - diagnostic
      - style
      - performance
  
  goimports:
    local-prefixes: github.com/Jebel-Quant/rhiza-go

issues:
  exclude-use-default: false
  max-issues-per-linter: 0
  max-same-issues: 0
```

#### **`.pre-commit-config.yaml`** (updated for Go)

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v5.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-toml
      - id: check-json
      - id: check-merge-conflict
      - id: detect-private-key

  # Go-specific hooks
  - repo: https://github.com/dnephin/pre-commit-golang
    rev: v0.5.1
    hooks:
      - id: go-fmt
      - id: go-imports
      - id: go-vet
      - id: go-unit-tests
      - id: golangci-lint

  # Markdown/documentation
  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.43.0
    hooks:
      - id: markdownlint

  # GitHub Actions validation
  - repo: https://github.com/rhysd/actionlint
    rev: v1.7.5
    hooks:
      - id: actionlint
```

### GitHub Workflows Adaptation

#### **`.github/workflows/go_ci.yml`** (replaces `rhiza_ci.yml`)

```yaml
name: Go CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        go-version: [1.21, 1.22, 1.23, 1.24]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
          cache: true
      
      - name: Download dependencies
        run: go mod download
      
      - name: Verify dependencies
        run: go mod verify
      
      - name: Run tests
        run: go test -v -race -coverprofile=coverage.out ./...
      
      - name: Generate coverage report
        run: go tool cover -html=coverage.out -o coverage.html
      
      - name: Upload coverage
        uses: codecov/codecov-action@v5
        with:
          files: ./coverage.out
          flags: go-${{ matrix.go-version }}

  lint:
    name: Lint
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.24'
          cache: true
      
      - name: golangci-lint
        uses: golangci/golangci-lint-action@v8
        with:
          version: latest
          args: --timeout=5m
```

#### **`.github/workflows/go_release.yml`** (replaces `rhiza_release.yml`)

```yaml
name: Go Release

on:
  push:
    tags:
      - 'v*.*.*'

permissions:
  contents: write
  packages: write

jobs:
  release:
    name: Release
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      
      - name: Set up Go
        uses: actions/setup-go@v5
        with:
          go-version: '1.24'
          cache: true
      
      - name: Run tests
        run: go test -v ./...
      
      - name: Run GoReleaser
        uses: goreleaser/goreleaser-action@v6
        with:
          version: latest
          args: release --clean
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Template Bundle Definitions for Go

**`.rhiza/template-bundles.yml`** (Go version):

```yaml
version: "0.1.0"

bundles:
  # Core Go infrastructure
  core:
    description: "Core Rhiza infrastructure for Go projects"
    required: true
    standalone: true
    files:
      # Core Rhiza files
      - .rhiza/rhiza.mk
      - .rhiza/.cfg.toml
      - .rhiza/.env
      - .rhiza/.gitignore
      - .rhiza/.rhiza-version
      - .rhiza/make.d/custom-env.mk
      - .rhiza/make.d/go-bootstrap.mk      # Go-specific
      - .rhiza/make.d/go-test.mk           # Go-specific
      - .rhiza/make.d/go-quality.mk        # Go-specific
      - .rhiza/make.d/go-docs.mk           # Go-specific
      - .rhiza/make.d/releasing.mk
      - .rhiza/scripts

      # Root configuration files
      - Makefile
      - .pre-commit-config.yaml            # Go hooks
      - .editorconfig
      - .gitignore
      - .go-version                        # Go-specific
      - .golangci.yml                      # Go-specific

      # Go project files (templates)
      - go.mod.template
      - go.sum.template

  github:
    description: "GitHub Actions workflows for Go CI/CD"
    standalone: true
    requires: [core]
    files:
      - .rhiza/make.d/github.mk
      - .github/workflows/go_ci.yml        # Go-specific
      - .github/workflows/go_lint.yml      # Go-specific
      - .github/workflows/go_release.yml   # Go-specific
      - .github/workflows/rhiza_sync.yml   # Same
      - .github/dependabot.yml

  tests:
    description: "Testing infrastructure for Go"
    standalone: true
    requires: []
    files:
      - .rhiza/make.d/go-test.mk
      - .github/workflows/go_ci.yml

  docker:
    description: "Docker containerization for Go"
    standalone: true
    requires: []
    files:
      - docker/Dockerfile.go               # Multi-stage Go build
      - .rhiza/make.d/docker.mk
      - .github/workflows/go_docker.yml
```

### Docker Adaptation

**`docker/Dockerfile.go`** (Multi-stage Go build):

```dockerfile
# Build stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Cache dependencies
COPY go.mod go.sum ./
RUN go mod download

# Build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy binary from builder
COPY --from=builder /app/main .

CMD ["./main"]
```

### Version Detection in Makefile

To support both Python and Go in the same repository (if choosing multi-language approach):

**`.rhiza/rhiza.mk`** (add language detection):

```makefile
# Detect project language
LANG := $(shell \
	if [ -f "go.mod" ]; then echo "go"; \
	elif [ -f "pyproject.toml" ]; then echo "python"; \
	else echo "unknown"; fi)

# Conditional includes based on language
ifeq ($(LANG),go)
  include .rhiza/make.d/go-*.mk
else ifeq ($(LANG),python)
  include .rhiza/make.d/bootstrap.mk
  include .rhiza/make.d/test.mk
  include .rhiza/make.d/quality.mk
  include .rhiza/make.d/docs.mk
endif

# Common includes (language-agnostic)
include .rhiza/make.d/github.mk
include .rhiza/make.d/releasing.mk
include .rhiza/make.d/docker.mk
```

---

## 5. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)

**Goal**: Create minimal viable Go template

- [ ] Create `.rhiza/make.d/go-bootstrap.mk`
- [ ] Create `.rhiza/make.d/go-test.mk`
- [ ] Create `.rhiza/make.d/go-quality.mk`
- [ ] Create `.golangci.yml` configuration
- [ ] Update `.pre-commit-config.yaml` for Go
- [ ] Create `go.mod.template` example
- [ ] Add `.go-version` file
- [ ] Test: Initialize a test Go project and run `make install`, `make test`

### Phase 2: CI/CD (Weeks 3-4)

**Goal**: Port all workflows to Go

- [ ] Create `.github/workflows/go_ci.yml`
- [ ] Create `.github/workflows/go_lint.yml`
- [ ] Create `.github/workflows/go_release.yml`
- [ ] Create `.github/workflows/go_docker.yml`
- [ ] Configure goreleaser (`.goreleaser.yml`)
- [ ] Update `.github/workflows/rhiza_sync.yml` (same for both)
- [ ] Test: Trigger workflows in a test repository

### Phase 3: Bundles & Documentation (Weeks 5-6)

**Goal**: Complete template system

- [ ] Update `.rhiza/template-bundles.yml` with Go bundles
- [ ] Create `docs/GO.md` with Go-specific instructions
- [ ] Update README.md with Go examples
- [ ] Create comparison table (Python vs Go features)
- [ ] Add Go-specific troubleshooting section
- [ ] Test: Use `uvx rhiza init` with Go project

### Phase 4: Polish & Release (Weeks 7-8)

**Goal**: Production-ready v0.1.0

- [ ] Create example Go projects using templates
- [ ] Comprehensive testing of all workflows
- [ ] Performance benchmarking (sync speed)
- [ ] Security review (CodeQL for Go)
- [ ] Write migration guide from Python Rhiza
- [ ] Tag `v0.1.0` release
- [ ] Announce in Go community

---

## 6. Key Decisions to Make

### Decision 1: Repository Strategy

**Option A: Go-Exclusive** ✅ Recommended
- This repo becomes pure Go templates
- Original rhiza stays Python-only
- Clear separation, easier maintenance

**Option B: Multi-Language**
- Support both Python and Go
- More complex but unified ecosystem
- Language detection in Makefile

**Recommendation**: Start with **Option A**, evolve to **Option B** if demand warrants.

### Decision 2: Namespace Strategy (if multi-language)

**Current (Python):**
```yaml
templates:
  - core
  - github
  - tests
```

**Option 1: Flat with prefixes**
```yaml
templates:
  - go-core
  - go-github
  - python-core
  - python-github
```

**Option 2: Nested (cleaner)**
```yaml
templates:
  - go:
      - core
      - github
  - python:
      - core
      - github
```

**Recommendation**: **Option 2** if supporting multiple languages.

### Decision 3: Makefile Organization

**Option A: Separate Go modules**
```
.rhiza/make.d/
├── go-bootstrap.mk
├── go-test.mk
├── go-quality.mk
├── bootstrap.mk        (Python)
├── test.mk             (Python)
└── quality.mk          (Python)
```

**Option B: Language subdirectories**
```
.rhiza/make.d/
├── go/
│   ├── bootstrap.mk
│   ├── test.mk
│   └── quality.mk
└── python/
    ├── bootstrap.mk
    ├── test.mk
    └── quality.mk
```

**Recommendation**: **Option A** initially, **Option B** if many language-specific modules.

---

## 7. Testing Strategy

### Unit Tests
```bash
# Test Makefile targets
make test-makefile

# Test bundle resolution
make test-bundles

# Test sync workflow
make test-sync
```

### Integration Tests
```bash
# Create test Go project
mkdir /tmp/test-go-project
cd /tmp/test-go-project
uvx rhiza init --language=go

# Verify templates applied correctly
test -f go.mod
test -f .golangci.yml
test -f .github/workflows/go_ci.yml

# Test build
make install
make test
make lint
```

### Workflow Validation
- Trigger all workflows in a test repository
- Verify matrix builds (Go 1.21-1.24)
- Test release workflow with a test tag
- Validate Docker build

---

## 8. Migration from Python Rhiza

For projects currently using Python Rhiza templates:

### Automated Migration Script

```bash
#!/bin/bash
# migrate-to-go.sh

set -euo pipefail

echo "Migrating from Python Rhiza to Go Rhiza..."

# Backup current state
git checkout -b migrate-to-go
git add -A
git commit -m "Backup before migration to Go Rhiza"

# Remove Python-specific files
rm -f pyproject.toml uv.lock ruff.toml pytest.ini .python-version

# Update .rhiza/template.yml
cat > .rhiza/template.yml <<EOF
repository: Jebel-Quant/rhiza-go
ref: v0.1.0

templates:
  - core
  - github
  - tests

exclude: |
  .rhiza/scripts/customisations/*
EOF

# Sync new templates
make sync

# Manual steps needed
echo ""
echo "✅ Migration complete! Manual steps:"
echo "1. Review changes with: git diff main"
echo "2. Create go.mod: go mod init github.com/yourorg/yourproject"
echo "3. Update .go-version with your Go version"
echo "4. Configure .golangci.yml for your project"
echo "5. Test with: make install && make test"
```

---

## 9. Comparison: Python vs Go Rhiza

| Aspect | Python Rhiza | Go Rhiza |
|--------|--------------|----------|
| **Package Management** | `uv` (fast pip alternative) | `go mod` (built-in) |
| **Linting** | `ruff` (Rust-based) | `golangci-lint` (aggregator) |
| **Formatting** | `ruff format` | `gofmt`, `goimports` |
| **Testing** | `pytest` + plugins | `go test` (built-in) |
| **Coverage** | `pytest-cov` | `go tool cover` |
| **Benchmarking** | `pytest-benchmark` | `go test -bench` |
| **Documentation** | `pdoc` | `godoc`, `pkgsite` |
| **Release Automation** | Custom shell script | `goreleaser` |
| **Container Build** | Single-stage | Multi-stage (optimal) |
| **Dependency Files** | `pyproject.toml` + `uv.lock` | `go.mod` + `go.sum` |
| **Version File** | `.python-version` | `.go-version` |
| **Virtual Environments** | `.venv/` | Not needed (Go workspace) |

---

## 10. Frequently Asked Questions

### Q: Can I use Rhiza-Go with existing Go projects?
**A**: Yes! Run `uvx rhiza init` in your project root, then `uvx rhiza materialize`. Review changes before committing.

### Q: Will sync overwrite my custom configurations?
**A**: No, use `exclude:` patterns in `.rhiza/template.yml` to protect your files. For example:
```yaml
exclude: |
  .golangci.yml    # Using custom linter config
  Makefile         # Custom targets
```

### Q: How do I update to newer Go versions?
**A**: Update `.go-version` and `.github/workflows/go_ci.yml` matrix, then `make sync` to pull other updates.

### Q: Can I customize Makefile targets?
**A**: Yes! Add targets to root `Makefile` (before the `include` line) or use hooks:
```makefile
post-install::
	@go install github.com/my/tool@latest
```

### Q: Does this replace go.mod entirely?
**A**: No! `go.mod` is your project's actual dependency file. Rhiza provides a `go.mod.template` as a starting point, but you manage the final `go.mod`.

### Q: What if I only want some features (e.g., just CI, not Docker)?
**A**: Use bundle selection:
```yaml
templates:
  - core
  - github     # Just GitHub Actions
  # - docker   # Commented out - not using
```

---

## Conclusion

Rhiza's architecture is **remarkably language-agnostic**. The core sync mechanism, bundle system, Makefile orchestration, and CI workflows translate cleanly to Go. The primary work is:

1. **Swap tool-specific configs** (ruff → golangci-lint, pytest → go test)
2. **Adapt Makefile modules** (replace `uv` commands with `go` commands)
3. **Update CI workflows** (Python matrix → Go matrix)
4. **Create Go-specific bundles** (same structure, different files)

The **90% that remains unchanged**:
- `.rhiza/` directory structure
- `rhiza.mk` orchestration logic
- Bundle resolution system
- Sync workflow (`.github/workflows/rhiza_sync.yml`)
- Hook system (`pre-install::`, `post-sync::`, etc.)
- Template materialization via `uvx rhiza materialize`

This makes Go adaptation **straightforward and low-risk** while preserving all the benefits of continuous template synchronization that make Rhiza valuable for Python projects.
