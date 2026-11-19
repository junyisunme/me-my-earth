#!/usr/bin/env bash
# ME Agent · install (macOS / Linux)
# Installs a versioned copy and never deletes an existing me-agent directory.
set -euo pipefail

VERSION="0.4.0"
EXPECTED_SHA256="2a19fe4c062bf1d4886048c2acb1285127d3ce7d2767e931855d16b72db43eed"
URL="https://github.com/junyisunme/me-my-earth/releases/download/v${VERSION}/me-agent-${VERSION}.zip"
DEST="${HOME}/me-agent-${VERSION}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading me-agent ${VERSION}..."
curl -L --fail -o "$TMP/me-agent-${VERSION}.zip" "$URL"

if command -v sha256sum >/dev/null 2>&1; then
  ACTUAL_SHA256="$(sha256sum "$TMP/me-agent-${VERSION}.zip" | awk '{print $1}')"
else
  ACTUAL_SHA256="$(shasum -a 256 "$TMP/me-agent-${VERSION}.zip" | awk '{print $1}')"
fi
if [[ "$ACTUAL_SHA256" != "$EXPECTED_SHA256" ]]; then
  echo "SHA-256 mismatch for me-agent-${VERSION}.zip." >&2
  echo "Expected: $EXPECTED_SHA256" >&2
  echo "Actual:   $ACTUAL_SHA256" >&2
  exit 1
fi
echo "SHA-256 verified."

# Some Info-ZIP builds report a warning (and exit 1) for ZIPs produced on
# Windows even when every entry extracted correctly. Check the real layout
# below instead of treating that warning as a failed install.
unzip -q "$TMP/me-agent-${VERSION}.zip" -d "$TMP" || true
SOURCE="$TMP/me-agent-${VERSION}"
if [[ ! -f "$SOURCE/me-agent.mjs" ]]; then
  echo "Unexpected ZIP layout: me-agent-${VERSION}/me-agent.mjs was not found." >&2
  exit 1
fi

# Copy over the versioned program directory without deleting user outputs.
mkdir -p "$DEST"
cp -R "$SOURCE/." "$DEST/"
cd "$DEST"
npm install

printf 'Installed to %s\n' "$DEST"
printf 'Existing files in %s (including .mezip, PNG and media) were not deleted.\n' "$DEST"
printf 'Try: node %s/me-agent.mjs help\n' "$DEST"
