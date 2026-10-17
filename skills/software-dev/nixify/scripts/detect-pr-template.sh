#!/usr/bin/env bash
# Detect repo PR/issue templates and template-enforcement workflows.
# Usage: detect-pr-template.sh [project-dir] [--verbose]
#
# Requires bash 4+ (uses mapfile) — consistent with the other nixify
# scripts; macOS ships bash 3.2, so invoke via devbox or a modern bash.
#
# Repos may carry a pull request template (.github/pull_request_template.md,
# PULL_REQUEST_TEMPLATE.md, .github/PULL_REQUEST_TEMPLATE/) and/or a
# pull_request_target workflow that enforces body sections (a "PR Policy"
# check). A generated PR body that ignores the repo's template gets blocked
# by the enforcement workflow — FluidVoice's PR Policy check held a nixify
# PR ~a day for missing "Screenshots / Video" and attestation checkboxes.
#
# Run before generating the orientation issue (Step 24) and PR body
# (Step 27). When templates exist, the generated body must follow the
# repo's structure — fill nixify's content into the repo's sections and
# answer every checkbox/attestation truthfully.
#
# Output: JSON with:
#   - pr_template_files: array of PR template paths found
#   - issue_template_files: array of issue template paths found
#   - enforcement_workflows: array of workflow paths that appear to enforce
#     PR body sections
#   - has_pr_template / has_issue_templates / has_template_enforcement: bools
#   - action: "conform" (repo template exists — follow its structure) or
#     "standalone" (no template — generate a standalone body)
#
# Use --verbose for a human-readable summary after the JSON.

set -euo pipefail

DIR="${1:-.}"
VERBOSE=""
if [ "${2:-}" = "--verbose" ] || [ "${1:-}" = "--verbose" ]; then
	VERBOSE="--verbose"
	[ "${1:-}" = "--verbose" ] && DIR="."
fi

if [ ! -d "$DIR" ]; then
	echo "error: directory '$DIR' not found" >&2
	exit 1
fi

command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 1; }

# ── PR/issue template files ───────────────────────────────────────────────
# GitHub resolves PR templates from .github/, docs/, and the repo root,
# including the multi-template .github/PULL_REQUEST_TEMPLATE/ directory.
# Same locations for issue templates (file or ISSUE_TEMPLATE/ directory).
mapfile -t pr_templates < <(
	{
		find "$DIR" "$DIR/.github" "$DIR/docs" -maxdepth 3 -type f \
			-iname '*pull_request_template*' 2>/dev/null || true
		# Multi-template directory: files inside *PULL_REQUEST_TEMPLATE*/ dirs.
		find "$DIR" "$DIR/.github" "$DIR/docs" -maxdepth 4 \
			-ipath '*pull_request_template*' -type f 2>/dev/null || true
	} | sort -u
)
mapfile -t issue_templates < <(
	{
		find "$DIR" "$DIR/.github" "$DIR/docs" -maxdepth 3 -type f \
			-iname '*issue_template*' 2>/dev/null || true
		# Multi-template directory: files inside *ISSUE_TEMPLATE*/ dirs.
		find "$DIR" "$DIR/.github" "$DIR/docs" -maxdepth 4 \
			-ipath '*issue_template*' -type f 2>/dev/null || true
	} | sort -u
)

# find returns literal "./path" or "<dir>/path"; normalize to repo-relative.
normalize() {
	local p="$1"
	p="${p#"$DIR"/}"
	p="${p#./}"
	echo "$p"
}

pr_json="[]"
for f in "${pr_templates[@]}"; do
	[ -z "$f" ] && continue
	pr_json=$(echo "$pr_json" | jq --arg p "$(normalize "$f")" '. + [$p]')
done

issue_json="[]"
for f in "${issue_templates[@]}"; do
	[ -z "$f" ] && continue
	issue_json=$(echo "$issue_json" | jq --arg p "$(normalize "$f")" '. + [$p]')
done

# ── Template-enforcement workflows ─────────────────────────────────────────
# A workflow is a suspected enforcement check when it (a) triggers on
# pull_request_target (write-capable check workflows live there), or
# (b) reads github.event.pull_request.body to validate required sections
# or attestation checkboxes.
enf_json="[]"
shopt -s nullglob
wf_files=("$DIR"/.github/workflows/*.yml "$DIR"/.github/workflows/*.yaml)
shopt -u nullglob
if [ "${#wf_files[@]}" -gt 0 ]; then
	for wf in "${wf_files[@]}"; do
		[ -f "$wf" ] || continue
		# Anchor the trigger match so a commented-out `# pull_request_target`
		# line doesn't count as an enforcement workflow.
		if grep -qE '^\s*pull_request_target\s*:' "$wf" ||
			{ grep -qE '^\s*pull_request\s*:' "$wf" &&
			  grep -qE 'pull_request\.body|pull\.request\.body' "$wf"; }; then
			enf_json=$(echo "$enf_json" | jq --arg p "$(normalize "$wf")" '. + [$p]')
		fi
	done
fi

has_pr="false"; [ "$(echo "$pr_json" | jq 'length')" -gt 0 ] && has_pr="true"
has_issue="false"; [ "$(echo "$issue_json" | jq 'length')" -gt 0 ] && has_issue="true"
has_enf="false"; [ "$(echo "$enf_json" | jq 'length')" -gt 0 ] && has_enf="true"

action="standalone"
{ [ "$has_pr" = "true" ] || [ "$has_enf" = "true" ]; } && action="conform"

result=$(jq -n \
	--argjson pr "$pr_json" \
	--argjson issue "$issue_json" \
	--argjson enf "$enf_json" \
	--argjson has_pr "$has_pr" \
	--argjson has_issue "$has_issue" \
	--argjson has_enf "$has_enf" \
	--arg action "$action" \
	'{pr_template_files: $pr, issue_template_files: $issue, enforcement_workflows: $enf, has_pr_template: $has_pr, has_issue_templates: $has_issue, has_template_enforcement: $has_enf, action: $action, note: "action=conform means the generated issue/PR body must follow the repo template structure and answer every checkbox/attestation truthfully — do not omit required sections."}')

if [ -n "$VERBOSE" ]; then
	echo "$result" | jq .
	echo "[detect-pr-template] action=$action (pr_templates=$(echo "$pr_json" | jq 'length'), issue_templates=$(echo "$issue_json" | jq 'length'), enforcement_workflows=$(echo "$enf_json" | jq 'length'))"
else
	echo "$result" | jq -c .
fi
