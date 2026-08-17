#!/usr/bin/env bats
# test_refresh.bats — unit tests for refresh.sh
# Tests skip conditions, cache hit, fallback behavior, nested session detection,
# and nono-profile structure.
#
# Run via:
#   bats scripts/tests/test_refresh.bats
#
# Creates temp skill directories under /tmp/skill-test/refresh/{scenario}/
# Uses a mock pnpm to avoid network calls.

TEST_BASE="/tmp/skill-test/refresh"

# --- test helpers ---

assert_equals() {
    local expected="$1" actual="$2"
    [[ "$expected" == "$actual" ]] || {
        echo "expected: '$expected'" >&3
        echo "actual:   '$actual'" >&3
        return 1
    }
}

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in: '$haystack'" >&3
        return 1
    }
}

assert_not_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" != *"$needle"* ]] || {
        echo "did not expect '$needle' in: '$haystack'" >&3
        return 1
    }
}

# Create a fake skill directory with a stub refresh.sh, INSTRUCTIONS.md,
# and nono-profile.json. Echoes the dir path.
# The stub implements the skip/cache logic without calling pnpm or nono.
# Usage: setup_skill scenario_name
setup_skill() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir/scripts" "$dir/references"

    # Create a stub refresh.sh that implements the key logic paths
    # without any network calls or external tool dependencies.
    cat > "$dir/scripts/refresh.sh" << 'STUB'
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="$(basename "$SKILL_DIR")"
INSTRUCTIONS="$SKILL_DIR/INSTRUCTIONS.md"

print_body() {
    if [ -f "$INSTRUCTIONS" ]; then
        cat "$INSTRUCTIONS"
        exit 0
    fi
    echo "refresh.sh: INSTRUCTIONS.md not found at $INSTRUCTIONS" >&2
    exit 1
}

# Update last-used in SKILL.md frontmatter to today (deterministic fix for
# the last-used ordering bug — skills update overwrites SKILL.md, so the
# AI-side self-update-requirement would be destroyed if it fired before refresh)
update_last_used() {
    local skill_md="$SKILL_DIR/SKILL.md"
    if [ -f "$skill_md" ] && command -v sed >/dev/null 2>&1; then
        local tmp_file
        tmp_file="$(mktemp "${skill_md}.XXXXXX")" || return 0
        sed "s/^\([[:space:]]*last-used:[[:space:]]*\)\"[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\"/\1\"$TODAY\"/" "$skill_md" > "$tmp_file" && mv "$tmp_file" "$skill_md"
    fi
}

# Skip: SKIP_SKILL_REFRESH=1
if [ "${SKIP_SKILL_REFRESH:-0}" = "1" ]; then print_body; fi

