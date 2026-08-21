#!/usr/bin/env bash
# land-on-env-dev.sh — Phase 9: land a completed feature branch onto env/dev
#
# Deterministic git operations for execute-upsert Phase 9 (Integration
# Landing). The AI calls this script with the feature branch name and
# project slug; the script handles all git operations and exits with a
# status code. The AI only decides whether to proceed based on the exit
# code and the summary on stdout.
#
# What this script does (in order):
#   1. Verify pre-conditions (env/dev exists on remote, feature branch
#      has commits beyond env/dev)
#   2. Push the feature branch to the remote
#   3. Switch the current worktree to env/dev and pull latest
#   4. Fetch and merge long-lived branches (main/master, env/prd) into
#      env/dev if env/dev is behind them
#   5. Merge the feature branch into env/dev with --no-ff
#   6. Run the project's test suite (caller-supplied via --test-command)
#   7. Push env/dev to the remote
#
# What this script does NOT do:
#   - Create the worktree (Phase 6 already created it; this script runs
#     inside it)
#   - Remove the worktree (the AI does this after confirming the push
#     succeeded — see Phase 9 Step 7)
#   - Force-push (never — non-fast-forward pushes are handled by
#     pull-remerge + re-test)
#   - Resolve semantic merge conflicts (aborts and reports; the AI
#     presents a blocker to the user)
#
# Exit codes:
#   0  — success: feature landed on env/dev and pushed
#   1  — pre-condition failure (env/dev missing, feature branch has no
#        new commits, etc.) — Phase 9 should be skipped, not retried
#   2  — merge conflict (long-lived branch sync or feature merge) —
#        merge was aborted; AI should present a blocker to the user
#   3  — test failure — env/dev was NOT pushed; AI should present a
#        blocker with the test output
#   4  — push rejected (non-fast-forward) and pull-remerge also
#        conflicted — AI should present a blocker
#   5  — unexpected error (git command failed in a way not covered
#        above) — AI should present the error to the user
#
# Usage:
#   ./scripts/land-on-env-dev.sh \
#     --feature-branch "feature/current/my-slug" \
#     --project-slug "my-project" \
#     --feature-slug "my-feature" \
#     --test-command "devbox run -- just test" \
#     [--test-command "devbox run -- just validate"] \
#     [--test-command "devbox run -- just build"]
#
# Multiple --test-command flags are run in order; all must pass.
# If --test-command is omitted, the test step is skipped (exit 0 after
# the merge, before push — the AI must confirm tests are not required).
#
# The script prints a JSON summary on stdout (last line) for the AI to
# parse and include in the Phase 9 summary:
#
#   {"status":"landed","feature_branch":"...","envdev_before":"abc123",
#    "envdev_after":"def456","tests":"pass","pushed":true}
#
# Sourcing: can be sourced to get individual functions, but the normal
# invocation is direct execution.

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────

FEATURE_BRANCH=""
PROJECT_SLUG=""
FEATURE_SLUG=""
TEST_COMMANDS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --feature-branch)
      FEATURE_BRANCH="$2"; shift 2 ;;
    --project-slug)
      PROJECT_SLUG="$2"; shift 2 ;;
    --feature-slug)
      FEATURE_SLUG="$2"; shift 2 ;;
    --test-command)
      TEST_COMMANDS+=("$2"); shift 2 ;;
    --help|-h)
      sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *)
      echo "ERROR: unknown argument: $1" >&2
      exit 5 ;;
  esac
done

if [[ -z "$FEATURE_BRANCH" ]]; then
  echo "ERROR: --feature-branch is required" >&2
  exit 5
fi
if [[ -z "$PROJECT_SLUG" ]]; then
  echo "ERROR: --project-slug is required" >&2
  exit 5
fi
if [[ -z "$FEATURE_SLUG" ]]; then
  echo "ERROR: --feature-slug is required" >&2
  exit 5
fi

# ─────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────

log() {
  echo "[land-on-env-dev] $*" >&2
}

emit_summary() {
  local status="$1" envdev_before="$2" envdev_after="$3" tests="$4" pushed="$5"
  printf '{"status":"%s","feature_branch":"%s","envdev_before":"%s","envdev_after":"%s","tests":"%s","pushed":%s}\n' \
    "$status" "$FEATURE_BRANCH" "$envdev_before" "$envdev_after" "$tests" "$pushed"
}

