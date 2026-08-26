#!/usr/bin/env bash
# quality-gate.sh — Phase 6 quality gate: lock → build → validate → test → catalog → unlock
#
# Deterministic quality gate for execute-upsert Phase 6. Acquires a
# concurrency lock (per-repo+scope), runs the project's quality commands
# in sequence, and releases the lock. The AI only passes the commands and
# scope — the script handles all lock lifecycle and command sequencing.
#
# What this script does (in order):
#   1. Acquire a concurrency lock (per-repo+scope)
#   2. Run each --command in order (build, validate, test, catalog, etc.)
#   3. Release the lock (always, even on failure)
#   4. Emit a JSON summary with pass/fail status per command
#
# What this script does NOT do:
#   - Decide which commands to run (the AI passes them via --command)
#   - Fix failing commands (the AI handles fix loops)
#   - Create worktrees (Phase 6 already created the worktree)
#
# Exit codes:
#   0  — all commands passed, lock released
#   1  — pre-condition failure (no commands, no repo, etc.)
#   2  — lock is active (another run holds it) — skip quality gate
#   3  — one or more commands failed — lock released, summary has details
#   4  — lock release failed (lock file not found, etc.)
#   5  — unexpected error
#
# Usage:
#   ./scripts/quality-gate.sh \
#     --repo "$REPO_ROOT" \
#     --scope "$FEATURE_SLUG" \
#     --slug "$RUN_SLUG" \
#     --command "devbox run -- just build" \
#     --command "devbox run -- just validate" \
#     --command "devbox run -- just test" \
#     --command "devbox run -- just bats" \
#     --command "devbox run -- just catalog" \
#     [--namespace "execute-upsert"] \
#     [--action skip|wait|kill|cancel|force]
#
# Multiple --command flags are run in order; all must pass. The first
# failure stops the gate and releases the lock.
#
# The script prints a JSON summary on stdout (last line):
#
#   {"status":"passed","lock_file":"...","commands":["build","validate","test"],
#    "results":[{"command":"devbox run -- just build","exit_code":0},...]}
#
# Or when locked:
#
#   {"status":"locked","lock_file":"...","commands":[],"results":[]}
#
# Or when a command failed:
#
#   {"status":"failed","lock_file":"...","commands":["build","validate"],
#    "results":[{"command":"devbox run -- just build","exit_code":0},
#               {"command":"devbox run -- just validate","exit_code":1}]}

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────

REPO=""
SCOPE=""
SLUG=""
NAMESPACE="execute-upsert"
ACTION=""
COMMANDS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"; shift 2 ;;
    --scope)
      SCOPE="$2"; shift 2 ;;
    --slug)
      SLUG="$2"; shift 2 ;;
    --namespace)
      NAMESPACE="$2"; shift 2 ;;
    --action)
      ACTION="$2"; shift 2 ;;
    --command)
      COMMANDS+=("$2"); shift 2 ;;
    --help|-h)
      sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      exit 5 ;;
  esac
done

if [[ -z "$REPO" ]]; then
  echo "ERROR: --repo is required" >&2
  exit 5
fi
if [[ -z "$SCOPE" ]]; then
  echo "ERROR: --scope is required" >&2
  exit 5
fi
if [[ -z "$SLUG" ]]; then
  echo "ERROR: --slug is required" >&2
  exit 5
