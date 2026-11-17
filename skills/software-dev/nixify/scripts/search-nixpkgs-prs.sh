#!/usr/bin/env bash
# search-nixpkgs-prs.sh — Pre-flight dedup search against the TARGET repo
# before opening ANY nixpkgs contribution: init, version bump, or fix.
#
# Why this exists: NixOS/nixpkgs is bot-heavy. r-ryantm/nix-update opens
# version-bump PRs for most packages continuously, so a hand-written
# duplicate is the most likely failure mode. Demonstrated 2026-11-07:
# NixOS/nixpkgs#576090 ("packer: 1.15.4 -> 1.16.1") was closed as a
# duplicate of r-ryantm's #545258, open since 2026-07-24. The project's
# own search-existing-work.sh only searches the PROJECT repo — it cannot
# catch duplicates in the target repo.
#
# Usage: search-nixpkgs-prs.sh <package> [--repo owner/name] [--version X.Y.Z] [--verbose]
#   package:  the nixpkgs attribute / upstream project name to search for
#   --repo:   target repo (default: NixOS/nixpkgs)
#   --version: target version (e.g. 1.16.1) — flags PRs whose title already
#             carries it, the strongest duplicate signal
#
# Output: JSON with:
#   repo, package, version     — echoed inputs
#   scoped_prs                 — PRs whose title is package-scoped
#                                ("<pkg>: ..." — the nixpkgs title convention),
#                                all states, with state/author/labels/url
#   open_scoped, merged_scoped — subsets of scoped_prs by state
#   bot_prs                    — scoped or body-matching PRs authored by known
#                                update bots (r-ryantm, *bot*, nix-update labels)
#   other_matches              — PRs matching the term in body but not title
#   issues                     — issues whose title mentions the package
#   recommendation             — coordinate | coordinate_version_match |
#                                skip_already_landed | investigate_merged |
#                                proceed | proceed_closed_only
#   reason                     — human-readable explanation of the recommendation
#
# Recommendation semantics:
#   coordinate              — an OPEN package-scoped PR exists; comment on or
#                             coordinate with it instead of opening a duplicate
#   coordinate_version_match— same, and its title already carries --version
#   skip_already_landed     — a MERGED package-scoped PR already carries
#                             --version (or a "-> <version>" bump to it)
#   investigate_merged      — merged package-scoped PRs exist but none match
#                             --version; read them before deciding
#   proceed_closed_only     — only closed (unmerged) scoped PRs exist
#   proceed                 — no package-scoped PRs found
#
# The script is a report, not a gate — it exits 0 whenever the searches
# complete, even with matches. The agent MUST present matches to the user
# before proceeding (see references/nixpkgs-fix-pr.md).
#
# Requires: gh, jq

set -euo pipefail

PACKAGE="${1:?Usage: search-nixpkgs-prs.sh <package> [--repo owner/name] [--version X.Y.Z] [--verbose]}"
shift

REPO="NixOS/nixpkgs"
VERSION=""
VERBOSE=""

while [ "$#" -gt 0 ]; do
	case "$1" in
	--repo)
		REPO="${2:?--repo requires owner/name}"
		shift 2
		;;
	--version)
		VERSION="${2:?--version requires a version}"
		shift 2
		;;
	--verbose)
		VERBOSE="1"
		shift
		;;
	*)
		echo "Unknown argument: $1" >&2
		echo "Usage: search-nixpkgs-prs.sh <package> [--repo owner/name] [--version X.Y.Z] [--verbose]" >&2
		exit 1
		;;
	esac
done

if [ -z "$PACKAGE" ]; then
	echo "ERROR: package name must not be empty" >&2
	exit 1
fi

if [ "$VERBOSE" = "1" ]; then
	echo "Searching ${REPO} for existing work on '${PACKAGE}'${VERSION:+ (target version ${VERSION})}..." >&2
fi

# --- Fetch PRs matching the package term (title + body) ---------------------
# gh search prs covers title and body in one call; fall back to gh pr list
# on older gh versions that lack it.
if [ "$VERBOSE" = "1" ]; then
	echo "  gh search prs --repo ${REPO} '${PACKAGE}'" >&2
fi
PRS_JSON=$(gh search prs --repo "$REPO" "$PACKAGE" --limit 60 \
	--json number,title,state,author,labels,url,updatedAt 2>/dev/null || true)
if [ -z "$PRS_JSON" ] || [ "$PRS_JSON" = "null" ]; then
	PRS_JSON=$(gh pr list --repo "$REPO" --search "$PACKAGE" --state all --limit 60 \
		--json number,title,state,author,labels,url,updatedAt 2>/dev/null || echo "[]")
