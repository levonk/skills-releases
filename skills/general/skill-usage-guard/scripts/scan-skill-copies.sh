#!/usr/bin/env bash
# scan-skill-copies.sh — list installed skills and detect duplicates/copies
#
# Scans common consumer-side skill install locations for SKILL.md files,
# extracts the skill name from each, and reports:
#   1. All installed skills (location, name, version)
#   2. Duplicates — the same skill name installed in multiple locations
#   3. Total count
#
# Usage:
#   bash scripts/scan-skill-copies.sh              # text report
#   bash scripts/scan-skill-copies.sh --json        # JSON report
#   bash scripts/scan-skill-copies.sh --quiet       # count only
#
# Exit codes:
#   0 — success (duplicates may or may not be present; check output)
#   2 — error

set -euo pipefail

JSON_MODE=0
QUIET_MODE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON_MODE=1; shift ;;
    --quiet) QUIET_MODE=1; shift ;;
    -h|--help)
      cat <<'HELP'
scan-skill-copies.sh — list installed skills and detect duplicates/copies

Usage:
  scan-skill-copies.sh [--json] [--quiet]

Options:
  --json    Machine-readable JSON output
  --quiet   Print only the total skill count
  -h, --help  Show this help
HELP
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done

SEARCH_PATHS=(
  "${HOME}/.agents/skills"
  "${HOME}/.config/devin/skills"
  "${HOME}/.config/agents/skills"
  "${HOME}/.claude/skills"
  "${HOME}/.cursor/skills"
  "./.agents/skills"
  "./.config/devin/skills"
  "./.config/agents/skills"
)

# Collect all SKILL.md files with their paths
collect_skills() {
  local dir
  for dir in "${SEARCH_PATHS[@]}"; do
    if [ -d "$dir" ]; then
      set +e
      find -L "$dir" -name SKILL.md -type f 2>/dev/null
      set -e
    fi
  done
}

# Extract the skill name from a SKILL.md file's frontmatter
extract_name() {
  local file="$1"
  local name=""
  # Read the frontmatter (between the first two --- lines) and find name:
  set +e
  name="$(awk '/^---$/{n++; next} n==1 && /^name:/{sub(/^name:[[:space:]]*/,""); gsub(/["'"'"']/,""); print; exit}' "$file" 2>/dev/null)"
  set -e
  if [ -z "$name" ]; then
    name="$(basename "$(dirname "$file")")"
  fi
  echo "$name"
}

main() {
  local skills_file
  skills_file="$(mktemp)"
  trap 'rm -f "$skills_file"' EXIT

  collect_skills > "$skills_file"

  local total
  set +e
  total="$(wc -l < "$skills_file" | tr -d ' ')"
  set -e

  if [ "$QUIET_MODE" -eq 1 ]; then
    echo "$total"
    exit 0
  fi

  # Build name→paths mapping for duplicate detection
  local names_file
  names_file="$(mktemp)"
  trap 'rm -f "$skills_file" "$names_file"' EXIT

  while IFS= read -r f; do
    [ -z "$f" ] && continue
    local n
    n="$(extract_name "$f")"
    printf '%s\t%s\n' "$n" "$f" >> "$names_file"
  done < "$skills_file"

  local dupes_file
  dupes_file="$(mktemp)"
  trap 'rm -f "$skills_file" "$names_file" "$dupes_file"' EXIT

  # Find names that appear more than once
  set +e
  cut -f1 "$names_file" | sort | uniq -d > "$dupes_file"
  set -e

  local dupes_count
  set +e
  dupes_count="$(wc -l < "$dupes_file" | tr -d ' ')"
  set -e

  if [ "$JSON_MODE" -eq 1 ]; then
    printf '{"total": %s, "duplicates": %s, "skills": [' "$total" "$dupes_count"
    local first=1
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      local n p
      n="${line%%	*}"
      p="${line#*	}"
      if [ "$first" -eq 1 ]; then
        first=0
      else
        printf ','
      fi
      printf '{"name":"%s","path":"%s"}' "$n" "$p"
    done < "$names_file"
    printf '], "duplicate_names": ['
    first=1
    while IFS= read -r d; do
      [ -z "$d" ] && continue
      if [ "$first" -eq 1 ]; then
        first=0
      else
        printf ','
      fi
      printf '"%s"' "$d"
    done < "$dupes_file"
    printf ']}\n'
    exit 0
  fi

  # Text report
  printf 'Installed skills (%s total):\n\n' "$total"
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    local n p
    n="${line%%	*}"
    p="${line#*	}"
    printf '  %s — %s\n' "$n" "$p"
  done < "$names_file"

  if [ "$dupes_count" -gt 0 ]; then
    printf '\nDuplicate skill names (%s):\n\n' "$dupes_count"
    while IFS= read -r d; do
      [ -z "$d" ] && continue
      printf '  %s:\n' "$d"
      grep "^$d	" "$names_file" | cut -f2 | while IFS= read -r p; do
        printf '    %s\n' "$p"
      done
    done < "$dupes_file"
  fi

  exit 0
}

main
