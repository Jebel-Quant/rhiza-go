# Rhiza Copilot Instructions

You are working in a project that utilises the `rhiza` framework. Rhiza is a collection of reusable
configuration templates and tooling designed to standardise and streamline modern Go development.

As a Rhiza-based project, this workspace adheres to specific conventions for structure, dependency management, and automation.

## Development Environment

The project uses `make` and Go tooling for development tasks. Go version management is handled via the `.go-version` file.

### Prerequisites

- **Git**: Required for version control
- **Make**: Command runner for all development tasks
- **Go**: Install the version specified in `.go-version` (currently 1.23) from https://go.dev/dl/

### Environment Setup

Setting up your environment is simple:

```bash
make install
```

This single command handles everything:
1. Verifies Go is installed and matches `.go-version`
2. Downloads module dependencies via `go mod download`
3. Installs development tools (`golangci-lint`, `goimports`, etc.)

### Verifying Installation

After installation completes, verify everything works:

```bash
make test  # Should run successfully
```

### Common Development Commands

- **Install Dependencies**: `make install` (downloads Go modules and installs dev tools)
- **Run Tests**: `make test` (runs `go test` with coverage and race detection)
- **Format Code**: `make fmt` (runs `go fmt`, `goimports`, and `golangci-lint --fix`)
- **Lint Code**: `make lint` (runs `golangci-lint` with 25+ linters)
- **Build Documentation**: `make book` (generates Go documentation)
- **Clean Environment**: `make clean` (removes build artifacts and stale branches)

### Troubleshooting

- **Installation fails**: Ensure Go is installed and matches the version in `.go-version`.
- **Go version issues**: The `.go-version` file is the single source of truth. Install the correct version from https://go.dev/dl/.
- **Pre-commit failures**: Run `make fmt` to auto-fix most formatting issues.
- **Module issues**: Run `go mod tidy` to clean up `go.mod` and `go.sum`.

### Important Notes for Agents

- **No Virtual Environment**: Go does not use virtual environments. Tools are installed to `$GOPATH/bin`.
- **Go Version**: The repository specifies the Go version in `.go-version`.
- **All Commands Through Make**: Always use `make` targets rather than running tools directly to ensure consistency.

### Customizing Setup with Hooks

The Makefile provides hooks for customizing the setup process. Add these to the root `Makefile`:

```makefile
# Run before make install
pre-install::
	@echo "Installing system dependencies..."

# Run after make install
post-install::
	@echo "Running custom setup..."
```

**Available hooks:**
- `pre-install` / `post-install`: Runs around `make install`
- `pre-sync` / `post-sync`: Runs around template synchronization
- `pre-validate` / `post-validate`: Runs around validation
- `pre-release` / `post-release`: Runs around releases

**Note**: Use double-colon syntax (`::`) for hooks to allow multiple definitions. See `.rhiza/make.d/README.md` for more details.

### Cloud/CI Environment Setup

The Copilot coding agent environment is automatically configured via official GitHub mechanisms:

- **`.github/workflows/copilot-setup-steps.yml`**: Runs before the agent starts. Sets up Go via `actions/setup-go`, configures git auth for private packages, and runs `make install` to set up a deterministic environment.
- **`.github/hooks/hooks.json`**: Defines session lifecycle hooks:
  - `sessionStart`: Validates the environment is correctly set up (Go available, `go.mod` exists)
  - `sessionEnd`: Runs `make fmt` and `make test` as quality gates after the agent finishes work

These files must exist on the default branch. The agent does not need to run any setup commands manually.

For DevContainers and Codespaces, the `.devcontainer/` configuration and `bootstrap.sh` handle setup automatically. See `docs/DEVCONTAINER.md` for details.

## Project Structure

- `cmd/`: Application entry points
- `pkg/`: Public library packages
- `internal/`: Private internal packages
- `docker/`: Docker configuration
- `.rhiza/`: Rhiza-specific scripts and configurations

## Coding Standards

- **Style**: Follow [Effective Go](https://go.dev/doc/effective_go) conventions. Use `make fmt` to enforce style.
- **Testing**: Write tests alongside source code using `go test`. Use table-driven tests where appropriate. Ensure high coverage.
- **Documentation**: Document code using Go doc comments on exported types, functions, and packages.
- **Dependencies**: Manage dependencies in `go.mod`. Use `go get` to add dependencies.

## Workflow

1.  **Setup**: Run `make install` to set up the environment.
2.  **Develop**: Write code in `cmd/`, `pkg/`, or `internal/` with tests alongside.
3.  **Test**: Run `make test` to verify changes.
4.  **Format**: Run `make fmt` before committing.
5.  **Lint**: Run `make lint` to check for issues.

## Key Files

- `Makefile`: Main entry point for tasks.
- `go.mod`: Go module definition and dependencies.
- `go.sum`: Go module checksums.
- `.go-version`: Single source of truth for Go version.
- `.golangci.yml`: Linter configuration (25+ linters).
- `.github/workflows/copilot-setup-steps.yml`: Agent environment setup (runs before agent starts).
- `.github/hooks/hooks.json`: Agent session hooks (quality gates).
