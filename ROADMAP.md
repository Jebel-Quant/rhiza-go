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
| `.rhiza/make.d/releasing.mk` | Uses `pyproject.toml`, `uv`, Python `rhiza[tools]` |
| `.rhiza/make.d/book.mk` | Uses `install-uv`, `UVX_BIN`, Python `minibook`, `pdoc` |
| `.rhiza/scripts/release.sh` | Reads version from `pyproject.toml` via `uv` |
| `.rhiza/.cfg.toml` | Bumpversion config targeting `pyproject.toml` |
| `.rhiza/.env` | References `SOURCE_FOLDER=src` |
| `.rhiza/requirements/` | Python pip requirements (entire directory) |
| `.rhiza/template-bundles.yml` | References `.python-version`, `ruff.toml`, `pytest.ini` |
| `.rhiza/tests/` | Python test infrastructure (`conftest.py`) |
| `.rhiza/templates/minibook/` | Python Jinja2 template |
| `.github/workflows/rhiza_release.yml` | Hatch build, PyPI publish, `cyclonedx-bom` |
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

### Phase 1: Release & Versioning Pipeline

**Goal**: A working `make bump` → `make release` → GitHub Release pipeline for Go projects.

**Why first**: Without a release pipeline, you can't version or distribute the template. This is the most critical missing piece — everything else can be iterated on once you can cut releases.

#### Deliverables

1. **Rewrite `.rhiza/scripts/release.sh`** for Go
   - Read version from a `VERSION` file (Go convention — no `pyproject.toml` equivalent)
   - Remove all `uv` references
   - Keep the same UX (prompts, dry-run, colour output, safety checks)

2. **Rewrite `.rhiza/make.d/releasing.mk`** for Go
   - `bump` target: increment version in `VERSION` file using shell or a Go tool (e.g., `svu` or simple sed)
   - `release` target: call the rewritten release script
   - Remove `pyproject.toml`, `uv`, and Python `rhiza[tools]` references

3. **Rewrite `.rhiza/.cfg.toml`** for Go
   - Either: adapt bumpversion to target `VERSION` file instead of `pyproject.toml`
   - Or: replace with a simpler Go-appropriate version management approach (e.g., `svu`, or a `VERSION` file + git tags)

4. **Rewrite `.github/workflows/rhiza_release.yml`** for Go
   - Replace Hatch build with `go build` or `goreleaser`
   - Replace PyPI publish with GitHub Releases binary upload (or `goreleaser`)
   - Replace `cyclonedx-bom` (Python SBOM) with `cyclonedx-gomod` or `syft`
   - Keep: draft release, SBOM generation, devcontainer publishing (language-agnostic)

5. **Create `VERSION` file** at repo root
   - Contains `0.1.0` (or similar)
   - Single source of truth for project version

#### Tests & Validation

- [ ] `make bump` increments the version in `VERSION` and creates a commit
- [ ] `make release --dry-run` (or `release.sh --dry-run`) shows correct tag without pushing
- [ ] `make release` creates a git tag matching `VERSION` and pushes it
- [ ] GitHub Actions `rhiza_release.yml` triggers on tag push and:
  - Builds Go binaries for linux/darwin/windows (amd64/arm64)
  - Generates SBOM
  - Creates a draft GitHub Release with assets attached
- [ ] The release workflow does NOT reference Python, `uv`, `hatch`, or `pyproject.toml`

---

### Phase 2: Template Infrastructure Cleanup

**Goal**: Remove all Python artefacts so this repo is a clean Go template. A downstream Go project syncing from this template should receive only Go-relevant files.

**Why second**: With the release pipeline working, you can now clean the template content that downstream projects will actually consume.

#### Deliverables

1. **Rewrite `.rhiza/template-bundles.yml`** for Go
   - Replace all Python file references:
     - `.python-version` → `.go-version`
     - `ruff.toml` → `.golangci.yml`
     - `pytest.ini` → (remove, Go uses Makefile flags)
     - `pyproject.toml` → `go.mod` (in examples/docs only)
   - Remove Python-only bundles: `marimo` (or create Go equivalent)
   - Update `tests` bundle: remove `pytest.ini`, `.rhiza/requirements/tests.txt`, `rhiza_mypy.yml`
   - Update `core` bundle: remove `.rhiza/requirements/docs.txt`, `.rhiza/requirements/tools.txt`
   - Add Go-specific entries where appropriate

