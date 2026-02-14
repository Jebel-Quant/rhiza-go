# Rhiza Test Suite

This directory contains Go-based template validation tests for the rhiza-go project.

## Purpose

Tests in this directory validate the Rhiza template structure and configuration.
They ensure that the template is well-formed and that downstream projects syncing
from this template will receive a correct set of files.

## Running Tests

```bash
make rhiza-test    # Run template self-tests
make validate      # Run full validation (tests + local checks)
```

The `rhiza-test` target looks for `*_test.go` files in this directory and runs them
with `go test`. The `validate` target additionally checks bundle file existence,
Makefile targets, and Go code compilation.

## Test Files

| File | Description |
|------|-------------|
| `structure_test.go` | Validates expected files and directories exist |
| `bundle_test.go` | Validates `template-bundles.yml` structure and file references |
| `makefile_test.go` | Validates required Makefile targets are defined |
| `config_test.go` | Validates `.golangci.yml` parses correctly and has required linters |
| `version_test.go` | Validates `.go-version` and `VERSION` contain valid versions |
| `script_test.go` | Validates `release.sh` has correct shebang and is executable |
| `helpers.go` | Shared test utilities (repo root detection, path helpers) |
