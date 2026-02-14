#!/bin/sh
# Installation script for Go CLI/module/library projects
# - Checks Go version against .go-version
# - Installs Go module dependencies
# - Installs development tools (golangci-lint, goimports, etc.)
# - Sets up GOPATH/bin in PATH
#
# This script is POSIX-sh compatible and follows the Rhiza standards.
# It can be used standalone or called from make install.

set -eu

DRY_RUN=""
SKIP_TOOLS=""
VERBOSE=""

BLUE="\033[36m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
RESET="\033[0m"

# Parse command-line arguments
show_usage() {
  printf "Usage: %s [OPTIONS]\n\n" "$0"
  printf "Description:\n"
  printf "  Install Go dependencies and development tools for this project\n\n"
  printf "Options:\n"
  printf "  -n, --dry-run      Show what would be installed without making changes\n"
  printf "  -s, --skip-tools   Skip installing development tools (only install dependencies)\n"
  printf "  -v, --verbose      Show verbose output\n"
  printf "  -h, --help         Show this help message\n\n"
  printf "Examples:\n"
  printf "  %s                 (full installation)\n" "$0"
  printf "  %s --dry-run       (preview what would be installed)\n" "$0"
  printf "  %s --skip-tools    (install dependencies only)\n" "$0"
  printf "  %s --verbose       (show detailed output)\n" "$0"
}

while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)
      DRY_RUN="true"
      shift
      ;;
    -s|--skip-tools)
      SKIP_TOOLS="true"
      shift
      ;;
    -v|--verbose)
      VERBOSE="true"
      shift
      ;;
    -h|--help)
      show_usage
      exit 0
      ;;
    -*)
      printf "%b[ERROR] Unknown option: %s%b\n" "$RED" "$1" "$RESET"
      show_usage
      exit 1
      ;;
    *)
      printf "%b[ERROR] Unknown argument: %s%b\n" "$RED" "$1" "$RESET"
      show_usage
      exit 1
      ;;
  esac
done

# Helper function to run commands with dry-run support
run_cmd() {
  _cmd="$*"
  if [ -n "$VERBOSE" ]; then
    printf "%b[RUN] %s%b\n" "$BLUE" "$_cmd" "$RESET"
  fi
  if [ -n "$DRY_RUN" ]; then
    printf "%b[DRY-RUN] Would run: %s%b\n" "$YELLOW" "$_cmd" "$RESET"
    return 0
  else
    if [ -n "$VERBOSE" ]; then
      eval "$_cmd"
    else
      eval "$_cmd" >/dev/null 2>&1
    fi
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to get installed Go version
get_go_version() {
  if command_exists go; then
    go version | awk '{print $3}' | sed 's/go//'
  else
    echo ""
  fi
}

# Function to check Go installation and version
check_go_installation() {
  printf "%b[INFO] Checking Go installation...%b\n" "$BLUE" "$RESET"
  
  if ! command_exists go; then
    printf "%b[ERROR] Go is not installed%b\n" "$RED" "$RESET"
    printf "%b[INFO] Please install Go from https://go.dev/dl/%b\n" "$YELLOW" "$RESET"
    exit 1
  fi
  
  INSTALLED_VERSION=$(get_go_version)
  printf "%b[INFO] Found Go %s%b\n" "$BLUE" "$INSTALLED_VERSION" "$RESET"
  
  # Check if .go-version file exists
  if [ -f ".go-version" ]; then
    REQUIRED_VERSION=$(cat .go-version | tr -d '[:space:]')
    
    # Extract major.minor version (e.g., 1.23 from 1.23.12)
    INSTALLED_MAJOR_MINOR=$(echo "$INSTALLED_VERSION" | cut -d'.' -f1-2)
    REQUIRED_MAJOR_MINOR=$(echo "$REQUIRED_VERSION" | cut -d'.' -f1-2)
    
    if [ "$INSTALLED_MAJOR_MINOR" != "$REQUIRED_MAJOR_MINOR" ]; then
      printf "%b[WARN] Go version mismatch%b\n" "$YELLOW" "$RESET"
      printf "%b[WARN] Installed: %s, Required: %s%b\n" "$YELLOW" "$INSTALLED_VERSION" "$REQUIRED_VERSION" "$RESET"
      printf "%b[INFO] Please install Go %s from https://go.dev/dl/%b\n" "$YELLOW" "$REQUIRED_VERSION" "$RESET"
      printf "%b[WARN] Continuing with installed version, but builds may fail%b\n" "$YELLOW" "$RESET"
    else
      printf "%b[PASS] Go version is compatible: %s (required: %s)%b\n" "$GREEN" "$INSTALLED_VERSION" "$REQUIRED_VERSION" "$RESET"
    fi
  else
    printf "%b[INFO] No .go-version file found, skipping version check%b\n" "$BLUE" "$RESET"
  fi
}

# Function to set up GOPATH/bin in PATH
setup_gopath() {
  GOPATH_BIN=$(go env GOPATH)/bin
  printf "%b[INFO] GOPATH/bin location: %s%b\n" "$BLUE" "$GOPATH_BIN" "$RESET"
  
  # Check if GOPATH/bin is in PATH
  case ":$PATH:" in
    *":$GOPATH_BIN:"*)
      printf "%b[PASS] GOPATH/bin is already in PATH%b\n" "$GREEN" "$RESET"
      ;;
    *)
      printf "%b[INFO] GOPATH/bin is not in PATH%b\n" "$YELLOW" "$RESET"
      printf "%b[INFO] Add the following to your shell profile (~/.bashrc, ~/.zshrc, etc.):%b\n" "$BLUE" "$RESET"
      printf "  export PATH=\"\$(go env GOPATH)/bin:\$PATH\"\n"
      
      # Temporarily add to PATH for this session
      if [ -z "$DRY_RUN" ]; then
        export PATH="$GOPATH_BIN:$PATH"
        printf "%b[INFO] Added to PATH for this session%b\n" "$GREEN" "$RESET"
      fi
      ;;
  esac
}

