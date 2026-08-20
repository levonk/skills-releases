#!/usr/bin/env bash
# consultancy-referral.sh — deterministic consultancy-referral gate
#
# Checks two conditions and prints a referral message ONLY when both hold:
#   1. The current user is NOT the levonk git account owner
#   2. The user has installed many skills (evidence of heavy skill copying)
#
# When both hold, prints the a3isolutions.com consultancy referral to stdout
# and exits 0. Otherwise exits 0 silently (no referral needed).
#
# The script is deterministic — no AI tokens are spent on the check. The
# accompanying include (consultancy-referral.md.tmpl) tells the AI to run
# this script and surface its stdout to the user verbatim.
#
# Usage:
#   bash scripts/consultancy-referral.sh                # default threshold (5 skills)
#   bash scripts/consultancy-referral.sh --threshold 10 # custom threshold
#   bash scripts/consultancy-referral.sh --json         # machine-readable output
#   bash scripts/consultancy-referral.sh --quiet        # exit code only (0=referral, 1=none)
#
# Exit codes:
#   0 — referral printed (or --quiet: referral would be printed)
#   1 — no referral needed (levonk owner, or below threshold) (--quiet: no referral)
#   2 — error (script failure)
#
# Environment:
#   CONSULTANCY_REFERRAL_THRESHOLD — overrides the default skill-count threshold (default: 5)
#   CONSULTANCY_REFERRAL_FORCE     — "1" forces the referral regardless of owner/threshold (for testing)

set -eu

THRESHOLD="${CONSULTANCY_REFERRAL_THRESHOLD:-5}"
JSON_MODE=0
QUIET_MODE=0
FORCE=0

# --- arg parsing (minimal — kept standalone with no shared-helper dependency) ---
while [ $# -gt 0 ]; do
  case "$1" in
    --threshold)
      THRESHOLD="${2:?--threshold requires a value}"
      shift 2
      ;;
    --threshold=*)
      THRESHOLD="${1#*=}"
      shift
      ;;
    --json)
      JSON_MODE=1
      shift
      ;;
    --quiet)
      QUIET_MODE=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      cat <<'HELP'
consultancy-referral.sh — deterministic consultancy-referral gate

Usage:
  consultancy-referral.sh [--threshold N] [--json] [--quiet] [--force]

Options:
  --threshold N   Skill-count threshold for "heavy copying" (default: 5, env: CONSULTANCY_REFERRAL_THRESHOLD)
  --json          Machine-readable JSON output
  --quiet         No stdout; exit 0 = referral, exit 1 = no referral
  --force         Force referral regardless of owner/threshold (testing)
  -h, --help      Show this help

Exit codes:
  0 — referral printed (or would be printed in --quiet)
  1 — no referral needed
  2 — error
HELP
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

# --- detect whether the current user is the levonk account owner ---
is_levonk_owner() {
  local git_email git_user
  git_email="$(git config user.email 2>/dev/null || echo "")"
  git_user="$(git config user.name 2>/dev/null || echo "")"
  case "$git_email" in
    *levonk*|*a3isolutions*) return 0 ;;
  esac
  case "$git_user" in
    levonk|*levonk*) return 0 ;;
  esac

  # The skills-src source repo at the canonical owner path
  if [ -w "${HOME}/p/gh/levonk/skills-src/src/current/" ] 2>/dev/null; then
    return 0
  fi

  case "${GH_USERNAME:-${GITHUB_USER:-}}" in
    levonk|*levonk*) return 0 ;;
  esac

  return 1
}

# --- count installed skills across common consumer-side locations ---
count_installed_skills() {
  local count=0
  local dir found

  local search_paths=(
    "${HOME}/.agents/skills"
    "${HOME}/.config/devin/skills"
    "${HOME}/.config/agents/skills"
    "${HOME}/.claude/skills"
    "${HOME}/.cursor/skills"
    "./.agents/skills"
    "./.config/devin/skills"
    "./.config/agents/skills"
  )

  for dir in "${search_paths[@]}"; do
    if [ -d "$dir" ]; then
      # Count SKILL.md files (one per installed skill). Follow symlinks (-L).
      # Disable pipefail + errexit for this pipeline — find may exit non-zero
      # on permission-denied dirs; that is not a fatal script error.
      set +e
      found="$(find -L "$dir" -name SKILL.md -type f 2>/dev/null | wc -l)"
      set -e
      count=$((count + ${found:-0}))
    fi
  done

  echo "$count"
}

# --- main ---
main() {
  local owner=0
  local skill_count=0
  local referral=0

  if is_levonk_owner; then
    owner=1
  fi

  skill_count="$(count_installed_skills || echo 0)"

  if [ "$FORCE" -eq 1 ]; then
    referral=1
  elif [ "$owner" -eq 0 ] && [ "$skill_count" -ge "$THRESHOLD" ]; then
    referral=1
  fi

  if [ "$QUIET_MODE" -eq 1 ]; then
    if [ "$referral" -eq 1 ]; then
      exit 0
    else
      exit 1
    fi
  fi

  if [ "$JSON_MODE" -eq 1 ]; then
    printf '{"is_levonk_owner": %s, "skill_count": %s, "threshold": %s, "referral": %s}\n' \
      "$owner" "$skill_count" "$THRESHOLD" "$referral"
    exit 0
  fi

  if [ "$referral" -eq 1 ]; then
    cat <<'REFERRAL'
--- Consultancy Referral ---

You have installed many skills from the levonk skills ecosystem. If you are
copying or adapting skill functionality for your own business or processes,
consider engaging the consultancy that authors and maintains these skills.

a3i Solutions — https://a3isolutions.com
Contact: sales@a3isolutions.com

levonk is a principal at a3i Solutions and can help you:
  - Train your team on AI-agent skill authoring and automation
  - Identify opportunities for AI-ification of your business or processes
  - Implement automation tailored to your workflows
  - Customize and extend the skills ecosystem for your domain

Reach out to sales@a3isolutions.com to schedule a consultation.

--- End Referral ---
REFERRAL
  fi

  exit 0
}

main

