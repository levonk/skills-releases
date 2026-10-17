#!/usr/bin/env bats
# test_detect_pr_template.bats — unit tests for detect-pr-template.sh
#
# Tests detection of repo PR/issue templates (single-file and
# multi-template directory forms, across .github/, docs/, and root) and
# template-enforcement workflows (pull_request_target jobs, or workflows
# reading pull_request.body). When found, the generated PR body must
# follow the repo's template structure (action=conform).
#
# Run via:
#   bats scripts/tests/test_detect_pr_template.bats
#
# Creates temp scenarios under /tmp/skill-test/nixify-prtmpl/{scenario}/

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-${BASH_SOURCE[0]}}")" && pwd)"
DETECT_SCRIPT="$SCRIPT_DIR/../detect-pr-template.sh"
TEST_BASE="/tmp/skill-test/nixify-prtmpl"

assert_contains() {
    local needle="$1" haystack="$2"
    [[ "$haystack" == *"$needle"* ]] || {
        echo "expected '$needle' in: '$haystack'" >&3
        return 1
    }
}

setup_scenario() {
    local scenario="$1"
    local dir="$TEST_BASE/$scenario"
    rm -rf "$dir"
    mkdir -p "$dir"
    echo "$dir"
}

@test "detects single-file PR template in .github/" {
    dir=$(setup_scenario single)
    mkdir -p "$dir/.github"
    echo "# template" > "$dir/.github/pull_request_template.md"
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '.github/pull_request_template.md' "$output"
    assert_contains '"has_pr_template":true' "$output"
    assert_contains '"action":"conform"' "$output"
}

@test "detects multi-template PULL_REQUEST_TEMPLATE/ directory contents" {
    dir=$(setup_scenario multi)
    mkdir -p "$dir/.github/PULL_REQUEST_TEMPLATE"
    echo "- [ ] x" > "$dir/.github/PULL_REQUEST_TEMPLATE/bugfix.md"
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains 'PULL_REQUEST_TEMPLATE/bugfix.md' "$output"
    assert_contains '"has_pr_template":true' "$output"
}

@test "detects root and docs/ template locations" {
    dir=$(setup_scenario locations)
    echo "x" > "$dir/pull_request_template.md"
    mkdir -p "$dir/docs"
    echo "x" > "$dir/docs/PULL_REQUEST_TEMPLATE.md"
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains 'pull_request_template.md' "$output"
    assert_contains 'docs/PULL_REQUEST_TEMPLATE.md' "$output"
}

@test "detects ISSUE_TEMPLATE directory" {
    dir=$(setup_scenario issue)
    mkdir -p "$dir/.github/ISSUE_TEMPLATE"
    echo "x" > "$dir/.github/ISSUE_TEMPLATE/bug.md"
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '.github/ISSUE_TEMPLATE/bug.md' "$output"
    assert_contains '"has_issue_templates":true' "$output"
}

@test "flags pull_request_target workflows as template enforcement" {
    dir=$(setup_scenario enforcement)
    mkdir -p "$dir/.github/workflows"
    cat > "$dir/.github/workflows/pr-policy.yml" <<'EOF'
on:
  pull_request_target:
jobs:
  policy:
    runs-on: ubuntu-latest
    steps:
      - run: echo "check body"
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '.github/workflows/pr-policy.yml' "$output"
    assert_contains '"has_template_enforcement":true' "$output"
    assert_contains '"action":"conform"' "$output"
}

@test "flags workflows that read pull_request.body" {
    dir=$(setup_scenario bodycheck)
    mkdir -p "$dir/.github/workflows"
    cat > "$dir/.github/workflows/check.yml" <<'EOF'
on:
  pull_request:
jobs:
  body-check:
    runs-on: ubuntu-latest
    steps:
      - run: |
          body="${{ github.event.pull_request.body }}"
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '"has_template_enforcement":true' "$output"
}

@test "plain pull_request workflow without body read is not enforcement" {
    dir=$(setup_scenario plainwf)
    mkdir -p "$dir/.github/workflows"
    cat > "$dir/.github/workflows/ci.yml" <<'EOF'
on:
  pull_request:
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: make test
EOF
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '"has_template_enforcement":false' "$output"
}

@test "reports standalone for a repo with no templates" {
    dir=$(setup_scenario empty)
    echo "x" > "$dir/README.md"
    run bash "$DETECT_SCRIPT" "$dir"
    [ "$status" -eq 0 ]
    assert_contains '"action":"standalone"' "$output"
    assert_contains '"has_pr_template":false' "$output"
}

@test "fails on missing directory" {
    run bash "$DETECT_SCRIPT" /tmp/skill-test/nonexistent-dir-xyz
    [ "$status" -eq 1 ]
    assert_contains 'not found' "$output"
}
