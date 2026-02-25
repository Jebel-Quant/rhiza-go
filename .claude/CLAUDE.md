# CLAUDE.md — Claude Code Project Instructions

This file provides context and rules for Claude Code when working in this repository.

## Project Overview

**rhiza-go** is a Go application built on the **Rhiza** framework — a living template system that
standardises project structure, build tooling, CI/CD, and code quality for Go development.

- **Module**: `github.com/jebel-quant/rhiza-go`
- **Go version**: pinned in `.go-version` (currently `1.25.6`)
- **Project version**: `VERSION` file (currently `0.2.2`)
- **External deps**: `gopkg.in/yaml.v3` only; everything else is stdlib

---

## Critical Rules

1. **Never edit files under `.rhiza/`** — framework-managed, overwritten on sync.
2. **Always use `make` targets** — never run Go tools directly.
3. **Run `make fmt` and `make test` after every change** — these are the quality gates.
4. **Do not hardcode the Go version** — read from `.go-version` at runtime.

---

## Commands

```bash
make install        # Download modules + install dev tools (golangci-lint, goimports, gotestsum, etc.)
make build          # Compile all packages → bin/
make test           # Tests with gotestsum, race detector, coverage (threshold: 80%)
make test-verbose   # Verbose test output
make fmt            # go fmt + goimports
make lint           # golangci-lint (25+ linters from .golangci.yml)
make vet            # go vet ./...
make tidy           # go mod tidy
make clean          # Remove build artifacts, caches, stale branches
```

---

## Architecture

```
cmd/  →  pkg/  →  (external deps)
  ↓
internal/              (pkg/ must NOT import internal/)
```

| Directory | Purpose | Editable? |
|-----------|---------|-----------|
| `cmd/` | Binary entry points with testable `run(w io.Writer) error` | Yes |
| `pkg/` | Public library packages (importable externally) | Yes |
| `internal/` | Private helpers (Go-enforced visibility) | Yes |
| `docker/` | Dockerfile and build context | Yes |
| `.rhiza/` | Framework config, Makefile extensions, scripts | **No** |
| `.github/` | Workflows, hooks, agents | Mostly yes |

### Current Packages

- `cmd/rhiza-go` — CLI entry point; calls `pkg/config.Load()`, writes to stdout
- `pkg/config` — Loads `Config{Version, GoVersion}` from `.go-version`/`VERSION`; parses `.rhiza/template.yml`
- `internal/utils` — `SanitizePath()`, `Contains()` helpers

---

## Coding Standards

### Style
- Follow [Effective Go](https://go.dev/doc/effective_go)
- `make fmt` enforces `go fmt` + `goimports`

### Error Handling
- Wrap with context: `fmt.Errorf("loading config: %w", err)`
- Use `%w` verb for wrappable errors (`errors.Is`/`errors.As`)
- Only `main()` calls `os.Exit`; everything else returns errors

### Naming
- Go doc comments on all exported symbols
- Package names: lowercase, single-word
- No stutter: `config.Config` ok, `config.ConfigLoader` not ok

### Testing
- Tests live next to source (`foo.go` → `foo_test.go`)
- **Table-driven tests** for edge cases:
  ```go
  tests := []struct {
      name    string
      input   string
      want    string
      wantErr bool
  }{...}
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) { ... })
  }
  ```
- `t.TempDir()` for filesystem tests
- `t.Helper()` in test helpers
- **Testable main pattern**: `run(w io.Writer) error` with `bytes.Buffer`

### Security
- `filepath.Clean` + bounds checking before file I/O
- `// #nosec G304 -- reason` for intentional exceptions
- `gosec` linter catches unsafe patterns

### Imports
- Group: stdlib → blank line → external → internal
- `goimports` via `make fmt` handles ordering

---

## Linting

`golangci-lint` with 25+ linters (`.golangci.yml`). Key ones:

- `errcheck` — unchecked errors (type assertion checks enabled)
- `govet` — all analysers
- `gosec` — security (excluded on `_test.go`)
- `revive` — style (var-naming, exported, error patterns)
- `staticcheck`, `gocritic`, `misspell`, `bodyclose`, `unparam`

---

## Makefile Hooks

Customise with double-colon targets in root `Makefile`:

```makefile
pre-install::
	@echo "before install"
post-install::
	@echo "after install"
```

Hooks: `pre-install`/`post-install`, `pre-sync`/`post-sync`, `pre-validate`/`post-validate`, `pre-release`/`post-release`, `pre-bump`/`post-bump`

---

## Key Files

| File | Purpose |
|------|---------|
| `Makefile` | Thin entry point → includes `.rhiza/rhiza.mk` |
| `go.mod` | Module definition (`go get` / `go mod tidy`) |
| `.go-version` | Go version — single source of truth |
| `VERSION` | Project version — use `make bump` |
| `.golangci.yml` | Linter config (synced from template) |
| `.rhiza/rhiza.mk` | Core build logic (do not edit) |
| `.rhiza/make.d/*.mk` | Build extensions (do not edit) |
| `docs/ARCHITECTURE.md` | Full architecture documentation |

---

## Workflow

1. Write code in `cmd/`, `pkg/`, or `internal/` with tests
2. `make build` — verify compilation
3. `make test` — verify tests pass
4. `make fmt` — format code
5. `make lint` — check for issues
6. Commit with conventional message
