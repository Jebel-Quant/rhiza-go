# GitLab CI/CD Workflows for Rhiza-Go

This directory contains GitLab CI/CD workflow configurations that mirror the functionality of the GitHub Actions workflows in `.github/workflows/`.

## Structure

```
.gitlab/
├── workflows/
│   ├── rhiza_ci.yml           # Continuous Integration - Go testing
│   ├── rhiza_validate.yml     # Rhiza configuration validation
│   ├── rhiza_pre-commit.yml   # Formatting & linting checks
│   ├── rhiza_book.yml         # Documentation building (GitLab Pages)
│   ├── rhiza_sync.yml         # Template synchronization
│   ├── rhiza_release.yml      # Release workflow (goreleaser)
│   └── rhiza_renovate.yml     # Automated dependency updates
└── README.md                  # This file

.gitlab-ci.yml                 # Main GitLab CI configuration (includes all workflows)
```

## Workflows

### 1. CI (`rhiza_ci.yml`)
**Purpose:** Run Go tests to ensure correctness and compatibility.

**Trigger:**
- On push to any branch
- On merge requests to main/master

**Key Features:**
- Uses `golang:${GO_VERSION}-bookworm` image
- Runs `make test` after `go mod download`

**Equivalent GitHub Action:** `.github/workflows/rhiza_ci.yml`

---

### 2. Validate (`rhiza_validate.yml`)
**Purpose:** Validate Rhiza configuration against template.

**Trigger:**
- On push to any branch
- On merge requests to main/master

**Key Features:**
- Skips validation in the rhiza-go repository itself
- Runs `make validate` for Go projects, falls back to `uvx rhiza validate`

**Equivalent GitHub Action:** `.github/workflows/rhiza_validate.yml`

---

### 3. Formatting & Linting (`rhiza_pre-commit.yml`)
**Purpose:** Run Go formatting and linting checks for code quality.

**Trigger:**
- On push to any branch
- On merge requests to main/master

**Key Features:**
- Runs `make fmt` (goimports, golangci-lint)
- Uses `golang:${GO_VERSION}-bookworm` image

**Equivalent GitHub Action:** `.github/workflows/rhiza_pre-commit.yml`

---

### 4. Book (`rhiza_book.yml`)
**Purpose:** Build and deploy Go documentation to GitLab Pages.

**Trigger:**
- On push to main/master branch

**Key Features:**
- Generates godoc API documentation and coverage reports
- Deploys to GitLab Pages
- Controlled by `PUBLISH_COMPANION_BOOK` variable

**Equivalent GitHub Action:** `.github/workflows/rhiza_book.yml`

**GitLab-specific:** Outputs to `public/` directory for GitLab Pages.

---

### 5. Sync (`rhiza_sync.yml`)
**Purpose:** Synchronize repository with its template.

**Trigger:**
- Scheduled (can be set in GitLab)
- Manual trigger
- Web pipeline trigger

**Key Features:**
- Template materialization with rhiza CLI
- Automatic branch creation
- Manual merge request creation

**Equivalent GitHub Action:** `.github/workflows/rhiza_sync.yml`

**GitLab-specific:** Requires Project/Group Access Token (PAT_TOKEN) for workflow modifications.

---

### 6. Release (`rhiza_release.yml`)
**Purpose:** Build Go binaries and create GitLab releases.

**Trigger:**
- On version tags (e.g., `v1.2.3`)

**Key Features:**
- Version validation against `VERSION` file
- Go binary building with goreleaser
- SBOM generation with syft
- GitLab release creation

**Equivalent GitHub Action:** `.github/workflows/rhiza_release.yml`

**GitLab-specific:**
- Uses GitLab Releases API instead of GitHub Releases

---

### 7. Renovate (`rhiza_renovate.yml`)
**Purpose:** Automated dependency updates via Renovate.

**Trigger:**
- Scheduled pipelines
- Manual trigger via web UI

**Key Features:**
- Language-agnostic dependency management
- Automatic merge request creation

---

## Key Differences from GitHub Actions

### 1. **Syntax and Structure**
- **GitHub Actions:** Uses `jobs` and `steps` with `uses` for actions
- **GitLab CI:** Uses `jobs` with `script` and `before_script` sections

