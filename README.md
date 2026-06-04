<div align="center">

# <img src=".rhiza/assets/rhiza-logo.svg" alt="Rhiza Logo" width="30" style="vertical-align: middle;"> Rhiza-Go

![GitHub Release](https://img.shields.io/github/v/release/jebel-quant/rhiza-go?sort=semver&color=2FA4A9&label=rhiza-go)
![Synced with Rhiza](https://img.shields.io/badge/synced%20with-rhiza-2FA4A9?color=2FA4A9)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.23-00ADD8?logo=go)](https://go.dev/)
[![CI](https://github.com/Jebel-Quant/rhiza-go/actions/workflows/rhiza_ci.yml/badge.svg?event=push)](https://github.com/Jebel-Quant/rhiza-go/actions/workflows/rhiza_ci.yml)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/jebel-quant/rhiza-go)

# Strong roots for Go projects
Creating and maintaining technical harmony across Go repositories.

A collection of reusable configuration templates
for modern Go projects.
Save time and maintain consistency across your Go projects
with these pre-configured templates.

![Last Updated](https://img.shields.io/github/last-commit/jebel-quant/rhiza-go/main?label=Last%20updated&color=blue)

In the original Greek, spelt **ῥίζα**, pronounced *ree-ZAH*, and having the literal meaning **root**.

</div>

## 🌟 Why Rhiza-Go?

**Unlike traditional project templates** (like cookiecutter or copier) that generate a one-time snapshot of configuration files, **Rhiza-Go provides living templates** that evolve with your Go project. Classic templates help you start a project, but once generated, your configuration drifts away from the template as best practices change. Rhiza-Go takes a different approach: it enables **continuous synchronization**, allowing you to selectively pull template updates into your project over time through automated workflows. This means you can benefit from improvements to CI/CD workflows, linting rules, and development tooling without manually tracking upstream changes. Think of it as keeping your project's foundation fresh and aligned with modern Go practices, while maintaining full control over what gets updated.

### How It Works

Rhiza-Go uses a simple configuration file (`.rhiza/template.yml`) to control which templates sync to your project:

```yaml
# .rhiza/template.yml
repository: Jebel-Quant/rhiza-go
ref: v0.1.0

include: |
  .github/workflows/*.yml
  .golangci.yml
  Makefile
  .rhiza/make.d/*.mk

exclude: |
  .rhiza/scripts/customisations/*
```

**What you're seeing:**
- **`repository`** - The upstream template source (**can be any repository!**)
- **`ref`** - Which version tag/branch to sync from (e.g., `v0.1.0` or `main`)
- **`include`** - File patterns to pull from the template (CI workflows, linting configs, etc.)
- **`exclude`** - Paths to skip, protecting your customisations

## 📚 Table of Contents

- [Why Rhiza-Go?](#-why-rhiza-go)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [What You Get](#-what-you-get)
- [Available Tasks](#-available-tasks)
- [Project Structure](#-project-structure)
- [CI/CD Support](#-cicd-support)
- [Contributing](#-contributing)

## 📦 Installation

Rhiza-Go can be installed in several ways depending on your needs:

### Quick Install (Recommended)

**macOS and Linux:**
```bash
curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sh
```

**Homebrew:**
```bash
brew tap Jebel-Quant/tap
brew install rhiza-go
```

**Go Install:**
```bash
go install github.com/jebel-quant/rhiza-go/cmd/rhiza-go@latest
```

**Windows:**

Download the latest release from the [releases page](https://github.com/Jebel-Quant/rhiza-go/releases/latest) or use the PowerShell script in [INSTALL.md](INSTALL.md).

### Full Installation Guide

For detailed installation instructions including:
- Manual downloads and verification
- Building from source
- Docker usage
- Troubleshooting

See the complete [Installation Guide](INSTALL.md).

## 🚀 Quick Start

### Prerequisites (For Development)

- **Git**: Required for version control
- **Make**: Command runner for all development tasks
- **Go 1.23+**: The project uses Go 1.23 (specified in `.go-version`)

### Environment Setup

Setting up your environment is simple:

```bash
make install
```

This single command handles everything:
1. Checks that Go is installed at the required version
2. Downloads and installs all dependencies from `go.mod`
3. Installs development tools (golangci-lint, goimports)

### Verifying Installation

After installation completes, verify everything works:

```bash
make test  # Should run successfully
```

### Common Development Commands

- **Install Dependencies**: `make install` (full setup: Go deps, dev tools)
- **Run Tests**: `make test` (runs `go test` with coverage)
- **Format Code**: `make fmt` (runs `go fmt`, `gofmt -s`, `goimports`)
- **Lint Code**: `make lint` (runs `golangci-lint`)
- **Check Formatting**: `make check-fmt` (verifies formatting without changing)
- **Vet Code**: `make vet` (runs `go vet`)
- **Build**: `go build ./...`
- **Clean Environment**: `make clean` (removes build artifacts and stale branches)

### Running the Application

```bash
# Run directly
go run cmd/rhiza-go/main.go

# Or build and run
go build -o bin/rhiza-go cmd/rhiza-go/main.go
./bin/rhiza-go
```

## ✨ What You Get

### Core Features

- 🚀 **CI/CD Templates** - Ready-to-use GitHub Actions workflows for Go
- 🧪 **Testing Framework** - Comprehensive test setup with Go testing
- 📚 **Documentation** - Automated documentation with godoc
- 🔍 **Code Quality** - Linting with golangci-lint, formatting with gofmt
- 📝 **Editor Configuration** - Cross-platform .editorconfig for consistent coding style
- 🐳 **Containerization** - Docker and Dev Container configurations
- 📊 **Benchmarking** - Performance benchmarking with Go's built-in tools

### Available Templates

This repository provides a curated set of reusable configuration templates for Go projects:

#### 🌱 Core Project Configuration
- **.gitignore** - Sensible defaults for Go projects
- **.editorconfig** - Editor configuration to enforce consistent coding standards
- **.golangci.yml** - Configuration for the golangci-lint linter
- **go.mod** - Go module definition
- **Makefile** - Task automation for common development workflows
- **CODE_OF_CONDUCT.md** - Code of conduct for open-source projects
- **CONTRIBUTING.md** - Contributing guidelines

#### 🔧 Developer Experience
- **.devcontainer/** - Development container setup (VS Code / Dev Containers)
- **.go-version** - Go version specification (similar to Python's .python-version)

#### 🚀 CI/CD & Automation
- **.github/** - GitHub Actions workflows for Go CI/CD
- **.gitlab/** - GitLab CI/CD workflows (see [.gitlab/README.md](.gitlab/README.md))

## 📋 Available Tasks

The project uses a [Makefile](Makefile) as the primary entry point for all tasks, powered by Go's native tooling.

### Key Commands

```bash
make install         # Install dependencies and setup environment
make test            # Run test suite with coverage
make fmt             # Format and lint code
make all             # Run all quality checks and tests
make lint            # Run golangci-lint
make vet             # Run go vet
make clean           # Clean build artifacts
```

Run `make help` for a complete list of available targets.

## 🏗️ Project Structure

```
rhiza-go/
├── cmd/              # Command-line applications
│   └── rhiza-go/     # Main application
├── pkg/              # Public libraries
│   └── config/       # Configuration management
├── internal/         # Private application code
│   └── utils/        # Internal utilities
├── .rhiza/           # Rhiza-specific scripts and configurations
│   ├── make.d/       # Modular Makefile components
│   │   ├── bootstrap.mk
│   │   ├── bootstrap-go.mk
│   │   ├── test.mk
│   │   ├── quality.mk
│   │   └── docs.mk
│   └── rhiza.mk      # Core Makefile logic
├── go.mod            # Go module dependencies
├── go.sum            # Dependency checksums
├── .go-version       # Go version specification
├── .golangci.yml     # Linter configuration
└── Makefile          # Main Makefile (includes .rhiza/rhiza.mk)
```

## 🔄 CI/CD Support

### GitHub Actions

The `.github/` directory contains comprehensive GitHub Actions workflows for:
- CI testing with Go
- Code quality checks (golangci-lint)
- Dependency management
- Docker and devcontainer validation
- Release automation
- Template synchronization

### GitLab CI/CD

Rhiza-Go provides GitLab CI/CD workflow configurations with feature parity to GitHub Actions. The `.gitlab/` directory includes workflows for CI, validation, and releases.

## 🛠️ Contributing

Contributions are welcome! To contribute to Rhiza-Go:

1. Fork the repository
2. Clone and setup:
   ```bash
   git clone https://github.com/your-username/rhiza-go.git
   cd rhiza-go
   make install
   ```
3. Create your feature branch (`git checkout -b feature/amazing-feature`)
4. Make your changes and test (`make test && make fmt`)
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Rhiza (Python)](https://github.com/jebel-quant/rhiza) - The original inspiration for this Go adaptation
- [GitHub Actions](https://github.com/features/actions) - For CI/CD capabilities
- [golangci-lint](https://golangci-lint.run/) - For comprehensive Go linting
- [Go](https://go.dev/) - For an amazing programming language and tooling
