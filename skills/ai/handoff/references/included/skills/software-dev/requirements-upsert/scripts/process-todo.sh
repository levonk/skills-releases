#!/usr/bin/env bash
# process-todo.sh — process a todo file: snapshot current, update current, archive todo to history
#
# Usage:
#   process-todo.sh --project <proj> --module <module> --slug <slug>
#   process-todo.sh --project <proj> --module <module> --slug <slug> --root <path>
#
# This script is called by execute-upsert after a feature that was described in
# a todo file has been implemented. It:
#
#   1. Snapshots the current/ requirement (if it exists) to history/ with the
#      pre-change version preserved.
#   2. Leaves the current/ file for the AI to update with the new behavior
#      (the todo's "Desired Behavior" section is the basis for the update).
#   3. Moves the todo file from todo/ to history/ with a timestamp prefix,
#      preserving the plan as part of the evolution log.
#   4. Regenerates INDEX.md and INDEX.html.
#
# If no current/ requirement exists yet (new requirement), step 1 is skipped —
# the AI creates the current/ file from the todo's "Desired Behavior" section.
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
TODO_FILE="$REQS_DIR/todo/$PROJECT/$MODULE/${PROJECT}_${MODULE}_${SLUG}.md"
CURRENT_FILE="$REQS_DIR/current/$PROJECT/$MODULE/${PROJECT}_${MODULE}_${SLUG}.md"

if [[ ! -f "$TODO_FILE" ]]; then
    echo "Error: todo file not found: $TODO_FILE" >&2
    exit 1
fi

# Timestamp
TIMESTAMP="$(date -u +%Y%m%d%H%M)"
YEAR="${TIMESTAMP:0:4}"
MONTH="${TIMESTAMP:4:2}"
TODAY="$(date -u +%Y-%m-%d)"

HISTORY_DIR="$REQS_DIR/history/$YEAR/$MONTH/$PROJECT/$MODULE"
mkdir -p "$HISTORY_DIR"

# Step 1: Snapshot current/ requirement if it exists (pre-change version)
if [[ -f "$CURRENT_FILE" ]]; then
    echo "[process-todo] Snapshotting current/ requirement (pre-change)..."
    "$SCRIPT_DIR/snapshot-requirement.sh" \
        --project "$PROJECT" --module "$MODULE" --slug "$SLUG" --root "$ROOT"
fi

# Step 2: Move todo file to history/ with timestamp prefix using git mv
# (preserves git history per repo rules — never plain rm for committed files)
TODO_HISTORY_FILE="$HISTORY_DIR/todo-${TIMESTAMP}-${SLUG}.md"

# Use git mv to preserve history, then edit the moved file in place
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git mv "$TODO_FILE" "$TODO_HISTORY_FILE"
    echo "[process-todo] git mv'd todo to: $TODO_HISTORY_FILE"
else
    # Not a git repo — fall back to plain mv
    mv "$TODO_FILE" "$TODO_HISTORY_FILE"
    echo "[process-todo] mv'd todo to: $TODO_HISTORY_FILE (not a git repo)"
fi

# Update the archived todo's frontmatter: set status to implemented,
# add date.implemented
{
    IN_FRONTMATTER=0
    ADDED_IMPLEMENTED=0
    while IFS= read -r line; do
        if [[ "$line" == "---" && $IN_FRONTMATTER -eq 0 ]]; then
            IN_FRONTMATTER=1
            echo "$line"
            continue
        fi
        if [[ "$line" == "---" && $IN_FRONTMATTER -eq 1 ]]; then
            IN_FRONTMATTER=0
            echo "$line"
            continue
        fi
        if [[ $IN_FRONTMATTER -eq 1 ]]; then
            # Replace status
            if [[ "$line" =~ ^status: ]]; then
                echo "status: implemented"
                continue
            fi
            # Add implemented date after the date: line
            if [[ "$line" =~ ^date: && $ADDED_IMPLEMENTED -eq 0 ]]; then
                echo "$line"
                echo "  implemented: \"$TODAY\""
                ADDED_IMPLEMENTED=1
                continue
            fi
        fi
        echo "$line"
    done < "$TODO_HISTORY_FILE"
} > "$TODO_HISTORY_FILE.tmp"

mv "$TODO_HISTORY_FILE.tmp" "$TODO_HISTORY_FILE"
echo "[process-todo] Updated frontmatter: status=implemented, date.implemented=$TODAY"

# Step 3: Regenerate INDEX
echo "[process-todo] Regenerating INDEX..."
"$SCRIPT_DIR/index-requirements.sh" --root "$ROOT"

echo ""
echo "[process-todo] Done."
echo ""
echo "Next steps for the AI:"
if [[ -f "$CURRENT_FILE" ]]; then
    echo "  1. Update $CURRENT_FILE to reflect the new behavior"
    echo "  2. Bump date.last-revised to $TODAY"
    echo "  3. Append a Change Log entry referencing the archived todo:"
    echo "       - $TODAY — Implemented planned change — [todo]($TODO_HISTORY_FILE)"
    echo "  4. Commit with: docs(reqs): process todo $PROJECT/$MODULE/$SLUG"
else
    echo "  1. Create $CURRENT_FILE fresh from references/requirement-template.md"
    echo "     - Do NOT copy the todo into current/ — current/ describes how the"
    echo "       system works NOW, with no plan baggage (no Desired Behavior, no"
    echo "       gap analysis, no status: implemented). One file per requirement,"
    echo "       pure description of current behavior."
    echo "     - Use the archived todo ($TODO_HISTORY_FILE) as reference material"
    echo "       for what was implemented, but write current/ as a clean Statement"
    echo "       (EARS pattern with SHALL), Rationale, Constraints, Verification."
    echo "     - Set status: active, date.created to $TODAY, date.last-revised to $TODAY"
    echo "     - Add a Change Log entry: $TODAY — Implemented from todo — [todo]($TODO_HISTORY_FILE)"
    echo "  2. Run snapshot-requirement.sh to create the initial history snapshot"
    echo "  3. Run index-requirements.sh to regenerate INDEX"
    echo "  4. Commit with: docs(reqs): process todo $PROJECT/$MODULE/$SLUG"
fi
