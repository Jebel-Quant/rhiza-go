#!/bin/bash
set -euo pipefail

# Session Start Hook
# Validates that the environment is correctly set up before the agent begins work.
# Go and dev tools should already be available via copilot-setup-steps.yml.

echo "[copilot-hook] Validating environment..."

# ── Go availability ──────────────────────────────────────────────────
if ! command -v go >/dev/null 2>&1; then
    echo "[copilot-hook] ERROR: go not found in PATH."
    echo "[copilot-hook] Run 'make install' or install Go from https://go.dev/dl/"
    exit 1
fi

# ── Go version check ────────────────────────────────────────────────
if [ -f ".go-version" ]; then
    EXPECTED_VERSION=$(tr -d '[:space:]' < .go-version)
    # Extract version from 'go version go1.25.6 ...' output
    INSTALLED_FULL=$(go version | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
    INSTALLED_MAJOR_MINOR=$(echo "$INSTALLED_FULL" | grep -oE '^[0-9]+\.[0-9]+')
    EXPECTED_MAJOR_MINOR=$(echo "$EXPECTED_VERSION" | grep -oE '^[0-9]+\.[0-9]+')
    if [ "$INSTALLED_MAJOR_MINOR" != "$EXPECTED_MAJOR_MINOR" ]; then
        echo "[copilot-hook] WARNING: Go version mismatch: installed=${INSTALLED_FULL}, expected=${EXPECTED_VERSION}"
    else
        echo "[copilot-hook] Go ${INSTALLED_FULL} (expected ${EXPECTED_VERSION})"
    fi
fi

# ── go.mod presence ──────────────────────────────────────────────────
if [ ! -f "go.mod" ]; then
    echo "[copilot-hook] ERROR: go.mod not found. This does not appear to be a Go project."
    exit 1
fi

# ── GOPATH/bin in PATH ──────────────────────────────────────────────
GOPATH_BIN="$(go env GOPATH)/bin"
case ":$PATH:" in
    *":${GOPATH_BIN}:"*) ;;
    *)
        echo "[copilot-hook] WARNING: GOPATH/bin (${GOPATH_BIN}) not in PATH — adding for this session."
        export PATH="${GOPATH_BIN}:${PATH}"
        ;;
esac

# ── Dev tool checks (non-fatal) ─────────────────────────────────────
MISSING_TOOLS=""
for tool in golangci-lint goimports gotestsum; do
    if ! command -v "$tool" >/dev/null 2>&1 && [ ! -x "${GOPATH_BIN}/${tool}" ]; then
        MISSING_TOOLS="${MISSING_TOOLS} ${tool}"
    fi
done

if [ -n "$MISSING_TOOLS" ]; then
    echo "[copilot-hook] WARNING: Missing dev tools:${MISSING_TOOLS}"
    echo "[copilot-hook] Run 'make install' to install them."
else
    echo "[copilot-hook] All dev tools available."
fi

# ── Build check ──────────────────────────────────────────────────────
if go build ./... 2>/dev/null; then
    echo "[copilot-hook] Project compiles successfully."
else
    echo "[copilot-hook] WARNING: Project has compilation errors. Run 'go build ./...' for details."
fi

echo "[copilot-hook] Environment validated successfully."
