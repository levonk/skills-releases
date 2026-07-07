#!/usr/bin/env bash

# git-commit-batch.sh - Execute batch of commits with AI-provided decisions
# Purpose: Single handoff to execute multiple commits with their messages and file groups
# Usage: git-commit-batch.sh [repo_root]
# Input: STDIN with commit specifications in format:
#   COMMIT:<commit_message>
#   FILES:<file1>
#   FILES:<file2>
#   FILES:<file3>
#   COMMIT:<another_commit_message>
#   FILES:<file1>
# One file per FILES: line — paths containing spaces are preserved
# because the entire line after "FILES:" is treated as a single path.
# Output: Execution results for each commit

set -euo pipefail

# RTK (Rust Token Killer) detection — use rtk as a proxy for git
# when available to reduce LLM token consumption by 60-90%.
# See: https://github.com/rtk-ai/rtk
if command -v rtk >/dev/null 2>&1; then
    RTK_AVAILABLE=1
else
    RTK_AVAILABLE=0
fi

# Devbox detection — use devbox run for environment-aware execution
# when devbox is available and a devbox.json is present.
if command -v devbox >/dev/null 2>&1 && [[ -f "devbox.json" ]]; then
    DEVBOX_AVAILABLE=1
else
    DEVBOX_AVAILABLE=0
fi

# Jujutsu (jj) — alternative VCS client
# See: https://github.com/martinvonz/jj
if command -v jj >/dev/null 2>&1; then
    JJ_AVAILABLE=1
else
    JJ_AVAILABLE=0
fi

# Difftastic — AST-aware structural diff
# See: https://github.com/Wilfred/difftastic
if command -v difft >/dev/null 2>&1; then
    DIFFT_AVAILABLE=1
else
    DIFFT_AVAILABLE=0
fi

# Delta — syntax-highlighted diff pager
# See: https://github.com/dandavison/delta
if command -v delta >/dev/null 2>&1; then
    DELTA_AVAILABLE=1
else
    DELTA_AVAILABLE=0
fi

# Hunk — review-first terminal diff viewer for agentic coders
# See: https://github.com/modem-dev/hunk
if command -v hunk >/dev/null 2>&1; then
    HUNK_AVAILABLE=1
else
    HUNK_AVAILABLE=0
fi

# git-extras — convenience git subcommands
# See: https://github.com/tj/git-extras
if command -v git-summary >/dev/null 2>&1; then
    GIT_EXTRAS_AVAILABLE=1
else
    GIT_EXTRAS_AVAILABLE=0
fi

# Probe devbox: verify `devbox run` actually responds within a timeout.
# Tests with the real command chain (rtk git / git) to catch wrapper recursion.
# If it hangs (e.g. broken wrapper recursion, nix store issues), disable
# devbox wrapping for the rest of the script and fall back to direct execution.
probe_devbox() {
    if [[ "$DEVBOX_AVAILABLE" -ne 1 ]]; then
        return 0
    fi
    local _test_cmd=(git --version)
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then
        _test_cmd=(rtk git --version)
    fi
    devbox run -- "${_test_cmd[@]}" >/dev/null 2>&1 &
    local _pid=$!
    local _elapsed=0
    while kill -0 "$_pid" 2>/dev/null; do
        if [[ "$_elapsed" -ge 15 ]]; then
            kill -9 "$_pid" 2>/dev/null
            wait "$_pid" 2>/dev/null || true
            echo "⚠️ devbox run hung after 15s (likely broken wrapper), falling back to direct execution" >&2
            DEVBOX_AVAILABLE=0
            return 1
        fi
        sleep 1
        _elapsed=$((_elapsed + 1))
    done
    local _exit=0
    wait "$_pid" || _exit=$?
    if [[ "$_exit" -ne 0 ]]; then
        echo "⚠️ devbox run failed (exit $_exit), falling back to direct execution" >&2
        DEVBOX_AVAILABLE=0
        return 1
    fi
    return 0
}

# Wrapper: run a command through devbox when available, otherwise directly
devbox_run() {
    if [[ "$DEVBOX_AVAILABLE" -eq 1 ]]; then
        devbox run -- "$@"
    else
        "$@"
    fi
}

