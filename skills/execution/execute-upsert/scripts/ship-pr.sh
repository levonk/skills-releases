#!/usr/bin/env bash
# ship-pr.sh — Phase 9: push branch, create PR, verify body, auto-merge, cleanup
#
# Deterministic git + gh operations for execute-upsert Phase 9 (Ship).
# The AI writes the PR body to a file (creative work) and calls this
# script with the path. The script handles everything else: push, PR
# creation, body verification, auto-merge (with opt-out conditions),
# and worktree cleanup.
#
# This script NEVER touches the main checkout. The merge happens on the
# remote via `gh pr merge`. The user updates their local main checkout
# when they want to — the script prints a reminder but does not do it.
#
# What this script does (in order):
#   1. Verify pre-conditions (feature branch has commits, body file exists)
#   2. Check auto-merge opt-out conditions (flags, config file)
#   3. Push the feature branch to the remote
#   4. Create the PR with --body-file (gh-posting-guard compliant)
#   5. Verify the posted PR body matches the file (no corruption)
#   6. Wait for CI checks (if --wait-for-ci was passed)
#   7. If auto-merge is enabled: squash-merge and delete the remote branch
#   8. Clean up the worktree (return treehouse lease or remove manual worktree)
#
# What this script does NOT do:
#   - Write the PR body (the AI does that — this is creative work)
#   - Decide the PR title (the AI passes it via --pr-title)
#   - Resolve merge conflicts on GitHub (the AI presents a blocker)
#   - Force-push (never)
#   - Touch the main checkout (never — the user pulls their own main)
#
# Exit codes:
#   0  — success: PR created and merged on remote, worktree cleaned up
#   1  — pre-condition failure (no commits, no body file, no remote, etc.)
#   2  — PR creation failed (gh pr create exited non-zero)
#   3  — PR body verification failed (posted body differs from file)
#   4  — merge failed (branch protection, permissions, conflict, etc.)
#   5  — unexpected error
#   6  — PR created but NOT merged (auto-merge disabled) — present URL to user
#   7  — CI checks failed (--wait-for-ci mode only; PR was NOT merged)
#
# Usage:
#   ./scripts/ship-pr.sh \
#     --feature-branch "feature/current/execute-upsert/my-slug" \
#     --base-branch "main" \
#     --pr-title "enhancement: my-slug — one-line summary" \
#     --pr-body-file /tmp/pr-body.md \
#     --project-slug "my-project" \
#     --feature-slug "my-feature" \
#     [--no-merge]                # skip auto-merge (user said "do not auto-merge")
#     [--admin]                   # use --admin flag for branch protection
#     [--quality-gate-skipped]    # quality gate did not run — don't auto-merge
#     [--wait-for-ci]             # wait for CI checks to pass before merging
#
# The script prints a JSON summary on stdout (last line) for the AI to
# parse and include in the Phase 9 summary:
#
#   {"status":"merged","pr_number":42,"pr_url":"https://...","merged":true,
#    "base_branch":"main","worktree_cleaned":true}
#
# Or when auto-merge is disabled:
#
#   {"status":"pr-created","pr_number":42,"pr_url":"https://...","merged":false,
#    "base_branch":"main","worktree_cleaned":false}
#
# Sourcing: can be sourced to get individual functions, but the normal
# invocation is direct execution.

set -euo pipefail

