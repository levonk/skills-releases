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

