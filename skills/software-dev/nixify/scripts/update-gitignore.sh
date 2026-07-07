#!/usr/bin/env bash
# Update .gitignore with Nix build result symlinks
# Usage: update-gitignore.sh
# Use --dry-run to preview changes
# Use --verbose for full output

set -euo pipefail

MODE="${1:-}"
NIX_ENTRIES=(
  "# Nix build result symlinks"
  "/result"
  "/result-*"
)

if [ "$MODE" = "--dry-run" ]; then
  if [ -f .gitignore ]; then
    if grep -q '/result' .gitignore 2>/dev/null; then
      echo "No changes needed — Nix entries already in .gitignore"
    else
      echo "Would append to existing .gitignore:"
      for entry in "${NIX_ENTRIES[@]}"; do
        echo "  + $entry"
      done
    fi
  else
    echo "Would create .gitignore with:"
    for entry in "${NIX_ENTRIES[@]}"; do
      echo "  + $entry"
    fi
  fi
  exit 0
fi

if [ -f .gitignore ]; then
  if grep -q '/result' .gitignore 2>/dev/null; then
    if [ "$MODE" = "--verbose" ]; then echo "Nix entries already in .gitignore"; fi
    echo "no changes needed"
  else
    echo "" >> .gitignore
    for entry in "${NIX_ENTRIES[@]}"; do
      echo "$entry" >> .gitignore
    done
    if [ "$MODE" = "--verbose" ]; then echo "Appended Nix entries to .gitignore"; fi
    echo "updated .gitignore"
  fi
else
  for entry in "${NIX_ENTRIES[@]}"; do
    echo "$entry" >> .gitignore
  done
  if [ "$MODE" = "--verbose" ]; then echo "Created .gitignore with Nix entries"; fi
  echo "created .gitignore"
fi
