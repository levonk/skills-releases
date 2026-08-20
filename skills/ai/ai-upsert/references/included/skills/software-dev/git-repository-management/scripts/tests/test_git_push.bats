#!/usr/bin/env bats
# test_git_push.bats - unit tests for git-push.sh
# Tests backup branch creation, fetch-rebase-push flow, remote-up-to-date,
# push success/failure output format, and cache warming regression.
#
# Run via: bats scripts/tests/test_git_push.bats
#
# Creates temp git repos under /tmp/skill-test/git-push/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-$BASH_SOURCE[0]}")" && pwd)"
PUSH="$SCRIPT_DIR/../git-push.sh"
TEST_BASE="/tmp/skill-test/git-push"

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in output:" >&3
        echo "$haystack" >&3
        return 1
    }
}

# Create a temp git repo with a main branch and initial commit. Echoes the dir.
# Usage: setup_repo scenario_name
setup_repo() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    git init -q -b main "$dir"
    git -C "$dir" config user.email "test@test.com"
    git -C "$dir" config user.name "Test"
    git -C "$dir" commit -q --allow-empty -m "initial"
    echo "$dir"
}

# Create a bare remote repo and add it as 'origin' to the given working repo.
# Echoes the bare repo path.
# Usage: setup_remote <working_dir> <remote_name>
setup_remote() {
    local working_dir="$1"
    local remote_name="${2:-origin}"
    local remote_dir="$TEST_BASE/remotes/${remote_name}"
    rm -rf "$remote_dir"
    mkdir -p "$remote_dir"
    git init -q --bare "$remote_dir"
    git -C "$working_dir" remote add "$remote_name" "$remote_dir"
    git -C "$working_dir" push -q "$remote_name" main 2>/dev/null || true
    echo "$remote_dir"
}

# Run git-push.sh on a repo. Echoes the full output.
# Usage: run_push <dir> [args...]
# git-push.sh takes [remote] [branch] [repo_root] [--slug <slug>].
# We pass origin/main and the dir as repo_root, plus any extra args.
run_push() {
    local dir="$1"; shift
    ( cd "$dir" && env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL GIT_CONFIG_GLOBAL=/dev/null WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 bash "$PUSH" origin main "$dir" "$@" 2>&1 ) || true
}

# Run git-push.sh with gh not available (simulates gh not installed).
# Creates a temp bin dir with only git (symlink), excluding gh.
# Usage: run_push_no_gh <dir> [args...]
run_push_no_gh() {
    local dir="$1"; shift
    local git_real
    git_real=$(command -v git 2>/dev/null || echo "/usr/bin/git")
    local fake_bin="$TEST_BASE/fake-no-gh-path"
    rm -rf "$fake_bin"
    mkdir -p "$fake_bin"
    ln -sf "$git_real" "$fake_bin/git"
    # Also link basic tools needed by the script (date, basename, etc.)
    local tool
    for tool in date basename grep cut head; do
        local tool_path
        tool_path=$(command -v "$tool" 2>/dev/null)
        [[ -n "$tool_path" ]] && ln -sf "$tool_path" "$fake_bin/$tool"
    done
    ( cd "$dir" && \
      env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL \
      GIT_CONFIG_GLOBAL=/dev/null \
      WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 \
      PATH="$fake_bin:/usr/bin:/bin" \
      bash "$PUSH" origin main "$dir" "$@" 2>&1 ) || true
}

# --- Basic push flow ---

@test "push to up-to-date remote succeeds" {
    local dir; dir="$(setup_repo push-uptodate)"
    setup_remote "$dir"
    local out; out="$(run_push "$dir" --slug uptodate)"
    assert_contains "=== PUSH_START ===" "$out"
    assert_contains "REMOTE:origin" "$out"
    assert_contains "BRANCH:main" "$out"
    assert_contains "BACKUP_CREATED" "$out"
    assert_contains "REMOTE_STATUS:UP_TO_DATE" "$out"
    assert_contains "PUSH_SUCCESS:origin/main" "$out"
    assert_contains "=== PUSH_END ===" "$out"
}