fi

# --- Fetch issues whose title mentions the package --------------------------
if [ "$VERBOSE" = "1" ]; then
	echo "  gh issue list --repo ${REPO} --search '${PACKAGE} in:title' --state all" >&2
fi
ISSUES_JSON=$(gh issue list --repo "$REPO" --search "${PACKAGE} in:title" --state all --limit 30 \
	--json number,title,state,url 2>/dev/null || echo "[]")

# --- Classify and recommend -------------------------------------------------
# jq does the matching so the logic is testable and the output is one JSON
# document. title_scoped = the nixpkgs "<pkg>: ..." title convention.
# bot = known update-bot authors or bot/nix-update labels.
jq -n \
	--arg repo "$REPO" \
	--arg package "$PACKAGE" \
	--arg version "$VERSION" \
	--argjson prs "$PRS_JSON" \
	--argjson issues "$ISSUES_JSON" \
	'
def lc: ascii_downcase;
($package | lc) as $p |
($version | lc) as $v |
# gh search prs emits labels as [["a","b"]] while gh pr list emits
# [{"name":"a"}] — flatten both shapes to a list of strings.
def label_names: [(.labels // [])[]? |
	(if type == "array" then .[]
	 elif type == "object" then (.name // "")
	 else . end) | select(type == "string" and . != "")];
def is_bot:
	(((.author.login // "") | test("bot$|^r-ryantm$|nix-update"; "i"))
	 or ((label_names | map(lc) | any(test("bot|nix-update"; "i")))));
def has_version: ($v != "" and (.title | contains($v)));
def scoped: ((.title | lc | startswith($p + ":")) or (.title | lc | contains(": " + $p + ":")));
def slim: {number, title, state: (.state | lc), url, updatedAt,
	author: (.author.login // null), labels: label_names, bot: is_bot, has_version: has_version};

($prs | map(. + {state_lc: (.state | lc), title_scoped: scoped, is_bot: is_bot, has_version: has_version})) as $all |
($all | map(select(.title_scoped))) as $scoped_prs |
($all | map(select(.title_scoped | not))) as $unscoped_prs |
($scoped_prs | map(select(.state_lc == "open"))) as $open_scoped |
($scoped_prs | map(select(.state_lc == "merged"))) as $merged_scoped |
($scoped_prs | map(select(.state_lc == "closed"))) as $closed_scoped |
($scoped_prs + $unscoped_prs | map(select(.is_bot))) as $bot_prs |

(if ($open_scoped | length) > 0 then
	(if ($open_scoped | map(select(.has_version)) | length) > 0 then
		{recommendation: "coordinate_version_match",
		 reason: "An OPEN nixpkgs PR for \($package) already targets version \($version) — comment on it or coordinate with its author instead of opening a duplicate."}
	else
		{recommendation: "coordinate",
		 reason: "An OPEN package-scoped PR exists for \($package) in \($repo) — read it, comment, or coordinate before opening anything."}
	end)
elif ($merged_scoped | map(select(.has_version)) | length) > 0 then
	{recommendation: "skip_already_landed",
	 reason: "A MERGED package-scoped PR already carries version \($version) — the work has landed; do not open anything."}
elif ($merged_scoped | length) > 0 then
	{recommendation: "investigate_merged",
	 reason: "Merged package-scoped PRs exist for \($package) but none match version \($version) — read them to check whether the needed fix already shipped."}
elif ($closed_scoped | length) > 0 then
	{recommendation: "proceed_closed_only",
	 reason: "Only closed (unmerged) package-scoped PRs exist for \($package) — read why they closed before proceeding."}
else
	{recommendation: "proceed",
	 reason: "No package-scoped PRs found for \($package) in \($repo)."}
end) as $rec |

{
	repo: $repo,
	package: $package,
	version: (if $version == "" then null else $version end),
	prs_searched: ($prs | length),
	scoped_prs: ($scoped_prs | map(slim)),
	open_scoped: ($open_scoped | map(slim)),
	merged_scoped: ($merged_scoped | map(slim)),
	closed_scoped: ($closed_scoped | map(slim)),
	bot_prs: ($bot_prs | map(slim)),
	other_matches: ($unscoped_prs | map(slim) | .[0:15]),
	other_matches_count: ($unscoped_prs | length),
	issues: $issues,
	recommendation: $rec.recommendation,
	reason: $rec.reason
}'
