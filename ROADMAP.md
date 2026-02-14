# Rhiza-Go Implementation Roadmap

## Current State Assessment

The first pass has successfully adapted the **core development loop** — the files a developer touches daily (`make install`, `make test`, `make fmt`, `make lint`) are working correctly with Go tooling. The CI workflow, Dockerfile, pre-commit config, golangci-lint config, and Go source code are all properly adapted.

However, the **infrastructure layer** — release pipeline, template sync, agent setup, dependency management automation, and the template bundle definitions themselves — remains entirely Python-centric. This means the repo works for local Go development but would not function correctly as a template that downstream Go projects sync from.

### What's Done (Go-adapted)

| File | Status |
|------|--------|
| `.rhiza/rhiza.mk` | ✅ Reads `.go-version`, uses `GO_BIN` |
| `.rhiza/make.d/bootstrap.mk` | ✅ `go mod download`, `go install` |
| `.rhiza/make.d/test.mk` | ✅ `go test` with coverage, race, benchmarks |
| `.rhiza/make.d/quality.mk` | ✅ `go fmt`, `goimports`, `golangci-lint`, `go vet` |
| `.rhiza/make.d/docs.mk` | ✅ `go doc`, `godoc` server |
| `.golangci.yml` | ✅ 25+ linters configured |
| `.pre-commit-config.yaml` | ✅ Go hooks |
| `go.mod` / `go.sum` | ✅ Proper Go module |
| `.go-version` | ✅ Single source of truth |
| `cmd/rhiza-go/main.go` | ✅ Entry point |
| `pkg/config/`, `internal/utils/` | ✅ Go packages with tests |
| `docker/Dockerfile` | ✅ Multi-stage Go build |
| `.github/workflows/rhiza_ci.yml` | ✅ Go CI with matrix |
| `.github/workflows/rhiza_docker.yml` | ✅ Go Docker build |
| `README.md` | ✅ Go-oriented |
| `.gitignore` | ✅ Go patterns |

### What's Not Done (Still Python)

| File | Problem |
|------|---------|
| `.rhiza/make.d/docker.mk` | References `PYTHON_VERSION` |
| `.rhiza/make.d/book.mk` | Uses `install-uv`, `UVX_BIN`, Python `minibook`, `pdoc` |
| `.rhiza/.env` | References `SOURCE_FOLDER=src` |
| `.rhiza/requirements/` | Python pip requirements (entire directory) |
| `.rhiza/template-bundles.yml` | References `.python-version`, `ruff.toml`, `pytest.ini` |
| `.rhiza/tests/` | Python test infrastructure (`conftest.py`) |
| `.rhiza/templates/minibook/` | Python Jinja2 template |
| `.github/workflows/rhiza_sync.yml` | `uvx rhiza materialize` |
| `.github/workflows/rhiza_validate.yml` | `uvx rhiza validate` |
| `.github/workflows/rhiza_codeql.yml` | Language matrix has `python`, missing `go` |
| `.github/workflows/copilot-setup-steps.yml` | Installs `uv`, activates `.venv` |
| `.github/copilot-instructions.md` | Entirely Python-focused |
| `.github/hooks/session-start.sh` | Validates `uv` and `.venv` |
| `.github/dependabot.yml` | `pep621` ecosystem, missing `gomod` |
| `renovate.json` | `pep621` manager, missing `gomod` |
| `.gitlab-ci.yml` | Python CI pipeline |
| `.devcontainer/` | Likely Python-oriented |
| `book/marimo/` | Python Marimo notebooks |

---

## Phased Implementation Plan

### Phase 1: Release & Versioning Pipeline ✅ COMPLETED

**Goal**: A working `make bump` → `make release` → GitHub Release pipeline for Go projects.

