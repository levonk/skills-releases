#!/usr/bin/env bats
# test_discover_contribution_standards.bats — regression tests for
# discover-contribution-standards.sh
#
# Regression context: the fetch path used to pipe `jq -r '.content'` into
# `base64 -d`. For a 404 response ({"message":"Not Found"}) jq prints the
# literal string "null", which base64 decodes to 3 bytes of binary garbage
# (rendered as "e"). Every probed path was then reported as "**Found**" with
# a non-UTF-8 body, and phantom CONTRIBUTORS/cla.yml hits produced a
# spurious "CLA likely required" warning.
#
# The fix requires HTTP 200 + {"type":"file","content":...} + valid UTF-8.
# These tests pin that behavior:
#   - all-404 repo: zero "Found" lines, no CLA warning, valid UTF-8 cache
#   - one real file: reported found with decoded content, others still absent
#   - live check (skip without network): a repo with no standards files
#     produces zero "Found" lines

SCRIPT_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")" && pwd)"
SCRIPT="$SCRIPT_DIR/../discover-contribution-standards.sh"

setup() {
	MOCK_BIN="$BATS_TEST_TMPDIR/mockbin"
	TEST_CACHE="$BATS_TEST_TMPDIR/cache"
	mkdir -p "$MOCK_BIN" "$TEST_CACHE"

	# Mock curl: returns GitHub's 404 JSON for every /contents/ path, and a
	# user-owned repo object for bare /repos/<owner>/<repo>. When
	# MOCK_FILE_PATH is set, that contents path returns a real file object.
	cat >"$MOCK_BIN/curl" <<'EOF'
#!/usr/bin/env bash
url=""
write_out=""
while [ $# -gt 0 ]; do
	case "$1" in
	-w)
		write_out="$2"
		shift 2
		;;
	-*)
		shift
		;;
	*)
		url="$1"
		shift
		;;
	esac
done

emit_write_out() {
	local code="$1"
	# The script uses exactly one -w format: $'\n%{http_code}'.
	case "$write_out" in
	*http_code*) printf '\n%s' "$code" ;;
	esac
}

case "$url" in
*"/contents/${MOCK_FILE_PATH:-__never__}")
	printf '{"type":"file","name":"%s","path":"%s","content":"%s","encoding":"base64"}' \
		"${MOCK_FILE_PATH##*/}" "$MOCK_FILE_PATH" "${MOCK_FILE_B64:-}"
	emit_write_out "200"
	;;
*/contents/*)
	printf '%s' '{"message":"Not Found","documentation_url":"https://docs.github.com/rest/repos/contents#get-repository-content"}'
	emit_write_out "404"
	;;
*/repos/*)
	printf '{"owner":{"login":"%s","type":"User"}}' "${MOCK_OWNER_LOGIN:-test-owner}"
	emit_write_out "200"
	;;
*)
	emit_write_out "000"
	;;
esac
EOF
	chmod +x "$MOCK_BIN/curl"
}

cache_file() {
	echo "$TEST_CACHE/skills/levonk/skills-src/skills/test-skill/github/TestOwner/test-repo/standards.md"
}

@test "all-404 repo: zero Found lines, no CLA warning, valid UTF-8" {
	run env PATH="$MOCK_BIN:$PATH" XDG_CACHE_HOME="$TEST_CACHE" \
		bash "$SCRIPT" TestOwner test-repo --skill test-skill --force
	[ "$status" -eq 0 ]

	local cache
	cache="$(cache_file)"
	[ -f "$cache" ]

	# No path may be reported as found
	! grep -q "Found" "$cache"

	# No spurious CLA signal from phantom files
	! grep -q "CLA likely required" "$cache"
	grep -q "No CLA/DCO signals detected" "$cache"

	# Explicit not-found messages for every probed section
	grep -q "No CONTRIBUTING.md found" "$cache"
	grep -q "No issue templates found" "$cache"
	grep -q "No PR template found" "$cache"
	grep -q "No CHANGELOG.md found" "$cache"

	# Cache body must be valid UTF-8 (no decoded-garbage bytes)
	iconv -f UTF-8 -t UTF-8 "$cache" >/dev/null
}

@test "real file is reported found; other paths still absent" {
	MOCK_FILE_PATH="CONTRIBUTING.md"
	export MOCK_FILE_PATH
	export MOCK_FILE_B64
	MOCK_FILE_B64="$(printf '# Contributing\n\nRun tests before submitting.\n' | base64)"

	run env PATH="$MOCK_BIN:$PATH" XDG_CACHE_HOME="$TEST_CACHE" \
		MOCK_FILE_PATH="$MOCK_FILE_PATH" MOCK_FILE_B64="$MOCK_FILE_B64" \
		bash "$SCRIPT" TestOwner test-repo --skill test-skill --force
	[ "$status" -eq 0 ]

	local cache
	cache="$(cache_file)"

	# The real file is found with its decoded body
	grep -q 'Found at.*CONTRIBUTING.md' "$cache"
	grep -q "Run tests before submitting" "$cache"

	# Everything else stays not-found — exactly one Found line total
	[ "$(grep -c "Found" "$cache")" -eq 1 ]
	! grep -q "CLA likely required" "$cache"
}

@test "live: repo with no standards files produces zero Found lines" {
	# Requires network + GitHub API. Skip when unreachable.
	command -v curl >/dev/null 2>&1 || skip "curl unavailable"
	curl -sf --max-time 10 -o /dev/null "https://api.github.com" 2>/dev/null ||
		skip "GitHub API unreachable"

	# Known repo with none of CONTRIBUTING.md, PR templates, CLA configs,
	# CONTRIBUTORS, CODEOWNERS, CHANGELOG.md, or AGENTS.md.
	run env XDG_CACHE_HOME="$TEST_CACHE" \
		bash "$SCRIPT" SaarthurR atticus-mac --skill test-skill --force
	[ "$status" -eq 0 ]

	local cache
	cache="$TEST_CACHE/skills/levonk/skills-src/skills/test-skill/github/SaarthurR/atticus-mac/standards.md"
	[ -f "$cache" ]
	! grep -q "Found" "$cache"
	! grep -q "CLA likely required" "$cache"
	iconv -f UTF-8 -t UTF-8 "$cache" >/dev/null
}
