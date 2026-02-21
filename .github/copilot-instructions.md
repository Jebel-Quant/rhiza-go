# Rhiza Copilot Instructions

You are working in a Go project that uses the **Rhiza** framework — a living template system that
standardises project structure, build tooling, CI/CD, and code quality for Go applications.

Module path: `github.com/jebel-quant/rhiza-go`

---

## Critical Rules

1. **Never edit files under `.rhiza/`** — they are managed by the upstream template and will be overwritten on sync. Customise behaviour via hooks in the root `Makefile` or `local.mk`.
2. **Always use `make` targets** — never run `go fmt`, `golangci-lint`, or test tools directly. The Makefile ensures correct flags, environment, and tool versions.
3. **Run `make fmt` then `make test` before finishing** — these are the quality gates enforced by session-end hooks.
4. **Go version is pinned in `.go-version`** — currently `1.25.5`. This is the single source of truth; do not hardcode version numbers elsewhere.
5. **Project version lives in `VERSION`** — bump it via `make bump`, never edit directly.

---

## Development Commands

| Command | Purpose |
|---------|---------|
| `make install` | Download modules, install dev tools (`golangci-lint`, `goimports`, `gotestsum`, etc.) |
| `make build` | Compile all packages and binaries to `bin/` |
| `make test` | Run tests with `gotestsum`, race detector, coverage report |
| `make test-verbose` | Verbose test output |
| `make test-coverage` | Coverage with threshold check (default 80%) |
| `make fmt` | Format with `go fmt` + `goimports` |
| `make lint` | Run `golangci-lint` (25+ linters defined in `.golangci.yml`) |
| `make vet` | Run `go vet ./...` |
| `make tidy` | Run `go mod tidy` |
| `make clean` | Remove build artifacts, caches, and stale branches |
| `make book` | Generate documentation site |

---

## Architecture & Dependency Rules

```
cmd/  ->  pkg/  ->  (external deps)
  |         |
internal/  <-  (not imported by pkg/)
```

- **`cmd/<app>/`** — Binary entry points. Each has `func main()` that delegates to a testable `run(w io.Writer) error` function. Imports `pkg/` and `internal/`, never the reverse.
- **`pkg/`** — Public library packages, importable by external consumers. Must NOT import `internal/`.
- **`internal/`** — Private helpers. Go enforces that external modules cannot import these.
- **`docker/`** — Dockerfile and build context.
- **`.rhiza/`** — Framework-managed files (Makefile extensions, scripts, assets). **Do not edit.**
- **`.github/`** — Workflows, hooks, agents, and actions.

### Current Packages

| Package | Responsibility |
|---------|---------------|
| `cmd/rhiza-go` | CLI entry point; wires `pkg/config` and writes to stdout |
| `pkg/config` | Loads application config from `.go-version`, `VERSION`; parses `.rhiza/template.yml` |
| `internal/utils` | Path sanitisation (`SanitizePath`), slice helpers (`Contains`) |

### Adding New Code

- New binary: `cmd/<name>/main.go` with a testable `run()` function
- New public package: `pkg/<name>/` with Go doc comments on all exports
- New internal package: `internal/<name>/`
- New Make target: root `Makefile` or `local.mk` (never `.rhiza/`)
- New dependency: `go get <module>` then `go mod tidy`

---

## Go Coding Conventions

