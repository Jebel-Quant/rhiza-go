#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# Read Go version from .go-version (single source of truth)
if [ -f ".go-version" ]; then
    GO_VERSION=$(cat .go-version | tr -d '[:space:]')
    echo "Expected Go version from .go-version: $GO_VERSION"
fi

# Verify Go is available
if ! command -v go &>/dev/null; then
    echo "ERROR: Go is not installed. The devcontainer image should provide Go."
    exit 1
fi

echo "Using Go $(go version)"

# Add GOPATH/bin to PATH for installed tools
export PATH="$(go env GOPATH)/bin:$PATH"

# Make GOPATH/bin persistent for all sessions
echo "export PATH=\"\$(go env GOPATH)/bin:\$PATH\"" >> ~/.bashrc

# Install dependencies and development tools
make install

# Initialize pre-commit hooks if configured
if [ -f .pre-commit-config.yaml ]; then
    if command -v pre-commit &>/dev/null; then
        pre-commit install
    else
        echo "Note: pre-commit not found, skipping hook installation"
    fi
fi
