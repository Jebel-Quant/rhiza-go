# Understanding Rhiza: Quick Reference

## TL;DR

**Rhiza** = Git for project templates. Instead of copying templates once and drifting away, you can continuously sync updates from a template repository.

```bash
# Initial setup
uvx rhiza init              # Create config
uvx rhiza materialize       # Pull templates

# Keep updated (manual or automated via CI)
make sync                   # Pull latest template changes
```

---

## The Problem Rhiza Solves

**Traditional Templates (cookiecutter, copier):**
- Generate files once
- Project drifts from template over time
- Manual effort to adopt new best practices
- No way to pull upstream improvements

**Rhiza:**
- Templates are living, versioned
- Sync updates via `make sync` or CI
- Selective adoption (include/exclude patterns)
- Automated PR creation with update summaries

---

## Core Concepts

### 1. Template Repository
A Git repository containing reusable configurations (e.g., `Jebel-Quant/rhiza` for Python, `Jebel-Quant/rhiza-go` for Go).

### 2. Target Project  
Your actual project that pulls templates from the template repository.

### 3. `.rhiza/template.yml`
Configuration file in target project specifying:
- Which template repository to use
- Which version/branch to sync from
- Which files to include/exclude

```yaml
repository: Jebel-Quant/rhiza-go
ref: v0.1.0
templates: [core, github, tests]
```

### 4. Bundles
Predefined groups of related files (e.g., `core` bundle includes Makefile, .gitignore, configs).

### 5. Sync
The process of fetching files from template repository and applying them to target project.

---

## File Structure

```
your-project/
├── Makefile                    # 3 lines: config + include .rhiza/rhiza.mk
├── go.mod                      # Your actual project files
├── main.go
│
└── .rhiza/                     # Template-managed (synced from template repo)
    ├── rhiza.mk                # Core Makefile logic
    ├── .rhiza-version          # rhiza CLI version to use
    ├── template-bundles.yml    # Bundle definitions
    ├── make.d/                 # Modular Makefile components
    │   ├── bootstrap.mk
    │   ├── test.mk
    │   └── ...
    ├── scripts/
    └── docs/
```

**Key Point**: `.rhiza/` is template-owned and gets updated via sync. Root `Makefile` is user-owned.

---