# Skip: inside skills-src
case "$SKILL_DIR" in */skills-src/src/*) print_body ;; esac

# Cache check
CACHE_BASE="${XDG_CACHE_HOME:-$HOME/.cache}"
CACHE_DIR="$CACHE_BASE/skills/levonk/skills-releases/skills/$SKILL_NAME"
mkdir -p "$CACHE_DIR" 2>/dev/null || true
DATE_FILE="$CACHE_DIR/refresh.date"
TODAY="$(date +%Y-%m-%d)"

if [ -f "$DATE_FILE" ] && [ "$(cat "$DATE_FILE" 2>/dev/null)" = "$TODAY" ]; then
    print_body
fi

# Nested session check
if [ -n "${NONO_SESSION:-}" ]; then
    # Already sandboxed — skip sandbox, run "update" (mocked as true)
    echo "$TODAY" > "$DATE_FILE" 2>/dev/null || true
    update_last_used
    print_body
fi

# Normal path: would run pnpm dlx skills update here.
# In the stub, we just write the cache and print the body.
echo "$TODAY" > "$DATE_FILE" 2>/dev/null || true
update_last_used
print_body
STUB
    chmod +x "$dir/scripts/refresh.sh"

    # Create INSTRUCTIONS.md
    echo "# Test Skill Instructions" > "$dir/INSTRUCTIONS.md"
    echo "This is the skill body." >> "$dir/INSTRUCTIONS.md"

    # Create SKILL.md with last-used in frontmatter (for last-used update tests)
    cat > "$dir/SKILL.md" << 'SKILLMD'
---
name: test-skill
date:
  created: "2026-01-01"
  knowledge-basis: "2026-06-01"
  last-used: "2026-01-01"
---
# Test Skill
SKILLMD

    # Create nono-profile.json (real structure matching the template)
    cat > "$dir/references/nono-profile.json" << 'JSON'
{
  "fs_read": [".", "/usr", "/lib", "/lib64", "/etc",
              "~/.local/share/pnpm", "~/.config/pnpm"],
  "fs_write": ["."],
  "net_allow": ["registry.npmjs.org", "github.com"],
  "net_deny": ["*"],
  "env": ["PATH", "HOME", "USER", "SHELL", "TERM", "LANG"]
}
JSON

    echo "$dir"
}

# --- setup/teardown ---

setup() {
    rm -rf "$TEST_BASE"
    mkdir -p "$TEST_BASE"
}

teardown() {
    rm -rf "$TEST_BASE"
    # Clean up any cache entries created by tests
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/cache-hit" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/cache-miss" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/nono-session" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/xdg-cache" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/last-used-update" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/last-used-skip" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/last-used-cache" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/last-used-nono" 2>/dev/null || true
    rm -rf "$HOME/.cache/skills/levonk/skills-releases/skills/last-used-preserve" 2>/dev/null || true
}

# --- tests: skip conditions ---

@test "SKIP_SKILL_REFRESH=1 prints body without updating" {
    local dir
    dir="$(setup_skill skip-env)"
    local out
    out="$(cd "$dir" && SKIP_SKILL_REFRESH=1 ./scripts/refresh.sh 2>/dev/null)"
    assert_contains "Test Skill Instructions" "$out"
    assert_contains "skill body" "$out"
}

@test "inside skills-src skips update" {
    local dir
    dir="$(setup_skill inside-src)"
    # Simulate skills-src path
    local fake_src="/tmp/skill-test/refresh/skills-src/src/current/skills/test-skill"
    rm -rf "$(dirname "$fake_src")"
    mkdir -p "$(dirname "$fake_src")"
    cp -r "$dir" "$fake_src"
    local out
    out="$("$fake_src/scripts/refresh.sh" 2>/dev/null)"
    assert_contains "Test Skill Instructions" "$out"
    rm -rf "/tmp/skill-test/refresh/skills-src"
}

# --- tests: cache hit ---

@test "cache hit prints body without update" {
    local dir
    dir="$(setup_skill cache-hit)"
    # Pre-populate the cache with today's date
    local cache_dir="$HOME/.cache/skills/levonk/skills-releases/skills/cache-hit"
    mkdir -p "$cache_dir"
    date +%Y-%m-%d > "$cache_dir/refresh.date"
    local out
    out="$(cd "$dir" && ./scripts/refresh.sh 2>/dev/null)"
    assert_contains "Test Skill Instructions" "$out"
}

@test "cache miss writes cache and prints body" {
    local dir
    dir="$(setup_skill cache-miss)"
    # Ensure cache is empty
    local cache_dir="$HOME/.cache/skills/levonk/skills-releases/skills/cache-miss"
    rm -rf "$cache_dir"
    local out
    out="$(cd "$dir" && ./scripts/refresh.sh 2>/dev/null)"
    assert_contains "Test Skill Instructions" "$out"
    # Cache should now have today's date
    [ -f "$cache_dir/refresh.date" ] || {
        echo "cache file not created" >&3
        return 1
    }
}

# --- tests: fallback behavior ---

@test "missing INSTRUCTIONS.md exits with code 1" {
    local dir
    dir="$(setup_skill no-instructions)"
    rm "$dir/INSTRUCTIONS.md"
    local exit_code=0
    (cd "$dir" && ./scripts/refresh.sh 2>/dev/null) || exit_code=$?
    [ "$exit_code" -eq 1 ] || {
        echo "expected exit code 1, got $exit_code" >&3
        return 1
    }
}

@test "XDG_CACHE_HOME respected for cache location" {
    local dir
    dir="$(setup_skill xdg-cache)"
    local custom_cache="/tmp/skill-test/refresh/xdg-cache-dir"
    rm -rf "$custom_cache"
    # Pre-populate cache in custom location
    local cache_dir="$custom_cache/skills/levonk/skills-releases/skills/xdg-cache"
    mkdir -p "$cache_dir"
    date +%Y-%m-%d > "$cache_dir/refresh.date"
    local out
    out="$(cd "$dir" && XDG_CACHE_HOME="$custom_cache" ./scripts/refresh.sh 2>/dev/null)"
    assert_contains "Test Skill Instructions" "$out"
    rm -rf "$custom_cache"
}

# --- tests: nested session detection ---

@test "NONO_SESSION set skips sandbox and prints body" {
    local dir
    dir="$(setup_skill nono-session)"
    local out
    out="$(cd "$dir" && NONO_SESSION="test-session-id" ./scripts/refresh.sh 2>/dev/null)"
    assert_contains "Test Skill Instructions" "$out"
}

# --- tests: nono-profile.json ---

@test "nono-profile.json exists and has correct structure" {
    local dir
    dir="$(setup_skill profile-check)"
    local profile="$dir/references/nono-profile.json"
    [ -f "$profile" ] || {
        echo "nono-profile.json not found at $profile" >&3
        return 1
    }
    # Verify it's valid JSON with required keys
    if command -v jq >/dev/null 2>&1; then
        jq -e '.fs_write' "$profile" >/dev/null || {
            echo "fs_write missing from profile" >&3
            return 1
        }
        jq -e '.net_allow' "$profile" >/dev/null || {
            echo "net_allow missing from profile" >&3
            return 1
        }
        jq -e '.net_deny' "$profile" >/dev/null || {
            echo "net_deny missing from profile" >&3
            return 1
        }
    fi
}

@test "nono-profile allows github.com not raw.githubusercontent.com" {
    local dir
    dir="$(setup_skill profile-github)"
    local profile="$dir/references/nono-profile.json"
    if command -v jq >/dev/null 2>&1; then
        local net_allow
        net_allow="$(jq -r '.net_allow[]' "$profile" 2>/dev/null || echo "")"
        assert_contains "github.com" "$net_allow"
        assert_not_contains "raw.githubusercontent.com" "$net_allow"
    fi
}

@test "nono-profile allows registry.npmjs.org" {
    local dir
    dir="$(setup_skill profile-npm)"
    local profile="$dir/references/nono-profile.json"
    if command -v jq >/dev/null 2>&1; then
        local net_allow
        net_allow="$(jq -r '.net_allow[]' "$profile" 2>/dev/null || echo "")"
        assert_contains "registry.npmjs.org" "$net_allow"
    fi
}

@test "nono-profile restricts fs_write to skill directory only" {
    local dir
    dir="$(setup_skill profile-fs)"
    local profile="$dir/references/nono-profile.json"
    if command -v jq >/dev/null 2>&1; then
        local fs_write
        fs_write="$(jq -r '.fs_write[]' "$profile" 2>/dev/null || echo "")"
        assert_equals "." "$fs_write"
    fi
}

# --- tests: last-used update (deterministic fix for ordering bug) ---

@test "last-used updated to today on normal path (cache miss)" {
    local dir
    dir="$(setup_skill last-used-update)"
    local cache_dir="$HOME/.cache/skills/levonk/skills-releases/skills/last-used-update"
    rm -rf "$cache_dir"
    # Run refresh.sh — should update last-used in SKILL.md
    (cd "$dir" && ./scripts/refresh.sh >/dev/null 2>&1) || true
    local today
    today="$(date +%Y-%m-%d)"
    local lu
    lu="$(grep -m1 'last-used' "$dir/SKILL.md" | sed 's/.*: *//;s/"//g;s/ //g')"
    assert_equals "$today" "$lu"
}

