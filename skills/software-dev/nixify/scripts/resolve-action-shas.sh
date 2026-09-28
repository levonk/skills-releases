#!/usr/bin/env bash
# Resolve commit SHAs for GitHub Actions used in nixify workflow templates.
#
# Two policies:
#   1. Actions the project already uses in .github/workflows/*.yml:
#      match the project's existing version (don't upgrade v4 to v6).
#   2. Actions the project doesn't use yet: resolve to the latest stable
#      tag's commit SHA.
#
# Output: JSON object mapping action names to {sha, tag} pairs.
#   {
#     "actions/checkout": {"sha": "11d5960...", "tag": "v4"},
#     "DeterminateSystems/nix-installer-action": {"sha": "ef8a148...", "tag": "v22"},
#     ...
#   }
#
# Usage: resolve-action-shas.sh [project-dir]
#   project-dir defaults to cwd
#
# Exit codes:
#   0 — all actions resolved
#   1 — one or more actions could not be resolved (errors printed to stderr)

set -euo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

# All actions the nixify templates reference. Each entry is:
#   "owner/repo|default-tag"
# default-tag is used only when the project doesn't already use the action
# and we need to query the latest release. It's a fallback hint for the
# minimum version to consider; the script always queries the actual latest.
ACTIONS=(
  "actions/checkout"
  "DeterminateSystems/nix-installer-action"
  "cachix/install-nix-action"
  "cachix/cachix-action"
  "peter-evans/create-pull-request"
)

# --- helpers ---

# Extract the version ref an action is used at in the project's workflows.
# Returns the first match (e.g. "v4", "v22", "main") or empty if not found.
# Only matches @vN or @main/@latest patterns — SHA-pinned actions return
# the SHA (40 hex chars), which we pass through.
find_project_version() {
  local action="$1"
  # Search all workflow files for `uses: <action>@<ref>`
  # The ref is captured without the @ prefix. Use grep -oE to extract
  # just the ref part (avoids sed delimiter issues with / in action names).
  local ref
  ref=$(grep -rhoE "${action}@[a-zA-Z0-9._-]+" .github/workflows/ 2>/dev/null \
    | head -1 \
    | sed 's/.*@//' \
    || true)
  echo "$ref"
}

# Resolve a tag to its commit SHA via GitHub API
resolve_sha() {
  local action="$1"
  local tag="$2"
  local sha
  sha=$(gh api "repos/${action}/git/refs/tags/${tag}" --jq '.object.sha' 2>/dev/null || true)
  if [ -z "$sha" ]; then
    # Tag might be an annotated tag (object type "tag") — dereference
    sha=$(gh api "repos/${action}/git/refs/tags/${tag}" --jq '.object.sha' 2>/dev/null \
      | xargs -I{} gh api "repos/${action}/git/tags/{}" --jq '.object.sha' 2>/dev/null || true)
  fi
  echo "$sha"
}

# Get the latest stable release tag for an action
get_latest_tag() {
  local action="$1"
  gh api "repos/${action}/releases/latest" --jq '.tag_name' 2>/dev/null || true
}

# Check if a tag is at least 7 days old (supply-chain safety)
is_tag_aged() {
  local action="$1"
  local tag="$2"
  local published_date
  published_date=$(gh api "repos/${action}/releases/tags/${tag}" --jq '.published_at' 2>/dev/null || true)
  if [ -z "$published_date" ]; then
    return 1  # Can't determine date — treat as not aged
  fi
  # Convert to epoch and compare with 7 days ago
  local tag_epoch now_epoch seven_days_ago
  tag_epoch=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$published_date" +%s 2>/dev/null \
    || date -d "$published_date" +%s 2>/dev/null || true)
  if [ -z "$tag_epoch" ]; then
    return 1
  fi
  now_epoch=$(date +%s)
  seven_days_ago=$((now_epoch - 604800))
  [ "$tag_epoch" -le "$seven_days_ago" ]
}

# --- main ---

first_error=""
output="{"

for action in "${ACTIONS[@]}"; do
  project_version=$(find_project_version "$action")

  if [ -n "$project_version" ]; then
    # Policy 1: project already uses this action — match its version
    tag="$project_version"
    # If it's already a SHA (40 hex chars), pass through — no API call needed
    if echo "$tag" | grep -qE '^[0-9a-f]{40}$'; then
      sha="$tag"
      # We don't know which tag the SHA corresponds to — leave the comment
      # as the SHA itself. The workflow already has a version comment if the
      # project pinned it properly.
      tag="$tag"
    elif echo "$tag" | grep -qE '^(main|master|latest)$'; then
      # Mutable ref — resolve to the SHA it currently points to
      sha=$(gh api "repos/${action}/git/refs/heads/${tag}" --jq '.object.sha' 2>/dev/null || true)
      if [ -z "$sha" ]; then
        echo "ERROR: could not resolve ${action}@${tag} (mutable ref) to SHA" >&2
        first_error="${first_error}${action},"
        output="${output}\"${action}\": {\"sha\": \"\", \"tag\": \"${tag}\", \"source\": \"error\"},"
        continue
      fi
      echo "WARNING: ${action}@${tag} is a mutable ref — resolved to SHA ${sha}" >&2
    else
      sha=$(resolve_sha "$action" "$tag")
    fi
    source="project"
  else
    # Policy 2: project doesn't use this action — get latest stable tag
    tag=$(get_latest_tag "$action")
    if [ -z "$tag" ]; then
      echo "ERROR: could not find latest release for ${action}" >&2
      first_error="${first_error}${action},"
      output="${output}\"${action}\": {\"sha\": \"\", \"tag\": \"\", \"source\": \"error\"},"
      continue
    fi
    sha=$(resolve_sha "$action" "$tag")
    source="latest"

    # Supply-chain safety: warn if tag is less than 7 days old
    if ! is_tag_aged "$action" "$tag"; then
      echo "WARNING: ${action}@${tag} was published less than 7 days ago — supply-chain risk" >&2
    fi
  fi

  if [ -z "$sha" ]; then
    echo "ERROR: could not resolve SHA for ${action}@${tag}" >&2
    first_error="${first_error}${action},"
    output="${output}\"${action}\": {\"sha\": \"\", \"tag\": \"${tag}\", \"source\": \"error\"},"
    continue
  fi

  # Final guard: the SHA must be exactly 40 hex chars before we emit it as ok.
  # A truncated SHA (e.g. 39 chars from a partial API response or copy error)
  # breaks CI — GitHub Actions cannot resolve it and zizmor flags it as
  # unpinned. This catches that class of bug before it reaches the workflow.
  if ! echo "$sha" | grep -qE '^[0-9a-f]{40}$'; then
    echo "ERROR: resolved SHA for ${action}@${tag} is not a valid 40-char hex SHA (got '${sha}')" >&2
    first_error="${first_error}${action},"
    output="${output}\"${action}\": {\"sha\": \"\", \"tag\": \"${tag}\", \"source\": \"error\"},"
    continue
  fi

  echo "ok: ${action}@${sha} # ${tag} (source: ${source})"
  output="${output}\"${action}\": {\"sha\": \"${sha}\", \"tag\": \"${tag}\", \"source\": \"${source}\"},"
done

# Remove trailing comma and close JSON
output="${output%,}}"
output="${output}}"

echo "$output"

if [ -n "$first_error" ]; then
  exit 1
fi
