# GitLab CI/CD Testing Guide

This document provides instructions for testing the GitLab CI/CD workflows.

## Prerequisites

1. A GitLab account (gitlab.com or self-hosted)
2. A GitLab repository (can be a mirror/fork of the GitHub repository)
3. Access to GitLab CI/CD settings

## Testing Approach

Since this is the rhiza-go repository itself, comprehensive testing requires:
1. Creating a test project/fork in GitLab
2. Configuring CI/CD variables
3. Triggering each workflow type

## Quick Validation

### 1. YAML Syntax Validation

All workflow files have been validated for YAML syntax:

```bash
# Validate all YAML files
for file in .gitlab-ci.yml .gitlab/workflows/*.yml; do
    python3 -c "import yaml; yaml.safe_load(open('$file'))" && \
    echo "✅ $file is valid YAML"
done
```

### 2. GitLab CI Lint

You can validate the configuration using GitLab's CI Lint tool:

**Option A: Web UI**
1. Go to your GitLab project
2. Navigate to **CI/CD > Pipelines**
3. Click **CI Lint** button (or visit `/-/ci/lint`)
4. Paste the contents of `.gitlab-ci.yml`
5. Click **Validate**

**Option B: API** (requires GitLab access token)
```bash
curl --header "PRIVATE-TOKEN: <your_token>" \
  "https://gitlab.com/api/v4/projects/<project_id>/ci/lint" \
  --form "content=@.gitlab-ci.yml"
```

## Workflow-Specific Testing

### 1. CI Workflow (`rhiza_ci.yml`)

**Test trigger:** Push to any branch or create merge request

**Expected behavior:**
- Uses `golang:${GO_VERSION}-bookworm` image
- Runs `go mod download` then `make test`

**Manual test:**
```bash
# Push to a test branch
git checkout -b test-gitlab-ci
git push origin test-gitlab-ci
```

**Success criteria:**
- Tests pass via `make test`

---

### 2. Validate Workflow (`rhiza_validate.yml`)

**Test trigger:** Push to any branch or create merge request

**Expected behavior:**
- Skips in the rhiza-go repository itself
- Runs `make validate` in downstream projects, falls back to `uvx rhiza validate`

**Success criteria:**
- Job skips in rhiza-go repository
- Would run and validate in downstream projects

---

### 3. Formatting & Linting Workflow (`rhiza_pre-commit.yml`)

**Test trigger:** Push to any branch or create merge request

**Expected behavior:**
- Runs `make fmt` for Go formatting and linting checks

**Manual test:**
```bash
# Run formatting locally
make fmt
```

**Success criteria:**
- All formatting and linting checks pass

---

### 4. Book Workflow (`rhiza_book.yml`)

**Test trigger:** Push to `main` or `master` branch

**Expected behavior:**
- Builds Go documentation (godoc + coverage)
- Deploys to GitLab Pages (public/ directory)

**Manual test:**
```bash
# Build book locally
make book
ls -la _book/
```

**Success criteria:**
- Documentation builds successfully
- GitLab Pages deployment succeeds
- Pages are accessible at `https://<username>.gitlab.io/<project>/`

**Configuration needed:**
- Enable GitLab Pages in project settings
- Set `PUBLISH_COMPANION_BOOK=true` (default)

---

### 5. Sync Workflow (`rhiza_sync.yml`)

**Test trigger:** Manual pipeline, scheduled pipeline, or web trigger

**Expected behavior:**
- Syncs repository with template
- Creates a new branch
- Commits changes
- Optionally creates merge request

**Manual test:**
```bash
# Trigger manually from GitLab UI
# CI/CD > Pipelines > Run pipeline
```

**Success criteria:**
- Template synchronization completes
- New branch created if changes detected
- No changes if already in sync

**Configuration needed:**
- Set `PAT_TOKEN` for workflow modifications
- Set `CREATE_MR=true` to auto-create merge requests

---

### 6. Release Workflow (`rhiza_release.yml`)

**Test trigger:** Push a version tag (e.g., `v1.0.0`)

**Expected behavior:**
- Validates tag format and VERSION file match
- Builds Go binaries with goreleaser
- Generates SBOM with syft
- Creates GitLab release

**Manual test:**
```bash
# Create and push a test tag
git tag v0.0.1-test
git push origin v0.0.1-test
```

**Success criteria:**
- Version in `VERSION` file matches tag
- Go binaries build successfully
- GitLab release created

---

### 7. Renovate Workflow (`rhiza_renovate.yml`)

**Test trigger:** Scheduled pipeline or manual trigger with `RENOVATE_RUN=true`

**Expected behavior:**
- Runs Renovate to check for dependency updates
- Creates merge requests for updates

**Configuration needed:**
- Set `RENOVATE_TOKEN` with appropriate scopes

---

## Required CI/CD Variables

Set these in GitLab project settings (Settings > CI/CD > Variables):

### Secrets (Protected & Masked)
- `PAT_TOKEN` - Project/Group Access Token (for sync workflow)
- `RENOVATE_TOKEN` - Token for Renovate (for renovate workflow)

### Configuration Variables
- `GO_VERSION` - Go version (default: 1.23)
- `PUBLISH_COMPANION_BOOK` - Publish documentation (default: true)
- `CREATE_MR` - Auto-create merge requests (default: true)

## Complete Testing Checklist

- [ ] Validate YAML syntax for all workflow files
- [ ] Set up test GitLab repository
- [ ] Configure required CI/CD variables
- [ ] Test CI workflow (push to branch)
- [ ] Test Validate workflow (in downstream project)
- [ ] Test Formatting workflow
- [ ] Test Book workflow (push to main)
- [ ] Test Sync workflow (manual trigger)
- [ ] Test Release workflow (push version tag)
- [ ] Verify GitLab Pages deployment

## Troubleshooting

### Pipeline doesn't start
- Check if `.gitlab-ci.yml` is in the root directory
- Verify YAML syntax is valid
- Check pipeline rules match the trigger condition

### Permission errors
- Ensure required variables are set
- Check if tokens have correct scopes
- Verify project permissions

### GitLab Pages not deploying
- Ensure job is named `pages`
- Verify artifacts are in `public/` directory
- Check if GitLab Pages is enabled in project settings
- Ensure pipeline runs on default branch

## Support

- **GitLab CI/CD Docs:** https://docs.gitlab.com/ee/ci/
- **GitLab API Docs:** https://docs.gitlab.com/ee/api/
- **Rhiza-Go Repository:** https://github.com/jebel-quant/rhiza-go
