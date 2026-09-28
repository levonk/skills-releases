#!/usr/bin/env bash
# shellcheck shell=bash
# daily-activity.sh — Compile today's git commits across all repos
#
# Scans all git repositories under the configured search paths and reports
# commits made today (or on a specified date) by the current user.
#
# Usage:
#   scripts/daily-activity.sh [--date YYYY-MM-DD] [--author EMAIL]
#
# Options:
#   --date YYYY-MM-DD  Date to report (default: today)
#   --author EMAIL     Filter by author email (default: current git user)
#
# Output (stdout, structured sections):
#   === ACTIVITY: <date> ===
#   <repo-path>
#     <hash> <subject> (<files-changed> files)
#     ...
#   === SUMMARY ===
#   <total-commits>\t<total-repos>\t<total-files>
#
# Exit codes:
#   0 — scan completed
#   1 — git not found or no repos found

set -euo pipefail

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================
REPORT_DATE=""
AUTHOR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --date) REPORT_DATE="$2"; shift 2 ;;
    --author) AUTHOR="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--date YYYY-MM-DD] [--author EMAIL]"
      echo ""
      echo "Compiles git commits for the given date across all repos."
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Default to today
if [[ -z "$REPORT_DATE" ]]; then
  REPORT_DATE=$(date +%Y-%m-%d)
fi

# Default to current git user
if [[ -z "$AUTHOR" ]]; then
  AUTHOR=$(git config user.email 2>/dev/null || echo "")
fi

# ==============================================================================
# PRE-FLIGHT
# ==============================================================================

if ! command -v git &>/dev/null; then
  echo "ERROR: git not found on PATH" >&2
  exit 1
fi

# Determine search roots (same logic as stale-branches.sh)
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

if [[ ${#REPOS[@]} -eq 0 ]]; then
  echo "ERROR: No git repos found" >&2
  exit 1
fi

# ==============================================================================
# SCAN
# ==============================================================================

TOTAL_COMMITS=0
TOTAL_FILES=0
REPOS_WITH_COMMITS=0

echo "=== ACTIVITY: ${REPORT_DATE} ==="
echo ""

for repo in "${REPOS[@]}"; do
  [[ -d "$repo/.git" ]] || continue

  # Build git log arguments
  LOG_ARGS=(--after="${REPORT_DATE} 00:00:00" --before="${REPORT_DATE} 23:59:59" --format='%H%x09%s' --shortstat)
  [[ -n "$AUTHOR" ]] && LOG_ARGS+=(--author="$AUTHOR")

  # Get commits for this date
  commits=$(git -C "$repo" log "${LOG_ARGS[@]}" 2>/dev/null || true)
  if [[ -z "$commits" ]]; then
    continue
  fi

  REPOS_WITH_COMMITS=$((REPOS_WITH_COMMITS + 1))
  echo "$repo"

  repo_commits=0
  repo_files=0
  pending_hash=""
  pending_subject=""

  while IFS= read -r line; do
    if [[ "$line" =~ ^([0-9a-f]{7,40})$'\t'(.*) ]]; then
      # This is a commit line: hash<TAB>subject
      # If there's a pending commit without a stat line, flush it first
      if [[ -n "$pending_hash" ]]; then
        printf '  %s %s\n' "${pending_hash:0:8}" "$pending_subject"
        pending_hash=""
        pending_subject=""
      fi
      pending_hash="${BASH_REMATCH[1]}"
      pending_subject="${BASH_REMATCH[2]}"
      repo_commits=$((repo_commits + 1))
      TOTAL_COMMITS=$((TOTAL_COMMITS + 1))
    elif [[ "$line" =~ ([0-9]+)\ files\ changed ]]; then
      files=${BASH_REMATCH[1]}
      repo_files=$((repo_files + files))
      TOTAL_FILES=$((TOTAL_FILES + files))
      if [[ -n "$pending_hash" ]]; then
        printf '  %s %s (%s files)\n' "${pending_hash:0:8}" "$pending_subject" "$files"
        pending_hash=""
        pending_subject=""
      fi
    elif [[ "$line" == "" && -n "$pending_hash" ]]; then
      # Blank line after a commit without a stat line (e.g., merge commit)
      printf '  %s %s\n' "${pending_hash:0:8}" "$pending_subject"
      pending_hash=""
      pending_subject=""
    fi
  done <<< "$commits"

  # Flush any remaining pending commit
  if [[ -n "$pending_hash" ]]; then
    printf '  %s %s\n' "${pending_hash:0:8}" "$pending_subject"
  fi

  echo ""
done

echo "=== SUMMARY ==="
printf '%s\t%s\t%s\n' "$TOTAL_COMMITS" "$REPOS_WITH_COMMITS" "$TOTAL_FILES"
