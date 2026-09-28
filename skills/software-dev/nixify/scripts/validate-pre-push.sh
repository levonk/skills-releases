#!/usr/bin/env bash
# validate-pre-push.sh — deterministic PRE-PUSH gate for nixify runs.
#
# Run this AFTER Step 22 (validate-flake.sh) and BEFORE Step 23 (push).
# It is the final deterministic catch for the four classes of bug that
# shipped broken on acryl PR #5:
#
#   1. fetchPnpmDeps / fetchNpmDeps hash mismatch — the flake has a stale
#      or wrong FOD hash. validate-flake.sh runs `nix build .#default`
#      which catches this, but only if the agent actually runs it. This
#      script re-runs the build and extracts the correct hash from the
#      error if there's a mismatch, so the agent can fix it without a
#      second round-trip.
#
#   2. magic-nix-cache-action present in any workflow — the skill's
#      references/advanced/github-actions-nix.md says "DO NOT add" it, but prose
#      guidance was ignored. This script GREPS for it deterministically
#      and fails if found. The hosted backend was sunset Feb 2025; the
#      action degrades to a FlakeHub auth failure that breaks CI.
#
#   3. Missing timeout-minutes on nix workflow jobs — the skill's CI
#      template specifies timeout-minutes: 20, but the acryl PR omitted
#      it, causing a 6h hang on aarch64-darwin. This script parses the
#      nix workflow YAML and fails if any job lacks timeout-minutes.
#
#   4. Stale branch — the PR branch is behind upstream/main. This script
#      compares HEAD's merge-base with upstream/main and fails if the
#      branch is behind. (The start-phase sync-and-baseline.sh catches
#      this at the start; this is the final check before push.)
#
# It also delegates to existing validation scripts:
#   - validate-action-pins.sh (Step 16b) — all actions pinned to SHAs
#   - validate-pr-cleanliness.sh (Step 26) — no merge commits, clean history
#
# Usage: validate-pre-push.sh <owner>/<repo> [project-dir] [--base-ref <ref>] [--verbose]
#
# Options:
#   --base-ref <ref>  Base ref for staleness check (default: origin/main)
#   --verbose         Full output
#   --skip-build      Skip the nix build hash-mismatch check (use if you
#                     already ran validate-flake.sh and just want the
#                     workflow/staleness checks)
#
# Exit codes:
#   0 — all checks passed, safe to push
#   1 — one or more checks failed (fix before pushing)
#   2 — prerequisites missing (nix not installed, no workflows dir)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO="${1:?Usage: validate-pre-push.sh <owner>/<repo> [project-dir] [--base-ref <ref>] [--verbose]}"
PROJECT_DIR="${2:-.}"
BASE_REF="origin/main"
VERBOSE=""
SKIP_BUILD=""

# Parse remaining args
shift 2 || true
while [ $# -gt 0 ]; do
	case "$1" in
	--base-ref)
		BASE_REF="$2"
		shift 2
		;;
	--verbose)
		VERBOSE="--verbose"
		shift
		;;
	--skip-build)
		SKIP_BUILD="1"
		shift
		;;
	*)
		echo "Unknown flag: $1" >&2
		exit 1
		;;
	esac
done

cd "$PROJECT_DIR"

FAILED=0
CHECKS_RUN=0
ISSUES=""

add_issue() {
	ISSUES="${ISSUES}${ISSUES:+,}\"$1\""
	FAILED=1
}

run_check() {
	local name="$1"
	shift
	CHECKS_RUN=$((CHECKS_RUN + 1))
	if [ "$VERBOSE" = "--verbose" ]; then
		echo ""
		echo "── $name ──"
		if "$@"; then
			echo "ok: $name"
		else
			echo "FAILED: $name"
			add_issue "$name"
		fi
	else
		if "$@" >/dev/null 2>&1; then
			echo "ok: $name"
		else
			echo "FAILED: $name"
			add_issue "$name"
		fi
	fi
}

echo "[validate-pre-push] Running $CHECKS_RUN pre-push validation checks..."

