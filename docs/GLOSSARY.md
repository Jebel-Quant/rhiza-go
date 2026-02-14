# Rhiza-Go Glossary

A comprehensive glossary of terms used in the Rhiza-Go template system.

## Core Concepts

### Living Templates
A template approach where configuration files remain synchronized with an upstream source over time, as opposed to traditional "one-shot" template generators (like cookiecutter or copier) that generate files once and then disconnect from the source.

### Template Sync
The process of pulling updates from the upstream Rhiza-Go repository into a downstream project. Executed via `make sync`. Allows projects to receive ongoing improvements without manual copying.

### Downstream Project
A project that has adopted Rhiza-Go templates. It receives updates from the upstream Rhiza-Go repository through template sync.

### Upstream Repository
The source Rhiza-Go repository (`jebel-quant/rhiza-go`) that contains the canonical template configurations. Changes here propagate to downstream projects via sync.

## Directory Structure

### `.rhiza/`
The core directory containing Rhiza's template system files. This directory is synced from upstream and should generally not be modified directly.

### `.rhiza/rhiza.mk`
The main Makefile containing core Rhiza functionality. Included by the project's root `Makefile`. Contains 268+ lines of make targets and logic.

### `.rhiza/make.d/`
Directory for modular Makefile extensions. Files are auto-loaded in numeric order:
- `00-19`: Configuration files
- `20-79`: Task definitions
- `80-99`: Hook implementations

### `.rhiza/scripts/`
Shell scripts for Rhiza operations (e.g., `release.sh`). POSIX-compliant for portability.

### `.rhiza/template.yml`
Configuration file defining which files to sync from upstream, include/exclude patterns, and sync behavior.

### `local.mk`
Optional file for project-specific Makefile extensions. Not synced from upstream, allowing local customization without conflicts.

## Makefile System

### Double-Colon Targets (`::`)
Make targets defined with `::` instead of `:`. These are "hook" targets that can be extended by downstream projects without overriding the original implementation.

### Hook Targets
Extension points in the Makefile system. Available hooks:
- `pre-install::` / `post-install::` - Before/after dependency installation
- `pre-sync::` / `post-sync::` - Before/after template sync
- `pre-validate::` / `post-validate::` - Before/after project validation
- `pre-release::` / `post-release::` - Before/after release creation
- `pre-bump::` / `post-bump::` - Before/after version bump

### Make Target
A named command in the Makefile (e.g., `make test`, `make fmt`). Rhiza provides 40+ targets out of the box.

## Version Management

### Version Bump
Incrementing the version number in the `VERSION` file. Types:
- `major`: Breaking changes (1.0.0 → 2.0.0)
- `minor`: New features (1.0.0 → 1.1.0)
- `patch`: Bug fixes (1.0.0 → 1.0.1)

### Release Tag
A git tag prefixed with `v` (e.g., `v1.2.3`) that triggers the release workflow.

## CI/CD

### SLSA Provenance
Supply-chain Levels for Software Artifacts. Cryptographic attestations proving that build artifacts were produced by a specific CI workflow. Enables supply chain verification.

### SBOM (Software Bill of Materials)
A formal record of components used to build software. Generated in SPDX or CycloneDX formats for supply chain transparency. Generated via `syft` for Go binaries.

## Tools

### Go
The Go programming language. Rhiza-Go uses Go for all project development, testing, and building.

### golangci-lint
A fast, configurable Go linter aggregator. Runs 25+ linters in parallel. Configured in `.golangci.yml`.

### goimports
A tool that updates Go import lines, adding missing ones and removing unreferenced ones. Also formats code like `gofmt`.

### go vet
Go's built-in static analysis tool. Examines Go source code and reports suspicious constructs.

### go test
Go's built-in testing framework. Supports unit tests, benchmarks, and examples. Run via `make test`.

### CodeQL
GitHub's semantic code analysis engine. Scans for security vulnerabilities in Go code and GitHub Actions workflows.

## Configuration Files

### `go.mod`
The Go module definition file. Contains the module path, Go version, and dependency requirements.

### `go.sum`
Checksums file containing cryptographic hashes of module dependencies. Ensures reproducible builds across environments.

### `.go-version`
Single-line file specifying the Go version for the project. Used by tooling and CI to ensure consistent Go versions.

### `.golangci.yml`
Configuration for golangci-lint. Defines enabled linters, rules, and per-file exceptions.

### `.pre-commit-config.yaml`
Configuration for pre-commit hooks. Defines checks that run before each git commit.

### `.editorconfig`
Cross-editor configuration for consistent coding style (indentation, line endings, etc.).

### `renovate.json`
Configuration for Renovate, an automated dependency update bot. Configured for `gomod` manager.

### `VERSION`
Single-line file containing the project version (e.g., `0.1.0`). Single source of truth for versioning.

## Workflows

### CI Workflow
Continuous Integration workflow that runs tests on every push and pull request.

### Release Workflow
Multi-phase workflow triggered by version tags. Builds Go binaries for multiple platforms, creates GitHub releases, generates SBOM, and optionally publishes devcontainer images.

### Sync Workflow
Workflow that synchronizes template files from upstream Rhiza-Go repository.

### CodeQL Workflow
Workflow running code security analysis using GitHub's CodeQL engine for Go and GitHub Actions.

## Commands Reference

| Command | Description |
|---------|-------------|
| `make install` | Install dependencies and set up environment |
| `make test` | Run `go test` with coverage and race detection |
| `make fmt` | Format code with `go fmt`, `goimports`, and `golangci-lint --fix` |
| `make lint` | Run `golangci-lint` with 25+ linters |
| `make vet` | Run `go vet` static analysis |
| `make sync` | Sync templates from upstream |
| `make bump` | Bump version number |
| `make release` | Create and push release tag |
| `make help` | Show all available targets |
