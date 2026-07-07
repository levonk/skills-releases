#!/usr/bin/env bash

# git-collect.sh - Collect all repository data for AI analysis
# Purpose: Single handoff to collect changes, run quality checks, and gather all needed data
# Usage: git-collect.sh [repo_root]
# Output: Structured data for AI decision-making

set -euo pipefail

# RTK (Rust Token Killer) detection — use rtk as a proxy for git and supported
# commands when available to reduce LLM token consumption by 60-90%.
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

# Jujutsu (jj) — alternative VCS client with cleaner log/status output
# See: https://github.com/martinvonz/jj
if command -v jj >/dev/null 2>&1; then
    JJ_AVAILABLE=1
else
    JJ_AVAILABLE=0
fi

# Difftastic — AST-aware structural diff (best for supported languages)
# See: https://github.com/Wilfred/difftastic
if command -v difft >/dev/null 2>&1; then
    DIFFT_AVAILABLE=1
else
    DIFFT_AVAILABLE=0
fi

# Delta — syntax-highlighted diff pager (fallback for difftastic)
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

# git-extras — convenience git subcommands (git summary, git effort, etc.)
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
    # Test with the actual command path the script will use
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

# Wrapper: use 'rtk <tool>' instead of '<tool>' for supported commands,
# and run through devbox when available
rtk_wrap() {
    local tool="$1"
    shift
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then
        devbox_run rtk "$tool" "$@"
    else
        devbox_run "$tool" "$@"
    fi
}

# Run probe after function definitions so it can test the real command chain
probe_devbox || true

# Wrapper: use 'jj log' when jj is available, otherwise 'git log'
# Produces cleaner, more structured log output for AI analysis
jj_log() {
    if [[ "$JJ_AVAILABLE" -eq 1 ]]; then
        devbox_run jj log "$@"
    else
        git_cmd log "$@"
    fi
}

# Wrapper: enhanced full diff using difftastic > delta > raw
# Use for full diffs only (not --name-status or --stat which are structured data)
diff_cmd() {
    if [[ "$DIFFT_AVAILABLE" -eq 1 ]]; then
        git_cmd -c diff.tool=difft -c difftool.difft.cmd='difft "$LOCAL" "$REMOTE"' difftool --no-prompt "$@" 2>/dev/null || git_cmd diff "$@"
    elif [[ "$DELTA_AVAILABLE" -eq 1 ]]; then
        git_cmd diff "$@" | delta 2>/dev/null || git_cmd diff "$@"
    else
        git_cmd diff "$@"
    fi
}

# Environment detection (for quality checks that may need other env managers)
detect_environment() {
    if [[ -f "devbox.json" ]]; then
        echo "devbox"
    elif [[ -f "mise.toml" || -f ".mise.toml" || -f ".tool-versions" ]]; then
        echo "mise"
    elif [[ -f "flake.nix" ]]; then
        echo "nix"
    else
        echo "native"
    fi
}

# Command wrapper for environment-aware execution
run_command() {
    local env_type
    env_type=$(detect_environment)

    case "$env_type" in
        "devbox")
            devbox_run "$@"
            ;;
        "mise")
            mise exec -- "$@"
            ;;
        "nix")
            nix develop --command "$@"
            ;;
        "native")
            "$@"
            ;;
    esac
}

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

main() {
    local target_path="${1:-.}"
    local repo_root
    repo_root=$(discover_repo_root "$target_path")
    cd "$repo_root"

    echo "=== COLLECTION_START ==="

    # Repository metadata
    echo "REPO_ROOT:$repo_root"
    echo "BRANCH:$(git_cmd rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
    echo "UPSTREAM:$(git_cmd rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo 'none')"

    # Available tools (for AI agent to use in subsequent operations)
    echo "AVAILABLE_TOOLS:"
    echo "RTK:$RTK_AVAILABLE"
    echo "DEVBOX:$DEVBOX_AVAILABLE"
    echo "JJ:$JJ_AVAILABLE"
    echo "DIFFT:$DIFFT_AVAILABLE"
    echo "DELTA:$DELTA_AVAILABLE"
    echo "HUNK:$HUNK_AVAILABLE"
    echo "GIT_EXTRAS:$GIT_EXTRAS_AVAILABLE"

    # Recent log (uses jj log when available for cleaner output)
    echo "RECENT_LOG:"
    jj_log -n 10 --no-graph 2>/dev/null || echo "<none>"

    # Change data
    echo "STAGED:"
    git_cmd diff --cached --name-status 2>/dev/null || echo "<none>"

    echo "UNSTAGED:"
    git_cmd diff --name-status 2>/dev/null || echo "<none>"

    echo "UNTRACKED:"
    git_cmd ls-files --others --exclude-standard 2>/dev/null || echo "<none>"

    # Diff stats
    echo "DIFF_STATS:"
    git_cmd diff --stat 2>/dev/null || echo "<none>"

    # Full diff (uses difftastic > delta > raw when available)
    echo "FULL_DIFF:"
    diff_cmd 2>/dev/null || echo "<none>"

    # Quality checks
    echo "QUALITY_CHECKS:"

    if command -v eslint >/dev/null 2>&1; then
        echo "ESLINT:"
        if run_command rtk_wrap eslint . 2>&1; then
            echo "ESLINT_STATUS:PASS"
        else
            echo "ESLINT_STATUS:FAIL"
        fi
    else
        echo "ESLINT:NOT_AVAILABLE"
    fi

    if command -v prettier >/dev/null 2>&1; then
        echo "PRETTIER:"
        if run_command rtk_wrap prettier --check . 2>&1; then
            echo "PRETTIER_STATUS:PASS"
        else
            echo "PRETTIER_STATUS:FAIL"
        fi
    else
        echo "PRETTIER:NOT_AVAILABLE"
    fi

    # Test runners
    if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
        echo "NPM_TEST:"
        if run_command rtk_wrap npm test 2>&1; then
            echo "NPM_TEST_STATUS:PASS"
        else
            echo "NPM_TEST_STATUS:FAIL"
        fi
    elif [[ -f "Cargo.toml" ]]; then
        echo "CARGO_TEST:"
        if run_command rtk_wrap cargo test 2>&1; then
            echo "CARGO_TEST_STATUS:PASS"
        else
            echo "CARGO_TEST_STATUS:FAIL"
        fi
    elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
        echo "PYTHON_TEST:"
        if run_command python -m pytest 2>&1; then
            echo "PYTHON_TEST_STATUS:PASS"
        else
            echo "PYTHON_TEST_STATUS:FAIL"
        fi
    else
        echo "TESTS:NOT_CONFIGURED"
    fi

    echo "=== COLLECTION_END ==="
}

main "$@"
