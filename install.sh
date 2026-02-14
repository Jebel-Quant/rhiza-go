#!/bin/sh
# Installation script for rhiza-go
# Usage: curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sh
# Or with custom location: curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/install.sh | sh -s -- -b /custom/path

set -e

# Default installation directory
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="rhiza-go"
REPO_OWNER="Jebel-Quant"
REPO_NAME="rhiza-go"

# Parse command line arguments
while getopts "b:v:h" opt; do
  case $opt in
    b) INSTALL_DIR="$OPTARG" ;;
    v) VERSION="$OPTARG" ;;
    h)
      echo "Usage: $0 [-b install_dir] [-v version]"
      echo "  -b: Installation directory (default: /usr/local/bin)"
      echo "  -v: Version to install (default: latest)"
      exit 0
      ;;
    *) exit 1 ;;
  esac
done

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$OS" in
  linux) OS="linux" ;;
  darwin) OS="darwin" ;;
  mingw*|msys*|cygwin*) OS="windows" ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

case "$ARCH" in
  x86_64|amd64) ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

# Determine version to install
if [ -z "$VERSION" ]; then
  echo "Fetching latest release..."
  VERSION=$(curl -sSfL "https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
  if [ -z "$VERSION" ]; then
    echo "Failed to fetch latest version"
    exit 1
  fi
fi

# Construct download URL
if [ "$OS" = "windows" ]; then
  ARCHIVE_EXT="zip"
else
  ARCHIVE_EXT="tar.gz"
fi

ARCHIVE_NAME="${BINARY_NAME}_${VERSION}_${OS}_${ARCH}.${ARCHIVE_EXT}"
DOWNLOAD_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/${VERSION}/${ARCHIVE_NAME}"
CHECKSUM_URL="https://github.com/$REPO_OWNER/$REPO_NAME/releases/download/${VERSION}/checksums.txt"

echo "Downloading rhiza-go $VERSION for ${OS}/${ARCH}..."
echo "URL: $DOWNLOAD_URL"

# Create temporary directory
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download archive
if ! curl -sSfL "$DOWNLOAD_URL" -o "$TMP_DIR/$ARCHIVE_NAME"; then
  echo "Failed to download $DOWNLOAD_URL"
  exit 1
fi

# Download and verify checksum
echo "Verifying checksum..."
if ! curl -sSfL "$CHECKSUM_URL" -o "$TMP_DIR/checksums.txt"; then
  echo "Warning: Failed to download checksums, skipping verification"
else
  cd "$TMP_DIR"
  if command -v sha256sum >/dev/null 2>&1; then
    grep "$ARCHIVE_NAME" checksums.txt | sha256sum -c -
  elif command -v shasum >/dev/null 2>&1; then
    grep "$ARCHIVE_NAME" checksums.txt | shasum -a 256 -c -
  else
    echo "Warning: No sha256sum or shasum command found, skipping checksum verification"
  fi
  cd - >/dev/null
fi

# Extract archive
echo "Extracting archive..."
if [ "$ARCHIVE_EXT" = "zip" ]; then
  unzip -q "$TMP_DIR/$ARCHIVE_NAME" -d "$TMP_DIR"
else
  tar -xzf "$TMP_DIR/$ARCHIVE_NAME" -C "$TMP_DIR"
fi

# Install binary
echo "Installing to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
if [ -w "$INSTALL_DIR" ]; then
  mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
  chmod +x "$INSTALL_DIR/$BINARY_NAME"
else
  echo "Elevated permissions required for installation to $INSTALL_DIR"
  sudo mv "$TMP_DIR/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
  sudo chmod +x "$INSTALL_DIR/$BINARY_NAME"
fi

echo ""
echo "Successfully installed rhiza-go $VERSION to $INSTALL_DIR/$BINARY_NAME"
echo ""
echo "Run 'rhiza-go --help' to get started"