@test "push creates backup branch before pushing" {
    local dir; dir="$(setup_repo push-backup)"
    setup_remote "$dir"
    local out; out="$(run_push "$dir" --slug backup-test)"
    assert_contains "BACKUP_BRANCH:scratch/merge/" "$out"
    assert_contains "BACKUP_CREATED" "$out"
    local backup_branch
    backup_branch=$(echo "$out" | grep '^BACKUP_BRANCH:' | head -1 | cut -d: -f2-)
    [[ -n "$backup_branch" ]] || { echo "no backup branch found in output" >&3; return 1; }
    git -C "$dir" show-ref --verify --quiet "refs/heads/$backup_branch" || { echo "backup branch $backup_branch does not exist" >&3; return 1; }
}

@test "push with new commits pushes to remote" {
    local dir; dir="$(setup_repo push-newcommits)"
    setup_remote "$dir"
    echo "new content" > "$dir/file.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "new commit"
    local out; out="$(run_push "$dir" --slug newcommits)"
    assert_contains "REMOTE_STATUS:UP_TO_DATE" "$out"
    assert_contains "PUSH_SUCCESS" "$out"
    local local_sha remote_sha
    local_sha=$(git -C "$dir" rev-parse HEAD)
    remote_sha=$(git -C "$dir" rev-parse origin/main)
    [[ "$local_sha" == "$remote_sha" ]] || { echo "remote SHA $remote_sha != local SHA $local_sha" >&3; return 1; }
}

@test "push fails on fetch error with no remote" {
    local dir; dir="$(setup_repo push-noremote)"
    local out; out="$(run_push "$dir" --no-create-repo --slug noremote)"
    assert_contains "PUSH_FAILED:FETCH_ERROR" "$out"
    assert_contains "BACKUP_RESTORE:" "$out"
}

@test "first push to empty remote branch succeeds with -u" {
    local dir; dir="$(setup_repo push-firstpush)"
    # Set up a bare remote but do NOT push main to it — simulates a brand-new
    # remote branch that has never received commits. Use a unique path to
    # avoid pollution from setup_remote in other tests.
    local remote_dir="$TEST_BASE/remotes/firstpush-origin"
    rm -rf "$remote_dir"
    mkdir -p "$remote_dir"
    git init -q --bare "$remote_dir"
    git -C "$dir" remote add origin "$remote_dir"
    # Add a commit so there's something to push.
    echo "content" > "$dir/file.txt"
    git -C "$dir" add -A
    git -C "$dir" commit -q -m "first commit"
    local out; out="$(run_push "$dir" --slug firstpush)"
    assert_contains "REMOTE_STATUS:NO_UPSTREAM" "$out"
    assert_contains "PUSH_SUCCESS:origin/main" "$out"
    assert_contains "=== PUSH_END ===" "$out"
    # Remote branch should now exist and match local HEAD.
    local local_sha remote_sha
    local_sha=$(git -C "$dir" rev-parse HEAD)
    remote_sha=$(git -C "$dir" rev-parse origin/main)
    [[ "$local_sha" == "$remote_sha" ]] || { echo "remote SHA $remote_sha != local SHA $local_sha after first push" >&3; return 1; }
    # Upstream tracking should be set.
    git -C "$dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null | grep -q '^origin/main$' || { echo "upstream tracking not set to origin/main" >&3; return 1; }
}

@test "first push without any remote configured fails with FETCH_ERROR" {
    local dir; dir="$(setup_repo push-noremote-firstpush)"
    # No remote add at all — no upstream ref AND no remote configured.
    # Use --no-create-repo to skip auto-create (which is the new default).
    local out; out="$(run_push "$dir" --no-create-repo --slug noremote-firstpush)"
    assert_contains "PUSH_FAILED:FETCH_ERROR" "$out"
    assert_not_contains "HINT:" "$out"
    assert_contains "BACKUP_RESTORE:" "$out"
}

