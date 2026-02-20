# Requirements Folder

This folder is reserved for future use. In the Go adaptation of Rhiza, dependencies
are managed through `go.mod` and `go.sum` at the project root.

## Go Dependency Management

Go modules handle all dependency management:

```bash
# Download dependencies
go mod download

# Add a new dependency
go get github.com/example/package

# Tidy dependencies
go mod tidy
```

## Development Tools

Development tools are installed via `make install`:

- `golangci-lint` — Linting
- `goimports` — Import formatting
- `gomarkdoc` — API documentation generator (produces self-contained Markdown)
- `goreleaser` — Release automation; `goreleaser check` runs in `make lint` and pre-commit
- `syft` — SBOM generation (CycloneDX format, used by GoReleaser)
- `pkgsite` — Interactive local documentation browser (`make docs-serve`)

## CI/CD

GitHub Actions workflows use `go mod download` to install dependencies.
