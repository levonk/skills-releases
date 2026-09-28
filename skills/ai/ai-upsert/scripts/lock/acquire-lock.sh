#!/usr/bin/env bash
# acquire-lock.sh — acquire a concurrency lock for quality gate exclusion.
#
# Shared lock primitive used by execute-upsert (Phase 6 quality gate),
# git-repository-management (pre-commit quality gate), and ai-upsert
# (Phase 4 quality gate).
#
# Lock scope: per-repo+scope. The lock key is derived from the target repo
# path and the scope identifier (skill name, feature slug, etc.). Two runs
# targeting the same repo and the same scope cannot overlap in the quality
# gate; runs targeting different repos or different scopes proceed
# concurrently.
#
# Lock files are self-validating executable scripts. Each lock file stores
# the PID and start-time of the process that acquired it. When executed,
# the lock file checks whether that PID is still alive AND whether the
# start-time matches (guards against PID reuse). If the PID is dead or the
# start-time differs, the lock file self-archives to archive/YYYY/MM/.
#
# Non-interactive default (when a lock is active and no user can be asked):
#   skip the quality gate, commit to the story branch, create the PR, do NOT
#   merge. This script exits with status 2 and prints "LOCKED:<path>" so the
#   caller can implement that policy. Override the default with:
#   QUALITY_LOCK_ACTION=wait|kill|cancel|force
#
# Usage:
#   acquire-lock.sh --repo <repo-path> --scope <scope-id> --slug <run-slug> [--namespace <ns>] [--pid <pid>] [--start <start-time>]
#   acquire-lock.sh --help
#
# Options:
#   --repo <path>       Target repository root (required)
#   --scope <id>        Scope being locked — skill name, feature slug, etc. (required)
#   --slug <slug>       Run slug for the lock filename (required)
#   --namespace <ns>    Lock directory namespace (default: "shared")
#   --pid <pid>         PID to lock on (default: $$ — the calling shell)
#   --start <time>      Process start-time (default: auto-detected via ps)
#   --action <mode>     Override non-interactive action: wait|kill|cancel|force
#   --json              Emit JSON on stdout for script callers
#
# Exit codes:
#   0 = lock acquired (prints lock file path on stdout)
#   2 = lock is active (prints LOCKED:<path> on stdout; caller skips quality gate)
#   3 = lock action failed (kill failed, wait timed out)
#   1 = usage error

set -euo pipefail

# --- Path resolution ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Lock directory resolution ---
# Default: ${XDG_CACHE_HOME:-~/.cache}/skills/locks/<namespace>/
# Override via skill-config.sh key: concurrency.lock_dir
resolve_lock_dir() {
    local cache_base="${XDG_CACHE_HOME:-$HOME/.cache}"
    local default_dir="$cache_base/skills/locks/${NAMESPACE}"

    # Try skill-config.sh if available
    local skill_config="$SCRIPT_DIR/../skill-config.sh"
    if [ -x "$skill_config" ]; then
        local configured
        configured="$(SKILL_CONFIG_PATH="ai/ai-upsert" "$skill_config" get concurrency.lock_dir --default "" 2>/dev/null || echo "")"
        if [ -n "$configured" ]; then
            # Expand ~ and env vars
            eval "LOCK_DIR=\"$configured\""
            return
        fi
    fi

    LOCK_DIR="$default_dir"
}

# --- Lock key computation ---
# Key = sha256(repo-path + ":" + scope), truncated to 16 hex chars.
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

# --- Process start-time detection ---
get_start_time() {
    local pid="$1"
    ps -p "$pid" -o lstart= 2>/dev/null || echo ""
}

