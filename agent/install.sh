#!/usr/bin/env bash
# ME Agent · install (macOS / Linux)
set -euo pipefail
VERSION="0.3.0"
URL="https://github.com/junyisunme/me-my-earth/releases/download/v${VERSION}/me-agent-${VERSION}.zip"
DEST="${HOME}/me-agent"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -L --fail -o "$TMP/me-agent.zip" "$URL"
rm -rf "$DEST"
mkdir -p "$DEST"
unzip -q "$TMP/me-agent.zip" -d "$TMP"
cp -R "$TMP/me-agent-${VERSION}/." "$DEST/"
cd "$DEST"
npm install
printf 'Installed to %s\nTry: node %s/me-agent.mjs help\n' "$DEST" "$DEST"
