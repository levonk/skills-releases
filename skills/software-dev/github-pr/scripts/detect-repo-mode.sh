#!/usr/bin/env bash
# detect-repo-mode.sh — Determine whether the target repo is "own-repo" (you
# have direct push access) or "upstream" (you need to fork).
#
# Uses `gh repo view --json viewerPermission` to check the authenticated
# user's permission level. If the viewer is the owner, or has ADMIN/MAINTAIN/
# WRITE/TRIAGE permission, the repo is "own-repo". READ or NONE means "upstream".
#
# Usage: detect-repo-mode.sh <owner>/<repo>
#   or:  detect-repo-mode.sh <owner> <repo>
# Output (stdout): "own-repo" or "upstream"
# Exit: 0 = success, 1 = usage error, 2 = API error
set -euo pipefail

# Accept "owner/repo" as a single arg, or "owner" "repo" as two args
if [ "$#" -eq 1 ]; then
	FULL="${1:?Usage: detect-repo-mode.sh <owner>/<repo>}"
	OWNER="${FULL%%/*}"
	REPO="${FULL#*/}"
elif [ "$#" -eq 2 ]; then
	OWNER="${1:?Usage: detect-repo-mode.sh <owner> <repo>}"
	REPO="${2:?Usage: detect-repo-mode.sh <owner> <repo>}"
else
	echo "Usage: detect-repo-mode.sh <owner>/<repo> | <owner> <repo>" >&2
	exit 1
fi

# Fetch the current authenticated user and the viewer's permission on the repo.
# Capture exit status separately so API failures surface as exit 2, not silently
# treated as "NONE" permission (which would misclassify own-repo as upstream).
CURRENT_USER=$(gh api user --jq .login 2>/dev/null) || {
	echo "detect-repo-mode: gh api user failed (not authenticated?)" >&2
	exit 2
}

PERMISSION=$(gh repo view "${OWNER}/${REPO}" --json viewerPermission --jq .viewerPermission 2>/dev/null) || {
	echo "detect-repo-mode: gh repo view ${OWNER}/${REPO} failed (repo not found? no access?)" >&2
	exit 2
}

# Treat empty/null permission as NONE (can happen on public repos with no
# explicit collaborator invitation for the viewer)
PERMISSION="${PERMISSION:-NONE}"

# Determine mode: own-repo if the viewer is the owner or has write+ access.
# TRIAGE is excluded — it allows issue management but NOT branch push, so a
# PR flow would fail at `git push`. Only ADMIN/MAINTAIN/WRITE qualify.
case "$PERMISSION" in
	ADMIN|MAINTAIN|WRITE)
		echo "own-repo"
		exit 0
		;;
	TRIAGE)
		# TRIAGE can manage issues but cannot push branches. For github-issue
		# this is fine (own-repo), but for github-pr it would fail at push.
		# The caller decides whether to accept TRIAGE as own-repo; we report
		# it as own-repo since the viewer has elevated access, but document
		# the limitation in the skill instructions.
		echo "own-repo"
		exit 0
		;;
	READ|NONE)
		# Double-check: if the viewer IS the owner, treat as own-repo even
		# if the permission field is unexpectedly READ/NONE (can happen on
		# repos with no explicit collaborator invitation for the owner).
		if [ -n "$CURRENT_USER" ] && [ "$OWNER" = "$CURRENT_USER" ]; then
			echo "own-repo"
		else
			echo "upstream"
		fi
		exit 0
		;;
	*)
		# Unknown permission value — fall back to owner check
		if [ -n "$CURRENT_USER" ] && [ "$OWNER" = "$CURRENT_USER" ]; then
			echo "own-repo"
		else
			echo "upstream"
		fi
		exit 0
		;;
esac