@test "auto-create-repo fails with FETCH_ERROR and hint when gh not available" {
    # This test verifies the HINT message when gh is not installed.
    # Skip if gh and git share the same directory (can't exclude gh from PATH).
    local git_dir gh_dir
    git_dir=$(dirname "$(command -v git 2>/dev/null)" 2>/dev/null || echo "")
    gh_dir=$(dirname "$(command -v gh 2>/dev/null)" 2>/dev/null || echo "")
    [[ "$git_dir" == "$gh_dir" ]] && skip "gh and git share the same directory in this environment"
    local dir; dir="$(setup_repo push-no-gh)"
    local out; out="$(run_push_no_gh "$dir" --slug no-gh)"
    assert_contains "PUSH_FAILED:FETCH_ERROR" "$out"
    assert_contains "HINT:gh CLI not found" "$out"
    assert_contains "BACKUP_RESTORE:" "$out"
}

@test "auto-create-repo creates private repo via gh" {
    local dir; dir="$(setup_repo push-autocreate)"
    local fake_bin="$TEST_BASE/fake-gh-bin"
    local gh_log="$TEST_BASE/gh-create-log.txt"
    rm -f "$gh_log"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/gh" <<EOF
#!/usr/bin/env bash
echo "gh called with: \$@" >> "$gh_log"
# Simulate successful repo creation + push
exit 0
EOF
    chmod +x "$fake_bin/gh"
    ( cd "$dir" && \
      env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL \
      GIT_CONFIG_GLOBAL=/dev/null \
      WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 \
      PATH="$fake_bin:$PATH" \
      bash "$PUSH" origin main "$dir" --slug autocreate 2>&1 ) || true
    [[ -f "$gh_log" ]] || { echo "gh was not called" >&3; return 1; }
    assert_contains "repo create" "$(cat "$gh_log")"
    # Default visibility should be --private
    assert_contains "--private" "$(cat "$gh_log")"
    rm -f "$gh_log"
}

@test "auto-create-repo with --public creates public repo" {
    local dir; dir="$(setup_repo push-autocreate-public)"
    local fake_bin="$TEST_BASE/fake-gh-bin-public"
    local gh_log="$TEST_BASE/gh-create-log-public.txt"
    rm -f "$gh_log"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/gh" <<EOF
#!/usr/bin/env bash
echo "gh called with: \$@" >> "$gh_log"
exit 0
EOF
    chmod +x "$fake_bin/gh"
    ( cd "$dir" && \
      env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL \
      GIT_CONFIG_GLOBAL=/dev/null \
      WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 \
      PATH="$fake_bin:$PATH" \
      bash "$PUSH" origin main "$dir" --public --slug autocreate-public 2>&1 ) || true
    [[ -f "$gh_log" ]] || { echo "gh was not called" >&3; return 1; }
    assert_contains "--public" "$(cat "$gh_log")"
    rm -f "$gh_log"
}

@test "auto-create-repo with --repo-name uses custom name" {
    local dir; dir="$(setup_repo push-autocustomname)"
    local fake_bin="$TEST_BASE/fake-gh-bin-name"
    local gh_log="$TEST_BASE/gh-create-log-name.txt"
    rm -f "$gh_log"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/gh" <<EOF
#!/usr/bin/env bash
echo "gh called with: \$@" >> "$gh_log"
exit 0
EOF
    chmod +x "$fake_bin/gh"
    ( cd "$dir" && \
      env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL \
      GIT_CONFIG_GLOBAL=/dev/null \
      WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 \
      PATH="$fake_bin:$PATH" \
      bash "$PUSH" origin main "$dir" --repo-name my-custom-repo --slug autocustom 2>&1 ) || true
    [[ -f "$gh_log" ]] || { echo "gh was not called" >&3; return 1; }
    assert_contains "my-custom-repo" "$(cat "$gh_log")"
    rm -f "$gh_log"
}

