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

# This script intentionally merges a feature branch into env/dev (a long-lived
# integration branch). It is the merge script exempt from the worktree
# isolation guard by default — SKILL_ALLOW_MAIN_WRITE=1 is baked in.
# The guard is still sourced (for the materialization chain) but always passes.
SKILL_ALLOW_MAIN_WRITE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Include shared worktree isolation guard (guard_worktree_isolation).
# Exempt via SKILL_ALLOW_MAIN_WRITE=1 above — this script intentionally
# operates on env/dev, a long-lived branch.
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


# Include shared nice-relaunch (low-priority relaunch for long-running scripts).
# land-on-env-dev runs tests after merging — can be long-running.
# nice-relaunch.sh — relaunch the current script at lower CPU priority
#
# For long-running, low-priority scripts (validate, lint, typecheck, build,
# test, detection, mining). Uses `exec nice -n <delta>` to replace the
# current process in-place with a nice'd copy — no subshell, no extra shell
# layer, the exit code propagates directly to the calling shell.
#
# The relaunch is skipped when:
#   - NICE_RELAUNCHED=1 is set (already relaunch-ed — prevents recursion)
#   - NICE_RELAUNCH=0 is set (explicit disable)
#   - stdout is a TTY (interactive session — don't nice interactive runs)
#   - `nice` is not available on the system
#   - $0 is not a readable file (e.g. bash -c "..." or piped input)
#
# Configuration:
#   NICE_RELAUNCH_DELTA — nice priority delta (default: 10, range 1-19)
#     Higher = lower priority. 10 is a moderate delta that yields to
#     interactive work without starving the script.
#   NICE_RELAUNCH=0 — disable the relaunch entirely (escape hatch)
#
# Usage (at the TOP of a consuming script, before any other work):
#   source "$SCRIPT_DIR/nice-relaunch.sh"
#
# Or when inlined via {{ include "includes/nice-relaunch.sh" . }}:
#   The function is defined and called automatically — no extra call needed.
#
# The relaunch is performed inside a function so that `return` works correctly
# in both contexts (sourced files and inlined code). If the relaunch fires,
# `exec` replaces the process and the function never returns. If it skips,
# the function returns and execution continues normally.
#
# Materialization: each consuming skill has a
# `scripts/nice-relaunch.sh.tmpl` file containing a single include
# directive that pulls in this file. The templater inlines this file at build
# time. Scripts then `source` the materialized copy from the same `scripts/`
# directory.
#
# Consumers:
#   - code-quality-validation/scripts/quality-validator.sh
#   - project-detection/scripts/detect-build-systems.sh
#   - project-detection/scripts/detect-ci-cd-systems.sh
#   - project-detection/scripts/detect-all-systems.sh
#   - nixify/scripts/test-with-act.sh
#   - nixify/scripts/detect-garnix-scope.sh
#   - regression-test-mining/scripts/mine-bug-fixes.sh.tmpl
#   - git-repository-management/scripts/git-collect.sh.tmpl
#   - git-repository-management/scripts/git-archive.sh.tmpl
#   - git-repository-management/scripts/git-push.sh.tmpl
#   - execution/execute-upsert/scripts/land-on-env-dev.sh.tmpl

nice_relaunch() {
	# Guard against double-calling (prevents recursion if sourced twice)
	if [[ -n "${_NICE_RELAUNCH_SOURCED:-}" ]]; then
		return 0
	fi
	_NICE_RELAUNCH_SOURCED=1

	# Skip if already relaunch-ed (prevents infinite recursion)
	if [[ "${NICE_RELAUNCHED:-0}" -eq 1 ]]; then
		return 0
	fi

	# Skip if explicitly disabled
	if [[ "${NICE_RELAUNCH:-1}" -eq 0 ]]; then
		return 0
	fi

	# Skip if stdout is a TTY (interactive session)
	if [[ -t 1 ]]; then
		return 0
	fi

	# Skip if nice is not available
	if ! command -v nice >/dev/null 2>&1; then
		return 0
	fi

	# Skip if $0 is not a readable file (e.g. bash -c, piped input, PATH lookup
	# that resolved to a function). Without a real file to re-exec, the relaunch
	# would fail.
	if [[ ! -r "$0" ]]; then
		return 0
	fi

	# Relaunch: replace the current process with a nice'd copy of itself.
	# exec replaces the process in-place — no subshell, no extra layer.
	# The exit code of the nice'd process propagates directly to the caller.
	local _nice_delta="${NICE_RELAUNCH_DELTA:-10}"
	exec nice -n "$_nice_delta" env NICE_RELAUNCHED=1 bash "$0" "$@"
}

# Execute the relaunch check immediately. If the relaunch fires, exec replaces
# the process and this line never returns. If it skips, execution continues.
nice_relaunch


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

# --- Return treehouse lease if the worktree was treehouse-managed ---
# The execution-gate records whether treehouse was used and the lease info.
# land-on-env-dev runs inside the worktree, so we check if we're in a
# treehouse-managed path and return the lease.
if [[ "$(treehouse_available)" == "1" ]]; then
  CURRENT_WD="$(pwd)"
  if [[ "$(treehouse_is_managed "$CURRENT_WD")" == "1" ]]; then
    log "Returning treehouse lease for $CURRENT_WD"
    treehouse_return "$CURRENT_WD" 2>&1 | sed 's/^/[land-on-env-dev] /' >&2 || true
  fi
fi

exit 0
