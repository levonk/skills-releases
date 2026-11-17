#!/usr/bin/env bats
# test_search_nixpkgs_prs.bats — unit tests for search-nixpkgs-prs.sh
#
# The script shells out to `gh search prs` / `gh issue list`; tests stub gh
# with a fixture dispatcher on PATH so no network is needed.
#
# Run via:
#   bats scripts/tests/test_search_nixpkgs_prs.bats

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME:-${BASH_SOURCE[0]}}")" && pwd)"
SEARCH_SCRIPT="$SCRIPT_DIR/../search-nixpkgs-prs.sh"
TEST_BASE="/tmp/skill-test/nixify-search-nixpkgs"

setup() {
	rm -rf "$TEST_BASE"
	mkdir -p "$TEST_BASE/bin"
}

# Install a fake `gh` that returns fixture JSON for prs and issues.
# $1 = prs fixture file, $2 = issues fixture file (default "[]")
install_fake_gh() {
	local prs_fixture="$1"
	local issues_fixture="${2:-[]}"
	cat > "$TEST_BASE/bin/gh" <<EOF
#!/usr/bin/env bash
for arg in "\$@"; do
	case "\$arg" in
		search) MODE="prs" ;;
	esac
done
if [ "\${1:-}" = "search" ] && [ "\${2:-}" = "prs" ]; then
	cat "$prs_fixture"
elif [ "\${1:-}" = "issue" ] && [ "\${2:-}" = "list" ]; then
	cat <<'ISSUES_EOF'
$issues_fixture
ISSUES_EOF
elif [ "\${1:-}" = "pr" ] && [ "\${2:-}" = "list" ]; then
	cat "$prs_fixture"
else
	echo "unexpected gh call: \$*" >&2
	exit 1
fi
EOF
	chmod +x "$TEST_BASE/bin/gh"
}

prs_fixture() {
	cat > "$TEST_BASE/prs.json"
}

@test "open scoped PR yields coordinate" {
	prs_fixture <<'EOF'
[{"number": 1,"title":"foo: 1.0 -> 2.0","state":"open","url":"u1","updatedAt":"t","author":{"login":"human"},"labels":[{"name":"8.has: package (update)"}]}]
EOF
	install_fake_gh "$TEST_BASE/prs.json"
	PATH="$TEST_BASE/bin:$PATH" run bash "$SEARCH_SCRIPT" foo --version 3.0
	[ "$status" -eq 0 ]
	[[ "$output" == *'"recommendation": "coordinate"'* ]]
	[[ "$output" == *'"number": 1'* ]]
}

@test "open scoped PR already carrying target version yields coordinate_version_match" {
	prs_fixture <<'EOF'
[{"number":2,"title":"foo: 1.0 -> 2.0","state":"open","url":"u2","updatedAt":"t","author":{"login":"r-ryantm"},"labels":[]}]
EOF
	install_fake_gh "$TEST_BASE/prs.json"
	PATH="$TEST_BASE/bin:$PATH" run bash "$SEARCH_SCRIPT" foo --version 2.0
	[ "$status" -eq 0 ]
	[[ "$output" == *'"recommendation": "coordinate_version_match"'* ]]
	[[ "$output" == *'"bot": true'* ]]
}

@test "merged scoped PR carrying target version yields skip_already_landed" {
	prs_fixture <<'EOF'
[{"number":3,"title":"foo: 1.0 -> 2.0","state":"merged","url":"u3","updatedAt":"t","author":{"login":"r-ryantm"},"labels":[]}]
EOF
	install_fake_gh "$TEST_BASE/prs.json"
	PATH="$TEST_BASE/bin:$PATH" run bash "$SEARCH_SCRIPT" foo --version 2.0
	[ "$status" -eq 0 ]
	[[ "$output" == *'"recommendation": "skip_already_landed"'* ]]
}

@test "merged scoped PR without version yields investigate_merged" {
	prs_fixture <<'EOF'
[{"number":4,"title":"foo: fix darwin build","state":"merged","url":"u4","updatedAt":"t","author":{"login":"human"},"labels":[]}]
EOF
	install_fake_gh "$TEST_BASE/prs.json"
	PATH="$TEST_BASE/bin:$PATH" run bash "$SEARCH_SCRIPT" foo --version 2.0
	[ "$status" -eq 0 ]
	[[ "$output" == *'"recommendation": "investigate_merged"'* ]]
}

@test "closed unmerged scoped PR yields proceed_closed_only" {
	prs_fixture <<'EOF'
[{"number":5,"title":"foo: 1.0 -> 2.0","state":"closed","url":"u5","updatedAt":"t","author":{"login":"human"},"labels":[]}]
EOF
	install_fake_gh "$TEST_BASE/prs.json"
	PATH="$TEST_BASE/bin:$PATH" run bash "$SEARCH_SCRIPT" foo --version 2.0
	[ "$status" -eq 0 ]
	[[ "$output" == *'"recommendation": "proceed_closed_only"'* ]]
}

@test "no scoped PRs yields proceed" {
	prs_fixture <<'EOF'
[{"number":6,"title":"unrelated change mentioning foo in body","state":"open","url":"u6","updatedAt":"t","author":{"login":"human"},"labels":[]}]
EOF
	install_fake_gh "$TEST_BASE/prs.json"
	PATH="$TEST_BASE/bin:$PATH" run bash "$SEARCH_SCRIPT" foo --version 2.0
	[ "$status" -eq 0 ]
	[[ "$output" == *'"recommendation": "proceed"'* ]]
	[[ "$output" == *'"other_matches_count": 1'* ]]
}

@test "bot label marks PR as bot even with human author" {
	prs_fixture <<'EOF'
[{"number":7,"title":"foo: 1.0 -> 2.0","state":"open","url":"u7","updatedAt":"t","author":{"login":"somehuman"},"labels":[{"name":"nix-update"}]}]
EOF
	install_fake_gh "$TEST_BASE/prs.json"
	PATH="$TEST_BASE/bin:$PATH" run bash "$SEARCH_SCRIPT" foo
	[ "$status" -eq 0 ]
	[[ "$output" == *'"bot": true'* ]]
}

@test "usage error without package arg" {
	run bash "$SEARCH_SCRIPT"
	[ "$status" -eq 1 ]
}