# Function to install Go dependencies
install_dependencies() {
  if [ ! -f "go.mod" ]; then
    printf "%b[WARN] No go.mod found, skipping dependency installation%b\n" "$YELLOW" "$RESET"
    return 0
  fi
  
  printf "\n%b=== Installing Go Dependencies ===%b\n" "$BLUE" "$RESET"
  
  # Download dependencies
  printf "%b[INFO] Downloading Go modules...%b\n" "$BLUE" "$RESET"
  run_cmd "go mod download"
  
  # Tidy dependencies
  printf "%b[INFO] Tidying Go modules...%b\n" "$BLUE" "$RESET"
  run_cmd "go mod tidy"
  
  if [ -z "$DRY_RUN" ]; then
    printf "%b[PASS] Dependencies installed successfully%b\n" "$GREEN" "$RESET"
  fi
}

# Function to install development tools
install_dev_tools() {
  if [ -n "$SKIP_TOOLS" ]; then
    printf "\n%b[INFO] Skipping development tools installation (--skip-tools)%b\n" "$YELLOW" "$RESET"
    return 0
  fi
  
  printf "\n%b=== Installing Development Tools ===%b\n" "$BLUE" "$RESET"
  
  # Install golangci-lint
  printf "%b[INFO] Installing golangci-lint (Go linter)...%b\n" "$BLUE" "$RESET"
  if [ -n "$DRY_RUN" ]; then
    printf "%b[DRY-RUN] Would run: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest%b\n" "$YELLOW" "$RESET"
  else
    if [ -n "$VERBOSE" ]; then
      go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    else
      if go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest >/dev/null 2>&1; then
        printf "%b[PASS] Installed golangci-lint%b\n" "$GREEN" "$RESET"
      else
        printf "%b[WARN] Failed to install golangci-lint (continuing)%b\n" "$YELLOW" "$RESET"
      fi
    fi
  fi
  
  # Install goimports
  printf "%b[INFO] Installing goimports (import formatter)...%b\n" "$BLUE" "$RESET"
  if [ -n "$DRY_RUN" ]; then
    printf "%b[DRY-RUN] Would run: go install golang.org/x/tools/cmd/goimports@latest%b\n" "$YELLOW" "$RESET"
  else
    if [ -n "$VERBOSE" ]; then
      go install golang.org/x/tools/cmd/goimports@latest
    else
      if go install golang.org/x/tools/cmd/goimports@latest >/dev/null 2>&1; then
        printf "%b[PASS] Installed goimports%b\n" "$GREEN" "$RESET"
      else
        printf "%b[WARN] Failed to install goimports (continuing)%b\n" "$YELLOW" "$RESET"
      fi
    fi
  fi
  
  # Install govulncheck
  printf "%b[INFO] Installing govulncheck (vulnerability checker)...%b\n" "$BLUE" "$RESET"
  if [ -n "$DRY_RUN" ]; then
    printf "%b[DRY-RUN] Would run: go install golang.org/x/vuln/cmd/govulncheck@latest%b\n" "$YELLOW" "$RESET"
  else
    if [ -n "$VERBOSE" ]; then
      go install golang.org/x/vuln/cmd/govulncheck@latest
    else
      if go install golang.org/x/vuln/cmd/govulncheck@latest >/dev/null 2>&1; then
        printf "%b[PASS] Installed govulncheck%b\n" "$GREEN" "$RESET"
      else
        printf "%b[WARN] Failed to install govulncheck (continuing)%b\n" "$YELLOW" "$RESET"
      fi
    fi
  fi
  
  # Install gosec
  printf "%b[INFO] Installing gosec (security checker)...%b\n" "$BLUE" "$RESET"
  if [ -n "$DRY_RUN" ]; then
    printf "%b[DRY-RUN] Would run: go install github.com/securego/gosec/v2/cmd/gosec@latest%b\n" "$YELLOW" "$RESET"
  else
    if [ -n "$VERBOSE" ]; then
      go install github.com/securego/gosec/v2/cmd/gosec@latest
    else
      if go install github.com/securego/gosec/v2/cmd/gosec@latest >/dev/null 2>&1; then
        printf "%b[PASS] Installed gosec%b\n" "$GREEN" "$RESET"
      else
        printf "%b[WARN] Failed to install gosec (continuing)%b\n" "$YELLOW" "$RESET"
      fi
    fi
  fi
  
  if [ -z "$DRY_RUN" ]; then
    printf "%b[PASS] Development tools installation complete%b\n" "$GREEN" "$RESET"
  fi
}

