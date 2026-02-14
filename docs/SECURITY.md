# Security Policy

## Supported Versions

We actively support the following versions with security updates:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue, please report it responsibly.

### How to Report

**Do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisories** (Preferred)
   - Go to the [Security Advisories](https://github.com/jebel-quant/rhiza-go/security/advisories) page
   - Click "New draft security advisory"
   - Fill in the details and submit

2. **Email**
   - Send details to the repository maintainers
   - Include "SECURITY" in the subject line

### What to Include

Please include the following information in your report:

- **Description**: A clear description of the vulnerability
- **Impact**: The potential impact of the vulnerability
- **Steps to Reproduce**: Detailed steps to reproduce the issue
- **Affected Versions**: Which versions are affected
- **Suggested Fix**: If you have one (optional)

### What to Expect

- **Acknowledgment**: We will acknowledge receipt within 48 hours
- **Initial Assessment**: We will provide an initial assessment within 7 days
- **Resolution Timeline**: We aim to resolve critical issues within 30 days
- **Credit**: We will credit reporters in the security advisory (unless you prefer to remain anonymous)

### Scope

This security policy applies to:

- The Rhiza-Go template system and configuration files
- GitHub Actions workflows provided by this repository
- Shell scripts in `.rhiza/scripts/`

### Out of Scope

The following are generally out of scope:

- Vulnerabilities in upstream dependencies (report these to the respective projects)
- Issues that require physical access to a user's machine
- Social engineering attacks
- Denial of service attacks that require significant resources

## Security Measures

This project implements several security measures:

### Code Scanning
- **CodeQL**: Automated code scanning for Go and GitHub Actions
- **golangci-lint**: Includes security-focused linters (`gosec`, `gocritic`)
- **go vet**: Built-in static analysis for common issues

### Supply Chain Security
- **SLSA Provenance**: Build attestations for release artifacts (public repositories only)
- **go.sum**: Cryptographic checksums ensure reproducible builds
- **Renovate**: Automated dependency updates with security patches
- **Dependabot**: Monitors `go.mod` for known vulnerabilities

### Release Security
- **Multi-platform binaries**: Built via CI with `syft` SBOM generation
- **Signed Commits**: GPG signing supported for releases
- **Tag Protection**: Releases require version tag validation

## Security Best Practices for Users

When using Rhiza-Go templates in your projects:

1. **Keep Updated**: Regularly sync with upstream templates
2. **Review Changes**: Review template sync PRs before merging
3. **Enable Security Features**: Enable CodeQL and Dependabot in your repositories
4. **Use go.sum**: Always commit `go.sum` for reproducible builds
5. **Configure Branch Protection**: Require PR reviews and status checks
6. **Run govulncheck**: Use `govulncheck ./...` to check for known vulnerabilities in dependencies

## Acknowledgments

We thank the security researchers and community members who help keep Rhiza-Go secure.
