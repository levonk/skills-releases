#!/usr/bin/env bash
# validate-ledger.sh — check requirements ledger consistency across four states
#
# Usage:
#   validate-ledger.sh
#   validate-ledger.sh --root <path>
#
# Checks:
#   1. Every current requirement has at least one history snapshot
#   2. No orphan history entries (every snapshot links to a current file)
#   3. Frontmatter dates are consistent
#   4. INDEX.md exists
#   5. EARS pattern validation (every current Statement/Constraint uses SHALL
#      + a valid EARS template; see lint-ears.py)
#   6. Proposed/todo files have valid status fields
#   7. Todo files have a ready date set
#
# Exit 0 if all checks pass, exit 1 on errors.

set -euo pipefail

ROOT=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --root) ROOT="$2"; shift 2 ;;
        -h|--help)
            head -12 "$0" | tail -10
            exit 0
            ;;
        *) echo "Unknown arg: $1" >&2; exit 1 ;;
    esac
done

if [[ -z "$ROOT" ]]; then
    ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
fi

REQS_DIR="$ROOT/internal-docs/reqs"
PROPOSED_DIR="$REQS_DIR/proposed"
TODO_DIR="$REQS_DIR/todo"
CURRENT_DIR="$REQS_DIR/current"
HISTORY_DIR="$REQS_DIR/history"
INDEX_FILE="$REQS_DIR/INDEX.md"

ERRORS=0
WARNINGS=0

if [[ ! -d "$CURRENT_DIR" ]]; then
    echo "Error: no requirements directory at $CURRENT_DIR" >&2
    exit 1
fi

# Helper: extract frontmatter field
extract_fm() {
    awk -v field="$2" '
        /^---$/{c++; next}
        c==1 && $0 ~ "^"field":" {
            gsub(/^[^:]+:[[:space:]]*"?/, "")
            gsub(/"$/, "")
            print
            exit
        }
        c==1 && $0 ~ "^[[:space:]]+"field":" {
            gsub(/^[[:space:]]*[^:]+:[[:space:]]*"?/, "")
            gsub(/"$/, "")
            print
            exit
        }
    ' "$1"
}

# Check 1: Every current requirement has at least one history snapshot
while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue

    rel="${filepath#$CURRENT_DIR/}"
    proj="${rel%%/*}"
    rest="${rel#*/}"
    module="${rest%%/*}"
    filename="${rest#*/}"
    slug="${filename#${proj}_${module}_}"
    slug="${slug%.md}"

    snapshot_count=$(find "$HISTORY_DIR" -path "*/$proj/$module/req-*-${slug}.md" 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$snapshot_count" -eq 0 ]]; then
        echo "ERROR: current requirement $proj/$module/$slug has no history snapshot (missing creation snapshot)"
        ERRORS=$((ERRORS + 1))
    fi
done < <(find "$CURRENT_DIR" -name '*.md' -type f)

# Check 2: No orphan history entries (both req- snapshots and todo- archives)
while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue

    rel="${filepath#$HISTORY_DIR/}"
    rest="${rel#*/}"
    rest="${rest#*/}"
    proj="${rest%%/*}"
    rest="${rest#*/}"
    module="${rest%%/*}"
    filename="${rest#*/}"

    # Parse slug based on file type: req-YYYYMMDDHHmm-{slug}.md or todo-YYYYMMDDHHmm-{slug}.md
    if [[ "$filename" == req-* ]]; then
        slug="${filename#req-*-}"
    elif [[ "$filename" == todo-* ]]; then
        slug="${filename#todo-*-}"
    else
        slug="${filename%.md}"
    fi
    slug="${slug%.md}"

    current_file="$CURRENT_DIR/$proj/$module/${proj}_${module}_${slug}.md"
    if [[ ! -f "$current_file" ]]; then
        echo "WARNING: history entry $filepath has no corresponding current file (orphan)"
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$HISTORY_DIR" \( -name 'req-*.md' -o -name 'todo-*.md' \) -type f 2>/dev/null)

# Check 3: Frontmatter date consistency (current/ files)
while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue

    created="$(extract_fm "$filepath" "created")"
    last_revised="$(extract_fm "$filepath" "last-revised")"
    status="$(extract_fm "$filepath" "status")"
    superseded="$(extract_fm "$filepath" "superseded")"

    if [[ -n "$created" && -n "$last_revised" ]]; then
        if [[ "$last_revised" < "$created" ]]; then
            echo "ERROR: $filepath — last-revised ($last_revised) is before created ($created)"
            ERRORS=$((ERRORS + 1))
        fi
    fi

    if [[ "$status" == "superseded" && -z "$superseded" ]]; then
        echo "ERROR: $filepath — status is superseded but date.superseded is not set"
        ERRORS=$((ERRORS + 1))
    fi

    if [[ "$status" != "superseded" && -n "$superseded" ]]; then
        echo "WARNING: $filepath — date.superseded is set but status is $status"
        WARNINGS=$((WARNINGS + 1))
    fi
done < <(find "$CURRENT_DIR" -name '*.md' -type f)

# Check 4: INDEX.md exists
if [[ ! -f "$INDEX_FILE" ]]; then
    echo "WARNING: INDEX.md does not exist — run index-requirements.sh to generate it"
    WARNINGS=$((WARNINGS + 1))
fi

# Check 5: EARS pattern validation
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINT_EARS="$SCRIPT_DIR/lint-ears.py"
if [[ -f "$LINT_EARS" ]] && command -v uv >/dev/null 2>&1; then
    echo "Check 5: EARS pattern validation..."
    if ! uv run --script "$LINT_EARS" --root "$ROOT"; then
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "WARNING: lint-ears.py or uv not available — skipping EARS validation (run 'uv run --script $LINT_EARS --root \"$ROOT\"' manually)"
    WARNINGS=$((WARNINGS + 1))
fi

# Check 6: Proposed/todo files have valid status fields
if [[ -d "$PROPOSED_DIR" ]]; then
    while IFS= read -r filepath; do
        [[ -z "$filepath" ]] && continue
        status="$(extract_fm "$filepath" "status")"
        if [[ "$status" != "proposed" ]]; then
            echo "WARNING: $filepath — in proposed/ but status is '$status' (expected 'proposed')"
            WARNINGS=$((WARNINGS + 1))
        fi
    done < <(find "$PROPOSED_DIR" -name '*.md' -type f)
fi

if [[ -d "$TODO_DIR" ]]; then
    while IFS= read -r filepath; do
        [[ -z "$filepath" ]] && continue
        status="$(extract_fm "$filepath" "status")"
        if [[ "$status" != "todo" ]]; then
            echo "WARNING: $filepath — in todo/ but status is '$status' (expected 'todo')"
            WARNINGS=$((WARNINGS + 1))
        fi
        # Check 7: Todo files should have a ready date
        ready="$(extract_fm "$filepath" "ready")"
        if [[ -z "$ready" ]]; then
            echo "WARNING: $filepath — todo file has no date.ready set (should be moved to proposed/ if not ready)"
            WARNINGS=$((WARNINGS + 1))
        fi
    done < <(find "$TODO_DIR" -name '*.md' -type f)
fi

# Summary
echo ""
echo "Validation complete: $ERRORS error(s), $WARNINGS warning(s)"

if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi
exit 0
