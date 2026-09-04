#!/usr/bin/env bash
# sync-and-baseline.sh — deterministic START gate for nixify runs.
#
# Run this RIGHT AFTER cloning (Step 6) and BEFORE creating the feature branch
# (Step 9). It does two things that setup-branch.sh and sync-upstream.sh do NOT:
#
#   1. Syncs from upstream (fetch + rebase) — same as setup-branch.sh, but
#      runs BEFORE branch creation so the base is fresh.
#   2. Baselines upstream CI status — checks that the upstream default branch's
#      CI is currently green. If upstream CI is red, any CI failures on the PR
#      branch are ambiguous (are they our fault or pre-existing?). This is the
#      deterministic catch for the acryl PR #5 class of bug: the PR branch was
#      stale relative to main, main had a fix commit the PR didn't have, and
#      the PR's "Typecheck, test, and build" check failed on a test that was
#      already fixed on main. Baselineing CI green BEFORE starting work means
#      a later failure is unambiguously the PR's fault, not a stale base.
#
# Usage: sync-and-baseline.sh <owner>/<repo> [upstream_branch] [--verbose]
#
# Output (JSON on stdout):
#   {
#     "synced": true/false,
#     "remote": "upstream"|"origin",
#     "branch": "main",
#     "upstream_sha": "<40-char SHA>",
#     "ci_green": true/false,
#     "ci_check_url": "<url or null>",
#     "issues": ["..."]  // empty if all good
#   }
#
# Exit codes:
#   0 — synced and CI is green (safe to start work)
#   1 — sync failed (rebase conflict or dirty tree)
#   2 — synced but upstream CI is red (warn user, don't start work on a broken base)
#   3 — cannot determine CI status (network error, no gh auth) — non-blocking warning

set -euo pipefail

REPO="${1:?Usage: sync-and-baseline.sh <owner>/<repo> [upstream_branch] [--verbose]}"
UPSTREAM_BRANCH="${2:-main}"
VERBOSE=""
if [ "${3:-}" = "--verbose" ]; then
	VERBOSE="--verbose"
fi

ISSUES=""

# ── 1. Sync from upstream ───────────────────────────────────────────────────
if git remote get-url upstream >/dev/null 2>&1; then
	REMOTE=upstream
else
	REMOTE=origin
fi

if [ "$VERBOSE" = "--verbose" ]; then
	echo "[sync-and-baseline] Fetching $REMOTE and rebasing onto $REMOTE/$UPSTREAM_BRANCH..."
fi

git fetch "$REMOTE"

if ! git rebase "$REMOTE/$UPSTREAM_BRANCH" 2>/dev/null; then
	echo "error: rebase onto $REMOTE/$UPSTREAM_BRANCH failed." >&2
	echo "  - Dirty tree (unstaged changes): commit or stash, then re-run." >&2
	echo "  - Merge conflicts: resolve them, then 'git rebase --continue' and re-run." >&2
	# Abort the rebase so the tree is clean for re-run
	git rebase --abort 2>/dev/null || true
	cat <<EOF
{"synced": false, "remote": "$REMOTE", "branch": "$UPSTREAM_BRANCH", "upstream_sha": "", "ci_green": false, "ci_check_url": null, "issues": ["rebase failed — dirty tree or merge conflicts"]}
EOF
	exit 1
fi

UPSTREAM_SHA=$(git rev-parse "$REMOTE/$UPSTREAM_BRANCH")

if [ "$VERBOSE" = "--verbose" ]; then
	echo "[sync-and-baseline] Synced. Upstream tip: $UPSTREAM_SHA"
fi

# ── 2. Baseline upstream CI status ──────────────────────────────────────────
# Check that the upstream default branch's most recent CI run is green.
# This uses `gh` to query the repo's CI status. If gh is unavailable or the
# repo has no CI, we skip with a warning (exit 3, non-blocking).
CI_GREEN="false"
CI_URL="null"

if ! command -v gh >/dev/null 2>&1; then
	ISSUES="\"gh CLI not found — cannot baseline upstream CI status\""
	if [ "$VERBOSE" = "--verbose" ]; then
		echo "[sync-and-baseline] WARNING: gh not found — skipping CI baseline check." >&2
	fi
	cat <<EOF
{"synced": true, "remote": "$REMOTE", "branch": "$UPSTREAM_BRANCH", "upstream_sha": "$UPSTREAM_SHA", "ci_green": false, "ci_check_url": null, "issues": [$ISSUES], "ci_unknown": true}
EOF
	exit 3