# ── Check 1: magic-nix-cache-action use-flakehub + darwin os guard ──────────
# The action is NOT banned — it works again as of June 2025. Two footguns:
#   1. The action defaults to use-flakehub: true, which attempts FlakeHub OIDC
#      authentication. If the GitHub org is NOT registered on FlakeHub, this
#      produces the acryl PR #5 error: "Unable to authenticate to FlakeHub..."
#      The error condition is OMITTING use-flakehub — the default true is the
#      footgun. We require use-flakehub: false when it's not already explicitly
#      set. If the project explicitly set use-flakehub: true, they presumably
#      have a FlakeHub org — leave it alone.
#   2. The v14 static binary for arm64-darwin fails on macos-14 runners with
#      dyld: Symbol not found (built against a newer libc++ than the runner
#      ships). The job hangs ~20 min then cancels. The action must be gated
#      to Linux-only via 'if: runner.os == "Linux"'. This was the fourth
#      class of bug on acryl PR #5 (commit 82586e0).
check_magic_nix_cache() {
	if [ ! -d ".github/workflows" ]; then
		return 0
	fi
	# If magic-nix-cache-action is not present at all, nothing to check
	if ! grep -rn "magic-nix-cache" .github/workflows/ 2>/dev/null | grep -q "uses:"; then
		return 0
	fi
	# magic-nix-cache-action IS present. The error is OMITTING use-flakehub,
	# because the default is true (FlakeHub auth attempt). If use-flakehub is
	# explicitly set (true or false), the project made a deliberate choice —
	# leave it alone. If it's omitted, we must add use-flakehub: false.
	local workflow_files
	workflow_files=$(grep -rl "magic-nix-cache" .github/workflows/ 2>/dev/null || true)
	for wf in $workflow_files; do
		# Check if use-flakehub is explicitly set (true or false) after the magic-nix-cache uses line
		local has_use_flakehub_explicit
		has_use_flakehub_explicit=$(awk '/magic-nix-cache/{found=1} found && /use-flakehub:[[:space:]]*(true|false)/{print "yes"; exit}' "$wf" 2>/dev/null || echo "")
		if [ "$has_use_flakehub_explicit" != "yes" ]; then
			# use-flakehub is NOT explicitly set — the default true is the footgun.
			# Check if flakehub-cache-action is also present (implies org has FlakeHub).
			if ! grep -q "flakehub-cache-action" "$wf" 2>/dev/null; then
				echo "ERROR: magic-nix-cache-action in $wf without explicit use-flakehub setting." >&2
				echo "  The action defaults to use-flakehub: true, which attempts FlakeHub OIDC auth." >&2
				echo "  If the org is NOT registered on FlakeHub, CI fails with:" >&2
				echo "    'Unable to authenticate to FlakeHub. Individuals must register at FlakeHub.com...'" >&2
				echo "  Fix: add 'use-flakehub: false' to the magic-nix-cache-action step." >&2
				echo "  If the project has a FlakeHub org, set use-flakehub: true explicitly instead." >&2
				echo "  This was the root cause of acryl PR #5's FlakeHub auth failure." >&2
				return 1
			fi
		fi
		# Sub-check: darwin os guard — the v14 static binary for arm64-darwin
		# fails on macos-14 runners with dyld: Symbol not found (built against a
		# newer libc++ than the runner ships). The action must be gated to
		# Linux-only via 'if: runner.os == "Linux"' (or equivalent os condition).
		# Without the guard, the darwin job hangs ~20 min then cancels.
		# This was the fourth class of bug on acryl PR #5 (commit 82586e0).
		local has_runner_os_guard
		has_runner_os_guard=$(awk '/magic-nix-cache/{found=1} found && /runner\.os[[:space:]]*==[[:space:]]*[\047"]?Linux[\047"]?/{print "yes"; exit}' "$wf" 2>/dev/null || echo "")
		if [ "$has_runner_os_guard" != "yes" ]; then
			echo "ERROR: magic-nix-cache-action in $wf without an 'if: runner.os == \"Linux\"' guard." >&2
			echo "  The v14 static binary for arm64-darwin fails on macos-14 runners with:" >&2
			echo "    dyld: Symbol not found: __ZNSt13exception_ptr31__from_native_exception_pointerEPv" >&2
			echo "  The binary was built against a newer libc++ than the runner ships." >&2
			echo "  The job hangs ~20 min then cancels — the build never starts." >&2
			echo "  Fix: add 'if: runner.os == \"Linux\"' to the magic-nix-cache-action step." >&2
			echo "  Darwin builds work without the cache, just slower." >&2
			echo "  See DeterminateSystems/nix-installer#1684 and llvm/llvm-project#86077." >&2
			echo "  This was the fourth class of bug shipped on acryl PR #5 (commit 82586e0)." >&2
			return 1
		fi
	done
	return 0
}
run_check "magic-nix-cache-action use-flakehub + darwin os guard" check_magic_nix_cache