**Status**: ✅ Complete (PR: [Update roadmap on task completion](https://github.com/Jebel-Quant/rhiza-go/pull/TBD))

**Completed Deliverables:**

1. ✅ **Created `VERSION` file** at repo root
   - Contains `0.1.0`
   - Single source of truth for project version

2. ✅ **Rewrote `.rhiza/scripts/release.sh`** for Go
   - Reads version from `VERSION` file (not `pyproject.toml`)
   - Removed all `uv` references
   - Maintains same UX (prompts, dry-run, colour output, safety checks)

3. ✅ **Rewrote `.rhiza/make.d/releasing.mk`** for Go
   - Uses `rhiza[tools]>=0.8.6` via `uv tool run` for version bumping
   - Reads configuration from `.rhiza/.cfg.toml`
   - `bump` target: uses rhiza[tools] to increment patch version
   - `release` target: calls the rewritten release script
   - Added dependency on `install-uv` target

4. ✅ **Created minimal `pyproject.toml`** for rhiza[tools] compatibility
   - Contains project name, version, and description
   - Required for rhiza[tools] to function
   - Bumped atomically with VERSION file

5. ✅ **Updated `.rhiza/.cfg.toml`** for Go
   - Removed bumpversion pre-commit hooks that referenced `uv sync` and `uv.lock`
   - Configured to bump both `VERSION` file and `pyproject.toml`
   - Used by rhiza[tools] for version management

6. ✅ **Added `install-uv` target** to `.rhiza/make.d/bootstrap.mk`
   - Automatically detects and uses system UV if available
   - Falls back to installing UV locally if needed
   - Defines `UVX_BIN` as `uv tool run` for executing Python tools

7. ✅ **Rewrote `.github/workflows/rhiza_release.yml`** for Go
   - Replaced Python/uv setup with Go setup
   - Builds Go binaries for linux/darwin/windows (amd64/arm64)
   - Generates SBOM using `syft` (instead of Python `cyclonedx-bom`)
   - Removed PyPI publishing job entirely
   - Kept: draft release, SBOM generation, SLSA attestations, devcontainer publishing

8. ✅ **Fixed `.github/workflows/rhiza_validate.yml`**
   - Added exclusion for `jebel-quant/rhiza-go` repository
   - Prevents validation errors for template repositories
   - Template repos don't have `.rhiza/template.yml` by design

#### Validation Results

- ✅ `make bump` uses rhiza[tools] to increment the version in `VERSION` and `pyproject.toml`, creates a commit
- ✅ `.rhiza/scripts/release.sh --dry-run` shows correct tag without pushing
- ✅ `make release` would create a git tag matching `VERSION` and push it
- ✅ The release workflow builds Go binaries with syft SBOM generation
- ✅ Validation workflow correctly skips rhiza-go template repository
- ⏸️ GitHub Actions `rhiza_release.yml` not yet tested (will be validated when first tag is pushed)

**What's Done (Go-adapted):**

| File | Status |
|------|--------|
| `VERSION` | ✅ Created with version 0.1.0 |
| `pyproject.toml` | ✅ Minimal file for rhiza[tools] compatibility |
| `.rhiza/make.d/releasing.mk` | ✅ Uses rhiza[tools] for version bumping |
| `.rhiza/make.d/bootstrap.mk` | ✅ Added install-uv target |
| `.rhiza/scripts/release.sh` | ✅ Reads VERSION file |
| `.rhiza/.cfg.toml` | ✅ Bumps VERSION and pyproject.toml |
| `.github/workflows/rhiza_release.yml` | ✅ Go builds, syft SBOM, no PyPI |
| `.github/workflows/rhiza_validate.yml` | ✅ Skips rhiza-go template repo |

**Next Agent Instructions:**
The release pipeline is ready for Go. Key implementation details:
- Version bumping uses `rhiza[tools]` via `uv tool run` (consistent with Python rhiza)
- Configuration is in `.rhiza/.cfg.toml` (bumps VERSION and pyproject.toml atomically)
- Minimal `pyproject.toml` exists for rhiza[tools] compatibility
- `install-uv` target auto-detects system UV or installs locally
- Validation workflow skips rhiza-go (it's a template, not a consumer)

To test the release pipeline end-to-end:
1. Ensure all changes are committed and pushed
2. Run `make release --dry-run` to verify the process
3. When ready for a real release, run `make release` to create and push the tag
4. Monitor the GitHub Actions workflow at the URL provided by the script

---

### Phase 2: Template Infrastructure Cleanup ✅ COMPLETED

**Goal**: Remove all Python artefacts so this repo is a clean Go template. A downstream Go project syncing from this template should receive only Go-relevant files.

**Status**: ✅ Complete (PR: [Phase 2: Template Infrastructure Cleanup](https://github.com/Jebel-Quant/rhiza-go/pull/5))

**Completed Deliverables:**

1. ✅ **Rewrote `.rhiza/template-bundles.yml`** for Go
   - Replaced `.python-version` → `.go-version`
   - Replaced `ruff.toml` → `.golangci.yml`
   - Removed `pytest.ini` (Go uses Makefile flags)
   - Removed `.rhiza/requirements/docs.txt`, `.rhiza/requirements/tools.txt` from core bundle
   - Removed `.rhiza/requirements/tests.txt` from tests bundle
   - Removed `rhiza_mypy.yml` and `rhiza_deptry.yml` workflow references
   - Removed entire `marimo` bundle (Python-only)
   - Removed `minibook` template reference from book bundle
   - Updated descriptions to reference Go tooling
   - Removed marimo recommendation from presentation bundle

2. ✅ **Fixed `.rhiza/make.d/docker.mk`**
   - Replaced `PYTHON_VERSION` → `GO_VERSION` in build-arg and info message
   - Now passes `--build-arg GO_VERSION=${GO_VERSION}` matching the Go Dockerfile

3. ✅ **Rewrote `.rhiza/make.d/book.mk`** for Go
   - Removed all Python dependencies (`install-uv`, `UV_BIN`, `UVX_BIN`, `python3`, `minibook`, `pdoc`)
   - Removed `marimushka` and `mkdocs-build` targets
   - Replaced with Go-native documentation compilation (godoc output + coverage reports)
   - Generates simple HTML index page linking available sections

4. ✅ **Updated `.rhiza/.env`**
   - Removed `MARIMO_FOLDER=book/marimo/notebooks`
   - Removed `SOURCE_FOLDER=src` (Go uses `cmd/`, `pkg/`, `internal/`)
   - Removed `BOOK_TITLE`, `BOOK_SUBTITLE`, `BOOK_TEMPLATE` (minibook references)
   - Kept `SCRIPTS_FOLDER=.rhiza/scripts` (still used)

5. ✅ **Cleaned `.rhiza/requirements/` directory**
   - Removed `docs.txt`, `tests.txt`, `tools.txt`, `marimo.txt` (all Python pip requirements)
   - Updated `README.md` to explain Go dependency management (`go.mod`, `go.sum`)

6. ✅ **Removed Python test infrastructure from `.rhiza/tests/`**
   - Removed all Python files: `conftest.py`, `test_utils.py`
   - Removed all Python test subdirectories: `api/`, `deps/`, `integration/`, `structure/`, `sync/`, `utils/`
   - Updated `README.md` to document Go test approach and future plans (Phase 5)

7. ✅ **Removed `.rhiza/templates/minibook/`**
   - Deleted `custom.html.jinja2` Jinja2 template
   - Removed empty `templates/` directory

8. ✅ **Removed `book/marimo/`**
   - Deleted `notebooks/rhiza.py` Python Marimo notebook
   - Removed empty `book/` directory

#### Validation Results

- ✅ `grep -r` on `.rhiza/` functional files (`.mk`, `.yml`, `.sh`, `.toml`, `.env`) returns zero Python references
- ✅ `make install && make test && make fmt && make lint` all pass cleanly
- ✅ `make -n docker-build` shows correct `--build-arg GO_VERSION=1.23` (not `PYTHON_VERSION`)
- ✅ No orphaned Python files remain in `.rhiza/` (only `README.md` files kept)
- ⚠️ Documentation files (`.rhiza/docs/*.md`, `.rhiza/make.d/README.md`) still contain Python references — these will be updated in Phase 4 (DevContainer & Documentation)
- ⚠️ `.rhiza/.cfg.toml` references `pyproject.toml` — this is intentional for rhiza[tools] compatibility (Phase 1)

**Next Agent Instructions:**
The template infrastructure is now clean of Python functional artefacts. Key notes:
- `.rhiza/template-bundles.yml` now references only Go-relevant files
- The `book` target now uses Go-native documentation (godoc output + coverage HTML)
- Python test infrastructure has been fully removed — Go template validation tests should be created in Phase 5
- Documentation markdown files in `.rhiza/docs/` still contain Python references and should be updated in Phase 4
- The `releasing.mk` and `.cfg.toml` intentionally reference `pyproject.toml` for rhiza[tools] version bumping

---

### Phase 3: CI/CD & Automation Workflows ✅ COMPLETED

**Goal**: All GitHub Actions workflows, Dependabot/Renovate configs, and agent infrastructure work for Go.

**Status**: ✅ Complete (PR: [Phase 3: CI/CD & Automation Workflows](https://github.com/Jebel-Quant/rhiza-go/pull/7))

**Completed Deliverables:**

1. ✅ **Rewrote `.github/workflows/copilot-setup-steps.yml`** for Go
   - Replaced `astral-sh/setup-uv` with `actions/setup-go@v5` using `go-version-file: .go-version`
   - Removed `UV_EXTRA_INDEX_URL` environment variable
   - Replaced `.venv/bin` PATH addition with `GOPATH/bin`
   - Kept `make install` (which now does `go mod download` and installs Go dev tools)

2. ✅ **Rewrote `.github/hooks/session-start.sh`** for Go
   - Validates `go` is available (not `uv`)
   - Validates Go version matches `.go-version` (warns on mismatch)
   - Validates `go.mod` exists (valid Go project check)
   - Removed all `.venv` and Python checks

3. ✅ **Rewrote `.github/copilot-instructions.md`** for Go
   - Replaced all Python/uv references with Go equivalents
   - Updated prerequisites (Go from `.go-version`, not Python)
   - Updated common commands (`go test`, `go fmt`, `golangci-lint` instead of `pytest`, `ruff`)
   - Updated project structure (`cmd/`, `pkg/`, `internal/` instead of `src/`, `tests/`)
   - Updated coding standards (Effective Go, not PEP 8)
   - Updated key files (`go.mod`, `.go-version`, `.golangci.yml` instead of `pyproject.toml`, `.python-version`)
   - Updated CI/CD section to reference Go setup

4. ✅ **Fixed `.github/workflows/rhiza_codeql.yml`**
   - Replaced `python` (build-mode: none) with `go` (build-mode: autobuild) in language matrix
   - Kept `actions` language for workflow scanning

5. ✅ **Updated `.github/dependabot.yml`**
   - Replaced `uv` package ecosystem with `gomod`
   - Updated labels from `python` to `go`
   - Updated group name from `python-dependencies` to `go-dependencies`
   - Kept `github-actions` ecosystem and Docker (commented out)
   - Updated header comment to reference rhiza-go

6. ✅ **Updated `renovate.json`**
   - Replaced `pep621` manager with `gomod`
   - Updated package rule to disable `go` version pinning (instead of `python`)
   - Kept `pre-commit`, `github-actions`, `gitlabci`, `devcontainer`, `dockerfile`, `custom.regex`
   - Kept custom regex manager for `.rhiza/template.yml` (language-agnostic)

7. ✅ **Updated `.github/workflows/rhiza_sync.yml`**
   - Added `jebel-quant/rhiza-go` to repository exclusion (template repos should not sync from themselves)
   - Kept `uvx rhiza materialize` for short-term (it's a language-agnostic CLI tool)
   - Note: Long-term, a Go-native `rhiza` CLI could replace this

8. ✅ **Updated `.github/workflows/rhiza_validate.yml`**
   - Replaced `astral-sh/setup-uv` with `actions/setup-go@v5` using `go-version-file: .go-version`
   - Simplified validation step (Go template repos skip Python rhiza CLI validation)
   - Kept `make rhiza-test` for Go-based template self-tests

9. ✅ **Updated `.github/workflows/rhiza_pre-commit.yml`**
   - Added `actions/setup-go@v5` step with `go-version-file: .go-version`
   - Go toolchain is now available for Go-based pre-commit hooks
   - Updated header comment to reference rhiza-go

10. ✅ **Rewrote `.gitlab-ci.yml`** for Go
    - Replaced Python-centric pipeline with self-contained Go CI
    - Replaced `.python_base` template (uv image) with `.go_base` template (`golang:${GO_VERSION}-bookworm`)
    - Removed all `include:` references to Python-specific GitLab workflow files
    - Added inline `ci`, `lint`, and `fmt` jobs using `make` targets
    - Removed Python-specific variables (`UV_EXTRA_INDEX_URL`, `PYPI_REPOSITORY_URL`)
    - Note: GitLab workflow files in `.gitlab/workflows/` still contain Python content — these are legacy and no longer included

#### Validation Results

- ✅ `session-start.sh` validates Go environment correctly (tested locally)
- ✅ `make test` passes after all changes
- ✅ No Python references in functional CI/CD files (workflows, hooks, configs)
- ✅ Dependabot configured for `gomod` ecosystem
- ✅ Renovate configured for `gomod` manager
- ✅ CodeQL configured for `go` language analysis
- ⏸️ GitHub Actions workflows not yet tested in CI (will be validated on push/tag)
- ⚠️ `.gitlab/workflows/` directory still contains Python-specific workflow files — these are no longer included by `.gitlab-ci.yml` but could be cleaned up in a future phase
- ⚠️ `rhiza_sync.yml` still uses `uvx rhiza` — this is intentional (language-agnostic CLI tool, short-term decision per roadmap)

**What's Done (Go-adapted):**

| File | Status |
|------|--------|
| `.github/workflows/copilot-setup-steps.yml` | ✅ setup-go, GOPATH/bin |
| `.github/hooks/session-start.sh` | ✅ Validates Go, go.mod |
| `.github/hooks/session-end.sh` | ✅ Already language-agnostic (make fmt, make test) |
| `.github/copilot-instructions.md` | ✅ Full Go documentation |
| `.github/workflows/rhiza_codeql.yml` | ✅ Go language matrix |
| `.github/dependabot.yml` | ✅ gomod ecosystem |
| `renovate.json` | ✅ gomod manager |
| `.github/workflows/rhiza_sync.yml` | ✅ Excludes rhiza-go template |
| `.github/workflows/rhiza_validate.yml` | ✅ setup-go, simplified validation |
| `.github/workflows/rhiza_pre-commit.yml` | ✅ setup-go for Go hooks |
| `.gitlab-ci.yml` | ✅ Go CI pipeline |

**Next Agent Instructions:**
The CI/CD and automation workflows are now Go-adapted. Key implementation details:
- All GitHub Actions workflows use `actions/setup-go@v5` with `go-version-file: .go-version`
- Agent setup (copilot-setup-steps) installs Go and adds `GOPATH/bin` to PATH
- Session hooks validate Go environment (not Python)
- Copilot instructions are fully Go-specific
- Dependabot and Renovate track Go module dependencies
- CodeQL scans Go code (not Python)
- `.gitlab-ci.yml` is self-contained Go CI (no longer includes Python workflow files)
- `rhiza_sync.yml` still uses `uvx rhiza` CLI — this is a conscious short-term decision
- GitLab workflow files in `.gitlab/workflows/` are legacy Python files no longer included by the main config

To validate CI/CD end-to-end:
1. Push a branch or PR to trigger `rhiza_ci.yml`, `rhiza_codeql.yml`, `rhiza_pre-commit.yml`
2. Verify workflows use Go toolchain (not Python)
3. Check Dependabot/Renovate create PRs for `go.mod` updates
4. When ready, push a tag to test `rhiza_release.yml`

---

### Phase 4: DevContainer & Documentation ✅ COMPLETED

**Goal**: A first-class developer experience for anyone using the Go template — proper devcontainer, documentation, and onboarding.

**Status**: ✅ Complete (PR: [Phase 4: DevContainer & Documentation](https://github.com/Jebel-Quant/rhiza-go/pull/7))

**Completed Deliverables:**

1. ✅ **Rewrote `.devcontainer/devcontainer.json`** for Go
   - Base image: `mcr.microsoft.com/devcontainers/go:1.23` (was `python:3.14`)
   - VS Code extensions: `golang.go`, `tamasfe.even-better-toml`, `ms-vscode.makefile-tools`, Copilot extensions
   - Removed all Python extensions (`ms-python.python`, `ms-python.vscode-pylance`, `charliermarsh.ruff`, Marimo extensions)
   - Go-specific settings: `go.lintTool`, `go.formatTool`, `go.testFlags`, tab indentation
   - `GOPATH` environment variable instead of `INSTALL_DIR`
   - Removed port 2718 (was for Marimo)

2. ✅ **Rewrote `.devcontainer/bootstrap.sh`** for Go
   - Reads `.go-version` and verifies Go is available
   - Adds `$GOPATH/bin` to PATH (persistent in `.bashrc`)
   - Runs `make install` for Go deps and tools
   - Removed all UV, `.venv`, Python, and Marimo references
   - Pre-commit hook installation uses system `pre-commit` if available

3. ✅ **Updated all `docs/` files** for Go
   - `docs/ARCHITECTURE.md` — Rewrote all Mermaid diagrams for Go (`cmd/`, `pkg/`, `internal/`, `go.mod`, `golangci-lint`); removed Python utils, `pyproject.toml`, `ruff.toml`, PyPI, deptry references
   - `docs/BOOK.md` — Replaced Marimo/pdoc/minibook with Go godoc and coverage reports
   - `docs/CUSTOMIZATION.md` — Replaced `uv pip install` and `uv run python` examples with `go install` and `go generate`; removed Python version override
   - `docs/DEMO.md` — Updated demo commands (removed `deptry`, added `lint`, `go build`); updated script names
   - `docs/DEVCONTAINER.md` — Replaced Python/UV/Marimo references with Go/GOPATH; updated "What's Configured" section
   - `docs/DOCKER.md` — Replaced `.python-version`/`PYTHON_VERSION` with `.go-version`/`GO_VERSION`
   - `docs/GLOSSARY.md` — Rewrote all tool definitions (Go, golangci-lint, goimports, go vet, go test); replaced `pyproject.toml`/`uv.lock`/`.python-version` with `go.mod`/`go.sum`/`.go-version`/`VERSION`; updated commands reference
   - `docs/QUICK_REFERENCE.md` — Replaced `uv run pytest`/`uvx` commands with `go test`/`go run`/`go build`; updated key files table
   - `docs/SECURITY.md` — Replaced `pip-audit`/`bandit` with `gosec`/`govulncheck`; updated supply chain and release security for Go
   - `docs/TESTS.md` — Complete rewrite from Python Hypothesis/pytest-benchmark to Go `testing.T`, table-driven tests, `testing.B` benchmarks
   - `docs/PRESENTATION.md` — Complete rewrite from Python to Go (all 30+ slides updated)
   - `docs/index.md` — Updated title to Rhiza-Go
   - `docs/mkdocs.yml` — Updated site name/description; expanded navigation to include Tests, Security, Docker, DevContainer

4. ✅ **Removed `docs/MARIMO.md`**
   - Entirely Python/Marimo-specific with no Go equivalent
   - Deleted the file

5. ✅ **Updated `.editorconfig`**
   - Added `[*.go]` section with `indent_style = tab` (Go convention)
   - Updated repository reference to `jebel-quant/rhiza-go`
   - Removed "Python" from section comments

6. ✅ **Verified `README.md`** (already Go-focused)
   - All badges point to correct workflows (`rhiza_ci.yml`)
   - All example commands are Go-specific
   - Only intentional Python references: acknowledgment of original Rhiza project, `.go-version` explanation

#### Validation Results

- ✅ `make test` passes with all tests passing
- ✅ `grep -ri "python|pyproject|pytest|ruff|.python-version|uv\b|pdoc|minibook|marimo" docs/` returns only one intentional reference (PRESENTATION.md links to Python Rhiza as comparison)
- ✅ No Python references in `.devcontainer/` or `.editorconfig`
- ✅ README.md only has intentional Python references (acknowledgment section)
- ⏸️ DevContainer build in Codespaces not yet tested (will be validated when PR is merged)

**What's Done (Go-adapted):**

| File | Status |
|------|--------|
| `.devcontainer/devcontainer.json` | ✅ Go base image, Go extensions, Go settings |
| `.devcontainer/bootstrap.sh` | ✅ Go version check, GOPATH/bin, no UV/Python |
| `.editorconfig` | ✅ Go tab indentation, updated references |
| `docs/ARCHITECTURE.md` | ✅ Go project layout diagrams |
| `docs/BOOK.md` | ✅ Go documentation (godoc, coverage) |
| `docs/CUSTOMIZATION.md` | ✅ Go hook examples |
| `docs/DEMO.md` | ✅ Go demo walkthrough |
| `docs/DEVCONTAINER.md` | ✅ Go devcontainer docs |
| `docs/DOCKER.md` | ✅ Go version handling |
| `docs/GLOSSARY.md` | ✅ Go terms and tools |
| `docs/MARIMO.md` | ✅ Deleted (Python-only) |
| `docs/PRESENTATION.md` | ✅ Go presentation slides |
| `docs/QUICK_REFERENCE.md` | ✅ Go commands |
| `docs/SECURITY.md` | ✅ Go security practices |
| `docs/TESTS.md` | ✅ Go testing guide |
| `docs/index.md` | ✅ Updated title |
| `docs/mkdocs.yml` | ✅ Updated navigation and description |
| `README.md` | ✅ Already Go-focused (verified) |

**Next Agent Instructions:**
The DevContainer and documentation are now fully Go-adapted. Key notes:
- DevContainer uses `mcr.microsoft.com/devcontainers/go:1.23` base image with Go VS Code extension
- Bootstrap script validates Go availability and adds `$GOPATH/bin` to PATH
- All 14 documentation files have been updated or removed (Marimo)
- The mkdocs navigation has been expanded to include more pages
- `.editorconfig` now has Go-specific tab indentation rules
- The only Python references remaining in docs are intentional comparisons to the original Rhiza project

To validate DevContainer:
1. Open the repository in GitHub Codespaces or VS Code Dev Container
2. Verify `go version` matches `.go-version`
3. Verify `make install && make test && make fmt && make lint` all pass
4. Verify Go extension features (IntelliSense, test runner, linting)

---

### Phase 5: Template Self-Tests & Validation

**Goal**: The template can validate itself and downstream projects. This is what elevates rhiza from "a bunch of config files" to "a living template system".

**Why fifth**: This is the quality assurance layer. Once everything works, these tests ensure it stays working.

#### Deliverables

1. **Create `.rhiza/tests/` with Go test files**
   - Structure tests: validate expected files exist (`.go-version`, `go.mod`, `.golangci.yml`, `Makefile`)
   - Bundle tests: validate that every file referenced in `template-bundles.yml` actually exists in the repo
   - Makefile tests: validate that key targets exist (`install`, `test`, `fmt`, `lint`, `clean`)
   - Config tests: validate `.golangci.yml` parses correctly
   - Version tests: validate `.go-version` contains a valid Go version
   - Script tests: validate `release.sh` has correct shebang line and is executable

2. **Create a test harness for downstream project simulation**
   - Script that creates a temporary Go project, copies template files into it, and runs `make install && make test`
   - Validates the template works outside the template repo itself

3. **Add `make validate` target that works for Go**
   - Currently prints a warning about needing `rhiza` CLI
   - Add local validation that runs without the CLI:
     - Check all bundled files exist
     - Check Makefile targets resolve
     - Check Go code compiles

4. **Update `rhiza-test` target in `rhiza.mk`**
   - Currently looks for `*_test.go` in `.rhiza/tests/` (correct approach)
   - Ensure the new Go tests are discoverable

#### Tests & Validation

- [ ] `make rhiza-test` runs all template self-tests and passes
- [ ] `make validate` runs local validation and passes
- [ ] Every file referenced in `template-bundles.yml` exists in the repo
- [ ] The downstream simulation test creates a project from the template and `make test` passes in it
- [ ] Adding a new file to the template without updating `template-bundles.yml` is caught by validation

---

### Phase 6: Release Pipeline Hardening & goreleaser

**Goal**: Production-grade release automation with multi-platform binary distribution, using Go community standard tooling.

**Why sixth**: Once the template is clean and tested, the release pipeline should be best-in-class — this is what makes Go developers want to adopt it.

#### Deliverables

1. **Add `.goreleaser.yml`**
   - Multi-platform builds (linux/darwin/windows × amd64/arm64)
   - Checksums file generation
   - Changelog from git log
   - Docker image publishing (optional)
   - Homebrew tap generation (optional)

2. **Integrate goreleaser into release workflow**
   - `rhiza_release.yml` calls `goreleaser release` instead of manual `go build`
   - SBOM generation via `syft` or `goreleaser`'s built-in support
   - Provenance attestation

3. **Add `govulncheck` to CI**
   - Go's official vulnerability scanner
   - Add to `rhiza_ci.yml` or as a separate workflow

4. **Add `make security` target**
   - Runs `govulncheck` and `gosec`
   - Optional: SBOM generation locally

#### Tests & Validation

- [ ] `goreleaser check` passes (config validation)
- [ ] `goreleaser release --snapshot --clean` builds all platforms locally
- [ ] Tag push triggers release workflow that uses goreleaser
- [ ] Release artefacts include binaries + checksums + SBOM
- [ ] `make security` runs without errors
- [ ] `govulncheck` is included in CI

---

### Phase 7: Cleanup, Polish & Dogfooding

**Goal**: Remove all migration artefacts, ensure the template is self-referential (uses itself), and validate by creating a real downstream project.

**Why last**: This is the final quality gate before the template is ready for public consumption.

#### Deliverables

1. **Remove migration documents**
   - Delete `UNDERSTANDING_RHIZA.md` (internal reference, not needed in template)
   - Delete `GO_ADAPTATION_GUIDE.md` (internal reference)
   - Delete `REPOSITORY_ANALYSIS.md` (internal reference)
   - Delete `IMPLEMENTATION_SUMMARY.md` (internal reference)
   - Delete `ROADMAP.md` (this file — once all phases complete)
   - These contain valuable context but should not ship in the template

2. **Strip the example Go application code**
   - `cmd/rhiza-go/main.go`, `pkg/config/`, `internal/utils/` are example code
   - Decision: keep as minimal example (like rhiza keeps `src/rhiza/__init__.py`) or remove?
   - Recommendation: keep minimal example that demonstrates project structure but make it clearly starter code

3. **Dogfood: create a real project using the template**
   - Create a new repo (e.g., `example-go-service`)
   - Set up `.rhiza/template.yml` pointing to `Jebel-Quant/rhiza-go`
   - Run sync and verify all files are correct
   - Run `make install && make test && make fmt && make lint`
   - Verify CI workflows trigger correctly
   - This is the ultimate validation

4. **Tag `v0.1.0`** — first official release
   - Verify the release pipeline end-to-end
   - Write release notes

5. **Final audit**
   - `grep -ri "python\|pyproject\|pytest\|ruff\.toml\|\.python-version\|uv\b\|pdoc\|minibook\|marimo\|pip\b" . --include='*.mk' --include='*.yml' --include='*.yaml' --include='*.sh' --include='*.toml' --include='*.json' --include='*.md'` — audit for Python leakage (excluding docs that intentionally reference Python for comparison)
   - Verify every `make` target works
   - Verify every workflow runs

#### Tests & Validation

- [ ] Zero Python references in functional files (Makefiles, workflows, scripts, configs)
- [ ] A downstream project can sync from this template and pass `make install && make test`
- [ ] `v0.1.0` release is created successfully with binaries
- [ ] All 10+ GitHub workflows pass on main branch
- [ ] Template is self-referential: `make sync` in the template repo correctly skips (as it's the source)

---

## Summary Timeline

| Phase | Name | Scope | Key Metric |
|-------|------|-------|------------|
| **1** | Release & Versioning | 5 files | `make release` creates GitHub Release with Go binaries |
| **2** | Template Cleanup | ~10 files | Zero Python references in `.rhiza/` functional files |
| **3** | CI/CD & Automation | ~10 workflows | All GitHub Actions pass for Go |
| **4** | DevContainer & Docs | ~12 files | DevContainer builds, docs are Go-specific |
| **5** | Self-Tests & Validation | New test suite | `make validate` and `make rhiza-test` pass |
| **6** | goreleaser & Security | 3-4 files | Multi-platform releases, vulnerability scanning |
| **7** | Cleanup & Dogfooding | Audit + new repo | Downstream project works end-to-end |

## Key Decision Points

These decisions should be made before or during the relevant phase:

1. **Phase 1**: Version source — use a `VERSION` file, or embed version in Go code with `ldflags`? (Recommendation: `VERSION` file for simplicity, injected via `ldflags` at build time)

2. **Phase 2**: Book system — port to Go-native tooling, or remove entirely? (Recommendation: remove for now, add back if there's demand)

3. **Phase 3**: Sync mechanism — keep using Python `rhiza` CLI (via `uvx`), or build a Go-native sync tool? (Recommendation: keep Python CLI short-term, it's language-agnostic in purpose)

4. **Phase 3**: GitLab CI — port to Go, or remove? (Recommendation: remove from initial release, add as a future bundle)

5. **Phase 7**: Example code — keep minimal starter code, or ship empty `cmd/`? (Recommendation: keep minimal example)
