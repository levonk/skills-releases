#!/usr/bin/env bash
# release-lock.sh — release a Phase 4 concurrency lock acquired by acquire-lock.sh.
#
# Moves the lock file from current/ to archive/YYYY/MM/ and records the
# completion timestamp. The lock file itself is preserved in the archive
# for audit purposes (it remains a self-validating script, but is no longer
# scanned by new runs because it lives outside current/).
#
# Usage:
#   release-lock.sh --lock-file <path>
#   release-lock.sh --lock-file <path> [--json]
#   release-lock.sh --help
#
# Exit codes:
#   0 = lock released (archived)
#   1 = usage error or lock file not found

set -euo pipefail

# --- Argument parsing ---
LOCK_FILE=""
JSON_OUTPUT=0

while [ "$#" -gt 0 ]; do
    case "$1" in
    --lock-file) LOCK_FILE="$2"; shift 2 ;;
    --json) JSON_OUTPUT=1; shift ;;
    -h | --help)
        sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
        exit 0
        ;;
    *)
        echo "release-lock.sh: unknown arg: $1" >&2
        exit 1
        ;;
    esac
done

if [ -z "$LOCK_FILE" ]; then
    echo "usage: release-lock.sh --lock-file <path> [--json]" >&2
    exit 1
fi

if [ ! -f "$LOCK_FILE" ]; then
    echo "release-lock.sh: lock file not found: $LOCK_FILE" >&2
    exit 1
fi

# --- Resolve archive directory ---
# The lock file's LOCK_DIR is embedded in the script. Extract it.
LOCK_DIR="$(grep '^LOCK_DIR=' "$LOCK_FILE" | head -1 | sed "s/^LOCK_DIR='//; s/'$//" 2>/dev/null || echo "")"
if [ -z "$LOCK_DIR" ]; then
    # Fallback: derive from the lock file's parent (current/)
    LOCK_DIR="$(cd "$(dirname "$LOCK_FILE")/.." && pwd)"
fi

ARCHIVE_DIR="$LOCK_DIR/archive/$(date +%Y/%m)"
mkdir -p "$ARCHIVE_DIR"

ARCHIVE_PATH="$ARCHIVE_DIR/$(basename "$LOCK_FILE")"

# Move the lock file to the archive
mv "$LOCK_FILE" "$ARCHIVE_PATH"

# Append a completion record to the archived lock file
{
    echo ""
    echo "# Released: $(date +%Y-%m-%dT%H:%M:%S%z)"
    echo "# Exit: normal"
} >> "$ARCHIVE_PATH"

if [ "$JSON_OUTPUT" -eq 1 ]; then
    printf '{"status":"released","archive_path":"%s"}\n' "$ARCHIVE_PATH"
else
    printf '%s\n' "$ARCHIVE_PATH"
fi
exit 0