remote_branch_exists() {
  local branch="$1"
  git ls-remote --heads origin "$branch" 2>/dev/null | grep -q .
}

current_short_sha() {
  git rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

# Merge a branch into the current branch if the current branch is behind
# it. Uses --no-ff to preserve the branch point. Returns 0 on success
# (including no-op skip), 2 on conflict.
merge_if_behind() {
  local ref="$1" label="$2"
  if git merge-base --is-ancestor "$ref" HEAD 2>/dev/null; then
    log "$label: already current (env/dev contains $ref) — skip"
    return 0
  fi
  log "$label: env/dev is behind $ref — merging"
  if git merge --no-ff "$ref" \
    -m "merge: sync $ref into env/dev

  - Source: execute-upsert Phase 9 (long-lived branch sync)
  - Reason: env/dev was behind $ref

  #project-${PROJECT_SLUG} #module-integration #type-merge #skill-execute-upsert-sync"; then
    log "$label: merged $ref into env/dev"
    return 0
  else
    log "$label: CONFLICT merging $ref — aborting"
    git merge --abort 2>/dev/null || true
    return 2
  fi
}

# ─────────────────────────────────────────────────────────────────────
# Step 1: Verify pre-conditions
# ─────────────────────────────────────────────────────────────────────

log "Step 1: verifying pre-conditions"

# 1a: env/dev exists on remote
if ! remote_branch_exists "env/dev"; then
  log "PRE-CONDITION FAILED: env/dev does not exist on remote"
  log "If env/dev is the integration landing branch for this project,"
  log "create it first: git checkout -b env/dev origin/main && git push -u origin env/dev"
  emit_summary "skipped" "" "" "n/a" "false"
  exit 1
fi

# 1b: feature branch has commits beyond env/dev
git fetch origin env/dev 2>/dev/null
NEW_COMMITS=$(git log --oneline "origin/env/dev..$FEATURE_BRANCH" 2>/dev/null | wc -l | tr -d ' ')
if [[ "$NEW_COMMITS" -eq 0 ]]; then
  log "PRE-CONDITION FAILED: feature branch has no commits beyond env/dev"
  emit_summary "skipped" "" "" "n/a" "false"
  exit 1
fi
log "Pre-conditions OK: $NEW_COMMITS new commit(s) to land"

# ─────────────────────────────────────────────────────────────────────
# Step 2: Push the feature branch
# ─────────────────────────────────────────────────────────────────────

log "Step 2: pushing feature branch $FEATURE_BRANCH"

# Ensure we're on the feature branch
git checkout "$FEATURE_BRANCH" 2>/dev/null || {
  log "ERROR: cannot checkout $FEATURE_BRANCH"
  exit 5
}

if ! git push -u origin "$FEATURE_BRANCH" 2>/dev/null; then
  log "WARNING: push of $FEATURE_BRANCH failed (may already be up to date or no upstream)"
  # Non-fatal — the branch may already be pushed
fi
log "Feature branch pushed"

# ─────────────────────────────────────────────────────────────────────
# Step 3: Switch to env/dev, pull latest, sync long-lived branches
# ─────────────────────────────────────────────────────────────────────

log "Step 3: switching worktree to env/dev"

git checkout env/dev 2>/dev/null || {
  log "ERROR: cannot checkout env/dev"
  exit 5
}

ENVDEV_BEFORE=$(current_short_sha)

# 3a: pull latest env/dev
if ! git pull --ff-only origin env/dev 2>/dev/null; then
  log "ERROR: git pull --ff-only origin env/dev failed — local env/dev has diverged"
  emit_summary "skipped" "$ENVDEV_BEFORE" "$ENVDEV_BEFORE" "n/a" "false"
  exit 1
fi
log "env/dev pulled (ff-only)"

# 3b: fetch long-lived branches
log "Step 3b: fetching long-lived branches"
git fetch origin main master env/prd 2>/dev/null || true

# 3c: merge long-lived branches into env/dev if behind
log "Step 3c: syncing long-lived branches"

# Determine primary branch (main, or master as fallback)
PRIMARY_BRANCH=""
if git rev-parse --verify origin/main >/dev/null 2>&1; then
  PRIMARY_BRANCH="origin/main"
elif git rev-parse --verify origin/master >/dev/null 2>&1; then
  PRIMARY_BRANCH="origin/master"
fi

if [[ -n "$PRIMARY_BRANCH" ]]; then
  merge_if_behind "$PRIMARY_BRANCH" "primary" || {
    emit_summary "conflict" "$ENVDEV_BEFORE" "$(current_short_sha)" "n/a" "false"
    exit 2
  }
fi

if git rev-parse --verify origin/env/prd >/dev/null 2>&1; then
  merge_if_behind "origin/env/prd" "env/prd" || {
    emit_summary "conflict" "$ENVDEV_BEFORE" "$(current_short_sha)" "n/a" "false"
    exit 2
  }
fi

log "Long-lived branch sync complete"

# ─────────────────────────────────────────────────────────────────────
# Step 4: Merge the feature branch into env/dev
# ─────────────────────────────────────────────────────────────────────

log "Step 4: merging $FEATURE_BRANCH into env/dev"

if git merge --no-ff "$FEATURE_BRANCH" \
  -m "merge: land $FEATURE_BRANCH onto env/dev

  - Feature: $FEATURE_SLUG
  - Source: execute-upsert Phase 9 (integration landing)

  #project-${PROJECT_SLUG} #module-integration #type-merge #skill-execute-upsert-landed"; then
  log "Feature branch merged into env/dev"
else
  log "CONFLICT merging $FEATURE_BRANCH — aborting"
  git merge --abort 2>/dev/null || true
  emit_summary "conflict" "$ENVDEV_BEFORE" "$(current_short_sha)" "n/a" "false"
  exit 2
fi

# ─────────────────────────────────────────────────────────────────────
# Step 5: Run the test suite
# ─────────────────────────────────────────────────────────────────────

TESTS_RESULT="skipped"

if [[ ${#TEST_COMMANDS[@]} -gt 0 ]]; then
  log "Step 5: running test suite (${#TEST_COMMANDS[@]} command(s))"

  TESTS_RESULT="pass"
  for cmd in "${TEST_COMMANDS[@]}"; do
    log "Running: $cmd"
    if ! eval "$cmd" 2>&1; then
      log "TEST FAILED: $cmd"
      TESTS_RESULT="fail"
      break
    fi
  done

  if [[ "$TESTS_RESULT" == "fail" ]]; then
    log "Tests failed — NOT pushing env/dev"
    log "To revert the merge: git reset --hard HEAD~1"
    emit_summary "test-failure" "$ENVDEV_BEFORE" "$(current_short_sha)" "fail" "false"
    exit 3
  fi
  log "All tests passed"
else
  log "Step 5: SKIPPED (no --test-command provided)"
fi

# ─────────────────────────────────────────────────────────────────────
# Step 6: Push env/dev
# ─────────────────────────────────────────────────────────────────────

log "Step 6: pushing env/dev"

PUSHED="false"

if git push origin env/dev 2>/dev/null; then
  PUSHED="true"
  log "env/dev pushed"
else
  log "Push rejected (non-fast-forward) — pulling and re-merging"
  if git pull --no-ff origin env/dev 2>/dev/null; then
    # Re-run tests after the pull-merge
    if [[ "$TESTS_RESULT" == "pass" && ${#TEST_COMMANDS[@]} -gt 0 ]]; then
      log "Re-running tests after pull-merge"
      for cmd in "${TEST_COMMANDS[@]}"; do
        log "Re-running: $cmd"
        if ! eval "$cmd" 2>&1; then
          log "TEST FAILED after pull-merge: $cmd"
          emit_summary "test-failure" "$ENVDEV_BEFORE" "$(current_short_sha)" "fail" "false"
          exit 3
        fi
      done
    fi

    if git push origin env/dev 2>/dev/null; then
      PUSHED="true"
      log "env/dev pushed (after pull-remerge)"
    else
      log "Push still rejected after pull-remerge — manual resolution required"
      emit_summary "push-rejected" "$ENVDEV_BEFORE" "$(current_short_sha)" "$TESTS_RESULT" "false"
      exit 4
    fi
  else
    log "Pull-merge conflicted — aborting"
    git merge --abort 2>/dev/null || true
    emit_summary "conflict" "$ENVDEV_BEFORE" "$(current_short_sha)" "$TESTS_RESULT" "false"
    exit 4
  fi
fi

ENVDEV_AFTER=$(current_short_sha)

# ─────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────

log "Phase 9 complete: $FEATURE_BRANCH landed on env/dev"
emit_summary "landed" "$ENVDEV_BEFORE" "$ENVDEV_AFTER" "$TESTS_RESULT" "$PUSHED"
exit 0
