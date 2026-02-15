#!/bin/sh
# Uninstallation script for rhiza-go
# Usage: curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/uninstall.sh | sh
# Or with custom location: curl -sSfL https://raw.githubusercontent.com/Jebel-Quant/rhiza-go/main/uninstall.sh | sh -s -- -b /custom/path

set -e

# Default installation directory
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
BINARY_NAME="rhiza-go"

# Parse command line arguments
while getopts "b:h" opt; do
  case $opt in
    b) INSTALL_DIR="$OPTARG" ;;
    h)
      echo "Usage: $0 [-b install_dir]"
      echo "  -b: Installation directory (default: /usr/local/bin)"
      exit 0
      ;;
    *) exit 1 ;;
  esac
done

BINARY_PATH="$INSTALL_DIR/$BINARY_NAME"

if [ ! -f "$BINARY_PATH" ]; then
  echo "rhiza-go not found at $BINARY_PATH"
  echo "If installed elsewhere, use: $0 -b /path/to/dir"
  exit 1
fi

echo "Removing $BINARY_PATH..."
if [ -w "$INSTALL_DIR" ]; then
  rm -f "$BINARY_PATH"
else
  echo "Elevated permissions required to remove $BINARY_PATH"
  sudo rm -f "$BINARY_PATH"
fi

echo ""
echo "Successfully uninstalled rhiza-go from $BINARY_PATH"