# This script intentionally checks out the base branch (main/master) in the
# main checkout and pulls. It is the merge script exempt from the worktree
# isolation guard by default — SKILL_ALLOW_MAIN_WRITE=1 is baked in.
SKILL_ALLOW_MAIN_WRITE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Include shared worktree isolation guard (guard_worktree_isolation).
# Exempt via SKILL_ALLOW_MAIN_WRITE=1 above — this script intentionally
# operates on the base branch in the main checkout.
# worktree-isolation-guard.sh — shared guard for scripts that mutate the repo
#
# Prevents file-mutating scripts from running on main/master or outside a
# linked worktree. Motivated by agents messing up the main working directory
# or trampling on each other's work when multiple agents run concurrently.
#
# The guard checks TWO conditions:
#   1. The current directory is inside a linked git worktree (not the main
#      checkout). Detected via `git rev-parse --absolute-git-dir` — linked
#      worktrees have a git dir under `.git/worktrees/<name>`.
#   2. The current branch is NOT main/master (or any branch listed in the
#      config file's `protected_branches` array).
#
# If EITHER condition is false, the guard refuses (returns 1) unless an
# opt-out is active.
#
# Opt-out layers (checked in order, first match wins):
#   1. SKILL_ALLOW_MAIN_WRITE=1 — environment variable (one-off override)
#   2. --allow-main-write flag — the consuming script must parse this and
#      set SKILL_ALLOW_MAIN_WRITE=1 before calling the guard
#   3. Config file at <repo-root>/.agents/config/script-guards.toml:
#        [worktree-isolation]
#        allow_main_write = true
#        protected_branches = ["main", "master"]  # optional, defaults to main+master
#
# Usage in a consuming script:
#   source "$SCRIPT_DIR/worktree-isolation-guard.sh"
#   guard_worktree_isolation || exit 1
#
# To add the --allow-main-write flag to a consuming script's arg parser:
#   --allow-main-write)
#       SKILL_ALLOW_MAIN_WRITE=1; shift ;;
#
# Materialization: each consuming skill has a
# `scripts/worktree-isolation-guard.sh.tmpl` file containing a single include
# directive that pulls in this file. The templater inlines this file at build
# time. Scripts then `source` the materialized copy from the same `scripts/`
# directory.
#
# Consumers:
#   - git-repository-management/scripts/git-commit-batch.sh.tmpl
#   - git-repository-management/scripts/git-rollback.sh.tmpl
#   - git-repository-management/scripts/git-push.sh.tmpl
#   - git-repository-management/scripts/git-archive.sh.tmpl
#   - execution/execute-upsert/scripts/land-on-env-dev.sh.tmpl (with opt-out)
#   - execution/execute-upsert/scripts/ship-pr.sh.tmpl (with opt-out)
#
# Treehouse awareness: when treehouse (https://github.com/kunchenguid/treehouse)
# is used for worktree management, worktrees are still regular git linked
# worktrees (detected via `/.git/worktrees/`), so the existing check passes.
# The guard additionally checks for treehouse-managed worktrees and reports
# "treehouse worktree detected" in diagnostics for clearer messaging.

# Guard against double-sourcing — use a function-safe pattern that works
# both when sourced and when inlined into a script body.
_WORKTREE_ISOLATION_GUARD_SOURCED="${_WORKTREE_ISOLATION_GUARD_SOURCED:-}"

