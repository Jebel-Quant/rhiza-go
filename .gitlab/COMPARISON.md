# GitHub Actions vs GitLab CI Comparison

This document provides a side-by-side comparison of GitHub Actions and GitLab CI implementations for the rhiza-go project.

## Workflow Mapping

| Feature | GitHub Actions | GitLab CI | Status |
|---------|----------------|-----------|--------|
| Main Config | `.github/workflows/*.yml` | `.gitlab-ci.yml` + `.gitlab/workflows/*.yml` | ✅ Complete |
| CI Testing | `rhiza_ci.yml` | `rhiza_ci.yml` | ✅ Complete |
| Validation | `rhiza_validate.yml` | `rhiza_validate.yml` | ✅ Complete |
| Formatting | `rhiza_pre-commit.yml` | `rhiza_pre-commit.yml` | ✅ Complete |
| Documentation | `rhiza_book.yml` | `rhiza_book.yml` | ✅ Complete |
| Sync | `rhiza_sync.yml` | `rhiza_sync.yml` | ✅ Complete |
| Release | `rhiza_release.yml` | `rhiza_release.yml` | ✅ Complete |
| Renovate | `rhiza_renovate.yml` | `rhiza_renovate.yml` | ✅ Complete |

## Syntax Differences

### Triggers

**GitHub Actions:**
```yaml
on:
  push:
  pull_request:
    branches: [main, master]
```

**GitLab CI:**
```yaml
rules:
  - if: $CI_PIPELINE_SOURCE == "merge_request_event"
  - if: $CI_COMMIT_BRANCH
```

### Jobs and Steps

**GitHub Actions:**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v6
      - name: Run tests
        run: make test
```

**GitLab CI:**
```yaml
test:
  stage: test
  image: golang:1.23-bookworm
  script:
    - make test
```

### Artifacts

**GitHub Actions:**
```yaml
- uses: actions/upload-artifact@v6
  with:
    name: dist
    path: dist
```

**GitLab CI:**
```yaml
artifacts:
  paths:
    - dist/
  expire_in: 1 day
```

### Container Images

**GitHub Actions:**
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: golang:1.23-bookworm
```

**GitLab CI:**
```yaml
test:
  image: golang:1.23-bookworm
```

### Secrets and Variables

**GitHub Actions:**
```yaml
env:
  TOKEN: ${{ secrets.PAT_TOKEN }}
  CUSTOM_VAR: ${{ vars.CUSTOM_VAR }}
```

**GitLab CI:**
```yaml
script:
  - echo $PAT_TOKEN
  - echo $CUSTOM_VAR
```

## Feature Comparison

### 1. Go Testing (CI)

| Feature | GitHub Actions | GitLab CI |
|---------|----------------|-----------|
| Go image | ✅ `golang:${GO_VERSION}-bookworm` | ✅ `golang:${GO_VERSION}-bookworm` |
| Test runner | ✅ `make test` | ✅ `make test` |
| Dep download | ✅ `go mod download` | ✅ `go mod download` |

### 2. Documentation (Book)

| Feature | GitHub Actions | GitLab CI |
|---------|----------------|-----------|
| Build | ✅ `make book` | ✅ `make book` |
| Output directory | `_book/` | `public/` (required) |
| Deployment | GitHub Pages | GitLab Pages |
| Deploy action | `actions/deploy-pages@v4` | Job named `pages` |

### 3. Release

| Feature | GitHub Actions | GitLab CI |
|---------|----------------|-----------|
| Build tool | ✅ goreleaser | ✅ goreleaser |
| Release creation | `softprops/action-gh-release` | GitLab Releases API |
| Version validation | ✅ VERSION file | ✅ VERSION file |
| SBOM generation | ✅ syft | ✅ syft |

### 4. Sync

| Feature | GitHub Actions | GitLab CI |
|---------|----------------|-----------|
| Template sync | ✅ `rhiza materialize` | ✅ `rhiza materialize` |
| PR/MR creation | ✅ Automatic | ⚠️ Manual (API call needed) |
| Token requirement | PAT_TOKEN | PAT_TOKEN |
| Scheduling | ✅ Cron syntax | ✅ Pipeline schedules |

## Platform-Specific Features

### GitHub Actions Only

1. **Action Marketplace:** Reusable actions from the community
2. **Job summaries:** Rich markdown summaries in the UI
3. **Environments:** Built-in environment protection rules

### GitLab CI Only

1. **Stages:** Explicit pipeline stages (`.pre`, `build`, `test`, `deploy`, `.post`)
2. **Job templates:** Reusable job definitions with `extends`
3. **Child pipelines:** Dynamic pipeline generation
4. **Auto DevOps:** Automatic CI/CD configuration

## Migration Considerations

### Easy Migrations
- ✅ Basic CI/CD pipelines
- ✅ Docker-based workflows
- ✅ Artifact handling
- ✅ Environment variables
- ✅ Scheduled pipelines

### Moderate Effort
- ⚠️ Marketplace actions (reimplement with scripts)
- ⚠️ Complex conditionals (restructure with rules)

### Challenging Migrations
- ❌ GitHub-specific APIs (use GitLab APIs)
- ❌ GitHub Apps (use GitLab integrations)

## Testing Status

| Workflow | YAML Valid | Logic Verified | Notes |
|----------|------------|----------------|-------|
| CI | ✅ | ⏳ | Go testing with make test |
| Validate | ✅ | ⏳ | Skips in rhiza-go repo |
| Formatting | ✅ | ⏳ | Go formatting and linting |
| Book | ✅ | ⏳ | Needs GitLab Pages setup |
| Sync | ✅ | ⏳ | Needs PAT_TOKEN |
| Release | ✅ | ⏳ | goreleaser + syft |
| Renovate | ✅ | ⏳ | Needs RENOVATE_TOKEN |

Legend:
- ✅ Complete
- ⏳ Pending (ready for testing)
- ❌ Not tested

## Recommendations

### For New Projects
1. Choose platform based on primary hosting (GitHub vs GitLab)
2. Consider OIDC requirements (GitHub has better support)
3. Evaluate marketplace actions vs custom scripts

### For Migration
1. Start with simple workflows (CI, pre-commit)
2. Test thoroughly in a fork/mirror
3. Configure all required variables
4. Update documentation links
5. Train team on platform differences

### For Dual Support
1. Maintain both workflow sets (as done here)
2. Keep feature parity
3. Document platform-specific differences
4. Test changes on both platforms

## Resources

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **GitLab CI Docs:** https://docs.gitlab.com/ee/ci/
- **Rhiza-Go GitHub:** https://github.com/jebel-quant/rhiza-go
- **Migration Guide:** `.gitlab/README.md`
- **Testing Guide:** `.gitlab/TESTING.md`

## Summary

Most GitHub Actions workflows have been converted to GitLab CI with equivalent functionality. The main differences are:

1. **Syntax:** Different trigger and job definitions
2. **Pages:** Different output directory requirements
3. **APIs:** Platform-specific endpoints

Both platforms are fully supported and provide equivalent functionality for the rhiza-go project.
