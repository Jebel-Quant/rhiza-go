# Testing Guide

This document describes the testing infrastructure and approaches used in Rhiza-Go projects.

## Overview

Rhiza-Go uses Go's built-in testing framework (`go test`) with additional tooling for comprehensive quality assurance:

1. **Unit Testing** — Standard Go tests using `testing.T`
2. **Table-Driven Tests** — Idiomatic Go pattern for testing multiple cases
3. **Benchmarking** — Performance measurement using `testing.B`
4. **Race Detection** — Built-in race condition detection with `-race` flag

## Running Tests

### Using Make (Recommended)

```bash
# Run all tests with coverage and race detection
make test

# Run benchmarks
go test -bench=. ./...
```

### Using Go Directly

```bash
# Run all tests
go test ./...

# Run tests in a specific package
go test ./pkg/config/ -v

# Run a specific test function
go test ./pkg/config/ -run TestConfigName -v

# Run with race detection
go test -race ./...

# Run with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Run benchmarks
go test -bench=. -benchmem ./...
```

## Writing Tests

### Unit Tests

Place test files alongside the code they test, using the `_test.go` suffix:

```go
// pkg/config/config_test.go
package config

import "testing"

func TestConfigName(t *testing.T) {
    cfg := New()
    if cfg.Name() != "expected" {
        t.Errorf("got %q, want %q", cfg.Name(), "expected")
    }
}
```

### Table-Driven Tests

The idiomatic Go approach for testing multiple cases:

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -2, -3},
        {"zero", 0, 0, 0},
        {"mixed", -1, 1, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d, want %d", tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

### Benchmarks

Measure performance with Go's built-in benchmarking:

```go
func BenchmarkProcess(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Process(testData)
    }
}
```

Run benchmarks:
```bash
go test -bench=. -benchmem ./...
```

### Test Helpers

Use `t.Helper()` for cleaner test output:

```go
func assertEqual(t *testing.T, got, want string) {
    t.Helper()
    if got != want {
        t.Errorf("got %q, want %q", got, want)
    }
}
```

## Test Organisation

### Project Structure

```text
cmd/
├── rhiza-go/
│   ├── main.go
│   └── main_test.go          # Tests for main package
pkg/
├── config/
│   ├── config.go
│   └── config_test.go        # Tests for config package
internal/
├── utils/
│   ├── utils.go
│   └── utils_test.go         # Tests for utils package
```

### Template Tests

Rhiza template validation tests live in `.rhiza/tests/`:

```bash
# Run template self-tests
make rhiza-test
```

## Integration with CI/CD

### GitHub Actions

Tests run automatically via `.github/workflows/rhiza_ci.yml`:
- Runs on every push and pull request
- Includes race detection (`-race`)
- Generates coverage reports
- Fails if tests don't pass

### Coverage

Coverage is collected during `make test` and reported in the CI output. View detailed coverage locally:

```bash
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
open coverage.html
```

## Best Practices

### Writing Good Tests

1. **Test behaviour, not implementation** — Focus on what the function does, not how
2. **Use table-driven tests** — Reduce boilerplate for multiple test cases
3. **Test edge cases** — Empty inputs, nil values, boundary conditions
4. **Keep tests fast** — Avoid network calls and file I/O where possible
5. **Use `t.Parallel()`** — Run independent tests concurrently
6. **Name tests descriptively** — Use `Test<Function>_<Scenario>` naming

### Test Fixtures

Use `testdata/` directories for test fixtures (automatically ignored by the Go toolchain):

```go
func TestParseConfig(t *testing.T) {
    data, err := os.ReadFile("testdata/config.json")
    if err != nil {
        t.Fatal(err)
    }
    // ... test with data
}
```

### Subtests

Use subtests for organised test output:

```go
func TestAPI(t *testing.T) {
    t.Run("Create", func(t *testing.T) { /* ... */ })
    t.Run("Read", func(t *testing.T) { /* ... */ })
    t.Run("Update", func(t *testing.T) { /* ... */ })
    t.Run("Delete", func(t *testing.T) { /* ... */ })
}
```

## Troubleshooting

### Tests Fail with Race Conditions

If tests fail with the `-race` flag:
1. Check for shared mutable state between goroutines
2. Use `sync.Mutex` or channels for synchronisation
3. Use `t.Parallel()` only for truly independent tests

### Tests Are Slow

If tests take too long:
1. Use `testing.Short()` to skip long-running tests: `go test -short ./...`
2. Mock external dependencies
3. Use `t.Parallel()` for independent tests
4. Profile with `go test -cpuprofile=cpu.out ./...`

### Coverage Is Low

If coverage is below the threshold:
1. Run `go test -coverprofile=coverage.out ./...`
2. View uncovered lines: `go tool cover -html=coverage.out`
3. Focus on testing critical paths first

## References

- [Go Testing Package](https://pkg.go.dev/testing)
- [Go Testing FAQ](https://go.dev/doc/faq#testing)
- [Table-Driven Tests](https://go.dev/wiki/TableDrivenTests)
- [Go Code Coverage](https://go.dev/blog/cover)
