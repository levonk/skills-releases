#!/usr/bin/env bash
# shellcheck shell=bash
# stale-branches.sh — Find stale branches across all git repos
#
# Scans all git repositories under the configured search paths and reports
# local branches that haven't had a commit in N days (default 30).
#
# Usage:
#   scripts/stale-branches.sh [--days N] [--repo PATH]
#
# Options:
#   --days N    Number of days since last commit to consider a branch stale
#               (default: 30)
#   --repo PATH Limit scan to a single repo path
#
# Output (stdout, tab-separated):
#   repo<TAB>branch<TAB>last-commit-date<TAB>days-stale
#
# Exit codes:
#   0 — scan completed (stale branches are information, not failure)
#   1 — no git repos found or git not available

set -euo pipefail

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================
DAYS=30
SINGLE_REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --days) DAYS="$2"; shift 2 ;;
    --repo) SINGLE_REPO="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--days N] [--repo PATH]"
      echo ""
      echo "Finds local branches not updated in N days across all git repos."
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ==============================================================================
# PRE-FLIGHT
# ==============================================================================

if ! command -v git &>/dev/null; then
  echo "ERROR: git not found on PATH" >&2
  exit 1
fi

# Determine search roots
if [[ -n "$SINGLE_REPO" ]]; then
  REPOS=("$SINGLE_REPO")
else
  REPOS=()
  # Prefer git-global-fetch --list for repo discovery (uses its YAML config)
  GGF=$(command -v git-global-fetch 2>/dev/null || command -v git-global-fetch.bash 2>/dev/null || true)
  if [[ -n "$GGF" ]]; then
    while IFS=$'\t' read -r path _ _ _ _ _ _ _ _; do
      [[ "$path" == "Path" || -z "$path" || "$path" == "=="* ]] && continue
      REPOS+=("$path")
    done < <("$GGF" --list --sort path 2>/dev/null)
  fi
  # Fallback: SIGN_OFF_SEARCH_ROOTS env var, then $HOME
  if [[ ${#REPOS[@]} -eq 0 ]]; then
    IFS=':' read -ra SEARCH_ROOTS <<< "${SIGN_OFF_SEARCH_ROOTS:-$HOME}"
    for root in "${SEARCH_ROOTS[@]}"; do
      [[ -d "$root" ]] || continue
      while IFS= read -r repo; do
        REPOS+=("$repo")
      done < <(find "$root" -maxdepth 4 -name ".git" -type d 2>/dev/null | sed 's|/.git$||' | sort)
    done
  fi
fi

if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "ERROR: No git repos found. Set SIGN_OFF_SEARCH_ROOTS or configure git-global-fetch." >&2
  exit 1
fi

# ==============================================================================
# SCAN
# ==============================================================================

NOW_EPOCH=$(date +%s)
STALE_THRESHOLD=$((NOW_EPOCH - DAYS * 86400))

for repo in "${REPOS[@]}"; do
  [[ -d "$repo/.git" ]] || continue

  # List all local branches with their last commit dates
  while IFS=$'\t' read -r branch _commit_hash commit_date; do
    [[ -z "$branch" ]] && continue

    # Convert commit date to epoch
    commit_epoch=$(git -C "$repo" log -1 --format=%ct "$branch" 2>/dev/null || echo 0)
    [[ "$commit_epoch" -eq 0 ]] && continue

    if [[ "$commit_epoch" -lt "$STALE_THRESHOLD" ]]; then
      days_stale=$(( (NOW_EPOCH - commit_epoch) / 86400 ))
      printf '%s\t%s\t%s\t%s\n' "$repo" "$branch" "$commit_date" "$days_stale"
    fi
  done < <(
    git -C "$repo" for-each-ref \
      --format='%(refname:short)%09%(objectname:short)%09%(committerdate:short)' \
      refs/heads/ 2>/dev/null | tr '\t' '\t'
  )
done
