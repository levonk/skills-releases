#!/usr/bin/env bash
# Check if a project or its dependencies are already in nixpkgs
# Usage: check-nixpkgs.sh <project-name> [dependency1 dependency2 ...]
# Output: JSON with project_in_nixpkgs, dependencies_in_nixpkgs
# Use --verbose for full search results

set -euo pipefail

PROJECT="${1:?Usage: check-nixpkgs.sh <project-name> [dependency1 dependency2 ...]}"
shift
DEPS=("$@")
VERBOSE=""

if [ "${DEPS[-1]:-}" = "--verbose" ]; then
  VERBOSE="--verbose"
  unset 'DEPS[-1]'
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Searching nixpkgs for: $PROJECT"
fi

PROJECT_RESULT=$(curl -s "https://search.nixos.org/packages?channel=unstable&query=$PROJECT" 2>/dev/null | grep -oP 'data-package-name="[^"]*"' | head -5 || echo "")
PROJECT_IN_NIXPKGS=false
if [ -n "$PROJECT_RESULT" ]; then
  PROJECT_IN_NIXPKGS=true
fi

if [ "$VERBOSE" = "--verbose" ]; then
  echo "Project in nixpkgs: $PROJECT_IN_NIXPKGS"
fi

DEPS_JSON="{}"
for dep in "${DEPS[@]:-}"; do
  if [ "$VERBOSE" = "--verbose" ]; then
    echo "Searching nixpkgs for dependency: $dep"
  fi
  DEP_RESULT=$(curl -s "https://search.nixos.org/packages?channel=unstable&query=$dep" 2>/dev/null | grep -oP 'data-package-name="[^"]*"' | head -3 || echo "")
  DEP_FOUND=false
  if [ -n "$DEP_RESULT" ]; then
    DEP_FOUND=true
  fi
  DEPS_JSON=$(echo "$DEPS_JSON" | jq --arg dep "$dep" --argjson found $DEP_FOUND '. + {($dep): $found}')
done

echo "{\"project_in_nixpkgs\": $PROJECT_IN_NIXPKGS, \"dependencies_in_nixpkgs\": $DEPS_JSON}"
