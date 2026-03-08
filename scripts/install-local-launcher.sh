#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN_DIR="${HOME}/.local/bin"
TARGET_LINK="$BIN_DIR/visidelta"

mkdir -p "$BIN_DIR"
ln -sf "$ROOT_DIR/visidelta" "$TARGET_LINK"

echo "Installed: $TARGET_LINK"
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo "Add this to your shell profile:"
  echo "  export PATH=\"$BIN_DIR:\$PATH\""
fi
