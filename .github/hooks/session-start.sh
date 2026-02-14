#!/bin/bash
set -euo pipefail

# Session Start Hook
# Validates that the environment is correctly set up before the agent begins work.
# Go should already be available via copilot-setup-steps.yml.

echo "[copilot-hook] Validating environment..."

# Verify Go is available
if ! command -v go >/dev/null 2>&1; then
    echo "[copilot-hook] ERROR: go not found. Run 'make install' to set up the environment."
    exit 1
fi

# Verify Go version matches .go-version
if [ -f ".go-version" ]; then
    EXPECTED_VERSION=$(cat .go-version | tr -d '[:space:]')
    INSTALLED_VERSION=$(go version | grep -oP '\d+\.\d+' | head -1)
    if [ "$INSTALLED_VERSION" != "$EXPECTED_VERSION" ]; then
        echo "[copilot-hook] WARNING: Go version mismatch: installed=${INSTALLED_VERSION}, expected=${EXPECTED_VERSION}"
    fi
fi

# Verify go.mod exists (valid Go project)
if [ ! -f "go.mod" ]; then
    echo "[copilot-hook] ERROR: go.mod not found. This does not appear to be a Go project."
    exit 1
fi

echo "[copilot-hook] Environment validated successfully."