# --- Scan current/ for active locks with the same key ---
scan_active_locks() {
    local key="$1"
    local current_dir="$LOCK_DIR/current"
    [ -d "$current_dir" ] || return 0

    local lock_file
    for lock_file in "$current_dir"/*-"${key}".sh; do
        [ -f "$lock_file" ] || continue
        if bash "$lock_file" >/dev/null 2>&1; then
            printf '%s' "$lock_file"
            return 0
        fi
    done
}

# --- Create the lock file (self-validating executable script) ---
create_lock_file() {
    local key="$1" slug="$2" pid="$3" start_time="$4" repo="$5" scope="$6"
    local current_dir="$LOCK_DIR/current"
    mkdir -p "$current_dir"

    local timestamp
    timestamp="$(date +%Y%m%d%H%M%S)"
    local lock_file="$current_dir/${timestamp}-${slug}-${key}.sh"

    local esc_pid="$pid"
    local esc_start="$start_time"
    local esc_repo="${repo//\'/\'\\\'\'}"
    local esc_scope="${scope//\'/\'\\\'\'}"
    local esc_slug="${slug//\'/\'\\\'\'}"
    local esc_key="$key"
    local esc_timestamp="$timestamp"

    cat > "$lock_file" <<LOCK_EOF
#!/usr/bin/env bash
# Lock file: ${slug} (key: ${key})
# Created: ${timestamp}
# Repo: ${repo}
# Scope: ${scope}
# PID: ${pid}
# Start-time: ${start_time}
set -euo pipefail

LOCK_PID='${esc_pid}'
LOCK_START='${esc_start}'
LOCK_REPO='${esc_repo}'
LOCK_SCOPE='${esc_scope}'
LOCK_SLUG='${esc_slug}'
LOCK_KEY='${esc_key}'
LOCK_TIMESTAMP='${esc_timestamp}'
LOCK_DIR='${LOCK_DIR}'

SELF="\${BASH_SOURCE[0]}"
SELF_DIR="\$(cd "\$(dirname "\$SELF")" && pwd)"

archive_self() {
    local reason="\$1"
    local archive_dir="\$LOCK_DIR/archive/\$(date +%Y/%m)"
    mkdir -p "\$archive_dir"
    local archive_path="\$archive_dir/\$(basename "\$SELF")"
    mv "\$SELF" "\$archive_path"
    echo "STALE:\$LOCK_PID:\$LOCK_SLUG:\$reason" >&2
}

if ! kill -0 "\$LOCK_PID" 2>/dev/null; then
    archive_self "PID \$LOCK_PID is not running"
    exit 1
fi

current_start="\$(ps -p "\$LOCK_PID" -o lstart= 2>/dev/null || echo "")"
if [ -z "\$current_start" ]; then
    archive_self "could not read start-time for PID \$LOCK_PID"
    exit 1
fi
if [ "\$current_start" != "\$LOCK_START" ]; then
    archive_self "PID \$LOCK_PID start-time mismatch (reuse detected)"
    exit 1
fi

echo "ACTIVE:\$LOCK_PID:\$LOCK_SLUG"
exit 0
LOCK_EOF

    chmod +x "$lock_file"
    printf '%s' "$lock_file"
}

# --- Wait for an active lock to release ---
wait_for_lock() {
    local active_lock="$1"
    local timeout="${QUALITY_LOCK_WAIT_TIMEOUT:-600}"
    local elapsed=0
    while [ "$elapsed" -lt "$timeout" ]; do
        if ! bash "$active_lock" >/dev/null 2>&1; then
            return 0
        fi
        sleep 5
        elapsed=$((elapsed + 5))
    done
    return 1
}

# --- Kill the active lock's process ---
kill_active_lock() {
    local active_lock="$1"
    local pid
    pid="$(grep '^# PID: ' "$active_lock" | awk '{print $3}' 2>/dev/null || echo "")"
    if [ -z "$pid" ]; then
        echo "acquire-lock.sh: could not extract PID from $active_lock" >&2
        return 1
    fi
    if kill -TERM "$pid" 2>/dev/null; then
        sleep 2
        if kill -0 "$pid" 2>/dev/null; then
            kill -KILL "$pid" 2>/dev/null || true
        fi
        bash "$active_lock" >/dev/null 2>&1 || true
        return 0
    else
        echo "acquire-lock.sh: could not kill PID $pid" >&2
        return 1
    fi
}

# --- Argument parsing ---
REPO=""
SCOPE=""
SLUG=""
NAMESPACE="shared"
PID="$$"
START_TIME=""
ACTION=""
JSON_OUTPUT=0

while [ "$#" -gt 0 ]; do
    case "$1" in
    --repo) REPO="$2"; shift 2 ;;
    --scope) SCOPE="$2"; shift 2 ;;
    --slug) SLUG="$2"; shift 2 ;;
    --namespace) NAMESPACE="$2"; shift 2 ;;
    --pid) PID="$2"; shift 2 ;;
    --start) START_TIME="$2"; shift 2 ;;
    --action) ACTION="$2"; shift 2 ;;
    --json) JSON_OUTPUT=1; shift ;;
    -h | --help)
        sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
        exit 0
        ;;
    *)
        echo "acquire-lock.sh: unknown arg: $1" >&2
        exit 1
        ;;
    esac
done

if [ -z "$REPO" ] || [ -z "$SCOPE" ] || [ -z "$SLUG" ]; then
    echo "usage: acquire-lock.sh --repo <path> --scope <id> --slug <slug> [--namespace <ns>] [--pid <pid>] [--start <time>] [--action <mode>] [--json]" >&2
    exit 1
fi

if [ -z "$ACTION" ]; then
    ACTION="${QUALITY_LOCK_ACTION:-skip}"
fi

# --- Main ---
resolve_lock_dir
LOCK_KEY="$(compute_lock_key "$REPO" "$SCOPE")"

if [ -z "$START_TIME" ]; then
    START_TIME="$(get_start_time "$PID")"
    if [ -z "$START_TIME" ]; then
        echo "acquire-lock.sh: could not determine start-time for PID $PID" >&2
        exit 1
    fi
fi

ACTIVE_LOCK="$(scan_active_locks "$LOCK_KEY" || echo "")"

if [ -n "$ACTIVE_LOCK" ]; then
    case "$ACTION" in
    skip)
        if [ "$JSON_OUTPUT" -eq 1 ]; then
            printf '{"status":"locked","action":"skip","lock_file":"%s","pid":%s}\n' "$ACTIVE_LOCK" "$PID"
        else
            printf 'LOCKED:%s\n' "$ACTIVE_LOCK"
        fi
        exit 2
        ;;
    wait)
        if wait_for_lock "$ACTIVE_LOCK"; then
            LOCK_FILE="$(create_lock_file "$LOCK_KEY" "$SLUG" "$PID" "$START_TIME" "$REPO" "$SCOPE")"
            if [ "$JSON_OUTPUT" -eq 1 ]; then
                printf '{"status":"acquired","action":"waited","lock_file":"%s","pid":%s}\n' "$LOCK_FILE" "$PID"
            else
                printf '%s\n' "$LOCK_FILE"
            fi
            exit 0
        else
            echo "acquire-lock.sh: wait timed out after ${QUALITY_LOCK_WAIT_TIMEOUT:-600}s" >&2
            exit 3
        fi
        ;;
    kill)
        if kill_active_lock "$ACTIVE_LOCK"; then
            LOCK_FILE="$(create_lock_file "$LOCK_KEY" "$SLUG" "$PID" "$START_TIME" "$REPO" "$SCOPE")"
            if [ "$JSON_OUTPUT" -eq 1 ]; then
                printf '{"status":"acquired","action":"killed","lock_file":"%s","pid":%s}\n' "$LOCK_FILE" "$PID"
            else
                printf '%s\n' "$LOCK_FILE"
            fi
            exit 0
        else
            exit 3
        fi
        ;;
    cancel)
        if [ "$JSON_OUTPUT" -eq 1 ]; then
            printf '{"status":"cancelled","action":"cancel","lock_file":"%s"}\n' "$ACTIVE_LOCK"
        else
            printf 'CANCELLED:%s\n' "$ACTIVE_LOCK"
        fi
        exit 2
        ;;
    force)
        LOCK_FILE="$(create_lock_file "$LOCK_KEY" "$SLUG" "$PID" "$START_TIME" "$REPO" "$SCOPE")"
        if [ "$JSON_OUTPUT" -eq 1 ]; then
            printf '{"status":"acquired","action":"forced","lock_file":"%s","pid":%s}\n' "$LOCK_FILE" "$PID"
        else
            printf '%s\n' "$LOCK_FILE"
        fi
        exit 0
        ;;
    *)
        echo "acquire-lock.sh: unknown action '$ACTION' (use skip|wait|kill|cancel|force)" >&2
        exit 1
        ;;
    esac
fi

LOCK_FILE="$(create_lock_file "$LOCK_KEY" "$SLUG" "$PID" "$START_TIME" "$REPO" "$SCOPE")"
if [ "$JSON_OUTPUT" -eq 1 ]; then
    printf '{"status":"acquired","action":"new","lock_file":"%s","pid":%s}\n' "$LOCK_FILE" "$PID"
else
    printf '%s\n' "$LOCK_FILE"
fi
exit 0