# guard_worktree_isolation — refuse to run unless in a linked worktree on a
# non-protected branch, or an opt-out is active.
# Returns 0 if the guard passes (safe to mutate), 1 if it refuses.
# Prints diagnostic messages to stderr when refusing.
guard_worktree_isolation() {
	# --- Opt-out layer 1: environment variable ---
	if [[ "${SKILL_ALLOW_MAIN_WRITE:-0}" -eq 1 ]]; then
		return 0
	fi

	# --- Resolve repo root ---
	local repo_root
	repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
		# Not inside a git repository — guard is not applicable
		return 0
	}

	# --- Opt-out layer 3: config file ---
	local cfg="$repo_root/.agents/config/script-guards.toml"
	if [[ -f "$cfg" ]]; then
		local section
		section="$(awk '/^\[worktree-isolation\]/{f=1;next} /^\[/{f=0} f' "$cfg" 2>/dev/null || true)"
		if printf '%s' "$section" | grep -Eq 'allow_main_write[[:space:]]*=[[:space:]]*true'; then
			return 0
		fi
	fi

	# --- Check 1: inside a linked worktree? ---
	local abs_git_dir
	abs_git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null)" || {
		echo "WORKTREE-GUARD: Cannot resolve git directory" >&2
		return 1
	}
	local in_worktree=0
	if [[ "$abs_git_dir" == *"/.git/worktrees/"* ]]; then
		in_worktree=1
	fi

	# --- Treehouse awareness: detect treehouse-managed worktrees ---
	# Treehouse worktrees are regular git linked worktrees, so the check above
	# already passes. This adds a diagnostic flag for clearer messaging.
	# We ask treehouse directly via `treehouse status --json` rather than
	# guessing the root path, since the root can be configured via
	# treehouse.toml, ~/.config/treehouse/config.toml, --root, or env vars.
	local treehouse_managed=0
	if command -v treehouse >/dev/null 2>&1; then
		local _th_status
		_th_status="$(treehouse status --json 2>/dev/null)" || _th_status=""
		if [[ -n "$_th_status" ]] && [[ "$_th_status" != "null" ]]; then
			local _th_paths
			if command -v jq >/dev/null 2>&1; then
				_th_paths="$(printf '%s' "$_th_status" | jq -r '.[].path // empty' 2>/dev/null)"
			else
				_th_paths="$(printf '%s' "$_th_status" | grep -o '"path":"[^"]*"' | sed 's/"path":"//;s/"//')"
			fi
			local _mp
			while IFS= read -r _mp; do
				[[ -z "$_mp" ]] && continue
				if [[ "$PWD" == "$_mp" ]] || [[ "$PWD" == "$_mp"/* ]]; then
					treehouse_managed=1
					break
				fi
			done <<< "$_th_paths"
		fi
	fi

	# --- Check 2: on a protected branch? ---
	# Default protected branches: main, master. Config can override with
	# protected_branches = ["main", "master", "develop", ...]
	local protected_branches=("main" "master")
	if [[ -f "$cfg" ]]; then
		local section
		section="$(awk '/^\[worktree-isolation\]/{f=1;next} /^\[/{f=0} f' "$cfg" 2>/dev/null || true)"
		# Extract protected_branches array from config if present
		local pb_line
		pb_line="$(printf '%s' "$section" | grep -E 'protected_branches[[:space:]]*=' || true)"
		if [[ -n "$pb_line" ]]; then
			# Parse the TOML array: ["main", "master", ...]
			local pb_values
			pb_values="$(printf '%s' "$pb_line" | sed 's/.*=\s*//; s/^\[//; s/\]$//; s/"//g; s/,/\n/g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' || true)"
			if [[ -n "$pb_values" ]]; then
				# shellcheck disable=SC2206  # intentional word-splitting on parsed array
				protected_branches=($pb_values)
			fi
		fi
	fi

	local current_branch
	current_branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null)"
	local on_protected=0
	local pb
	for pb in "${protected_branches[@]}"; do
		if [[ "$current_branch" == "$pb" ]]; then
			on_protected=1
			break
		fi
	done

	# --- Refuse if not in worktree OR on protected branch ---
	local _override_hint="Override: SKILL_ALLOW_MAIN_WRITE=1, --allow-main-write, or config [worktree-isolation] allow_main_write=true"

	if [[ "$in_worktree" -eq 0 ]]; then
		echo "WORKTREE-GUARD: Not in a linked worktree (in main checkout at $repo_root)" >&2
		echo "WORKTREE-GUARD: File-mutating scripts must run in an isolated worktree." >&2
		if command -v treehouse >/dev/null 2>&1; then
			echo "WORKTREE-GUARD: Use treehouse: treehouse get --lease" >&2
		else
			echo "WORKTREE-GUARD: Create a worktree: git worktree add ../<name> -b <branch>" >&2
		fi
		echo "WORKTREE-GUARD: $_override_hint" >&2
		return 1
	fi

	if [[ "$on_protected" -eq 1 ]]; then
		echo "WORKTREE-GUARD: On protected branch '$current_branch'" >&2
		echo "WORKTREE-GUARD: File-mutating scripts must not run on ${protected_branches[*]}." >&2
		echo "WORKTREE-GUARD: Switch to a feature branch: git checkout -b <branch>" >&2
		echo "WORKTREE-GUARD: $_override_hint" >&2
		return 1
	fi

	# Pass — in a linked worktree on a non-protected branch.
	if [[ "$treehouse_managed" -eq 1 ]]; then
		echo "WORKTREE-GUARD: Treehouse worktree detected (in isolated worktree on '$current_branch')" >&2
	fi

	return 0
}


# Include shared treehouse helpers (treehouse_return for lease release).
# treehouse-helpers.sh — shared helpers for treehouse worktree pool management
#
# Treehouse (https://github.com/kunchenguid/treehouse) manages a pool of
# reusable, isolated git worktrees so each agent gets its own environment
# instantly — no cloning, no conflicts, no coordination overhead.
#
# This include provides thin wrappers around the treehouse CLI for use by
# execution-gate.sh and other scripts that need to acquire or release
# worktrees. When treehouse is not available, callers fall back to manual
# `git worktree add` commands.
#
# Functions provided:
#   treehouse_available       — check if treehouse is on PATH (echoes 1/0)
#   treehouse_acquire         — lease a worktree, echo its path (sets TREEHOUSE_LEASE_ID)
#   treehouse_acquire_json    — lease a worktree, echo JSON {path, lease_id, lease_holder, leased_at}
#   treehouse_return          — release a lease and return worktree to pool
#   treehouse_status          — print pool status (JSON or text)
#   treehouse_is_managed      — check if a path is inside a treehouse-managed worktree
#
# Environment variables:
#   TREEHOUSE_LEASE_HOLDER   — label recorded as the lease holder (default: $USER or "agent")
#   TREEHOUSE_NO_FETCH       — if set to 1, pass --no-fetch to treehouse get
#
# Materialization: each consuming skill has a
# `scripts/treehouse-helpers.sh.tmpl` file containing a single include
# directive that pulls in this file. The templater inlines this file at build
# time. Scripts then `source` the materialized copy from the same `scripts/`
# directory.
#
# Consumers:
#   - execution/execute-upsert/scripts/execution-gate.sh.tmpl
#   - execution/execute-upsert/scripts/land-on-env-dev.sh.tmpl
#   - execution/execute-upsert/scripts/ship-pr.sh.tmpl

# Guard against double-sourcing
_TREEHOUSE_HELPERS_SOURCED="${_TREEHOUSE_HELPERS_SOURCED:-}"

# treehouse_available — check if treehouse CLI is available.
# Echoes 1 if available, 0 if not. Does not use `return` so it works both
# when sourced and when inlined.
treehouse_available() {
	if command -v treehouse >/dev/null 2>&1; then
		echo 1
	else
		echo 0
	fi
}

# treehouse_acquire — lease a worktree from the pool.
# Echoes the absolute path of the leased worktree to stdout.
# Sets TREEHOUSE_LEASE_ID and TREEHOUSE_LEASE_PATH in the environment.
# Returns 0 on success, 1 on failure.
#
# Optional args:
#   $1 — lease holder label (defaults to $TREEHOUSE_LEASE_HOLDER or $USER or "agent")
treehouse_acquire() {
	local holder="${1:-${TREEHOUSE_LEASE_HOLDER:-${USER:-agent}}}"
	local extra_args=()
	if [[ "${TREEHOUSE_NO_FETCH:-0}" == "1" ]]; then
		extra_args+=(--no-fetch)
	fi

	# treehouse get --lease prints the path to stdout, banners to stderr.
	# --json gives us path + lease_id for programmatic use.
	local json_out
	json_out="$(treehouse get --lease --lease-holder "$holder" --json "${extra_args[@]}" 2>/dev/null)" || {
		echo "TREEHOUSE: failed to acquire worktree" >&2
		return 1
	}

	# Parse JSON output (path, lease_id, lease_holder, leased_at)
	# Use jq if available, otherwise fall back to grep/sed
	if command -v jq >/dev/null 2>&1; then
		TREEHOUSE_LEASE_PATH="$(printf '%s' "$json_out" | jq -r '.path // empty')"
		TREEHOUSE_LEASE_ID="$(printf '%s' "$json_out" | jq -r '.lease_id // empty')"
		TREEHOUSE_LEASE_HOLDER="$(printf '%s' "$json_out" | jq -r '.lease_holder // empty')"
	else
		TREEHOUSE_LEASE_PATH="$(printf '%s' "$json_out" | grep -o '"path":"[^"]*"' | head -1 | sed 's/"path":"//;s/"//')"
		TREEHOUSE_LEASE_ID="$(printf '%s' "$json_out" | grep -o '"lease_id":"[^"]*"' | head -1 | sed 's/"lease_id":"//;s/"//')"
		TREEHOUSE_LEASE_HOLDER="$(printf '%s' "$json_out" | grep -o '"lease_holder":"[^"]*"' | head -1 | sed 's/"lease_holder":"//;s/"//')"
	fi

	if [[ -z "$TREEHOUSE_LEASE_PATH" ]]; then
		echo "TREEHOUSE: no path in lease output" >&2
		return 1
	fi

	export TREEHOUSE_LEASE_PATH
	export TREEHOUSE_LEASE_ID
	export TREEHOUSE_LEASE_HOLDER
	echo "$TREEHOUSE_LEASE_PATH"
}

# treehouse_return — release a lease and return a worktree to the pool.
# Terminates lingering processes, verifies no foreign process remains,
# resets the worktree, and clears the lease.
#
# Args:
#   $1 — worktree path (required)
#   $2 — lease ID (optional, for ABA-safe return via --if-lease-id)
#   $3 — lease holder (optional, for --if-lease-holder)
# Returns 0 on success, 1 on failure.
treehouse_return() {
	local path="$1"
	local lease_id="${2:-}"
	local holder="${3:-}"

	if [[ -z "$path" ]]; then
		echo "TREEHOUSE: return requires a worktree path" >&2
		return 1
	fi

	local args=(--force)
	if [[ -n "$lease_id" ]]; then
		args+=(--if-lease-id "$lease_id")
	fi
	if [[ -n "$holder" ]]; then
		args+=(--if-lease-holder "$holder")
	fi

	treehouse return "${args[@]}" "$path" 2>&1 || {
		echo "TREEHOUSE: failed to return worktree at $path" >&2
		return 1
	}
}

# treehouse_status — print pool status.
# Args:
#   --json — print JSON status (default is human-readable text)
treehouse_status() {
	if [[ "${1:-}" == "--json" ]]; then
		treehouse status --json 2>/dev/null
	else
		treehouse status 2>&1
	fi
}

# treehouse_is_managed — check if a path is a treehouse-managed worktree.
#
# This is the authoritative check: it asks treehouse itself via
# `treehouse status --json`, which lists all worktrees in the pool with their
# paths. This works regardless of where the treehouse root is configured
# (default ~/.treehouse, repo-level treehouse.toml, user-level
# ~/.config/treehouse/config.toml, --root flag, or environment variables).
#
# Echoes 1 if the path matches a treehouse-managed worktree, 0 if not.
treehouse_is_managed() {
	local path="${1:-$PWD}"
	local abs_path
	abs_path="$(cd "$path" 2>/dev/null && pwd)" || { echo 0; return 0; }

	# If treehouse is not available, the path cannot be treehouse-managed.
	if ! command -v treehouse >/dev/null 2>&1; then
		echo 0
		return 0
	fi

	# Ask treehouse for all managed worktree paths.
	# `treehouse status --json` returns a JSON array with objects containing
	# "path" fields. We extract the paths and check if ours is among them.
	# This is authoritative — no hard-coded root paths, no config file parsing.
	local status_json
	status_json="$(treehouse status --json 2>/dev/null)" || { echo 0; return 0; }

	if [[ -z "$status_json" ]] || [[ "$status_json" == "null" ]]; then
		echo 0
		return 0
	fi

	# Extract paths from JSON. Use jq when available, otherwise grep/sed.
	local managed_paths
	if command -v jq >/dev/null 2>&1; then
		managed_paths="$(printf '%s' "$status_json" | jq -r '.[].path // empty' 2>/dev/null)"
	else
		# Fallback: extract "path":"..." values from the JSON array
		managed_paths="$(printf '%s' "$status_json" | grep -o '"path":"[^"]*"' | sed 's/"path":"//;s/"//')"
	fi

	if [[ -z "$managed_paths" ]]; then
		echo 0
		return 0
	fi

	# Check if abs_path matches or is inside any managed worktree path.
	# We check both exact match and prefix (in case the caller is in a
	# subdirectory of the worktree).
	local mp
	while IFS= read -r mp; do
		[[ -z "$mp" ]] && continue
		if [[ "$abs_path" == "$mp" ]] || [[ "$abs_path" == "$mp"/* ]]; then
			echo 1
			return 0
		fi
	done <<< "$managed_paths"

	echo 0
}


# ─────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────

FEATURE_BRANCH=""
BASE_BRANCH=""
PR_TITLE=""
PR_BODY_FILE=""
PROJECT_SLUG=""
FEATURE_SLUG=""
NO_MERGE=0
ADMIN_FLAG=0
QUALITY_GATE_SKIPPED=0
WAIT_FOR_CI=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --feature-branch)
      FEATURE_BRANCH="$2"; shift 2 ;;
    --base-branch)
      BASE_BRANCH="$2"; shift 2 ;;
    --pr-title)
      PR_TITLE="$2"; shift 2 ;;
    --pr-body-file)
      PR_BODY_FILE="$2"; shift 2 ;;
    --project-slug)
      PROJECT_SLUG="$2"; shift 2 ;;
    --feature-slug)
      FEATURE_SLUG="$2"; shift 2 ;;
    --no-merge)
      NO_MERGE=1; shift ;;
    --admin)
      ADMIN_FLAG=1; shift ;;
    --quality-gate-skipped)
      QUALITY_GATE_SKIPPED=1; shift ;;
    --wait-for-ci)
      WAIT_FOR_CI=1; shift ;;
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
if [[ -z "$BASE_BRANCH" ]]; then
  echo "ERROR: --base-branch is required" >&2
  exit 5
fi
if [[ -z "$PR_TITLE" ]]; then
  echo "ERROR: --pr-title is required" >&2
  exit 5
fi
if [[ -z "$PR_BODY_FILE" ]]; then
  echo "ERROR: --pr-body-file is required" >&2
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
  echo "[ship-pr] $*" >&2
}

emit_summary() {
  local status="$1" pr_number="$2" pr_url="$3" merged="$4"
  local worktree_cleaned="$5"
  printf '{"status":"%s","pr_number":%s,"pr_url":"%s","merged":%s,"base_branch":"%s","worktree_cleaned":%s}\n' \
    "$status" "$pr_number" "$pr_url" "$merged" "$BASE_BRANCH" "$worktree_cleaned"
}

current_short_sha() {
  git rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

# Check if we're inside a linked worktree (not the main checkout).
in_linked_worktree() {
  local abs_git_dir
  abs_git_dir="$(git rev-parse --absolute-git-dir 2>/dev/null)" || return 1
  [[ "$abs_git_dir" == *"/.git/worktrees/"* ]]
}

# Check skill-config.toml for [pr] auto-merge = false
check_config_no_merge() {
  local repo_root
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
  local cfg="$repo_root/skill-config.toml"
  [[ -f "$cfg" ]] || return 1
  local section
  section="$(awk '/^\[pr\]/{f=1;next} /^\[/{f=0} f' "$cfg" 2>/dev/null || true)"
  if printf '%s' "$section" | grep -Eq 'auto-merge[[:space:]]*=[[:space:]]*false'; then
    return 0  # auto-merge is disabled
  fi
  return 1  # auto-merge is not disabled
}

# ─────────────────────────────────────────────────────────────────────
# Step 1: Verify pre-conditions
# ─────────────────────────────────────────────────────────────────────

log "Step 1: verifying pre-conditions"

# 1a: PR body file exists and is non-empty
if [[ ! -f "$PR_BODY_FILE" ]]; then
  log "PRE-CONDITION FAILED: PR body file does not exist: $PR_BODY_FILE"
  exit 1
fi
BODY_SIZE="$(wc -c < "$PR_BODY_FILE" | tr -d ' ')"
if [[ "$BODY_SIZE" -lt 10 ]]; then
  log "PRE-CONDITION FAILED: PR body file is too small ($BODY_SIZE bytes)"
  exit 1
fi

# 1b: gh-posting-guard sanity checks
LITERAL_NEWLINES="$(grep -c '\\n' "$PR_BODY_FILE" 2>/dev/null || echo 0)"
if [[ "$LITERAL_NEWLINES" -gt 0 ]]; then
  log "WARNING: PR body file contains $LITERAL_NEWLINES literal '\\n' sequences"
  log "These will appear as two characters, not newlines. Consider fixing before posting."
  # Non-fatal — the AI may have intentional backslash-n in a code block
fi

# 1c: feature branch exists
if ! git rev-parse --verify "$FEATURE_BRANCH" >/dev/null 2>&1; then
  log "PRE-CONDITION FAILED: feature branch '$FEATURE_BRANCH' does not exist"
  exit 1
fi

# 1d: feature branch has commits beyond the base branch
git fetch origin "$BASE_BRANCH" 2>/dev/null || true
NEW_COMMITS="$(git log --oneline "origin/${BASE_BRANCH}..${FEATURE_BRANCH}" 2>/dev/null | wc -l | tr -d ' ')"
if [[ "$NEW_COMMITS" -eq 0 ]]; then
  log "PRE-CONDITION FAILED: feature branch has no commits beyond origin/$BASE_BRANCH"
  exit 1
fi

# 1e: gh CLI is available
if ! command -v gh >/dev/null 2>&1; then
  log "PRE-CONDITION FAILED: gh CLI is not installed"
  exit 1
fi

log "Pre-conditions OK: $NEW_COMMITS new commit(s), body file ($BODY_SIZE bytes)"

# ─────────────────────────────────────────────────────────────────────
# Step 2: Check auto-merge opt-out conditions
# ─────────────────────────────────────────────────────────────────────

log "Step 2: checking auto-merge conditions"

AUTO_MERGE=1

if [[ "$NO_MERGE" -eq 1 ]]; then
  log "Auto-merge DISABLED: --no-merge flag"
  AUTO_MERGE=0
fi

if [[ "$QUALITY_GATE_SKIPPED" -eq 1 ]]; then
  log "Auto-merge DISABLED: --quality-gate-skipped flag (quality gate did not run)"
  AUTO_MERGE=0
fi

if check_config_no_merge; then
  log "Auto-merge DISABLED: skill-config.toml has [pr] auto-merge = false"
  AUTO_MERGE=0
fi

if [[ "$AUTO_MERGE" -eq 1 ]]; then
  log "Auto-merge ENABLED"
else
  log "Auto-merge DISABLED — PR will be created but not merged"
fi

# ─────────────────────────────────────────────────────────────────────
# Step 3: Push the feature branch
# ─────────────────────────────────────────────────────────────────────

log "Step 3: pushing feature branch $FEATURE_BRANCH"

# Ensure we're on the feature branch
git checkout "$FEATURE_BRANCH" 2>/dev/null || {
  log "ERROR: cannot checkout $FEATURE_BRANCH"
  exit 5
}

if ! git push -u origin "$FEATURE_BRANCH" 2>&1; then
  log "WARNING: push of $FEATURE_BRANCH failed (may already be up to date)"
  # Non-fatal — the branch may already be pushed
fi
log "Feature branch pushed"

# ─────────────────────────────────────────────────────────────────────
# Step 4: Create the PR
# ─────────────────────────────────────────────────────────────────────

log "Step 4: creating PR"

# Determine the repo slug from the remote
REPO_SLUG="$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || echo "")"
if [[ -z "$REPO_SLUG" ]]; then
  log "ERROR: cannot determine repo slug via gh repo view"
  exit 5
fi

PR_CREATE_OUTPUT=""
PR_CREATE_EXIT=0
PR_CREATE_OUTPUT="$(gh pr create \
  --repo "$REPO_SLUG" \
  --base "$BASE_BRANCH" \
  --head "$FEATURE_BRANCH" \
  --title "$PR_TITLE" \
  --body-file "$PR_BODY_FILE" 2>&1)" || PR_CREATE_EXIT=$?

if [[ "$PR_CREATE_EXIT" -ne 0 ]]; then
  log "PR creation failed (exit $PR_CREATE_EXIT):"
  echo "$PR_CREATE_OUTPUT" >&2
  # Check if it's a "PR already exists" error
  if echo "$PR_CREATE_OUTPUT" | grep -qi "already exists"; then
    log "A PR already exists for this branch. Attempting to find it."
    PR_URL="$(gh pr view --json url --jq '.url' 2>/dev/null || echo "")"
    if [[ -n "$PR_URL" ]]; then
      PR_NUMBER="$(gh pr view --json number --jq '.number' 2>/dev/null || echo "0")"
      log "Found existing PR #$PR_NUMBER: $PR_URL"
    else
      log "ERROR: could not find existing PR"
      exit 2
    fi
  else
    exit 2
  fi
else
  PR_URL="$(echo "$PR_CREATE_OUTPUT" | tail -1 | tr -d '[:space:]')"
  # Extract PR number from the URL (last path segment)
  PR_NUMBER="$(echo "$PR_URL" | grep -oE '[0-9]+$' || echo "0")"
  log "PR created: #$PR_NUMBER at $PR_URL"
fi

if [[ -z "$PR_URL" ]] || [[ "$PR_NUMBER" == "0" ]]; then
  log "ERROR: could not determine PR URL or number"
  exit 2
fi

# ─────────────────────────────────────────────────────────────────────
# Step 5: Verify the posted PR body
# ─────────────────────────────────────────────────────────────────────

log "Step 5: verifying PR body"

POSTED_BODY="$(gh pr view "$PR_NUMBER" --json body --jq '.body' 2>/dev/null || echo "")"
if [[ -z "$POSTED_BODY" ]]; then
  log "WARNING: could not fetch posted PR body — skipping verification"
else
  # Normalize both for comparison: strip trailing whitespace per line and trailing newlines
  NORMALIZED_FILE="$(sed 's/[[:space:]]*$//' "$PR_BODY_FILE" | sed -e :a -e '/^\n*$/{$d;N;ba}' )"
  NORMALIZED_POSTED="$(printf '%s' "$POSTED_BODY" | sed 's/[[:space:]]*$//' | sed -e :a -e '/^\n*$/{$d;N;ba}')"

  if [[ "$NORMALIZED_FILE" != "$NORMALIZED_POSTED" ]]; then
    log "PR body verification FAILED: posted body differs from file"
    log "This may indicate corruption (literal \\n, stripped backticks, etc.)"
    log "Attempting to fix by re-posting with --body-file"
    if gh pr edit "$PR_NUMBER" --body-file "$PR_BODY_FILE" 2>&1; then
      log "PR body re-posted successfully"
    else
      log "ERROR: re-posting PR body failed"
      emit_summary "body-verification-failed" "$PR_NUMBER" "$PR_URL" "false" "false"
      exit 3
    fi
  else
    log "PR body verified: matches file"
  fi
fi

# ─────────────────────────────────────────────────────────────────────
# Step 6: Wait for CI checks (optional, --wait-for-ci)
# ─────────────────────────────────────────────────────────────────────

WORKTREE_CLEANED="false"

if [[ "$AUTO_MERGE" -eq 0 ]]; then
  log "Step 6: SKIPPED (auto-merge disabled)"
  log "PR created but not merged. Present the URL to the user:"
  log "  $PR_URL"
  emit_summary "pr-created" "$PR_NUMBER" "$PR_URL" "false" "false"
  exit 6
fi

if [[ "$WAIT_FOR_CI" -eq 1 ]]; then
  log "Step 6: waiting for CI checks on PR #$PR_NUMBER"
  if gh pr checks "$PR_NUMBER" --watch 2>&1; then
    log "CI checks passed"
  else
    CHECK_STATUS=$?
    log "CI checks failed (exit $CHECK_STATUS) — NOT merging"
    emit_summary "ci-failed" "$PR_NUMBER" "$PR_URL" "false" "false"
    exit 7
  fi
else
  log "Step 6: SKIPPED (--wait-for-ci not set)"
fi

# ─────────────────────────────────────────────────────────────────────
# Step 7: Squash-merge the PR
# ─────────────────────────────────────────────────────────────────────

log "Step 7: merging PR #$PR_NUMBER (squash, delete branch)"

MERGE_FLAGS="--squash --delete-branch"
if [[ "$ADMIN_FLAG" -eq 1 ]]; then
  MERGE_FLAGS="$MERGE_FLAGS --admin"
fi

MERGE_EXIT=0
gh pr merge "$PR_NUMBER" $MERGE_FLAGS 2>&1 || MERGE_EXIT=$?

if [[ "$MERGE_EXIT" -ne 0 ]]; then
  log "Merge failed (exit $MERGE_EXIT)"
  log "If this is a branch protection error, retry with --admin flag"
  log "If the token lacks admin permissions, present the PR URL for manual merge:"
  log "  $PR_URL"
  emit_summary "merge-failed" "$PR_NUMBER" "$PR_URL" "false" "false"
  exit 4
fi
log "PR merged successfully on remote"

# ─────────────────────────────────────────────────────────────────────
# Step 8: Clean up the worktree (if we're in one)
# ─────────────────────────────────────────────────────────────────────

log "Step 8: cleaning up worktree"

if in_linked_worktree; then
  CURRENT_WD="$(pwd)"

  # Return treehouse lease if applicable
  if [[ "$(treehouse_available)" == "1" ]] && [[ "$(treehouse_is_managed "$CURRENT_WD")" == "1" ]]; then
    log "Returning treehouse lease for $CURRENT_WD"
    treehouse_return "$CURRENT_WD" 2>&1 | sed 's/^/[ship-pr] /' >&2 || true
    WORKTREE_CLEANED="true"
  else
    # Manual worktree removal
    log "Removing manual worktree at $CURRENT_WD"
    MAIN_REPO_FOR_CLEANUP="$(git rev-parse --git-common-dir 2>/dev/null)/.."
    MAIN_REPO_FOR_CLEANUP="$(cd "$MAIN_REPO_FOR_CLEANUP" && pwd)"
    if git -C "$MAIN_REPO_FOR_CLEANUP" worktree remove "$CURRENT_WD" --force 2>&1; then
      log "Worktree removed"
      WORKTREE_CLEANED="true"
    else
      log "WARNING: could not remove worktree at $CURRENT_WD"
      log "Manual step: git worktree remove \"$CURRENT_WD\" --force"
    fi
  fi
else
  log "Not in a linked worktree — nothing to clean up"
  WORKTREE_CLEANED="true"
fi

# ─────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────

log "Phase 9 complete: PR #$PR_NUMBER merged on remote"
log "Your local $BASE_BRANCH checkout is now behind origin — run: git pull origin $BASE_BRANCH"
emit_summary "merged" "$PR_NUMBER" "$PR_URL" "true" "$WORKTREE_CLEANED"

exit 0
