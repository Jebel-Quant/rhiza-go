# Rhiza Test Suite

This directory is reserved for Go-based template validation tests.

## Purpose

Tests in this directory validate the Rhiza template structure and configuration.
They ensure that the template is well-formed and that downstream projects syncing
from this template will receive a correct set of files.

## Running Tests

```bash
make rhiza-test
```

This target looks for `*_test.go` files in this directory and runs them with `go test`.

## Future Tests

Template validation tests will be added in Phase 5 of the roadmap:

- Structure tests: validate expected files exist (`.go-version`, `go.mod`, `.golangci.yml`)
- Bundle tests: validate that every file referenced in `template-bundles.yml` exists
- Makefile tests: validate that key targets exist (`install`, `test`, `fmt`, `lint`, `clean`)
- Config tests: validate `.golangci.yml` parses correctly
- Version tests: validate `.go-version` contains a valid Go version
