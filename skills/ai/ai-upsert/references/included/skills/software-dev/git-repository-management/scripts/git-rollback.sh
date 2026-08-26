#!/usr/bin/env bash

# git-rollback.sh - Roll back to a tag or SHA with backup branch
# Purpose: Single handoff to reset HEAD to a prior tag or SHA, creating a
#          backup branch first so the pre-rollback state is always recoverable.
# Usage: git-rollback.sh --to <tag-or-sha> [--slug <slug>] [--allow-main-write] [repo_root]
# Output: ROLLBACK_SUCCESS or ROLLBACK_FAILED with backup branch info.

set -euo pipefail

# Tool detection and wrapper helpers are shared via includes.
# These provide: probe_devbox(), wrapper_prefix(), devbox_run(), run_command(),
# rtk_available(), rtk_prefix(), git_cmd(), rtk_wrap().
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_TOOL_DISCOVERY="$SCRIPT_DIR/cli-tool-discovery.sh"

# Optional tool availability flags.
if command -v rtk >/dev/null 2>&1; then RTK_AVAILABLE=1; else RTK_AVAILABLE=0; fi

# Include shared wrapper helpers (probe_devbox, wrapper_prefix, devbox_run, run_command).
# wrapper-helpers.sh — shared functions for environment wrapper detection
#
# Included by skills that need to wrap commands with environment wrappers
# (devbox, mise, flox, direnv, nix). Provides:
#   - probe_devbox():    hang-safe probe that disables devbox if it doesn't respond
#   - wrapper_prefix():  resolve the wrapper prefix (e.g. "devbox run --")
#   - devbox_run():      run a command through devbox when available, else directly
#   - run_command():     run a command through the detected wrapper, else directly
#
# Depends on: cli-tool-discovery.sh materialized in the same scripts/ directory.
#
# Consumers:
#   - shell-wrapper/scripts/wrap_command.sh.tmpl
#   - git-repository-management/scripts/git-collect.sh.tmpl
#   - git-repository-management/scripts/git-commit-batch.sh.tmpl
#   - git-repository-management/scripts/git-push.sh.tmpl
#   - git-repository-management/scripts/git-rollback.sh.tmpl
#
# Usage (in a .tmpl script, after defining SCRIPT_DIR and CLI_TOOL_DISCOVERY):
#   Include this file via the templater's include directive.
#
# Optional override: set WRAPPER_DEVBOX_DISABLED=1 before including to make
# wrapper_prefix() skip the devbox wrapper (also set by probe_devbox on hang).