### 2. **Triggers**
- **GitHub Actions:** `on: push`, `on: pull_request`
- **GitLab CI:** `rules` with conditions like `if: $CI_PIPELINE_SOURCE == "merge_request_event"`

### 3. **Artifacts and Caching**
- **GitHub Actions:** `actions/upload-artifact@v6`, `actions/download-artifact@v7`
- **GitLab CI:** `artifacts: paths:` and automatic artifact passing between stages

### 4. **Container Images**
- **GitHub Actions:** `runs-on: ubuntu-latest` with `uses: actions/setup-go`
- **GitLab CI:** `image: golang:${GO_VERSION}-bookworm`

### 5. **Pages Deployment**
- **GitHub Actions:** `actions/deploy-pages@v4`
- **GitLab CI:** Job named `pages` with `artifacts: paths: [public]`

### 6. **Secrets and Variables**
- **GitHub Actions:** `secrets.*` and `vars.*`
- **GitLab CI:** `$CI_VARIABLE_NAME` or protected/masked variables

### 7. **Release Management**
- **GitHub Actions:** `softprops/action-gh-release@v2`
- **GitLab CI:** GitLab Releases API with `curl` commands

---

## Configuration Variables

These variables can be set in GitLab CI/CD settings (Settings > CI/CD > Variables):

| Variable | Default | Description |
|----------|---------|-------------|
| `GO_VERSION` | `1.23` | Go version to use |
| `PUBLISH_COMPANION_BOOK` | `true` | Whether to publish documentation |
| `CREATE_MR` | `true` | Whether to create merge request on sync |
| `PAT_TOKEN` | N/A | **Secret** - Project/Group Access Token for sync |
| `RENOVATE_TOKEN` | N/A | **Secret** - Token for Renovate dependency updates |

### Setting Variables

1. Navigate to your GitLab project
2. Go to **Settings > CI/CD > Variables**
3. Click **Add variable**
4. Enter the variable name and value
5. Mark as **Protected** for production variables
6. Mark as **Masked** for sensitive values

---

## Testing GitLab CI Locally

You can validate the GitLab CI configuration syntax using:

```bash
# Install GitLab CI Lint tool
curl --header "PRIVATE-TOKEN: <your_access_token>" \
  "https://gitlab.com/api/v4/projects/<project_id>/ci/lint" \
  --data-urlencode "content@.gitlab-ci.yml"
```

Or use the GitLab UI:
1. Go to **CI/CD > Pipelines**
2. Click **CI Lint** button (or go to `/ci/lint`)
3. Paste your `.gitlab-ci.yml` content
4. Click **Validate**

---

## Migration Checklist

When migrating from GitHub Actions to GitLab CI:

- [ ] Set required CI/CD variables
- [ ] Configure Project/Group Access Token for `PAT_TOKEN` (if using sync)
- [ ] Enable GitLab Pages in project settings (if using book)
- [ ] Configure scheduled pipelines for sync and renovate workflows
- [ ] Update any repository-specific configurations
- [ ] Test each workflow individually
- [ ] Verify release workflow with a test tag
- [ ] Update documentation links

---

## Troubleshooting

### Common Issues

1. **Pipeline fails with "permission denied"**
   - Check if required variables are set
   - Verify token permissions

2. **Pages deployment doesn't work**
   - Ensure job is named `pages`
   - Verify artifacts are in `public/` directory
   - Check if GitLab Pages is enabled

3. **Release workflow fails**
   - Check tag format (must start with `v`)
   - Ensure version in `VERSION` file matches tag

---

## Support

For issues specific to:
- **GitLab CI syntax:** Refer to [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- **Rhiza-Go workflows:** See main repository README
- **Workflow behavior:** Compare with corresponding GitHub Actions workflows

---

## Contributing

When adding or modifying workflows:

1. Update both `.gitlab/workflows/*.yml` and `.github/workflows/*.yml`
2. Keep feature parity between GitHub Actions and GitLab CI
3. Document any platform-specific differences
4. Test changes in a fork before merging
5. Update this README with new workflows or variables

---

## License

These workflows are part of the jebel-quant/rhiza-go repository and follow the same license.
