# Rhiza Scripts

This directory contains utility scripts for Rhiza-Go project management.

## Available Scripts

### install.sh

Standalone installation script for Go projects. Installs dependencies and development tools.

**Usage:**

```bash
# Full installation
./install.sh

# Preview what will be installed (dry-run)
./install.sh --dry-run

# Install dependencies only (skip dev tools)
./install.sh --skip-tools

# Show detailed output
./install.sh --verbose

# Show help
./install.sh --help
```

**Features:**

- ✅ **Go version validation**: Checks installed Go version against `.go-version` (compatible with major.minor versions)
- ✅ **Dependency installation**: Runs `go mod download` and `go mod tidy`
- ✅ **Development tools**: Installs golangci-lint, goimports, govulncheck, gosec
- ✅ **PATH setup**: Provides guidance for adding GOPATH/bin to PATH
- ✅ **Installation verification**: Validates that tools are accessible
- ✅ **Dry-run mode**: Preview changes without modifying the system
- ✅ **POSIX-sh compatible**: Works on any Unix-like system

**Installation Process:**

1. **Go Check**: Verifies Go is installed and compatible with `.go-version`
2. **GOPATH Setup**: Checks if GOPATH/bin is in PATH and provides setup instructions
3. **Dependencies**: Downloads and tidies Go module dependencies
4. **Dev Tools**: Installs development tools via `go install`
5. **Verification**: Confirms all tools are accessible

**Use Cases:**

- CI/CD pipelines where Make may not be available
- Quick setup on new systems
- Custom installation workflows
- Testing installation in isolation
- Automated environment setup scripts

**Example CI/CD Usage:**

```yaml
# GitHub Actions
- name: Install dependencies
  run: ./install.sh --skip-tools

# GitLab CI
script:
  - ./install.sh
```

**Exit Codes:**

- `0`: Success
- `1`: Error (Go not installed, missing requirements, etc.)

---

### release.sh

Creates and pushes release tags based on the VERSION file.

**Usage:**

```bash
# Create and push release tag
.rhiza/scripts/release.sh

# Dry-run mode (preview without changes)
.rhiza/scripts/release.sh --dry-run

# Show help
.rhiza/scripts/release.sh --help
```

**Features:**

- ✅ Reads version from `VERSION` file
- ✅ Creates git tag with `v` prefix (e.g., `v1.0.0`)
- ✅ Checks for uncommitted changes
- ✅ Validates branch is up-to-date with remote
- ✅ Supports GPG-signed tags
- ✅ Dry-run mode for safe preview
- ✅ POSIX-sh compatible

**Release Process:**

1. **Version Check**: Reads current version from `VERSION` file
2. **Branch Validation**: Ensures you're on the default branch
3. **Status Check**: Verifies no uncommitted changes
4. **Remote Sync**: Confirms branch is up-to-date with remote
5. **Tag Creation**: Creates annotated (or signed) tag
6. **Tag Push**: Pushes tag to trigger release workflow

**Use Cases:**

- Manual releases from command line
- Automated release workflows
- Version management

## Script Standards

All scripts in this directory follow Rhiza standards:

- **POSIX-sh compatible**: Use `#!/bin/sh` and avoid Bash-specific features
- **Error handling**: Use `set -eu` for strict error handling
- **Colored output**: Use ANSI color codes for better readability
- **Help messages**: Provide `--help` flag with usage examples
- **Dry-run support**: Offer `--dry-run` for safe preview
- **Clear messaging**: Use `[INFO]`, `[WARN]`, `[ERROR]`, `[PASS]` prefixes
- **Exit codes**: Return 0 on success, 1 on error

## Adding New Scripts

When adding new scripts to this directory:

1. Use POSIX-sh (`#!/bin/sh`)
2. Add `set -eu` at the top for error handling
3. Include help message with `--help` flag
4. Support `--dry-run` for non-destructive preview
5. Use colored output with standard prefixes
6. Document the script in this README
7. Make the script executable: `chmod +x script.sh`
8. Test on different shells (sh, bash, zsh)

## Testing Scripts

```bash
# Test help message
./script.sh --help

# Test dry-run mode
./script.sh --dry-run

# Test actual execution
./script.sh

# Test POSIX compatibility
sh ./script.sh
dash ./script.sh  # if available
```