# Probe devbox: verify `devbox run` actually responds within a timeout.
# Tests with the real command chain (rtk git / git) to catch wrapper recursion.
# If it hangs (e.g. broken wrapper recursion, nix store issues), disable
# devbox wrapping for the rest of the script and fall back to direct execution.
#
# Optional: set PROBE_DEVBOX_TIMEOUT_SECS to override the default 15s timeout.
# Optional: set PROBE_DEVBOX_TEST_CMD to override the test command (default:
#   "rtk git --version" if rtk is available, else "git --version").
#
# This function is idempotent — calling it multiple times is safe. After the
# first call, WRAPPER_DEVBOX_DISABLED reflects the probe result and subsequent
# calls return immediately.
probe_devbox() {
	# If devbox was already disabled by a prior probe or caller, nothing to do.
	if [[ "${WRAPPER_DEVBOX_DISABLED:-0}" -eq 1 ]]; then
		return 0
	fi
	# If cli-tool-discovery says we're already inside a devbox shell, no probe
	# needed — devbox binaries are on PATH and no wrapper detection is required.
	if [[ -n "${DEVBOX_SHELL:-}${IN_DEVBOX_SHELL:-}" ]]; then
		return 0
	fi
	# If no devbox.json up the tree, no point probing.
	if ! command -v devbox >/dev/null 2>&1; then
		WRAPPER_DEVBOX_DISABLED=1
		return 0
	fi
	local _timeout="${PROBE_DEVBOX_TIMEOUT_SECS:-15}"
	local _test_cmd=(git --version)
	if command -v rtk >/dev/null 2>&1; then
		_test_cmd=(rtk git --version)
	fi
	# Honor caller override for the test command.
	if [[ -n "${PROBE_DEVBOX_TEST_CMD:-}" ]]; then
		# shellcheck disable=SC2206  # intentional word-splitting on caller's command
		_test_cmd=(${PROBE_DEVBOX_TEST_CMD})
	fi
	devbox run -- "${_test_cmd[@]}" >/dev/null 2>&1 &
	local _pid=$!
	local _elapsed=0
	while kill -0 "$_pid" 2>/dev/null; do
		if [[ "$_elapsed" -ge "$_timeout" ]]; then
			kill -9 "$_pid" 2>/dev/null
			wait "$_pid" 2>/dev/null || true
			echo "⚠️ devbox run hung after ${_timeout}s (likely broken wrapper), falling back to direct execution" >&2
			WRAPPER_DEVBOX_DISABLED=1
			return 1
		fi
		sleep 1
		_elapsed=$((_elapsed + 1))
	done
	local _exit=0
	wait "$_pid" || _exit=$?
	if [[ "$_exit" -ne 0 ]]; then
		echo "⚠️ devbox run failed (exit $_exit), falling back to direct execution" >&2
		WRAPPER_DEVBOX_DISABLED=1
		return 1
	fi
	return 0
}

# Resolve the environment wrapper for the current directory.
# Prints the wrapper prefix (e.g. "devbox run --") or empty if none.
# Delegates entirely to cli-tool-discovery.sh, which checks "already inside"
# env vars (DEVBOX_SHELL, MISE_SHELL, FLOX_ACTIVE, DIRENV_DIR, IN_NIX_SHELL)
# and walks up from cwd for config files. No duplicate detection logic here.
#
# CACHING: The result is cached in WRAPPER_PREFIX_CACHE for the lifetime of the
# script. cli-tool-discovery.sh can take up to 15s per call (devbox probe
# timeout), and wrapper_prefix() is called on every devbox_run() — without
# caching, a script that makes 20 git_cmd() calls would block for 300s.
# The cache is invalidated if WRAPPER_DEVBOX_DISABLED changes after the first
# call (probe_devbox may set it). Set WRAPPER_PREFIX_REFRESH=1 to force a
# re-probe.
wrapper_prefix() {
	# Return cached result if available and the devbox-disabled flag hasn't changed.
	if [[ -n "${WRAPPER_PREFIX_CACHE+x}" && "${WRAPPER_PREFIX_REFRESH:-0}" -eq 0 ]]; then
		if [[ "${WRAPPER_PREFIX_CACHE_DISABLED:-0}" -eq "${WRAPPER_DEVBOX_DISABLED:-0}" ]]; then
			printf '%s' "$WRAPPER_PREFIX_CACHE"
			return
		fi
	fi

	# Fast path: if devbox was disabled by probe_devbox (hang/failure) or by
	# the caller, skip the cli-tool-discovery.sh probe entirely. The probe
	# internally calls `devbox run --` which can take 15s to timeout — calling
	# it when devbox is already known-broken defeats the purpose of the probe.
	# Check for other wrappers (mise, flox, direnv, nix) only when devbox is
	# NOT the disabled one — but in practice, if devbox.json exists and devbox
	# is disabled, the other wrappers are not relevant for this repo.
	if [[ "${WRAPPER_DEVBOX_DISABLED:-0}" -eq 1 ]]; then
		# Still check for non-devbox wrappers via cli-tool-discovery, but only
		# if there's no devbox.json up the tree (if there IS one, devbox was
		# the intended wrapper and it's broken — don't waste 15s re-probing).
		local _has_devbox_json=0
		local _dir="$PWD"
		while [[ "$_dir" != "/" ]]; do
			if [[ -f "$_dir/devbox.json" ]]; then
				_has_devbox_json=1
				break
			fi
			_dir="$(dirname "$_dir")"
		done
		if [[ "$_has_devbox_json" -eq 1 ]]; then
			WRAPPER_PREFIX_CACHE=""
			WRAPPER_PREFIX_CACHE_DISABLED="${WRAPPER_DEVBOX_DISABLED:-0}"
			printf ''
			return
		fi
	fi

	if [[ ! -f "${CLI_TOOL_DISCOVERY:-}" ]]; then
		WRAPPER_PREFIX_CACHE=""
		WRAPPER_PREFIX_CACHE_DISABLED="${WRAPPER_DEVBOX_DISABLED:-0}"
		printf ''
		return
	fi

	# Use --detect-wrapper mode — checks config file existence + wrapper
	# functionality WITHOUT requiring a specific tool to exist inside the
	# wrapper. This is needed for devbox: the old __wrapper_probe__ trick
	# (nonexistent tool name) failed because devbox detection in resolve mode
	# requires the tool to exist inside devbox (step 2a). --detect-wrapper
	# probes devbox with `devbox run -- true` (hang-safe, always-available
	# builtin) instead. For mise/flox/nix, config file existence is sufficient.
	local result
	result="$(bash "$CLI_TOOL_DISCOVERY" --detect-wrapper 2>/dev/null || true)"
	local prefix=""
	case "$result" in
	WRAPPER:\ *)
		prefix="${result#WRAPPER: }"
		# Allow callers to disable devbox at runtime (e.g. probe_devbox)
		if [[ "$prefix" == "devbox run --" && "${WRAPPER_DEVBOX_DISABLED:-0}" -eq 1 ]]; then
			prefix=""
		fi
		;;
	*)
		prefix=""
		;;
	esac

	WRAPPER_PREFIX_CACHE="$prefix"
	WRAPPER_PREFIX_CACHE_DISABLED="${WRAPPER_DEVBOX_DISABLED:-0}"
	printf '%s' "$prefix"
}