# Wrapper: use 'rtk git' instead of 'git' when rtk is available,
# and run through devbox when available
git_cmd() {
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then
        devbox_run rtk git "$@"
    else
        devbox_run git "$@"
    fi
}

# Run probe after function definitions so it can test the real command chain
probe_devbox || true

discover_repo_root() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(cd "$target_path" && git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "ERROR: $target_path is not inside a git repository" >&2
        exit 1
    fi
    echo "$repo_root"
}

# Expand \n literals in commit message to real newlines
expand_message() {
    local msg="$1"
    printf '%s' "${msg//\\n/$'\n'}"
}

# Commit with a multi-line message via -F instead of -m.
# devbox run serializes argv in a way that re-escapes newlines in -m args,
# turning real newlines into literal "\n" in the resulting commit message.
# Writing the message to a temp file and using -F sidesteps argv entirely.
# ponytail: ceiling — temp file per commit; fine for batch sizes of dozens.
_COMMIT_MSG_FILE=""
commit_with_message() {
    local msg="$1"
    if [[ -z "$_COMMIT_MSG_FILE" ]]; then
        _COMMIT_MSG_FILE=$(mktemp -t git-commit-batch.XXXXXX)
        trap 'rm -f "$_COMMIT_MSG_FILE"' EXIT
    fi
    printf '%s' "$msg" > "$_COMMIT_MSG_FILE"
    git_cmd commit -F "$_COMMIT_MSG_FILE"
}

# A path is stageable if it exists on disk OR is tracked by git.
# Covers deleted-but-tracked files (git rm'd or removed from worktree)
# which no longer exist on disk but `git add` still stages the deletion.
stageable() {
    local p="$1"
    if [[ -f "$p" ]] || [[ -d "$p" ]]; then
        return 0
    fi
    git_cmd ls-files --error-unmatch -- "$p" >/dev/null 2>&1 || return 1
}