@test "auto-create-repo with --no-create-repo skips creation even with gh available" {
    local dir; dir="$(setup_repo push-nocreate-with-gh)"
    local fake_bin="$TEST_BASE/fake-gh-bin-nocreate"
    local gh_log="$TEST_BASE/gh-create-log-nocreate.txt"
    rm -f "$gh_log"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/gh" <<EOF
#!/usr/bin/env bash
echo "gh called" >> "$gh_log"
exit 0
EOF
    chmod +x "$fake_bin/gh"
    local out
    out=$( cd "$dir" && \
      env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL \
      GIT_CONFIG_GLOBAL=/dev/null \
      WRAPPER_DEVBOX_DISABLED=1 RTK_SKIP=1 \
      PATH="$fake_bin:$PATH" \
      bash "$PUSH" origin main "$dir" --no-create-repo --slug nocreate 2>&1 ) || true
    assert_contains "PUSH_FAILED:FETCH_ERROR" "$out"
    assert_not_contains "HINT:" "$out"
    [[ ! -f "$gh_log" ]] || { echo "gh was called despite --no-create-repo" >&3; rm -f "$gh_log"; return 1; }
}

@test "push outputs ORIGINAL_SHA matching HEAD" {
    local dir; dir="$(setup_repo push-sha)"
    setup_remote "$dir"
    local head_sha
    head_sha=$(git -C "$dir" rev-parse HEAD)
    local out; out="$(run_push "$dir" --slug sha-test)"
    assert_contains "ORIGINAL_SHA:$head_sha" "$out"
}

@test "push --slug sets backup branch slug" {
    local dir; dir="$(setup_repo push-slugarg)"
    setup_remote "$dir"
    local out; out="$(run_push "$dir" --slug custom-slug-name)"
    assert_contains "custom-slug-name-pre" "$out"
}

# --- Cache warming regression test ---
# git-push.sh warms wrapper_prefix() and rtk_prefix() caches after probe_devbox
# so $(git_cmd ...) subshells inherit them. Without warming, each $(git_cmd ...)
# call re-probes wrapper_prefix() (~1s each), making the script take 10s+ instead
# of <2s.

@test "cache warming prevents repeated wrapper probes" {
    local dir; dir="$(setup_repo push-cache)"
    setup_remote "$dir"
    local start_time end_time elapsed
    start_time=$(date +%s)
    run_push "$dir" --slug cache >/dev/null 2>&1
    end_time=$(date +%s)
    elapsed=$((end_time - start_time))
    [[ "$elapsed" -lt 15 ]] || { echo "git-push took ${elapsed}s - cache warming may not be working" >&3; echo "expected <15s, got ${elapsed}s" >&3; return 1; }
}

@test "subshell git_cmd inherits parent cache" {
    local dir; dir="$(setup_repo push-subshell-cache)"
    setup_remote "$dir"
    local fake_bin="$TEST_BASE/fake-cli-bin-push"
    local log="$TEST_BASE/cli-discovery-log-push.txt"
    rm -f "$log"
    mkdir -p "$fake_bin"
    cat > "$fake_bin/cli-tool-discovery.sh" <<EOF
#!/usr/bin/env bash
echo "called" >> "$log"
EOF
    chmod +x "$fake_bin/cli-tool-discovery.sh"
    ( cd "$dir" && \
      env -u DEVBOX_SHELL_ENABLED -u IN_NIX_SHELL \
      GIT_CONFIG_GLOBAL=/dev/null \
      WRAPPER_DEVBOX_DISABLED=1 \
      CLI_TOOL_DISCOVERY="$fake_bin/cli-tool-discovery.sh" \
      bash "$PUSH" --slug subshell-cache >/dev/null 2>&1 ) || true
    local call_count
    call_count=$(wc -l < "$log" 2>/dev/null || echo 0)
    rm -f "$log"
    [[ "$call_count" -le 1 ]] || { echo "cli-tool-discovery.sh was called ${call_count} times - cache not inherited by subshells" >&3; echo "expected at most 1 call, got ${call_count}" >&3; return 1; }
}