2. **Fix `.rhiza/make.d/docker.mk`**
   - Replace `PYTHON_VERSION` → `GO_VERSION`
   - Update build-arg to match the Go Dockerfile

3. **Rewrite or remove `.rhiza/make.d/book.mk`**
   - Option A: Remove entirely (Go projects typically use `godoc` or `pkgsite`, not minibook)
   - Option B: Rewrite to use Go-native documentation tooling
   - Decision point: does the book concept translate to Go? If yes, use `pkgsite` + `mkdocs`. If no, remove.

4. **Update `.rhiza/.env`**
   - Change `SOURCE_FOLDER=src` to something Go-appropriate (e.g., `SOURCE_FOLDER=.` or remove)
   - Remove or update `SCRIPTS_FOLDER`, `MARIMO_FOLDER` if not applicable

5. **Remove `.rhiza/requirements/` directory**
   - These are Python pip requirements — not applicable to Go
   - Keep the `README.md` explaining the directory's purpose (or replace with a note about Go tooling)

6. **Remove or replace `.rhiza/tests/`**
   - Contains Python tests (`conftest.py`, etc.)
   - Replace with Go tests that validate template structure (e.g., "does `.go-version` exist?", "does `go.mod` parse?")

7. **Remove `.rhiza/templates/minibook/`**
   - Python Jinja2 template — not applicable to Go

8. **Remove `book/marimo/`**
   - Python Marimo notebooks — not applicable to Go

#### Tests & Validation

- [ ] `grep -r "python\|pyproject\|pytest\|ruff\.toml\|\.python-version\|uv\b\|pdoc\|minibook\|marimo" .rhiza/` returns zero matches (excluding documentation/comments explaining the Python→Go migration)
- [ ] `make install && make test && make fmt && make lint` all pass cleanly
- [ ] `make docker-build` works (uses `GO_VERSION`, not `PYTHON_VERSION`)
- [ ] `.rhiza/template-bundles.yml` validates against schema (all referenced files exist in the repo)
- [ ] No orphaned Python files remain in `.rhiza/`

---

### Phase 3: CI/CD & Automation Workflows

**Goal**: All GitHub Actions workflows, Dependabot/Renovate configs, and agent infrastructure work for Go.

**Why third**: CI/CD is critical for a template, but only meaningful once the template content (Phase 2) is correct.

#### Deliverables

