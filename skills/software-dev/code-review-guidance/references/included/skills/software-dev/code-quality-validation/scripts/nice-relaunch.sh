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

