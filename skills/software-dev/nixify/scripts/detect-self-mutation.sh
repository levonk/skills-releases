#!/usr/bin/env bash
# Detect in-place self-mutation paths in a project's source tree.
# Usage: detect-self-mutation.sh [project-dir] [--verbose]
#
# When a flake wraps a prebuilt binary (flake_type=prebuilt_tarball or
# nixpkgs_override_attrs), the packaged code runs out of the read-only
# Nix store. Any self-updater, in-app rollback, or self-repair path that
# writes beside the install location fails at runtime — always, for every
# user. This script greps the source tree for the signals of in-place
# mutation (update check, install, rollback, self-repair, delta patchers,
# Sparkle/Squirrel/electron-updater frameworks, bundle-path writes) so the
# agent can enumerate ALL of them — not just the first one found.
#
# The agent must triage each hit: determine whether the write target
# resolves to the install prefix (fails in /nix/store) vs a user-writable
# directory (~/Library/Application Support, ~/.config, %APPDATA% — fine;
# model/asset downloads to home are NOT a problem).
#
# Output: JSON with:
#   - hits: array of { signal, file, line, snippet }
#   - signals_checked: array of signal names
#   - hit_count: number of hits
#   - truncated: true when a signal's hit list was capped at MAX_HITS
#   - has_hits: true when any signal matched
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

MAX_HITS=50

# ── Signal table ───────────────────────────────────────────────────────────
# Format: signal_name|extended-regex (matched case-insensitively)
# Keep this aligned with references/architecture-analysis.md —
# "Prebuilt Apps with In-Place Self-Mutation".
SIGNALS=(
	"updater|updater"
	"auto-update|auto.?updat|automatic.?updat"
	"sparkle|sparkle|SPUUpdater|SUUpdater|appcast"
	"squirrel|squirrel|Update\\.exe"
	"electron-updater|electron.?updater"
	"rollback|roll.?back"
	"self-replace|self.?replac|self.?updat"
	"swap-relaunch|swap.*relaunch|relaunch"
	"bundle-mutation|bundleURL|installLocation|Bundle\\.main.*(writ|mov|replac|copy|delet|trash)"
	"delta-patch|delta.?patch|bsdiff|bspatch"
	"self-repair|self.?repair"
	"update-check|check.?for.?updat|update.?check"
)

# ── Scan exclusions ────────────────────────────────────────────────────────
# Dependency trees, build output, and lockfiles produce noise, not signal.
EXCLUDE_DIRS=(
	.git node_modules vendor dist build target out .devbox result result-*
	coverage .next .nuxt __pycache__ .cargo .idea .vscode .direnv
)
EXCLUDE_FILES=(
	'*.lock' '*-lock.json' 'package-lock.json' 'pnpm-lock.yaml' 'yarn.lock'
	'bun.lock' 'bun.lockb' 'Cargo.lock' 'go.sum' 'poetry.lock' 'Gemfile.lock'
	'composer.lock' '*.min.js' '*.min.css' '*.map'
)

grep_args=(-rEniI)
for d in "${EXCLUDE_DIRS[@]}"; do
	grep_args+=("--exclude-dir=$d")
done
for f in "${EXCLUDE_FILES[@]}"; do
	grep_args+=("--exclude=$f")
done

hits_file=$(mktemp)
trap 'rm -f "$hits_file"' EXIT

signal_names=()
truncated="false"
files_scanned=0

# Count scanned files once (all files grep would consider).
find_args=()
for d in "${EXCLUDE_DIRS[@]}"; do
	find_args+=(-not -path "*/$d/*")
done
for f in "${EXCLUDE_FILES[@]}"; do
	find_args+=(-not -name "$f")
done
files_scanned=$(find "$DIR" -type f "${find_args[@]}" 2>/dev/null | wc -l | tr -d ' ')

for entry in "${SIGNALS[@]}"; do
	sig="${entry%%|*}"
	pat="${entry#*|}"
	signal_names+=("$sig")
	count=0
	# grep exits 1 on no matches; tolerate that.
	while IFS= read -r line; do
		[ -z "$line" ] && continue
		count=$((count + 1))
		if [ "$count" -gt "$MAX_HITS" ]; then
			truncated="true"
			break
		fi
		file="${line%%:*}"
		rest="${line#*:}"
		lineno="${rest%%:*}"
		snippet="${rest#*:}"
		# Strip leading whitespace and tabs (JSON/TSV safety), cap length.
		# cut -b + iconv -c avoids emitting an invalid UTF-8 tail if the cap
		# lands inside a multibyte character (jq -R rejects invalid UTF-8).
		snippet=$(printf '%s\n' "$snippet" | sed 's/^[[:space:]]*//' | tr '\t' ' ' \
			| cut -b1-200 | iconv -f UTF-8 -t UTF-8 -c 2>/dev/null)
		file="${file#"$DIR"/}"
		printf '%s\t%s\t%s\t%s\n' "$sig" "$file" "$lineno" "$snippet" >>"$hits_file"
	done < <(grep "${grep_args[@]}" "$pat" "$DIR" 2>/dev/null || true)
done

# ── Build JSON output ──────────────────────────────────────────────────────
signal_names_json=$(printf '%s\n' "${signal_names[@]}" | jq -R . | jq -s .)

if [ ! -s "$hits_file" ]; then
	hits_json="[]"
	hit_count=0
else
	# One hit per (file,line) — merge signals that matched the same line.
	hits_json=$(jq -R -s '
		split("\n") | map(select(length > 0))
		| map(split("\t") | {signal: .[0], file: .[1], line: (.[2] | tonumber? // 0), snippet: .[3]})
		| group_by(.file + ":" + (.line | tostring))
		| map({
			file: .[0].file,
			line: .[0].line,
			snippet: .[0].snippet,
			signals: ([.[].signal] | unique)
		})
		| sort_by(.file, .line)
	' "$hits_file")
	hit_count=$(echo "$hits_json" | jq 'length')
fi

has_hits="false"
[ "$hit_count" -gt 0 ] && has_hits="true"

result=$(jq -n \
	--argjson hits "$hits_json" \
	--argjson signals "$signal_names_json" \
	--argjson hit_count "$hit_count" \
	--argjson files_scanned "$files_scanned" \
	--argjson truncated "$truncated" \
	--argjson has_hits "$has_hits" \
	'{hits: $hits, signals_checked: $signals, hit_count: $hit_count, files_scanned: $files_scanned, truncated: $truncated, has_hits: $has_hits, triage: "for each hit, determine whether the write target resolves to the install prefix (fails in /nix/store) vs a user-writable dir (~/Library/Application Support, ~/.config, %APPDATA% — fine; downloads to home are NOT a problem). If any install-prefix mutation exists, the PR must include a source patch guarding ALL mutation paths behind a store-path check."}')

if [ -n "$VERBOSE" ]; then
	echo "$result" | jq .
	echo "[detect-self-mutation] Scanned $files_scanned files across ${#signal_names[@]} signals: $hit_count hit(s)."
	if [ "$hit_count" -gt 0 ]; then
		echo "[detect-self-mutation] Triage each hit: install-prefix writes fail in /nix/store; user-dir writes are fine."
		echo "[detect-self-mutation] If any install-prefix mutation exists, gate ALL mutation paths behind a store-path guard in the PR."
	fi
else
	echo "$result" | jq -c .
fi
