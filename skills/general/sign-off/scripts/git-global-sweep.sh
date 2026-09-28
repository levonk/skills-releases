#!/usr/bin/env bash
# shellcheck shell=bash
# git-global-sweep.sh — End-of-day git maintenance sweep across all repos
#
# Wraps git-global-fetch with --devbox --prune --notify, then parses the
# output to produce a structured summary of:
#   - Repos with uncommitted changes (dirty)
#   - Repos with commits ahead of upstream (unpushed)
#   - Repos with commits behind upstream (unpulled)
#   - Repos where devbox update ran
#   - Fetch errors
#
# Usage:
#   scripts/git-global-sweep.sh [--dry-run] [--no-devbox] [--no-prune]
#
# Output (stdout): structured sections separated by blank lines
#   === DIRTY REPOS ===
#   <repo-path>\t<staged>\t<unstaged>\t<untracked>
#   === UNPUSHED ===
#   <repo-path>\t<ahead-count>
#   === UNPULLED ===
#   <repo-path>\t<behind-count>
#   === DEVBOX UPDATED ===
#   <repo-path>
#   === ERRORS ===
#   <repo-path>\t<error-message>
#   === SUMMARY ===
#   <total-repos>\t<dirty>\t<unpushed>\t<unpulled>\t<errors>
#
# Exit codes:
#   0 — sweep completed (even if repos are dirty; that's information, not failure)
#   1 — git-global-fetch not found on PATH
#   2 — git-global-fetch exited non-zero

set -euo pipefail

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================
DRY_RUN=false
NO_DEVBOX=false
NO_PRUNE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)  DRY_RUN=true; shift ;;
    --no-devbox) NO_DEVBOX=true; shift ;;
    --no-prune)  NO_PRUNE=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [--no-devbox] [--no-prune]"
      echo ""
      echo "Runs git-global-fetch across all configured repos and produces"
      echo "a structured summary of dirty, unpushed, and unpulled repos."
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ==============================================================================
# PRE-FLIGHT
# ==============================================================================

# Locate git-global-fetch on PATH
GGF=""
for cmd_name in git-global-fetch git-global-fetch.bash; do
  candidate=$(command -v "$cmd_name" 2>/dev/null || true)
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    GGF="$candidate"
    break
  fi
done

if [[ -z "$GGF" ]]; then
  echo "ERROR: git-global-fetch not found on PATH" >&2
  echo "Ensure git-global-fetch is installed and on your PATH." >&2
  exit 1
fi

# Build the argument list for git-global-fetch
ARGS=()
[[ "$NO_PRUNE" == false ]] && ARGS+=(--prune)
[[ "$NO_DEVBOX" == false ]] && ARGS+=(--devbox)
ARGS+=(--notify)

if [[ "$DRY_RUN" == true ]]; then
  echo "=== DRY RUN ==="
  echo "Would run: $GGF ${ARGS[*]}"
  echo "(Remove --dry-run to execute)"
  exit 0
fi

# ==============================================================================
# RUN SWEEP
# ==============================================================================

# Capture git-global-fetch output (it writes to stdout and stderr)
TMP_OUT=$(mktemp)
TMP_ERR=$(mktemp)
trap 'rm -f "$TMP_OUT" "$TMP_ERR"' EXIT

# git-global-fetch exit 0 means all operations succeeded
# non-zero means some repos had errors (it still produces output)
"$GGF" "${ARGS[@]}" >"$TMP_OUT" 2>"$TMP_ERR" || true

# ==============================================================================
# PARSE OUTPUT
# ==============================================================================

# git-global-fetch --list mode produces tabular output we can parse.
# We also run a status pass to get dirty/unpushed/unpulled counts.
# The list mode output has columns: Path, Remote, Branch, Push, Pull, Staged, Unstaged, Untracked

# Run list mode to get structured status
TMP_LIST=$(mktemp)
trap 'rm -f "$TMP_OUT" "$TMP_ERR" "$TMP_LIST"' EXIT

"$GGF" --list --sort path >"$TMP_LIST" 2>/dev/null || true

# Parse the list output
DIRTY_REPOS=()
UNPUSHED_REPOS=()
UNPULLED_REPOS=()
TOTAL_REPOS=0

while IFS=$'\t' read -r path _remote _branch push pull staged unstaged untracked; do
  # Skip header lines and empty lines
  [[ "$path" == "Path" || "$path" == "" || "$path" == "=="* ]] && continue
  [[ -z "$path" ]] && continue

  TOTAL_REPOS=$((TOTAL_REPOS + 1))

  # Parse push/pull counts (strip +N/-N format)
  ahead="${push#+}"
  behind="${pull#-}"
  [[ "$ahead" == "0" || -z "$ahead" ]] && ahead=0
  [[ "$behind" == "0" || -z "$behind" ]] && behind=0

  # Check if dirty (any staged, unstaged, or untracked)
  staged_num="${staged//[^0-9]/}"
  unstaged_num="${unstaged//[^0-9]/}"
  untracked_num="${untracked//[^0-9]/}"
  [[ -z "$staged_num" ]] && staged_num=0
  [[ -z "$unstaged_num" ]] && unstaged_num=0
  [[ -z "$untracked_num" ]] && untracked_num=0

  if [[ "$staged_num" -gt 0 || "$unstaged_num" -gt 0 || "$untracked_num" -gt 0 ]]; then
    DIRTY_REPOS+=("${path}"$'\t'"${staged_num}"$'\t'"${unstaged_num}"$'\t'"${untracked_num}")
  fi

  if [[ "$ahead" -gt 0 ]]; then
    UNPUSHED_REPOS+=("${path}"$'\t'"${ahead}")
  fi

  if [[ "$behind" -gt 0 ]]; then
    UNPULLED_REPOS+=("${path}"$'\t'"${behind}")
  fi
done < "$TMP_LIST"

# ==============================================================================
# OUTPUT
# ==============================================================================

echo "=== DIRTY REPOS ==="
if [[ ${#DIRTY_REPOS[@]} -gt 0 ]]; then
  printf '%s\n' "${DIRTY_REPOS[@]}"
else
  echo "(none)"
fi

echo ""
echo "=== UNPUSHED ==="
if [[ ${#UNPUSHED_REPOS[@]} -gt 0 ]]; then
  printf '%s\n' "${UNPUSHED_REPOS[@]}"
else
  echo "(none)"
fi

echo ""
echo "=== UNPULLED ==="
if [[ ${#UNPULLED_REPOS[@]} -gt 0 ]]; then
  printf '%s\n' "${UNPULLED_REPOS[@]}"
else
  echo "(none)"
fi

echo ""
echo "=== DEVBOX UPDATED ==="
# Extract repos where devbox update ran from the fetch output
grep -i "devbox" "$TMP_OUT" 2>/dev/null | grep -i "updated\|refresh" | awk '{print $1}' || echo "(none)"

echo ""
echo "=== ERRORS ==="
if [[ -s "$TMP_ERR" ]]; then
  # Show first 20 error lines to avoid flooding output
  head -20 "$TMP_ERR"
else
  echo "(none)"
fi

echo ""
echo "=== SUMMARY ==="
echo -e "${TOTAL_REPOS}\t${#DIRTY_REPOS[@]}\t${#UNPUSHED_REPOS[@]}\t${#UNPULLED_REPOS[@]}\t$(wc -l < "$TMP_ERR" 2>/dev/null || echo 0)"