# Run a command through devbox when available, otherwise directly.
# This is the simple wrapper — it does NOT probe. Call probe_devbox first if
# you want hang-safety. wrapper_prefix() honors WRAPPER_DEVBOX_DISABLED.
devbox_run() {
	local wrapper
	wrapper="$(wrapper_prefix)"
	if [[ -n "$wrapper" ]]; then
		$wrapper "$@"
	else
		"$@"
	fi
}

# Run a command through the detected environment wrapper (if any), otherwise directly.
# Alias for devbox_run — kept for backward compatibility with existing callers.
run_command() {
	devbox_run "$@"
}


# Include shared rtk helpers (rtk_available, rtk_prefix, git_cmd, rtk_wrap).
# Must come after wrapper-helpers.sh since it depends on devbox_run/wrapper_prefix.
# rtk-helpers.sh — shared functions for rtk (Rust Token Killer) wrapping
#
# Provides rtk_available(), rtk_prefix(), rtk_wrap_command(), git_cmd(), and rtk_wrap().
# rtk compresses CLI output by 60-90% for LLM context. Coverage is determined
# by `rtk rewrite` — the single source of truth that rtk's own hooks use.
# No hardcoded list of supported commands is maintained here.
#
# Depends on: cli-tool-discovery.sh and wrapper-helpers.sh materialized in the
# same scripts/ directory. Include wrapper-helpers.sh BEFORE this file.
#
# Consumers:
#   - shell-wrapper/scripts/wrap_command.sh.tmpl
#   - git-repository-management/scripts/git-collect.sh.tmpl
#   - git-repository-management/scripts/git-commit-batch.sh.tmpl
#   - git-repository-management/scripts/git-push.sh.tmpl
#   - git-repository-management/scripts/git-rollback.sh.tmpl
#
# Optional: set RTK_SKIP=1 before including to disable all rtk wrapping
# (used by shell-wrapper's --raw flag and git-collect's probe failure).

