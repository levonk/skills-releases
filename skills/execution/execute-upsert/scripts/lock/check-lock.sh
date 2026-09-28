#!/usr/bin/env bash
# check-lock.sh — check whether a concurrency lock is active for a repo+scope.
#
# Scans the lock directory's current/ folder for lock files matching the
# given repo+scope key. Executes each matching lock file (they self-validate
# via PID + start-time and self-archive if stale). Prints the active lock
# file path on stdout, or nothing if no lock is active.
#
# Usage:
#   check-lock.sh --repo <path> --scope <id> [--namespace <ns>] [--json]
#   check-lock.sh --help
#
# Exit codes:
#   0 = no active lock (stdout empty)
#   0 = active lock found (stdout: lock file path)
#   1 = usage error

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

resolve_lock_dir() {
    local cache_base="${XDG_CACHE_HOME:-$HOME/.cache}"
    local default_dir="$cache_base/skills/locks/${NAMESPACE}"

    local skill_config="$SCRIPT_DIR/../skill-config.sh"
    if [ -x "$skill_config" ]; then
        local configured
        configured="$(SKILL_CONFIG_PATH="ai/ai-upsert" "$skill_config" get concurrency.lock_dir --default "" 2>/dev/null || echo "")"
        if [ -n "$configured" ]; then
            eval "LOCK_DIR=\"$configured\""
            return
        fi
    fi

    LOCK_DIR="$default_dir"
}

compute_lock_key() {
    local repo="$1" scope="$2"
    local input="$repo:$scope"
    if command -v shasum >/dev/null 2>&1; then
        printf '%s' "$input" | shasum -a 256 | cut -c1-16
    elif command -v sha256sum >/dev/null 2>&1; then
        printf '%s' "$input" | sha256sum | cut -c1-16
    else
        printf '%s' "$input" | cksum | awk '{printf "%016x", $1}'
    fi
}

REPO=""
SCOPE=""
NAMESPACE="shared"
JSON_OUTPUT=0

while [ "$#" -gt 0 ]; do
    case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --scope) SCOPE="$2"; shift 2 ;;
    --namespace) NAMESPACE="$2"; shift 2 ;;
    --json) JSON_OUTPUT=1; shift ;;
    -h | --help)
        sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
        exit 0
        ;;
    *)
        echo "check-lock.sh: unknown arg: $1" >&2
        exit 1
        ;;
    esac
done

if [ -z "$REPO" ] || [ -z "$SCOPE" ]; then
    echo "usage: check-lock.sh --repo <path> --scope <id> [--namespace <ns>] [--json]" >&2
    exit 1
fi

resolve_lock_dir
LOCK_KEY="$(compute_lock_key "$REPO" "$SCOPE")"
CURRENT_DIR="$LOCK_DIR/current"

ACTIVE_LOCKS=()
if [ -d "$CURRENT_DIR" ]; then
    for lock_file in "$CURRENT_DIR"/*-"${LOCK_KEY}".sh; do
        [ -f "$lock_file" ] || continue
        if bash "$lock_file" >/dev/null 2>&1; then
            ACTIVE_LOCKS+=("$lock_file")
        fi
    done
fi

if [ "${#ACTIVE_LOCKS[@]}" -eq 0 ]; then
    if [ "$JSON_OUTPUT" -eq 1 ]; then
        printf '{"status":"free","active_locks":[]}\n'
    fi
    exit 0
fi

if [ "$JSON_OUTPUT" -eq 1 ]; then
    locks_json=""
    for lock in "${ACTIVE_LOCKS[@]}"; do
        if [ -n "$locks_json" ]; then
            locks_json="$locks_json,\"$lock\""
        else
            locks_json="\"$lock\""
        fi
    done
    printf '{"status":"locked","active_locks":[%s]}\n' "$locks_json"
else
    for lock in "${ACTIVE_LOCKS[@]}"; do
        printf '%s\n' "$lock"
    done
fi
exit 0

