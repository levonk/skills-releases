#!/usr/bin/env bash
# snapshot-requirement.sh — copy a current requirement to history/ with a timestamp
#
# Usage:
#   snapshot-requirement.sh --project <proj> --module <module> --slug <slug>
#   snapshot-requirement.sh --project <proj> --module <module> --slug <slug> --root <path>
#
# Reads the current requirement file from
#   <root>/internal-docs/reqs/current/<proj>/<module>/<proj>_<module>_<slug>.md
# and writes a snapshot to
#   <root>/internal-docs/reqs/history/YYYY/MM/<proj>/<module>/req-YYYYMMDDHHmm-<slug>.md
#
# The snapshot gets status: superseded (or status: created if no prior history
# exists) and superseded-by pointing to the current file.
#
# --root defaults to the git repo root (or PWD if not in a git repo).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Args
PROJECT=""
MODULE=""
SLUG=""
ROOT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project) PROJECT="$2"; shift 2 ;;
        --module)  MODULE="$2";  shift 2 ;;
        --slug)    SLUG="$2";    shift 2 ;;
        --root)    ROOT="$2";    shift 2 ;;
        -h|--help)
            head -16 "$0" | tail -14
            exit 0
            ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$PROJECT" || -z "$MODULE" || -z "$SLUG" ]]; then
    echo "Error: --project, --module, and --slug are required" >&2
    exit 1
fi

# Resolve root
if [[ -z "$ROOT" ]]; then
    ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
fi

REQS_DIR="$ROOT/internal-docs/reqs"
CURRENT_FILE="$REQS_DIR/current/$PROJECT/$MODULE/${PROJECT}_${MODULE}_${SLUG}.md"

if [[ ! -f "$CURRENT_FILE" ]]; then
    echo "Error: current requirement not found: $CURRENT_FILE" >&2
    exit 1
fi

# Timestamp
TIMESTAMP="$(date -u +%Y%m%d%H%M)"
YEAR="${TIMESTAMP:0:4}"
MONTH="${TIMESTAMP:4:2}"
TODAY="$(date -u +%Y-%m-%d)"

HISTORY_DIR="$REQS_DIR/history/$YEAR/$MONTH/$PROJECT/$MODULE"
HISTORY_FILE="$HISTORY_DIR/req-${TIMESTAMP}-${SLUG}.md"

mkdir -p "$HISTORY_DIR"

# Check if any prior history exists for this requirement
PRIOR_HISTORY=$(find "$REQS_DIR/history" -path "*/$PROJECT/$MODULE/req-*-${SLUG}.md" 2>/dev/null | head -1)

if [[ -z "$PRIOR_HISTORY" ]]; then
    SNAPSHOT_STATUS="created"
else
    SNAPSHOT_STATUS="superseded"
fi

# Read the current file and modify frontmatter for the snapshot
# Preserve the body; change status and add superseded-by
CURRENT_CONTENT="$(cat "$CURRENT_FILE")"

# Write snapshot with updated frontmatter
{
    # Copy everything, but replace status and add superseded-by in frontmatter
    IN_FRONTMATTER=0
    ADDED_SUPERSEDED_BY=0
    while IFS= read -r line; do
        if [[ "$line" == "---" && $IN_FRONTMATTER -eq 0 ]]; then
            IN_FRONTMATTER=1
            echo "$line"
            continue
        fi
        if [[ "$line" == "---" && $IN_FRONTMATTER -eq 1 ]]; then
            if [[ $ADDED_SUPERSEDED_BY -eq 0 ]]; then
                echo "superseded-by: \"$CURRENT_FILE\""
            fi
            IN_FRONTMATTER=0
            echo "$line"
            continue
        fi
        if [[ $IN_FRONTMATTER -eq 1 ]]; then
            # Replace status
            if [[ "$line" =~ ^status: ]]; then
                echo "status: $SNAPSHOT_STATUS"
                continue
            fi
            # Add superseded date if status is superseded
            if [[ "$line" =~ ^date: && "$SNAPSHOT_STATUS" == "superseded" ]]; then
                echo "$line"
                echo "  superseded: \"$TODAY\""
                continue
            fi
        fi
        echo "$line"
    done <<< "$CURRENT_CONTENT"
} > "$HISTORY_FILE"

echo "Snapshot written: $HISTORY_FILE"
echo "Status: $SNAPSHOT_STATUS"