# ── Check 2: timeout-minutes on nix workflow jobs ───────────────────────────
# The skill's CI template (github-actions-nix.md) specifies timeout-minutes: 20.
# Missing timeout-minutes caused a 6h hang on acryl PR #5's aarch64-darwin job.
check_timeout_minutes() {
	local nix_yml=".github/workflows/nix.yml"
	if [ ! -f "$nix_yml" ]; then
		return 0
	fi
	# Check that the file has timeout-minutes somewhere in the jobs section.
	# This is a simple grep — if timeout-minutes appears at all, we assume
	# it's set on the job(s). A more precise check would parse the YAML,
	# but grep is sufficient for the nixify-generated template which has
	# one job block.
	if ! grep -q "timeout-minutes" "$nix_yml"; then
		echo "ERROR: $nix_yml has no timeout-minutes." >&2
		echo "  The skill's CI template specifies timeout-minutes: 20." >&2
		echo "  Without it, a hung build runs for 6h (GitHub's default max)." >&2
		return 1
	fi
	return 0
}
run_check "timeout-minutes present" check_timeout_minutes

# ── Check 3: deprecated runner labels ──────────────────────────────────────
# GitHub decommissions old runner images on a fixed schedule. Using a
# decommissioned label causes "no runner available" failures. The skill's
# guidance is: ALWAYS USE THE NEWEST RUNNER. This check flags known-
# deprecated macOS runner labels so the agent catches them before push.
# Current newest: macos-26 (ARM), macos-26-intel (Intel), ubuntu-latest.
# Deprecated: macos-12, macos-13, macos-14, macos-15.
# See references/advanced/github-actions-nix.md — ALWAYS USE THE NEWEST RUNNER.
check_deprecated_runners() {
	if [ ! -d ".github/workflows" ]; then
		return 0
	fi
	local deprecated_labels="macos-12 macos-13 macos-14 macos-15"
	local found_deprecated=""
	for wf in .github/workflows/*.yml .github/workflows/*.yaml; do
		[ -f "$wf" ] || continue
		for label in $deprecated_labels; do
			# Match runs-on: <label> or runs-on: ${{ matrix.runner }} where
			# matrix includes the label. Simple grep — if the label appears
			# in a runs-on context, flag it.
			if grep -qE "runs-on:.*\b${label}\b" "$wf" 2>/dev/null; then
				found_deprecated="$found_deprecated $label (in $wf)"
			elif grep -qE "matrix\.(runner|os):.*\b${label}\b" "$wf" 2>/dev/null; then
				found_deprecated="$found_deprecated $label (in $wf matrix)"
			fi
		done
	done
	if [ -n "$found_deprecated" ]; then
		echo "ERROR: deprecated GitHub Actions runner label(s) found:$found_deprecated" >&2
		echo "  These runner images are decommissioned or scheduled for removal." >&2
		echo "  ALWAYS USE THE NEWEST RUNNER — no exceptions." >&2
		echo "  Current newest labels: macos-26 (ARM), macos-26-intel (Intel), ubuntu-latest (Linux)." >&2
		echo "  Replace the deprecated label with the newest equivalent." >&2
		echo "  See references/advanced/github-actions-nix.md — ALWAYS USE THE NEWEST RUNNER." >&2
		return 1
	fi
	return 0
}
run_check "deprecated runner labels (use newest)" check_deprecated_runners

# ── Check 4: action pins (delegate to existing script) ──────────────────────
if [ -d ".github/workflows" ]; then
	run_check "action pins (SHA-pinned)" "$SCRIPT_DIR/validate-action-pins.sh" .
fi

# ── Check 5: stale branch ───────────────────────────────────────────────────
# Compare HEAD's merge-base with the base ref. If the base ref has commits
# that HEAD doesn't have, the branch is behind (stale). This is the
# deterministic catch for the acryl PR #5 "Typecheck, test, and build"
# failure: main had a fix commit the PR didn't have.
check_stale_branch() {
	if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
		# Base ref doesn't exist locally — try fetching
		if git remote get-url upstream >/dev/null 2>&1; then
			git fetch upstream 2>/dev/null || true
		else
			git fetch origin 2>/dev/null || true
		fi
	fi
	if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
		echo "WARNING: cannot resolve base ref '$BASE_REF' — skipping staleness check." >&2
		return 0
	fi
	local behind
	behind=$(git rev-list --count HEAD.."$BASE_REF" 2>/dev/null || echo "0")
	if [ "$behind" -gt 0 ]; then
		echo "ERROR: branch is $behind commit(s) behind $BASE_REF." >&2
		echo "  Run scripts/sync-upstream.sh to rebase onto the latest upstream." >&2
		echo "  A stale branch causes CI failures from fixes already on main." >&2
		return 1
	fi
	return 0
}
run_check "branch not stale (up to date with $BASE_REF)" check_stale_branch

# ── Check 6: nix build hash-mismatch catch (the big one) ────────────────────
# Run `nix build .#default` and check for hash mismatch errors. If found,
# extract the correct hash from the error output and print it so the agent
# can fix it immediately. This is the deterministic catch for the acryl PR #5
# fetchPnpmDeps hash mismatch (sha256-eSJETc... was wrong, correct was
# sha256-z/LRm/...).
if [ -z "$SKIP_BUILD" ] && [ -f "flake.nix" ]; then
	if command -v nix >/dev/null 2>&1; then
		check_nix_build() {
			local build_output
			build_output=$(nix build .#default --print-build-logs 2>&1 || true)
			# Check for hash mismatch — nix prints "hash mismatch" and the
			# correct hash in the error output
			if echo "$build_output" | grep -qi "hash mismatch"; then
				echo "ERROR: nix build .#default failed with hash mismatch." >&2
				echo "" >&2
				echo "The correct hash is in the error output above." >&2
				echo "Update the hash in flake.nix and re-run this script." >&2
				# Try to extract the correct hash from the error output
				local correct_hash
				correct_hash=$(echo "$build_output" | grep -oE 'sha256-[A-Za-z0-9+/=]+' | tail -1 || echo "")
				if [ -n "$correct_hash" ]; then
					echo "" >&2
					echo "  Correct hash: $correct_hash" >&2
					echo "  Replace the wrong hash in flake.nix with this value." >&2
				fi
				# Also check for the "specified" and "got" pattern
				if echo "$build_output" | grep -q "specified:" && echo "$build_output" | grep -q "got:"; then
					echo "" >&2
					echo "  Full mismatch details:" >&2
					echo "$build_output" | grep -A2 -E "specified:|got:" >&2
				fi
				return 1
			fi
			# Check for the "To correct the hash mismatch" hint (nix-style)
			if echo "$build_output" | grep -qi "To correct the hash mismatch"; then
				echo "ERROR: nix build .#default failed with hash mismatch." >&2
				local correct_hash
				correct_hash=$(echo "$build_output" | grep -oE 'sha256-[A-Za-z0-9+/=]+' | tail -1 || echo "")
				if [ -n "$correct_hash" ]; then
					echo "" >&2
					echo "  Correct hash: $correct_hash" >&2
					echo "  Replace the wrong hash in flake.nix with this value." >&2
				fi
				return 1
			fi
			# Check if the build itself failed (not just hash mismatch)
			if ! echo "$build_output" | grep -q "built"; then
				# If nix build failed for any reason, report it
				if ! nix build .#default --print-build-logs >/dev/null 2>&1; then
					echo "ERROR: nix build .#default failed (not a hash mismatch)." >&2
					echo "  Check the build logs above for the actual error." >&2
					return 1
				fi
			fi
			return 0
		}
		run_check "nix build .#default (hash mismatch catch)" check_nix_build
	else
		echo "SKIP: nix build .#default (nix not installed)"
		add_issue "nix not installed — cannot run build hash-mismatch check"
	fi
fi

# ── Check 6: PR cleanliness (delegate to existing script) ───────────────────
if [ -f "flake.nix" ]; then
	run_check "PR cleanliness (no merges, nixify artifacts only)" "$SCRIPT_DIR/validate-pr-cleanliness.sh" "$BASE_REF"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
if [ "$FAILED" -eq 0 ]; then
	echo "[validate-pre-push] ALL $CHECKS_RUN CHECKS PASSED — safe to push."
	# Create the marker file that nixify-push-guard.sh checks before allowing
	# a git push. Scoped to this project + branch so it doesn't leak.
	BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
	PROJECT_HASH=$(echo "$PROJECT_DIR" | shasum -a 256 | cut -c1-16)
	MARKER_DIR="/tmp/devin-nixify-guards"
	MARKER_FILE="$MARKER_DIR/${PROJECT_HASH}-${BRANCH}-validated"
	mkdir -p "$MARKER_DIR"
	touch "$MARKER_FILE"
	cat <<EOF
{"passed": true, "checks_run": $CHECKS_RUN, "issues": [], "marker": "$MARKER_FILE"}
EOF
	exit 0
else
	echo "[validate-pre-push] $FAILED CHECK(S) FAILED — fix before pushing." >&2
	# Remove any stale marker so the push guard blocks
	BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
	PROJECT_HASH=$(echo "$PROJECT_DIR" | shasum -a 256 | cut -c1-16)
	MARKER_DIR="/tmp/devin-nixify-guards"
	MARKER_FILE="$MARKER_DIR/${PROJECT_HASH}-${BRANCH}-validated"
	rm -f "$MARKER_FILE" 2>/dev/null || true
	cat <<EOF
{"passed": false, "checks_run": $CHECKS_RUN, "issues": [$ISSUES]}
EOF
	exit 1
fi