fi
if [[ ${#COMMANDS[@]} -eq 0 ]]; then
  echo "ERROR: at least one --command is required" >&2
  exit 5
fi

# ─────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────

log() {
  echo "[quality-gate] $*" >&2
}

emit_summary() {
  local status="$1" lock_file="$2"
  # Build commands JSON array
  local cmds_json="["
  local first=1
  for cmd in "${COMMANDS[@]}"; do
    if [[ $first -eq 1 ]]; then
      first=0
    else
      cmds_json+=","
    fi
    cmds_json+="\"$(printf '%s' "$cmd" | sed 's/"/\\"/g')\""
  done
  cmds_json+="]"

  # Build results JSON array
  local results_json="["
  first=1
  for result in "${RESULTS[@]:-}"; do
    if [[ -z "$result" ]]; then continue; fi
    if [[ $first -eq 1 ]]; then
      first=0
    else
      results_json+=","
    fi
    results_json+="$result"
  done
  results_json+="]"

  printf '{"status":"%s","lock_file":"%s","commands":%s,"results":%s}\n' \
    "$status" "$lock_file" "$cmds_json" "$results_json"
}

# ─────────────────────────────────────────────────────────────────────
# Step 1: Acquire lock
# ─────────────────────────────────────────────────────────────────────

log "Step 1: acquiring concurrency lock (repo=$REPO scope=$SCOPE namespace=$NAMESPACE)"

LOCK_FILE=""
ACQUIRE_ARGS=(--repo "$REPO" --scope "$SCOPE" --slug "$SLUG" --namespace "$NAMESPACE" --json)
if [[ -n "$ACTION" ]]; then
  ACQUIRE_ARGS+=(--action "$ACTION")
fi

ACQUIRE_OUTPUT="$(bash "$SCRIPT_DIR/lock/acquire-lock.sh" "${ACQUIRE_ARGS[@]}" 2>&1)" || {
  ACQUIRE_EXIT=$?
  if [[ $ACQUIRE_EXIT -eq 2 ]]; then
    log "Lock is active — skipping quality gate"
    # Parse the lock file path from JSON
    LOCK_FILE="$(printf '%s' "$ACQUIRE_OUTPUT" | grep -o '"lock_file":"[^"]*"' | sed 's/"lock_file":"//;s/"//')"
    emit_summary "locked" "$LOCK_FILE"
    exit 2
  else
    log "Lock acquisition failed (exit $ACQUIRE_EXIT):"
    echo "$ACQUIRE_OUTPUT" >&2
    emit_summary "error" "" 
    exit 5
  fi
}

# Parse lock file path from JSON
LOCK_FILE="$(printf '%s' "$ACQUIRE_OUTPUT" | grep -o '"lock_file":"[^"]*"' | sed 's/"lock_file":"//;s/"//')"
log "Lock acquired: $LOCK_FILE"

# ─────────────────────────────────────────────────────────────────────
# Step 2: Run quality commands
# ─────────────────────────────────────────────────────────────────────

log "Step 2: running ${#COMMANDS[@]} quality command(s)"

RESULTS=()
GATE_FAILED=0

for cmd in "${COMMANDS[@]}"; do
  log "Running: $cmd"
  set +e
  eval "$cmd" 2>&1 | sed 's/^/[quality-gate] /' >&2
  CMD_EXIT=${PIPESTATUS[0]}
  set -e

  # Escape command for JSON
  local esc_cmd
  esc_cmd="$(printf '%s' "$cmd" | sed 's/"/\\"/g')"
  RESULTS+=("{\"command\":\"$esc_cmd\",\"exit_code\":$CMD_EXIT}")

  if [[ $CMD_EXIT -ne 0 ]]; then
    log "FAILED: $cmd (exit $CMD_EXIT)"
    GATE_FAILED=1
    break
  fi
  log "PASSED: $cmd"
done

# ─────────────────────────────────────────────────────────────────────
# Step 3: Release lock (always, even on failure)
# ─────────────────────────────────────────────────────────────────────

log "Step 3: releasing lock"

RELEASE_EXIT=0
bash "$SCRIPT_DIR/lock/release-lock.sh" --lock-file "$LOCK_FILE" 2>&1 || RELEASE_EXIT=$?

if [[ $RELEASE_EXIT -ne 0 ]]; then
  log "WARNING: lock release failed (exit $RELEASE_EXIT) — lock may need manual cleanup"
  log "Manual: bash $SCRIPT_DIR/lock/release-lock.sh --lock-file $LOCK_FILE"
fi

# ─────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────

if [[ $GATE_FAILED -eq 1 ]]; then
  log "Quality gate FAILED — one or more commands did not pass"
  emit_summary "failed" "$LOCK_FILE"
  exit 3
fi

log "Quality gate PASSED — all commands succeeded"
emit_summary "passed" "$LOCK_FILE"
exit 0