# Validate that a commit message has a body (text after a blank line).
# Returns 0 if valid, 1 if missing body.
# A valid message looks like:
#   Subject line\n\n- Body bullet 1\n- Body bullet 2
# An invalid message is just:
#   Subject line
validate_commit_message() {
    local msg="$1"
    # A body exists if there's a blank line followed by non-empty content
    if [[ "$msg" == *$'\n\n'* ]]; then
        # Has a blank line — check that there's actual body text after it
        local body="${msg#*$'\n\n'}"
        # Remove trailing whitespace and check if body is non-empty
        body="${body%"${body##*[![:space:]]}"}"
        if [[ -n "$body" ]]; then
            return 0
        fi
    fi
    return 1
}

main() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    cd "$repo_root"

    echo "=== BATCH_COMMIT_START ==="

    local current_message=""
    local current_files=()
    local commit_count=0

    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^# ]] && continue

        if [[ "$line" =~ ^COMMIT:(.*)$ ]]; then
            # Process previous commit if exists
            if [[ -n "$current_message" ]] && [[ ${#current_files[@]} -gt 0 ]]; then
                # Expand \n literals to real newlines
                current_message="$(expand_message "$current_message")"

                # Validate: every commit must have a body explaining the why
                if ! validate_commit_message "$current_message"; then
                    echo "COMMIT_FAILED:NO_BODY"
                    echo "ERROR: Commit message must include a body after a blank line." >&2
                    echo "ERROR: Format: \"Subject line\\n\\n- Body bullet 1\\n- Body bullet 2\"" >&2
                    echo "ERROR: Got: $current_message" >&2
                    exit 1
                fi

                echo "PROCESSING_COMMIT:$((commit_count + 1))"
                echo "MESSAGE:$current_message"
                echo "FILES:${current_files[*]}"

                # Stage files
                for file in "${current_files[@]}"; do
                    if stageable "$file"; then
                        git_cmd add -- "$file"
                        echo "STAGED:$file"
                    else
                        echo "ERROR: Path not found and not tracked by git: $file" >&2
                        echo "COMMIT_FAILED:FILE_NOT_FOUND"
                        exit 1
                    fi
                done

                # Commit
                if commit_with_message "$current_message"; then
                    local commit_hash
                    commit_hash=$(git_cmd rev-parse HEAD)
                    echo "COMMIT_SUCCESS:$commit_hash"
                    commit_count=$((commit_count + 1))
                else
                    echo "COMMIT_FAILED:GIT_ERROR"
                    exit 1
                fi

                # Reset for next commit
                current_message=""
                current_files=()
            elif [[ -n "$current_message" ]] && [[ ${#current_files[@]} -eq 0 ]]; then
                # Guard: a COMMIT: block ended with no FILES: lines. This is
                # almost always a parsing error — typically the caller's
                # FILES: lines got absorbed into the COMMIT: message (e.g. a
                # printf that joined lines with literal \n instead of real
                # newlines, so "COMMIT:subj\n\n- body\nFILES:foo" was read as
                # one physical line). Without this guard the block is silently
                # dropped and the caller believes a commit landed that didn't,
                # producing a split history (some files committed, some left
                # dirty) with no error signal. Fail loudly instead.
                echo "COMMIT_FAILED:NO_FILES"
                echo "ERROR: Commit block ended with no FILES: lines." >&2
                echo "ERROR: This usually means FILES: lines were joined onto the COMMIT: line" >&2
                echo "ERROR: (e.g. printf with literal \\n instead of real newlines)." >&2
                echo "ERROR: Each FILES:<path> must be on its own physical line." >&2
                echo "ERROR: Offending message: $current_message" >&2
                exit 1
            fi

            # Set new message
            current_message="${BASH_REMATCH[1]}"

        elif [[ "$line" =~ ^FILES:(.*)$ ]]; then
            # Add file to current commit — one path per FILES: line
            # so paths containing spaces are preserved intact
            current_files+=("${BASH_REMATCH[1]}")
        fi
    done

    # Process final commit
    if [[ -n "$current_message" ]] && [[ ${#current_files[@]} -gt 0 ]]; then
        # Expand \n literals to real newlines
        current_message="$(expand_message "$current_message")"

        # Validate: every commit must have a body explaining the why
        if ! validate_commit_message "$current_message"; then
            echo "COMMIT_FAILED:NO_BODY"
            echo "ERROR: Commit message must include a body after a blank line." >&2
            echo "ERROR: Format: \"Subject line\\n\\n- Body bullet 1\\n- Body bullet 2\"" >&2
            echo "ERROR: Got: $current_message" >&2
            exit 1
        fi

        echo "PROCESSING_COMMIT:$((commit_count + 1))"
        echo "MESSAGE:$current_message"
        echo "FILES:${current_files[*]}"

        for file in "${current_files[@]}"; do
            if stageable "$file"; then
                git_cmd add -- "$file"
                echo "STAGED:$file"
            else
                echo "ERROR: Path not found and not tracked by git: $file" >&2
                echo "COMMIT_FAILED:FILE_NOT_FOUND"
                exit 1
            fi
        done

        if commit_with_message "$current_message"; then
            local commit_hash
            commit_hash=$(git_cmd rev-parse HEAD)
            echo "COMMIT_SUCCESS:$commit_hash"
            commit_count=$((commit_count + 1))
        else
            echo "COMMIT_FAILED:GIT_ERROR"
            exit 1
        fi
    elif [[ -n "$current_message" ]] && [[ ${#current_files[@]} -eq 0 ]]; then
        # Guard: final COMMIT: block has no FILES: lines. Same root cause as
        # the in-loop guard above — FILES: lines were absorbed into the
        # COMMIT: message (e.g. printf with literal \n instead of real
        # newlines). Without this guard the trailing block is silently
        # dropped and the caller never learns the last commit didn't land.
        echo "COMMIT_FAILED:NO_FILES"
        echo "ERROR: Final commit block ended with no FILES: lines." >&2
        echo "ERROR: This usually means FILES: lines were joined onto the COMMIT: line" >&2
        echo "ERROR: (e.g. printf with literal \\n instead of real newlines)." >&2
        echo "ERROR: Each FILES:<path> must be on its own physical line." >&2
        echo "ERROR: Offending message: $current_message" >&2
        exit 1
    fi

    echo "BATCH_COMMIT_COMPLETE:$commit_count"
    echo "=== BATCH_COMMIT_END ==="
}

main "$@"
