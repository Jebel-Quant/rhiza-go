---
marp: true
theme: default
paginate: true
backgroundColor: #fff
color: #2c3e50
style: |
  section {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  }
  h1 {
    color: #2FA4A9;
  }
  h2 {
    color: #2FA4A9;
  }
  code {
    background: #f5f5f5;
  }
  .columns {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

<!-- _class: lead -->
# 🌱 Rhiza-Go

**Reusable Configuration Templates for Modern Go Projects**

![w:200](assets/rhiza-logo.svg)

*ῥίζα (ree-ZAH) — Ancient Greek for "root"*

---

## 🤔 The Problem

Setting up a new Go project is time-consuming:

- ⚙️ Configuring CI/CD pipelines
- 🧪 Setting up testing frameworks
- 📝 Creating linting and formatting rules
- 📚 Configuring documentation generation
- 🔧 Establishing development workflows
- 🐳 Setting up dev containers

**Result**: Hours of configuration before writing actual code

---

## 💡 The Solution: Rhiza-Go

A curated collection of **battle-tested templates** that:

✅ Save time on project setup
✅ Enforce best practices
✅ Maintain consistency across projects
✅ Stay up-to-date automatically
✅ Support Go development with golangci-lint (25+ linters)

---

## ✨ Key Features

<div class="columns">
<div>

### 🚀 Automation
- GitHub Actions workflows
- Pre-commit hooks
- Automated releases
- Version bumping

### 🧪 Testing
- `go test` with race detection
- CI testing
- Code coverage
- Benchmarking

</div>
<div>

### 📚 Documentation
- API docs with godoc
- Presentation slides with Marp
- Quick reference cards

### 🔧 Developer Experience
- Dev containers
- VS Code integration
- GitHub Codespaces ready
- SSH agent forwarding

</div>
</div>

---

## 📁 Available Templates

### 🌱 Core Project Configuration
- `.gitignore` — Go project defaults
- `.editorconfig` — Consistent coding standards
- `.golangci.yml` — Linting with 25+ linters
- `go.mod` — Go module definition
- `Makefile` — Common development tasks
- `CODE_OF_CONDUCT.md` & `CONTRIBUTING.md`

---

## 📁 Available Templates (cont.)

### 🔧 Developer Experience
- `.devcontainer/` — VS Code dev containers
- `.pre-commit-config.yaml` — Pre-commit hooks
- `docker/` — Dockerfile templates

### 🚀 CI/CD & Automation
- `.github/workflows/` — GitHub Actions
- Automated testing & releases
- Template synchronization

---

## 🎯 Quick Start

### 1. Clone and Set Up

```bash
git clone https://github.com/jebel-quant/rhiza-go.git
cd rhiza-go
make install
```

### 2. Configure Sync

```yaml
# .rhiza/template.yml
repository: Jebel-Quant/rhiza-go
ref: v0.1.0
include: |
  .github/workflows/*.yml
  .golangci.yml
  Makefile
```

---

## 🔄 Template Synchronization

Templates stay up-to-date with Rhiza-Go's latest improvements:

### Configuration: `.rhiza/template.yml`

```yaml
repository: Jebel-Quant/rhiza-go
ref: v0.1.0

include: |
  .github/workflows/*.yml
  .pre-commit-config.yaml
  .golangci.yml

exclude: |
  .rhiza/scripts/customisations/*
```

---

## 🔄 Automated Sync Workflow

The `sync.yml` workflow keeps your project current:

- 📅 Runs weekly (configurable)
- 🔄 Fetches latest templates from Rhiza-Go
- 🔍 Applies only included files
- 🎯 Respects exclude patterns
- 📝 Creates pull request with changes
- 🤖 Fully automated

**Manual trigger**: GitHub Actions → "Sync Templates" → "Run workflow"

---

## 🛠️ Makefile: Your Command Center

```bash
make install      # Setup project with Go deps & tools
make test         # Run go test with coverage & race detection
make fmt          # Format with goimports + golangci-lint --fix
make lint         # Run golangci-lint
make vet          # Run go vet
make bump         # Interactive version bump
make release      # Tag and release
make help         # Show all targets
```

**Tip**: Run `make help` to see all available targets

---

## 🚀 Release Workflow

### Two-Step Process

```bash
# 1. Bump version
make bump
# → Interactive prompts for patch/minor/major
# → Updates VERSION file
# → Commits and pushes changes

# 2. Create release
make release
# → Creates git tag
# → Pushes tag to GitHub
# → Triggers release workflow
```

### Release Automation
✅ Builds Go binaries (linux/darwin/windows × amd64/arm64)
✅ Creates GitHub release
✅ Generates SBOM with syft
✅ Publishes devcontainer image (optional)

---

## 🐳 Dev Container Features

### What You Get

- 🐹 Go runtime environment
- 🔧 golangci-lint, goimports, and dev tools
- ⚡ All project dependencies
- 🧪 Pre-commit hooks
- 🔐 SSH agent forwarding
- 🚀 Port 8080 forwarding

### Usage

**VS Code**: Reopen in Container
**Codespaces**: Create codespace on GitHub

---

## 🔧 Customization

### Makefile Hooks

Add to your root `Makefile`:

```makefile
post-install::
	@echo "Installing additional tools..."
	@go install github.com/securego/gosec/v2/cmd/gosec@latest

##@ Custom Tasks
generate: ## Run code generation
	@go generate ./...
```

Runs during: `make install`

---

## ⚙️ Configuration Variables

Override variables in your `Makefile` or `local.mk`:

```makefile
# Override test coverage threshold (default: 90)
COVERAGE_FAIL_UNDER = 80

# Include the Rhiza API (template-managed)
include .rhiza/rhiza.mk
```

**Set in**: `Makefile`, `local.mk`, or environment variables

---

## 🔍 Code Quality Tools

### Pre-commit Hooks
- ✅ YAML validation
- ✅ TOML validation
- ✅ Markdown formatting
- ✅ Trailing whitespace
- ✅ End-of-file fixes
- ✅ GitHub workflow validation

### golangci-lint
- 25+ linters in parallel
- Configurable via `.golangci.yml`
- Auto-fixing with `--fix`
- Includes gosec, gocritic, errcheck

---

## 🧪 Testing Philosophy

### What Gets Tested

- 🔧 Go packages with `go test`
- 🏃 Race condition detection
- 📊 Code coverage reporting
- 🎯 Benchmarks with `testing.B`

### Test Command

```bash
make test
```

Runs `go test` with coverage and race detection.

---

## 🌐 CI/CD Workflows

### Automated Workflows

1. **CI** — Test with coverage and race detection
2. **PRE-COMMIT** — Validate code quality
3. **CODEQL** — Security scanning for Go
4. **DOCKER** — Build and publish images
5. **DEVCONTAINER** — Validate dev environment
6. **RELEASE** — Multi-platform binary releases
7. **SYNC** — Template synchronization

---

## 🎯 Real-World Usage

### Perfect For:

- 🆕 New Go projects
- 🔄 Standardizing existing projects
- 👥 Team templates
- 📚 Educational projects
- 🏢 Corporate standards

### Not Ideal For:

- ❌ Non-Go projects (see [Rhiza](https://github.com/jebel-quant/rhiza) for Python)
- ❌ Projects requiring exotic configurations
- ❌ One-off scripts

---

## 🏗️ Architecture Decisions

### Why Makefile?

- ✅ Universal (no language-specific tools)
- ✅ Self-documenting
- ✅ Easy to extend
- ✅ Works everywhere

### Why Go?

- ⚡ Fast compilation and execution
- 📦 Single binary deployment
- 🔒 Strong type system
- 🎯 Excellent tooling ecosystem

---

## 🤝 Contributing

### How to Contribute

1. 🍴 Fork the repository
2. 🌿 Create feature branch
3. ✍️ Make your changes
4. ✅ Run `make test` and `make fmt`
5. 📤 Submit pull request

### What to Contribute

- 🆕 New templates
- 🐛 Bug fixes
- 📚 Documentation improvements
- 💡 Feature suggestions

---

## 📈 Project Stats

- 🐹 **Go Version**: 1.23
- 📄 **License**: MIT
- 🏷️ **Current Version**: 0.1.0
- 🔧 **Templates**: 20+ configuration files
- 🤖 **Workflows**: 7+ GitHub Actions
- ⭐ **Badge**: ![Created with Rhiza](https://img.shields.io/badge/synced%20with-rhiza-2FA4A9)

---

## 🔗 Useful Links

- 📖 **Repository**: [github.com/jebel-quant/rhiza-go](https://github.com/jebel-quant/rhiza-go)
- 📚 **Issues**: [github.com/jebel-quant/rhiza-go/issues](https://github.com/jebel-quant/rhiza-go/issues)
- 🚀 **Codespaces**: [Open in GitHub Codespaces](https://codespaces.new/jebel-quant/rhiza-go)
- 📝 **Documentation**: Auto-generated with `make docs`

---

## 🙏 Acknowledgments

### Built With

- **GitHub Actions** — CI/CD automation
- **Go** — Fast, reliable programming language
- **golangci-lint** — Comprehensive Go linting
- **Marp** — This presentation!
- **godoc** — API documentation

---

## 💡 Getting Started Today

### Three Simple Steps

1. **Clone**: `git clone https://github.com/jebel-quant/rhiza-go.git`
2. **Setup**: `make install`
3. **Test**: `make test`

### Or Explore First

```bash
# Open in Codespaces
# → Click "Create codespace on main"

# Or clone locally
git clone https://github.com/jebel-quant/rhiza-go.git
cd rhiza-go
make install
make test
```

---

<!-- _class: lead -->

# 🎉 Thank You!

## Questions?

**Rhiza-Go** — Your foundation for modern Go projects

*From the Greek ῥίζα (root) — because every great project needs strong roots*

---

## 📋 Quick Reference Card

```bash
# Setup
git clone https://github.com/jebel-quant/rhiza-go.git
cd rhiza-go

# Development
make install                   # Install dependencies
make test                      # Run tests
make fmt                       # Format & lint

# Documentation
make docs                      # API documentation

# Release
make bump                      # Bump version
make release                   # Create release
```

---

<!-- _class: lead -->

# Ready to Root Your Project?

**Get Started**: [github.com/jebel-quant/rhiza-go](https://github.com/jebel-quant/rhiza-go)

![w:300](assets/rhiza-logo.svg)
