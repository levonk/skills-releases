#!/usr/bin/env bash
# Detect how the project creates GitHub releases and recommend a workflow trigger.
# Must be run from within the cloned repo (after fork-and-clone.sh).
# Usage: check-release-trigger.sh
# Output: JSON with trigger, reason, workflow_file, token_type
#
# The GITHUB_TOKEN trap: if releases are created with secrets.GITHUB_TOKEN,
# a release: published workflow will NEVER fire (GitHub does not start new
# runs from GITHUB_TOKEN-authored events). In that case, recommend either:
#   - release_workflow_job (Template C): add a job to the existing release
#     workflow. Preferred when the project owns its release workflow — fires
#     immediately after the release, no 24h delay, no separate workflow file.
#     When Template C is selected, also deploy Template A as a daily safety
#     net (catches Template C job failures, manual releases, and releases
#     from other workflows — the two do not conflict since Template A uses
#     hash comparison and exits with "nothing to do" if Template C already
#     updated the hashes).
#   - scheduled_lag_check (Template A): daily lag-check in a separate
#     workflow. Fallback when the release workflow is external/untouchable.

set -euo pipefail

WORKFLOWS_DIR=".github/workflows"

if [ ! -d "$WORKFLOWS_DIR" ]; then
	echo '{"trigger":"none","reason":"no .github/workflows directory found","workflow_file":null,"token_type":null}'
	exit 0
fi

# Find workflow files that contain "release create" or "gh release"
RELEASE_WF=""
for f in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
	[ -f "$f" ] || continue
	if grep -qiE 'gh release create|release create' "$f" 2>/dev/null; then
		RELEASE_WF="$f"
		break
	fi
done

if [ -z "$RELEASE_WF" ]; then
	echo '{"trigger":"none","reason":"no release-creation workflow found; releases may be created manually or externally","workflow_file":null,"token_type":null}'
	exit 0
fi

# Check what token the release-creation step uses.
# Look for GH_TOKEN or GITHUB_TOKEN env vars near the release create step.
TOKEN_TYPE="unknown"
if grep -qiE 'GH_TOKEN.*secrets\.GITHUB_TOKEN|GITHUB_TOKEN.*secrets\.GITHUB_TOKEN' "$RELEASE_WF" 2>/dev/null; then
	TOKEN_TYPE="github_token"
elif grep -qiE 'GH_TOKEN.*secrets\.[A-Z_]*TOKEN|GITHUB_TOKEN.*secrets\.[A-Z_]*TOKEN' "$RELEASE_WF" 2>/dev/null; then
	# Matches secrets.SOMETHING_TOKEN but not secrets.GITHUB_TOKEN — likely a PAT or App token.
	if grep -qiE 'secrets\.GITHUB_TOKEN' "$RELEASE_WF" 2>/dev/null; then
		# Has both GITHUB_TOKEN and other tokens — check which is near release create.
		# Default to GITHUB_TOKEN (the common case) unless a non-GITHUB_TOKEN is clearly
		# the one used for release creation.
		TOKEN_TYPE="github_token"
	else
		TOKEN_TYPE="pat_or_app"
	fi
fi

# Broad fallback: if the file mentions secrets.GITHUB_TOKEN anywhere, assume that.
if [ "$TOKEN_TYPE" = "unknown" ] && grep -qiE 'secrets\.GITHUB_TOKEN' "$RELEASE_WF" 2>/dev/null; then
	TOKEN_TYPE="github_token"
fi

case "$TOKEN_TYPE" in
github_token)
	# The project owns its release workflow (we found it in .github/workflows/).
	# Template C (release-workflow job) is preferred: fires immediately after
	# the release, no 24h delay, can cross-check against SHA256SUMS.txt.
	# The agent may fall back to Template A (scheduled lag-check) if the
	# project's contribution guidelines prohibit modifying the release workflow.
	TRIGGER="release_workflow_job"
	REASON="releases created with secrets.GITHUB_TOKEN in a project-owned workflow; add a hash-update job to the existing release workflow (Template C) and also deploy Template A as a daily safety net. Falls back to Template A alone if the release workflow is external or the project prohibits modifying it"
	;;
pat_or_app)
	TRIGGER="release_published"
	REASON="releases created with a PAT or App token; release:published events will trigger downstream workflows"
	;;
*)
	TRIGGER="scheduled_lag_check"
	REASON="could not determine token type; defaulting to scheduled lag-check (safe default — works regardless of release mechanism)"
	;;
esac

# Escape the workflow filename for JSON
WF_ESCAPED=$(echo "$RELEASE_WF" | jq -R .)

echo "{\"trigger\":\"$TRIGGER\",\"reason\":\"$REASON\",\"workflow_file\":$WF_ESCAPED,\"token_type\":\"$TOKEN_TYPE\"}"