# Resolve rtk via cli-tool-discovery.sh (finds it even in non-standard locations).
# Prints "rtk" if available, empty otherwise.
rtk_available() {
	if [[ "${RTK_SKIP:-0}" -eq 1 ]]; then
		printf ''
		return
	fi
	if [[ ! -f "${CLI_TOOL_DISCOVERY:-}" ]]; then
		command -v rtk >/dev/null 2>&1 && printf 'rtk'
		return
	fi
	local result
	result="$(bash "$CLI_TOOL_DISCOVERY" rtk 2>/dev/null || true)"
	case "$result" in
	FOUND:* | WRAPPER:*)
		printf 'rtk'
		;;
	*)
		printf ''
		;;
	esac
}

# Check if rtk supports a command by probing `rtk rewrite`.
# Exit codes from rtk rewrite: 0=allow, 1=not supported, 2=deny, 3=ask.
# 0 and 3 both mean "rtk supports this command".
# Prints "rtk" if the command should be wrapped, empty otherwise.
rtk_prefix() {
	if [[ "${RTK_SKIP:-0}" -eq 1 ]]; then
		printf ''
		return
	fi
	if [[ -z "$(rtk_available)" ]]; then
		printf ''
		return
	fi
	# Probe with the full command — rtk rewrite needs the subcommand to
	# determine coverage (e.g. `git` alone is rc=1, but `git status` is rc=3).
	rtk rewrite -- "$@" >/dev/null 2>&1
	local rc=$?
	if [[ $rc -eq 0 || $rc -eq 3 ]]; then
		printf 'rtk'
	fi
}

# Wrap a command with rtk if supported, run through environment wrapper if present.
# Usage: rtk_wrap_command <tool> [args...]
# If rtk supports the command, runs: <env-wrapper> rtk <tool> [args...]
# Otherwise runs:                   <env-wrapper> <tool> [args...]
rtk_wrap_command() {
	local tool="$1"
	shift
	local rtk_prefix_val
	rtk_prefix_val="$(rtk_prefix "$tool" "$@" 2>/dev/null || true)"
	local wrapper
	wrapper="$(wrapper_prefix)"
	if [[ -n "$rtk_prefix_val" ]]; then
		if [[ -n "$wrapper" ]]; then
			$wrapper rtk "$tool" "$@"
		else
			rtk "$tool" "$@"
		fi
	else
		if [[ -n "$wrapper" ]]; then
			$wrapper "$tool" "$@"
		else
			"$tool" "$@"
		fi
	fi
}

# Wrapper: use 'rtk git' instead of 'git' when rtk supports it,
# and run through devbox when available. Uses rtk_prefix() for coverage check.
# This is the canonical git command wrapper — all git-repository-management
# scripts use this instead of redefining their own git_cmd().
git_cmd() {
	local rtk_p
	rtk_p="$(rtk_prefix git "$@" 2>/dev/null || true)"
	if [[ -n "$rtk_p" ]]; then
		devbox_run rtk git "$@"
	else
		devbox_run git "$@"
	fi
}

# Wrapper: use 'rtk <tool>' for supported commands, run through devbox when available.
# Uses rtk_prefix() for coverage check — no longer wraps unconditionally.
# This is the generic tool wrapper — all git-repository-management scripts use
# this instead of redefining their own rtk_wrap().
rtk_wrap() {
	local tool="$1"
	shift
	local rtk_p
	rtk_p="$(rtk_prefix "$tool" "$@" 2>/dev/null || true)"
	if [[ -n "$rtk_p" ]]; then
		devbox_run rtk "$tool" "$@"
	else
		devbox_run "$tool" "$@"
	fi
}


# Include shared worktree isolation guard (guard_worktree_isolation).
# Prevents rollbacks on main/master or outside a linked worktree.
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