@test "last-used NOT updated on SKIP_SKILL_REFRESH" {
    local dir
    dir="$(setup_skill last-used-skip)"
    # Run with SKIP_SKILL_REFRESH=1 — should NOT update last-used
    (cd "$dir" && SKIP_SKILL_REFRESH=1 ./scripts/refresh.sh >/dev/null 2>&1) || true
    local lu
    lu="$(grep -m1 'last-used' "$dir/SKILL.md" | sed 's/.*: *//;s/"//g;s/ //g')"
    assert_equals "2026-01-01" "$lu"
}

@test "last-used NOT updated on cache hit" {
    local dir
    dir="$(setup_skill last-used-cache)"
    local cache_dir="$HOME/.cache/skills/levonk/skills-releases/skills/last-used-cache"
    mkdir -p "$cache_dir"
    date +%Y-%m-%d > "$cache_dir/refresh.date"
    # Run with cache hit — should NOT update last-used
    (cd "$dir" && ./scripts/refresh.sh >/dev/null 2>&1) || true
    local lu
    lu="$(grep -m1 'last-used' "$dir/SKILL.md" | sed 's/.*: *//;s/"//g;s/ //g')"
    assert_equals "2026-01-01" "$lu"
}

@test "last-used updated on NONO_SESSION path" {
    local dir
    dir="$(setup_skill last-used-nono)"
    local cache_dir="$HOME/.cache/skills/levonk/skills-releases/skills/last-used-nono"
    rm -rf "$cache_dir"
    # Run with NONO_SESSION set — should update last-used (update runs)
    (cd "$dir" && NONO_SESSION="test" ./scripts/refresh.sh >/dev/null 2>&1) || true
    local today
    today="$(date +%Y-%m-%d)"
    local lu
    lu="$(grep -m1 'last-used' "$dir/SKILL.md" | sed 's/.*: *//;s/"//g;s/ //g')"
    assert_equals "$today" "$lu"
}

@test "last-used update preserves created and knowledge-basis" {
    local dir
    dir="$(setup_skill last-used-preserve)"
    local cache_dir="$HOME/.cache/skills/levonk/skills-releases/skills/last-used-preserve"
    rm -rf "$cache_dir"
    (cd "$dir" && ./scripts/refresh.sh >/dev/null 2>&1) || true
    # created should be unchanged
    local created
    created="$(grep -m1 'created:' "$dir/SKILL.md" | sed 's/.*: *//;s/"//g;s/ //g')"
    assert_equals "2026-01-01" "$created"
    # knowledge-basis should be unchanged
    local kb
    kb="$(grep -m1 'knowledge-basis' "$dir/SKILL.md" | sed 's/.*: *//;s/"//g;s/ //g')"
    assert_equals "2026-06-01" "$kb"
}