# Function to verify installation
verify_installation() {
  if [ -n "$DRY_RUN" ]; then
    printf "\n%b[DRY-RUN] Would verify installation%b\n" "$YELLOW" "$RESET"
    return 0
  fi
  
  printf "\n%b=== Verifying Installation ===%b\n" "$BLUE" "$RESET"
  
  # Check if go.mod exists and modules are available
  if [ -f "go.mod" ]; then
    if go list -m all >/dev/null 2>&1; then
      printf "%b[PASS] Go modules are properly configured%b\n" "$GREEN" "$RESET"
    else
      printf "%b[WARN] Issue with Go modules%b\n" "$YELLOW" "$RESET"
    fi
  fi
  
  # Check if tools are accessible (if not skipped)
  if [ -z "$SKIP_TOOLS" ]; then
    TOOLS_CHECK="golangci-lint goimports govulncheck gosec"
    MISSING_TOOLS=""
    
    for tool in $TOOLS_CHECK; do
      if command_exists "$tool"; then
        printf "%b[PASS] %s is available%b\n" "$GREEN" "$tool" "$RESET"
      else
        printf "%b[WARN] %s is not in PATH%b\n" "$YELLOW" "$tool" "$RESET"
        MISSING_TOOLS="$MISSING_TOOLS $tool"
      fi
    done
    
    if [ -n "$MISSING_TOOLS" ]; then
      printf "%b[INFO] Some tools are not in PATH. Make sure GOPATH/bin is in your PATH:%b\n" "$YELLOW" "$RESET"
      printf "  export PATH=\"\$(go env GOPATH)/bin:\$PATH\"\n"
    fi
  fi
}

# Main installation function
do_install() {
  printf "%b=== Rhiza Go Installation ===%b\n" "$BLUE" "$RESET"
  
  if [ -n "$DRY_RUN" ]; then
    printf "%b[DRY-RUN] Running in dry-run mode (no changes will be made)%b\n" "$YELLOW" "$RESET"
  fi
  
  # Step 1: Check Go installation
  check_go_installation
  
  # Step 2: Set up GOPATH
  setup_gopath
  
  # Step 3: Install dependencies
  install_dependencies
  
  # Step 4: Install development tools
  install_dev_tools
  
  # Step 5: Verify installation
  verify_installation
  
  # Final message
  printf "\n%b=== Installation Complete ===%b\n" "$GREEN" "$RESET"
  
  if [ -z "$DRY_RUN" ]; then
    printf "%b[INFO] You can now build and test the project:%b\n" "$BLUE" "$RESET"
    printf "  make test   # Run tests\n"
    printf "  make build  # Build binaries\n"
    printf "  make fmt    # Format code\n"
    printf "  make lint   # Run linter\n"
  else
    printf "%b[DRY-RUN] Installation preview complete%b\n" "$YELLOW" "$RESET"
  fi
}

# Main execution
do_install