1. **Rewrite `.github/workflows/copilot-setup-steps.yml`**
   - Remove `uv` installation
   - Replace `setup-uv` with `setup-go`  
   - Remove `.venv` activation (Go doesn't use virtualenvs)
   - Run `make install` (which now does `go mod download`)
   - Add `GOPATH/bin` to `GITHUB_PATH` for Go tools

2. **Rewrite `.github/hooks/session-start.sh`**
   - Validate `go` is available (not `uv`)
   - Validate Go version matches `.go-version`
   - Remove `.venv` checks

3. **Rewrite `.github/copilot-instructions.md`**
   - Replace all Python references with Go equivalents
   - Document `make install`, `make test`, `make fmt` in Go context
   - Reference `go.mod` instead of `pyproject.toml`
   - Reference `.go-version` instead of `.python-version`
   - Reference `golangci-lint` instead of `ruff` and `go fmt` instead of `ruff format`
   - Update project structure (`cmd/`, `pkg/`, `internal/` instead of `src/`, `tests/`)
   - Update coding standards (effective Go, not PEP 8)

4. **Fix `.github/workflows/rhiza_codeql.yml`**
   - Replace `python` with `go` in the language matrix
   - Remove `actions` if not needed

5. **Update `.github/dependabot.yml`**
   - Replace `pep621` package ecosystem with `gomod`
   - Keep `github-actions` and `docker` ecosystems

6. **Update `renovate.json`**
   - Replace `pep621` manager with `gomod`
   - Keep `pre-commit`, `github-actions`, `dockerfile`, `devcontainer`
   - Keep custom regex manager for `.rhiza/template.yml` (language-agnostic)

7. **Update `.github/workflows/rhiza_sync.yml`**
   - Currently uses `uvx rhiza materialize` — this depends on the Python `rhiza` CLI
   - Decision point: Will the Go template sync mechanism use the same Python `rhiza` CLI (as a standalone tool), or will there be a Go-native sync tool?
   - Short-term: keep using `uvx rhiza` (it's a CLI tool, language of the template doesn't matter)
   - Long-term: note this as a future item for a Go-native `rhiza` CLI

8. **Update `.github/workflows/rhiza_validate.yml`**
   - Same decision as sync — keep `uvx rhiza validate` or build Go alternative
   - Short-term: keep as-is with a note

9. **Update `.github/workflows/rhiza_pre-commit.yml`**
   - Ensure it installs Go (not Python/uv) for running pre-commit hooks
   - Note: pre-commit itself is Python, so `uv`/`pip` may still be needed to install pre-commit... but the hooks it runs should be Go tools

10. **Update or remove `.gitlab-ci.yml`**
    - Currently entirely Python-centric
    - Option A: Rewrite for Go
    - Option B: Remove if GitLab CI is not a priority for the Go template

#### Tests & Validation

- [ ] Push a test branch → `rhiza_ci.yml` runs Go tests successfully
- [ ] Push a tag → `rhiza_release.yml` builds Go binaries and creates GitHub Release
- [ ] `rhiza_codeql.yml` runs CodeQL for `go` (not `python`)
- [ ] `copilot-setup-steps.yml` completes without errors in a Go-only environment
- [ ] `session-start.sh` validates Go (not Python) environment
- [ ] Dependabot creates PRs for `go.mod` dependency updates
- [ ] Renovate creates PRs for Go module updates
- [ ] `rhiza_docker.yml` builds successfully
- [ ] `rhiza_pre-commit.yml` runs all Go hooks successfully

---

### Phase 4: DevContainer & Documentation

**Goal**: A first-class developer experience for anyone using the Go template — proper devcontainer, documentation, and onboarding.

**Why fourth**: Developer experience polishes the template but isn't blocking for core functionality.

#### Deliverables

1. **Rewrite `.devcontainer/devcontainer.json`**
   - Base image: `mcr.microsoft.com/devcontainers/go` (not Python)
   - VS Code extensions: Go, golangci-lint, Go Test Explorer
   - Features: `ghcr.io/devcontainers/features/go`
   - Remove Python-specific features

2. **Rewrite `.devcontainer/bootstrap.sh`**
   - Install Go tools (`golangci-lint`, `goimports`, `godoc`)
   - Run `make install`
   - Remove `uv`, `.venv`, Python references

3. **Update `docs/` directory**
   - `docs/ARCHITECTURE.md` — Update for Go project layout (`cmd/`, `pkg/`, `internal/`)
   - `docs/CUSTOMIZATION.md` — Update hook examples for Go
   - `docs/DOCKER.md` — Already mostly correct (verify)
   - `docs/DEVCONTAINER.md` — Update for Go devcontainer
   - `docs/QUICK_REFERENCE.md` — Update commands for Go
   - `docs/SECURITY.md` — Update for Go security practices (`gosec`, `govulncheck`)
   - `docs/TESTS.md` — Update for `go test` (not pytest)
   - `docs/DEMO.md` — Create Go-specific demo walkthrough
   - `docs/GLOSSARY.md` — Update terms for Go

4. **Update `.editorconfig`**
   - Change Go indentation to tabs (Go convention)
   - Remove Python-specific section or update

5. **Update `README.md`** (final pass)
   - Ensure all badges point to correct workflows
   - Ensure all example commands are Go-specific
   - Add template usage instructions (how a downstream project onboards)
   - Add comparison vs Python rhiza

#### Tests & Validation

- [ ] DevContainer builds successfully in GitHub Codespaces
- [ ] Inside the devcontainer: `make install && make test && make fmt && make lint` all pass
- [ ] All documentation references are Go-specific (no Python leakage)
- [ ] `grep -r "python\|pyproject\|pytest\|ruff\|\.python-version\|uv\b" docs/` returns zero unexpected matches
- [ ] README renders correctly on GitHub with all badges functional

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
