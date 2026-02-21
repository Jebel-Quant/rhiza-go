#!/bin/bash
set -euo pipefail

# Session End Hook
# Runs quality gates after the agent finishes work.
# Gates: format → lint (warning-only) → test → module tidiness check.

echo "[copilot-hook] Running post-work quality gates..."

# ── 1. Format ────────────────────────────────────────────────────────
echo "[copilot-hook] [1/4] Formatting code..."
if ! make fmt; then
    echo "[copilot-hook] ERROR: Formatting failed."
    exit 1
fi

# ── 2. Lint ──────────────────────────────────────────────────────────
echo "[copilot-hook] [2/4] Running linter..."
if ! make lint; then
    echo "[copilot-hook] WARNING: Linting reported issues — review findings above."
    # Lint failures are warnings, not blockers, to avoid false positives blocking commits
fi

# ── 3. Test ──────────────────────────────────────────────────────────
echo "[copilot-hook] [3/4] Running tests..."
if ! make test; then
    echo "[copilot-hook] ERROR: Tests failed."
    exit 1
fi

# ── 4. Module tidiness ──────────────────────────────────────────────
echo "[copilot-hook] [4/4] Checking module tidiness..."
if go mod tidy 2>/dev/null; then
    # Check for uncommitted go.mod/go.sum changes from tidy
    if ! git diff --quiet go.mod go.sum 2>/dev/null; then
        echo "[copilot-hook] WARNING: go.mod or go.sum changed after 'go mod tidy' — stage these changes."
    fi
fi

echo "[copilot-hook] All quality gates passed."