Follow [Effective Go](https://go.dev/doc/effective_go) and the patterns already in the codebase:

### Error Handling

- Always wrap errors with context: `fmt.Errorf("loading config: %w", err)`
- Return errors instead of calling `os.Exit` — only `main()` should exit
- Use `%w` for wrapping (allows `errors.Is` / `errors.As` upstream)

### Naming

- Exported symbols get Go doc comments: `// Load returns a Config populated from project files.`
- Package names are lowercase, single-word where possible
- Interfaces are named by behaviour: `Reader`, `Writer`, `Closer`
- Avoid stutter: `config.Config` is fine, but `config.ConfigLoader` is not

### Testing

- Test files live next to source: `config.go` -> `config_test.go`
- Use **table-driven tests** for systematic edge-case coverage:
  ```go
  tests := []struct {
      name    string
      input   string
      want    string
      wantErr bool
  }{
      {name: "valid", input: "foo", want: "foo"},
      {name: "empty", input: "", wantErr: true},
  }
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) { ... })
  }
  ```
- Use `t.TempDir()` for filesystem tests (automatic cleanup)
- Use `t.Helper()` in test helper functions
- Prefer injecting `io.Writer` over mocking `os.Stdout`
- Entry points use the **testable main** pattern: `run(w io.Writer) error`

### Security

- Validate file paths before I/O — use `filepath.Clean` and verify the result stays within bounds
- Annotate intentional security exceptions with `// #nosec G304 -- reason`
- The linter suite includes `gosec` — it will flag unsafe patterns

### Imports

- Group imports: stdlib, then a blank line, then external, then internal
- `goimports` (run via `make fmt`) handles ordering automatically

---

## Linting

The project uses `golangci-lint` with 25+ linters configured in `.golangci.yml`. Key linters include:

- `errcheck` — unchecked errors (with type assertion checks)
- `govet` — all analysers enabled
- `gosec` — security issues (excluded from `_test.go` files)
- `revive` — Go style (var-naming, exported, error conventions)
- `staticcheck` — advanced static analysis
- `gocritic` — opinionated suggestions
- `misspell` — typos in comments/strings
- `bodyclose` — unclosed HTTP response bodies
- `unparam` — unused function parameters

Test files are exempt from `gosec` and `errcheck`.

---

## Makefile Hook System

Customise lifecycle behaviour with double-colon hooks in the root `Makefile`:

```makefile
pre-install::
	@echo "Custom pre-install step"

post-install::
	@echo "Custom post-install step"
```

Available hooks: `pre-install`/`post-install`, `pre-sync`/`post-sync`, `pre-validate`/`post-validate`, `pre-release`/`post-release`, `pre-bump`/`post-bump`.

---

## CI/CD Environment

- **`copilot-setup-steps.yml`** — Runs before the agent: sets up Go (from `.go-version`), configures git auth, runs `make install`.
- **`hooks.json`** — Session lifecycle hooks:
  - `sessionStart` validates Go is available, correct version, `go.mod` exists, dev tools present
  - `sessionEnd` runs `make fmt`, `make lint`, and `make test` as quality gates
- Dev tools are installed to `$GOPATH/bin`. No virtual environments.

---

## Key Files

| File | Purpose | Editable? |
|------|---------|-----------|
| `Makefile` | Thin entry point, includes `.rhiza/rhiza.mk` | Yes |
| `go.mod` / `go.sum` | Module definition and checksums | Yes (via `go get`/`go mod tidy`) |
| `.go-version` | Go version (single source of truth) | Yes (bump carefully) |
| `VERSION` | Project version | Via `make bump` only |
| `.golangci.yml` | Linter configuration | Synced — override via `local.mk` |
| `.rhiza/rhiza.mk` | Core build logic | **No** — framework-managed |
| `.rhiza/make.d/*.mk` | Modular build extensions | **No** — framework-managed |
| `.github/workflows/*.yml` | CI/CD pipelines | Synced — some are framework-managed |
| `.github/hooks/` | Agent session hooks | Yes |
| `.github/agents/` | Copilot agent definitions | Yes |

---

## External Dependency

The module has a single external dependency: `gopkg.in/yaml.v3` for YAML parsing.
All other imports are from the Go standard library.

---

## Workflow Summary

1. Write code in `cmd/`, `pkg/`, or `internal/` with tests alongside
2. `make build` — verify it compiles
3. `make test` — verify tests pass with coverage
4. `make fmt` — auto-format before committing
5. `make lint` — check for issues
6. Commit with a clear, conventional message
