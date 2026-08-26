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