fi

# Query the latest CI run on the upstream default branch.
# We look for the most recent completed run on the default branch and check
# its conclusion. If any required check failed, ci_green=false.
# The --jq filter extracts the latest run's status and HTML URL.
CI_JSON=$(gh run list --repo "$REPO" --branch "$UPSTREAM_BRANCH" --limit 1 --json status,conclusion,htmlURL,databaseId 2>/dev/null || echo "[]")

if [ "$CI_JSON" = "[]" ] || [ -z "$CI_JSON" ]; then
	ISSUES="\"no CI runs found on $UPSTREAM_BRANCH — repo may not have CI\""
	if [ "$VERBOSE" = "--verbose" ]; then
		echo "[sync-and-baseline] No CI runs found on $REMOTE/$UPSTREAM_BRANCH." >&2
	fi
	cat <<EOF
{"synced": true, "remote": "$REMOTE", "branch": "$UPSTREAM_BRANCH", "upstream_sha": "$UPSTREAM_SHA", "ci_green": false, "ci_check_url": null, "issues": [$ISSUES], "ci_unknown": true}
EOF
	exit 3
fi

# Extract conclusion from the latest run
CI_CONCLUSION=$(echo "$CI_JSON" | python3 -c "
import json, sys
try:
    runs = json.load(sys.stdin)
    if runs:
        print(runs[0].get('conclusion', ''))
    else:
        print('')
except Exception:
    print('')
" 2>/dev/null || echo "")

CI_URL=$(echo "$CI_JSON" | python3 -c "
import json, sys
try:
    runs = json.load(sys.stdin)
    if runs:
        url = runs[0].get('htmlURL', '')
        print('\"' + url + '\"' if url else 'null')
    else:
        print('null')
except Exception:
    print('null')
" 2>/dev/null || echo "null")

if [ "$CI_CONCLUSION" = "success" ]; then
	CI_GREEN="true"
	if [ "$VERBOSE" = "--verbose" ]; then
		echo "[sync-and-baseline] Upstream CI is GREEN."
	fi
elif [ "$CI_CONCLUSION" = "failure" ] || [ "$CI_CONCLUSION" = "cancelled" ]; then
	ISSUES="\"upstream CI on $UPSTREAM_BRANCH is $CI_CONCLUSION — do not start work on a broken base\""
	if [ "$VERBOSE" = "--verbose" ]; then
		echo "[sync-and-baseline] WARNING: Upstream CI is $CI_CONCLUSION." >&2
		echo "[sync-and-baseline] Do not start work on a broken base. Wait for upstream CI to go green." >&2
	fi
	cat <<EOF
{"synced": true, "remote": "$REMOTE", "branch": "$UPSTREAM_BRANCH", "upstream_sha": "$UPSTREAM_SHA", "ci_green": false, "ci_check_url": $CI_URL, "issues": [$ISSUES]}
EOF
	exit 2
else
	# conclusion might be "" (still running) or null
	ISSUES="\"upstream CI on $UPSTREAM_BRANCH has conclusion '$CI_CONCLUSION' (may be in progress)\""
	if [ "$VERBOSE" = "--verbose" ]; then
		echo "[sync-and-baseline] Upstream CI conclusion: '$CI_CONCLUSION' (may be in progress)." >&2
	fi
	cat <<EOF
{"synced": true, "remote": "$REMOTE", "branch": "$UPSTREAM_BRANCH", "upstream_sha": "$UPSTREAM_SHA", "ci_green": false, "ci_check_url": $CI_URL, "issues": [$ISSUES], "ci_unknown": true}
EOF
	exit 3
fi

# ── Success ─────────────────────────────────────────────────────────────────
cat <<EOF
{"synced": true, "remote": "$REMOTE", "branch": "$UPSTREAM_BRANCH", "upstream_sha": "$UPSTREAM_SHA", "ci_green": true, "ci_check_url": $CI_URL, "issues": []}
EOF
exit 0
