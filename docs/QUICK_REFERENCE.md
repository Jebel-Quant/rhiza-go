# Rhiza-Go Quick Reference Card

A concise reference for common Rhiza-Go operations.

## Essential Commands

| Command | Description |
|---------|-------------|
| `make install` | Install dependencies and set up environment |
| `make test` | Run `go test` with coverage and race detection |
| `make fmt` | Format code with `go fmt`, `goimports`, `golangci-lint --fix` |
| `make help` | Show all available targets |

## Version & Release

| Command | Description |
|---------|-------------|
| `make bump` | Bump version (prompts for major/minor/patch) |
| `make bump BUMP=patch` | Bump patch version directly |
| `make bump BUMP=minor` | Bump minor version directly |
| `make bump BUMP=major` | Bump major version directly |
| `make release` | Create and push release tag |

## Code Quality

| Command | Description |
|---------|-------------|
| `make fmt` | Format + lint with auto-fix |
| `make lint` | Run golangci-lint |
| `make vet` | Run go vet static analysis |
| `make pre-commit` | Run all pre-commit hooks |

## Template Sync

| Command | Description |
|---------|-------------|
| `make sync` | Sync templates from upstream Rhiza-Go |

## Running Tests

```bash
# All tests
make test

# Specific package
go test ./pkg/config/ -v

# Specific test function
go test ./pkg/config/ -run TestConfigName -v

# With verbose output
go test -v -race ./...

# With coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Directory Structure

```text
.rhiza/
├── rhiza.mk          # Core Makefile logic
├── make.d/           # Modular extensions (auto-loaded)
│   ├── 00-19*.mk     # Configuration
│   ├── 20-79*.mk     # Task definitions
│   └── 80-99*.mk     # Hook implementations
├── scripts/          # Shell scripts (release.sh)
└── template.yml      # Sync configuration
```

## Hook Targets

Extend these with `::` syntax in `local.mk` or `.rhiza/make.d/`:

| Hook | When it runs |
|------|--------------|
| `pre-install::` | Before dependency installation |
| `post-install::` | After dependency installation |
| `pre-sync::` | Before template sync |
| `post-sync::` | After template sync |
| `pre-validate::` | Before project validation |
| `post-validate::` | After project validation |
| `pre-release::` | Before release creation |
| `post-release::` | After release creation |
| `pre-bump::` | Before version bump |
| `post-bump::` | After version bump |

## Key Files

| File | Purpose |
|------|---------|
| `go.mod` | Go module definition and dependencies |
| `go.sum` | Dependency checksums for reproducible builds |
| `.go-version` | Go version (single source of truth) |
| `VERSION` | Project version (single source of truth) |
| `.golangci.yml` | Linter configuration (25+ linters) |
| `local.mk` | Local Makefile customizations (not synced) |

## Go Execution

Use Go tooling directly for development:

```bash
go run cmd/rhiza-go/main.go   # Run main application
go test ./...                  # Run all tests
go build ./...                 # Build all packages
go vet ./...                   # Static analysis
```

## Version Format

- Source of truth: `VERSION` file
- Git tags: `v` prefix (e.g., `v1.2.3`)
- Semantic versioning: `MAJOR.MINOR.PATCH`

## CI Workflows

| Workflow | Trigger |
|----------|---------|
| CI | Push, Pull Request |
| Release | Tag `v*` |
| CodeQL | Push, Schedule |
| Sync | Manual |

## Common Patterns

### Add a custom make target

Create `.rhiza/make.d/50-custom.mk`:
```makefile
my-target:
	@echo "Custom target"
```

### Extend a hook

Add to `local.mk`:
```makefile
post-install::
	@echo "Additional setup after install"
```

### Skip CI on commit

```bash
git commit -m "docs: update readme [skip ci]"
```