## How Sync Works

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. Read .rhiza/template.yml                                     │
│    - repository: Jebel-Quant/rhiza-go                           │
│    - ref: v0.1.0                                                │
│    - templates: [core, github, tests]                           │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. Expand bundles to file lists                                 │
│    - core → [Makefile, .gitignore, .golangci.yml, ...]          │
│    - github → [.github/workflows/*.yml, ...]                    │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. Fetch files from template repo (GitHub API)                  │
│    - GET https://api.github.com/repos/Jebel-Quant/rhiza-go/...  │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. Apply include/exclude filters                                │
│    - Skip files matching 'exclude:' patterns                    │
└─────────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5. Write files to target project                                │
│    - Overwrite existing template-managed files                  │
│    - Preserve excluded files (your customizations)              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Makefile Architecture

```makefile
# Root Makefile (you own this, never synced)
GO_VERSION=1.24
LOGO_FILE=.rhiza/assets/logo.svg

include .rhiza/rhiza.mk    # ← Pull in all template logic
-include local.mk          # ← Optional local overrides

# .rhiza/rhiza.mk (template-owned, synced)
# - Sets up environment (colors, paths, version variables)
# - Defines core targets (sync, validate, help)
# - Includes all .rhiza/make.d/*.mk modules

# .rhiza/make.d/*.mk (template-owned, synced)
# - Each file provides specific functionality
# - bootstrap.mk: install, clean
# - test.mk: test, benchmark
# - quality.mk: fmt, lint
# - github.mk: GitHub CLI helpers
# - releasing.mk: bump, release
```

**Result**: Run `make test` and it:
1. Root Makefile includes `.rhiza/rhiza.mk`
2. `.rhiza/rhiza.mk` includes `.rhiza/make.d/test.mk`
3. `test.mk` defines `test` target
4. `make test` executes → `go test -v -race -coverprofile=coverage.out ./...`

---

## Customization via Hooks

```makefile
# Root Makefile (before include .rhiza/rhiza.mk)

pre-install::
@echo "Installing custom tools..."
@go install github.com/my/tool@latest

post-sync::
@echo "Synced! Running custom validation..."
@./scripts/validate-config.sh

pre-release::
@./scripts/security-scan.sh
```

**Available Hooks:**
- `pre-install::` / `post-install::`
- `pre-sync::` / `post-sync::`
- `pre-validate::` / `post-validate::`
- `pre-bump::` / `post-bump::`
- `pre-release::` / `post-release::`

---

## Python vs Go Rhiza

| Component | Python | Go |
|-----------|--------|-----|
| **Package file** | `pyproject.toml` | `go.mod` |
| **Lock file** | `uv.lock` | `go.sum` |
| **Version file** | `.python-version` | `.go-version` |
| **Linter config** | `ruff.toml` | `.golangci.yml` |
| **Test config** | `pytest.ini` | (none, flags in Makefile) |
| **Package manager** | `uv` | `go mod` |
| **Linter** | `ruff` | `golangci-lint` |
| **Test framework** | `pytest` | `go test` |
| **Doc generator** | `pdoc` | `godoc` / `pkgsite` |
| **Release tool** | Shell script | `goreleaser` |

**Everything else is the same:**
- `.rhiza/` structure
- Bundle system
- Sync mechanism
- Makefile orchestration
- CI workflow pattern
- Hook system

---

## Typical Workflow

### Initial Project Setup
```bash
# 1. Create project
mkdir my-go-project && cd my-go-project
git init
go mod init github.com/myorg/my-go-project

# 2. Initialize Rhiza
uvx rhiza init --git-host github

# 3. Edit .rhiza/template.yml (optional)
#    Select which bundles you want

# 4. Pull templates
uvx rhiza materialize

# 5. Commit
git add .
git commit -m "Initial commit with Rhiza templates"
```

### Daily Development
```bash
make install      # Install dependencies
make test         # Run tests
make lint         # Run linters
make fmt          # Format code
```

### Updating Templates
```bash
# Manual update
make sync         # Pull latest from template repo
git diff          # Review changes
git commit -am "chore: Update Rhiza templates"

# Or automated via CI
# .github/workflows/rhiza_sync.yml runs weekly
# Creates PR automatically
```

### Releasing
```bash
make bump         # Bump version (interactive)
make release      # Create tag and trigger release workflow
```

---

## Common Use Cases

### Use Case 1: Standardize Across Team Projects
**Problem**: 10 projects, all with slightly different CI configs, linting rules, etc.

**Solution**:
1. Create template repo with team standards
2. Each project runs `uvx rhiza init --template-repository myorg/my-templates`
3. `make sync` keeps all projects aligned

### Use Case 2: Adopt New Best Practices
**Problem**: New security scanning tool released, want to add to all projects.

**Solution**:
1. Add to template repo (e.g., `.github/workflows/security.yml`)
2. Each project runs `make sync`
3. Review PR, merge

### Use Case 3: Support Multiple Languages
**Problem**: Have Python, Go, Rust projects - want consistent tooling.

**Solution**:
1. Create multi-language template repo
2. Use bundles: `python.core`, `go.core`, `rust.core`
3. Each project selects appropriate bundles

---

## FAQs

**Q: Will sync overwrite my changes?**  
A: No, use `exclude:` patterns to protect files:
```yaml
exclude: |
  .golangci.yml    # Using custom config
  Makefile         # Custom targets
```

**Q: Can I sync from multiple template repos?**  
A: Not directly, but you can:
- Fork template repos and merge
- Use different bundles from different sources
- Layer multiple syncs (advanced)

**Q: What if I don't like a template update?**  
A: 
- Review the PR created by sync workflow
- Cherry-pick changes you want
- Close PR to skip update
- Use `exclude:` to prevent future updates to that file

**Q: Can I use this without CI?**  
A: Yes! `make sync` works locally. CI just automates it.

**Q: Does this replace my build tool?**  
A: No, it complements it. Rhiza manages configs/workflows, not your actual build.

---

## Quick Command Reference

```bash
# Initialize
uvx rhiza init                    # Create .rhiza/template.yml
uvx rhiza materialize             # Pull templates

# Sync
make sync                         # Pull latest updates
uvx rhiza validate                # Check if in sync

# Development
make install                      # Install dependencies
make test                         # Run tests
make fmt                          # Format code
make lint                         # Lint code
make docs                         # Generate docs

# Release
make bump                         # Bump version
make release                      # Create release

# Help
make help                         # Show all targets
make print-VAR                    # Print variable value
```

---

## Resources

- **Python Rhiza**: https://github.com/Jebel-Quant/rhiza
- **Go Rhiza**: https://github.com/Jebel-Quant/rhiza-go
- **Full Documentation**: [GO_ADAPTATION_GUIDE.md](GO_ADAPTATION_GUIDE.md)
- **Repository Analysis**: [REPOSITORY_ANALYSIS.md](REPOSITORY_ANALYSIS.md)

---

## Next Steps for rhiza-go

This repository currently contains Python templates. To adapt for Go:

1. ✅ Read [GO_ADAPTATION_GUIDE.md](GO_ADAPTATION_GUIDE.md)
2. ⬜ Create Go-specific Makefile modules (`.rhiza/make.d/go-*.mk`)
3. ⬜ Replace configs (`.golangci.yml`, `.go-version`)
4. ⬜ Update bundles (`.rhiza/template-bundles.yml`)
5. ⬜ Port CI workflows (`.github/workflows/go_*.yml`)
6. ⬜ Test with sample Go projects
7. ⬜ Update README with Go examples

**Estimated Effort**: 4-6 weeks for production-ready v0.1.0

---

*Last Updated: 2026-02-14*