# Probe devbox after function definitions.
probe_devbox || true

discover_repo_root() {
	local target_path="${1:-.}"
	local repo_root
	repo_root=$(cd "$target_path" && git rev-parse --show-toplevel 2>/dev/null)
	if [ -z "$repo_root" ]; then
		echo "ERROR: $target_path is not inside a git repository" >&2
		exit 1
	fi
	echo "$repo_root"
}

main() {
	local target="" slug="rollback" target_path="."
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--to)
			target="$2"
			shift 2
			;;
		--to=*)
			target="${1#--to=}"
			shift
			;;
		--slug)
			slug="$2"
			shift 2
			;;
		--slug=*)
			slug="${1#--slug=}"
			shift
			;;
		--allow-main-write)
			SKILL_ALLOW_MAIN_WRITE=1
			shift
			;;
		-h | --help)
			sed -n '2,8p' "$0"
			exit 0
			;;
		*)
			target_path="$1"
			shift
			;;
		esac
	done

	if [[ -z "$target" ]]; then
		echo "ERROR: --to <tag-or-sha> is required" >&2
		echo "Usage: git-rollback.sh --to <tag-or-sha> [--slug <slug>] [repo_root]" >&2
		exit 1
	fi

	local repo_root
	repo_root=$(discover_repo_root "$target_path")
	cd "$repo_root"

	# Worktree isolation guard — rollbacks mutate the working tree.
	guard_worktree_isolation || exit 1

	# Resolve the target to a valid SHA — accept tags, SHAs, and branch names
	local target_sha
	target_sha=$(git_cmd rev-parse --verify "$target^{commit}" 2>/dev/null || echo "")
	if [[ -z "$target_sha" ]]; then
		echo "ROLLBACK_FAILED:INVALID_TARGET"
		echo "ERROR: Could not resolve '$target' to a commit" >&2
		exit 1
	fi

	local original_sha
	original_sha=$(git_cmd rev-parse HEAD)

	# Refuse no-op rollback (target is already HEAD)
	if [[ "$target_sha" == "$original_sha" ]]; then
		echo "ROLLBACK_FAILED:ALREADY_AT_TARGET"
		echo "ERROR: HEAD is already at $target_sha" >&2
		exit 1
	fi

	echo "=== ROLLBACK_START ==="
	echo "TARGET:${target}"
	echo "TARGET_SHA:${target_sha}"
	echo "ORIGINAL_SHA:${original_sha}"

	# Step 1: Create backup branch at scratch/rollback/YYYY/MM/YYYYMMDDHHmm-{slug}-pre
	local timestamp backup_branch
	timestamp=$(date -u +%Y%m%d%H%M)
	backup_branch="scratch/rollback/$(date -u +%Y/%m)/${timestamp}-${slug}-pre"
	echo "BACKUP_BRANCH:$backup_branch"
	if ! git_cmd branch "$backup_branch" "$original_sha" 2>/dev/null; then
		echo "ROLLBACK_FAILED:BACKUP_BRANCH_ERROR"
		echo "=== ROLLBACK_END ==="
		exit 1
	fi
	echo "BACKUP_CREATED"

	# Step 2: Reset HEAD to the target
	echo "RESETTING:"
	if git_cmd reset --hard "$target_sha" 2>&1; then
		echo "ROLLBACK_SUCCESS:${target_sha}"
		echo "BACKUP_BRANCH:$backup_branch"
		echo "BACKUP_NOTE:Recover with: git reset --hard $backup_branch"
		echo "BACKUP_REMOVE:git branch -D $backup_branch (when no longer needed)"
	else
		echo "ROLLBACK_FAILED:GIT_ERROR"
		echo "BACKUP_RESTORE:git reset --hard $original_sha"
		echo "=== ROLLBACK_END ==="
		exit 1
	fi

	echo "=== ROLLBACK_END ==="
}

main "$@"
