#!/usr/bin/env bash
# Check for prebuilt release tarballs and GitHub binary releases
# Usage: check-releases.sh <owner> <repo>
# Output: JSON with has_tarballs, has_binary_releases, asset_names
# Use --verbose for full API responses

set -euo pipefail

OWNER="${1:?Usage: check-releases.sh <owner> <repo>}"
REPO="${2:?Usage: check-releases.sh <owner> <repo>}"
VERBOSE="${3:-}"

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Checking releases for $OWNER/$REPO..."
fi

ASSETS=$(curl -s "https://api.github.com/repos/$OWNER/$REPO/releases" | jq -r '.[].assets[].name' 2>/dev/null || echo "")

if [ "$VERBOSE" = "--verbose" ]; then
  echo "All assets: $ASSETS"
fi

# Check for tarball patterns
TARBALLS=$(echo "$ASSETS" | grep -iE '\.(tar\.gz|tar\.bz2|tar\.xz|tgz)$' || echo "")
HAS_TARBALLS=false
if [ -n "$TARBALLS" ]; then
  HAS_TARBALLS=true
fi

# Check for platform-specific binary patterns
PLATFORM_BINS=$(echo "$ASSETS" | grep -iE '(linux|darwin|windows|musl|macos|arm64|x86_64|aarch64)' || echo "")
HAS_BINARY_RELEASES=false
if [ -n "$PLATFORM_BINS" ]; then
  HAS_BINARY_RELEASES=true
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Has tarballs: $HAS_TARBALLS"
  echo "Has binary releases: $HAS_BINARY_RELEASES"
fi

# Format asset names as JSON array
ASSET_JSON=$(echo "$ASSETS" | jq -R . | jq -s . 2>/dev/null || echo "[]")

echo "{\"has_tarballs\": $HAS_TARBALLS, \"has_binary_releases\": $HAS_BINARY_RELEASES, \"asset_names\": $ASSET_JSON}"
