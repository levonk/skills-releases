#!/usr/bin/env bash
# Validate that every `uses:` line in generated GitHub Actions workflows is
# pinned to a 40-char commit SHA — not a mutable tag (@v22) or branch (@main).
#
# This is a fast post-write guard that catches the class of bug where a
# truncated SHA (e.g. 39 chars) or an unresolved placeholder (<checkout-sha>)
# reaches the generated workflow. It complements resolve-action-shas.sh (which
# resolves SHAs at generation time) by re-reading the written files and
# verifying the pins are intact. Run this BEFORE the heavier zizmor/actionlint
# checks in Step 16b — it catches pinning errors in milliseconds without
# needing Nix or network access.
#
# A 39-char SHA got through resolve-action-shas.sh in pnpm PR #14255 and broke
# CI (GitHub Actions couldn't resolve it, zizmor flagged it as unpinned). This
# script is the deterministic catch for that class of bug after the files are
# written.
#
# Usage: validate-action-pins.sh [project-dir]
#   project-dir defaults to cwd
#
# Exit codes:
#   0 — all actions pinned to 40-char commit SHAs
#   1 — one or more actions are not pinned to a commit SHA (errors printed)

set -euo pipefail

PROJECT_DIR="${1:-.}"

if [ ! -d "$PROJECT_DIR/.github/workflows" ]; then
  echo "ok: no .github/workflows directory in $PROJECT_DIR — nothing to validate"
  exit 0
fi

errors=0

# Grep all workflow YAML files for `uses:` lines. The pattern matches:
#   uses: actions/checkout@<ref>
#   - uses: actions/checkout@<ref>
# Local actions (uses: ./path) are skipped — they are not third-party actions.
# docker:// images are also skipped (pinned by digest, not SHA).
while IFS= read -r line; do
  # Extract the action ref (everything after @, up to the first whitespace or #)
  # Strip leading whitespace, the optional "- " list marker, and "uses:".
  ref=$(echo "$line" \
    | sed -E 's/^[[:space:]]*(-[[:space:]]*)?uses:[[:space:]]*//' \
    | sed -E 's/#.*$//' \
    | tr -d '[:space:]')

  # Skip local actions and docker images
  case "$ref" in
    ./*|./) continue ;;
    docker://*) continue ;;
  esac

  # Extract the ref after the last @
  sha="${ref##*@}"

  # A valid pin is exactly 40 hex chars (a git commit SHA).
  # Reject mutable refs: @v22, @main, @latest, @v4.2.1, etc.
  if ! echo "$sha" | grep -qE '^[0-9a-f]{40}$'; then
    file=$(echo "$line" | cut -d: -f1)
    echo "ERROR: action in $file is not pinned to a 40-char commit SHA:" >&2
    echo "  $line" >&2
    echo "  ref '$sha' is not a valid commit SHA (expected 40 hex chars)" >&2
    echo "  Mutable refs (@vN, @main, @latest) are forbidden — resolve to a SHA." >&2
    errors=$((errors + 1))
  fi
done < <(grep -rnE '^[[:space:]]*(-[[:space:]]*)?uses:[[:space:]]+[^[:space:]]+@' \
  "$PROJECT_DIR/.github/workflows/"*.yml "$PROJECT_DIR/.github/workflows/"*.yaml 2>/dev/null || true)

if [ "$errors" -gt 0 ]; then
  echo "" >&2
  echo "FAIL: $errors action(s) not pinned to commit SHAs. Fix before pushing." >&2
  exit 1
fi

echo "ok: all actions pinned to commit SHAs"
