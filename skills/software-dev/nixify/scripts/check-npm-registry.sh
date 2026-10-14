#!/usr/bin/env bash
# check-npm-registry.sh — detect whether a Node.js project is eligible for the
# npm registry tarball flake route (references/flake-templates/npm-registry-tarball.md)
# Usage: check-npm-registry.sh [project-dir] [--verbose]
#
# The registry tarball route uses `buildNpmPackage` over `fetchurl` of the
# published npm tarball — skipping the project's build pipeline entirely when
# the tarball already ships compiled output. This probe reports the facts the
# Step 12 routing decision needs; the final choice between
# `npm_registry_tarball` and a source build also weighs `is_complex` from
# classify-node-complexity.sh (registry tarball wins on complex builds).
#
# Output: JSON with:
#   - applicable:                     false when the project is not Node.js
#   - pkg_name:                       package.json "name" (may be scoped)
#   - local_version:                  package.json "version"
#   - has_bin:                        package.json declares bin entries
#   - is_published:                   npm view succeeded — package is on npm
#   - published_version:              latest version on the registry
#   - tarball_url:                    dist.tarball URL for the latest version
#   - bin_targets_exist:              every bin target is inside the tarball
#   - bin_targets_are_typescript:     bin targets are .ts files (not runnable)
#   - tarball_has_compiled_output:    tarball contains dist/|lib/|build/|out/
#   - tarball_has_lockfile:           package-lock.json or npm-shrinkwrap.json shipped
#   - tarball_has_gypfile:            binding.gyp shipped (compiles on install)
#   - native_deps:                    deps known to ship native addons
#   - node_engine:                    published engines.node (local fallback)
#   - npm_registry_tarball_eligible:  is_published && has_bin &&
#                                     bin_targets_exist && !typescript bins
#   - signals:                        array of { signal, source, detail }
#   - rationale:                      short human-readable summary
#
# The script is a probe: it exits 0 and reports facts even when the project
# is ineligible or npm/network is unavailable (is_published=false and
# npm_registry_tarball_eligible=false in that case). It exits 1 only on
# usage errors (missing directory).
#
# Use --verbose for full scan details on stderr.

set -euo pipefail

DIR="."
VERBOSE=""
for arg in "$@"; do
	case "$arg" in
	--verbose) VERBOSE="--verbose" ;;
	-h | --help)
		echo "Usage: $0 [project-dir] [--verbose]"
		exit 0
		;;
	-*) echo "error: unknown flag '$arg'" >&2; exit 1 ;;
	*) DIR="$arg" ;;
	esac
done

if [ ! -d "$DIR" ]; then
	echo "error: directory '$DIR' not found" >&2
	exit 1
fi

vlog() {
	if [ -n "$VERBOSE" ]; then
		echo "[check-npm-registry] $*" >&2
	fi
}

signals_file=$(mktemp)
tmp_dir=$(mktemp -d)
trap 'rm -f "$signals_file"; rm -rf "$tmp_dir"' EXIT

add_signal() {
	echo "$1|$2|$3" >>"$signals_file"
}

json_array_from_file() {
	# Emit a JSON array from a newline-separated list file (empty file -> [])
	if [ -s "$1" ]; then
		jq -R . "$1" | jq -s .
	else
		echo "[]"
	fi
}

if ! command -v jq >/dev/null 2>&1; then
	echo "error: jq is required (run via devbox run -- ...)" >&2
	exit 1
fi

PKG="$DIR/package.json"
if [ ! -f "$PKG" ]; then
	cat <<'EOF'
{"applicable": false, "rationale": "No package.json — not a Node.js project; npm registry tarball route does not apply."}
EOF
	exit 0
fi

PKG_NAME=$(jq -r '.name // empty' "$PKG")
PKG_PRIVATE=$(jq -r '.private // false' "$PKG")
PKG_VERSION=$(jq -r '.version // empty' "$PKG")
LOCAL_ENGINE=$(jq -r '.engines.node // empty' "$PKG")

# bin entries: string form ("bin": "./cli.js") or object form
# ("bin": {"a": "...", "b": "..."}). Collect the target paths.
BIN_PATHS_FILE="$tmp_dir/bin_paths"
jq -r 'if .bin == null then empty
       elif (.bin | type) == "string" then .bin
       else (.bin | to_entries[].value) end' "$PKG" >"$BIN_PATHS_FILE"

HAS_BIN=false
if [ -s "$BIN_PATHS_FILE" ]; then
	HAS_BIN=true
fi

vlog "pkg_name=$PKG_NAME private=$PKG_PRIVATE version=$PKG_VERSION engine=$LOCAL_ENGINE"
vlog "bin paths: $(tr '\n' ' ' <"$BIN_PATHS_FILE")"

# Native deps — packages whose install may compile or fetch binaries in the
# sandbox. Prefixed entries (@swc/core) match exactly; the rest are exact
# dependency names.
KNOWN_NATIVES='better-sqlite3 sqlite3 sharp esbuild bcrypt canvas node-sass @swc/core node-pty node-gyp-build prebuild-install node-pre-gyp @parcel/watcher utf-8-validate bufferutil re2 ssh2 cpu-features kerberos grpc farmhash'
DEPS_FILE="$tmp_dir/deps"
jq -r '[(.dependencies // {}), (.optionalDependencies // {})] | map(keys) | add | .[]' "$PKG" >"$DEPS_FILE" 2>/dev/null || true

NATIVE_DEPS_FILE="$tmp_dir/native_deps"
: >"$NATIVE_DEPS_FILE"
if [ -s "$DEPS_FILE" ]; then
	while IFS= read -r dep; do
		for n in $KNOWN_NATIVES; do
			if [ "$dep" = "$n" ]; then
				echo "$dep" >>"$NATIVE_DEPS_FILE"
				add_signal "native_dep" "$PKG" "depends on $dep — verify it ships N-API prebuilds in its own npm tarball"
			fi
		done
	done <"$DEPS_FILE"
fi

NATIVE_DEPS_JSON=$(json_array_from_file "$NATIVE_DEPS_FILE")

# Early exits that don't need the network.
if [ "$PKG_PRIVATE" = "true" ]; then
	add_signal "private_package" "$PKG" "private: true — not published to npm"
	jq -n --arg n "$PKG_NAME" --argjson b "$HAS_BIN" --argjson d "$NATIVE_DEPS_JSON" \
		'{"applicable": true, "pkg_name": $n, "has_bin": $b, "is_published": false, "native_deps": $d, "npm_registry_tarball_eligible": false, "rationale": "package.json has private: true — the package is not published to npm, so there is no registry tarball to wrap. Use a source build."}'
	exit 0
fi

if [ "$HAS_BIN" = "false" ]; then
	jq -n --arg n "$PKG_NAME" --argjson d "$NATIVE_DEPS_JSON" \
		'{"applicable": true, "pkg_name": $n, "has_bin": false, "is_published": false, "native_deps": $d, "npm_registry_tarball_eligible": false, "rationale": "No bin entries in package.json — the package is a library, not an installable CLI. The registry tarball route targets tools runnable via nix run; use a source build if the project still needs a flake."}'
	exit 0
fi

if [ -z "$PKG_NAME" ]; then
	jq -n --argjson b "$HAS_BIN" --argjson d "$NATIVE_DEPS_JSON" \
		'{"applicable": true, "pkg_name": null, "has_bin": $b, "is_published": false, "native_deps": $d, "npm_registry_tarball_eligible": false, "rationale": "package.json has no name field — cannot query the npm registry."}'
	exit 0
fi

# ── Registry checks ──────────────────────────────────────────────────────────

IS_PUBLISHED=false
PUBLISHED_VERSION=""
TARBALL_URL=""
REGISTRY_ENGINE=""

if command -v npm >/dev/null 2>&1; then
	PUBLISHED_VERSION=$(npm view "$PKG_NAME" version 2>/dev/null | tail -1 || true)
	if [ -n "$PUBLISHED_VERSION" ]; then
		IS_PUBLISHED=true
		TARBALL_URL=$(npm view "$PKG_NAME@$PUBLISHED_VERSION" dist.tarball 2>/dev/null || true)
		REGISTRY_ENGINE=$(npm view "$PKG_NAME@$PUBLISHED_VERSION" engines.node 2>/dev/null || true)
		vlog "published_version=$PUBLISHED_VERSION tarball_url=$TARBALL_URL engine=$REGISTRY_ENGINE"
	else
		vlog "npm view $PKG_NAME failed — not published (or private scope without auth)"
	fi
else
	vlog "npm not on PATH — skipping registry checks"
fi

BIN_TARGETS_EXIST=false
BIN_TS=false
HAS_COMPILED_OUTPUT=false
HAS_LOCKFILE=false
HAS_GYPFILE=false

if [ "$IS_PUBLISHED" = "true" ] && [ -n "$TARBALL_URL" ]; then
	LISTING="$tmp_dir/tarball-listing"
	if curl -fsSL "$TARBALL_URL" -o "$tmp_dir/pkg.tgz" 2>/dev/null && tar tzf "$tmp_dir/pkg.tgz" >"$LISTING" 2>/dev/null; then
		vlog "tarball entries: $(wc -l <"$LISTING" | tr -d ' ')"

		# npm tarballs are rooted at package/
		if grep -qxF 'package/package-lock.json' "$LISTING" || grep -qxF 'package/npm-shrinkwrap.json' "$LISTING"; then
			HAS_LOCKFILE=true
			add_signal "lockfile_in_tarball" "npm tarball" "tarball ships a lockfile — use it directly, no generated lockfile needed"
		fi
		if grep -qxF 'package/binding.gyp' "$LISTING"; then
			HAS_GYPFILE=true
			add_signal "gypfile_in_tarball" "npm tarball" "binding.gyp shipped — install compiles a native addon in the sandbox"
		fi
		if grep -qE '^package/(dist|lib|build|out)/' "$LISTING"; then
			HAS_COMPILED_OUTPUT=true
		fi

		# Every bin target must exist inside the tarball for the route to work.
		all_exist=true
		while IFS= read -r bpath; do
			# Strip leading ./ from the declared target
			bpath="${bpath#./}"
			if ! grep -qxF "package/$bpath" "$LISTING"; then
				all_exist=false
				add_signal "bin_target_missing" "npm tarball" "bin target '$bpath' is not in the published tarball — it is a build output the tarball omits"
			fi
			case "$bpath" in
			*.ts | *.mts | *.cts)
				BIN_TS=true
				add_signal "typescript_bin" "npm tarball" "bin target '$bpath' is TypeScript — shipped but not runnable without a build"
				;;
			esac
		done <"$BIN_PATHS_FILE"
		BIN_TARGETS_EXIST=$all_exist
	else
		vlog "failed to fetch or list tarball at $TARBALL_URL"
		add_signal "tarball_fetch_failed" "$TARBALL_URL" "could not download/list the npm tarball — treating as ineligible"
	fi
fi

ELIGIBLE=false
if [ "$IS_PUBLISHED" = "true" ] && [ "$BIN_TARGETS_EXIST" = "true" ] && [ "$BIN_TS" = "false" ]; then
	ELIGIBLE=true
fi

NODE_ENGINE="${REGISTRY_ENGINE:-$LOCAL_ENGINE}"

if [ "$ELIGIBLE" = "true" ]; then
	RATIONALE="Published npm tarball ships all bin targets (compiled output present: $HAS_COMPILED_OUTPUT, lockfile shipped: $HAS_LOCKFILE). Eligible for the npm registry tarball route — prefer it over a source build when classify-node-complexity.sh reports is_complex=true."
elif [ "$IS_PUBLISHED" = "true" ]; then
	RATIONALE="Package is published to npm but the tarball does not ship runnable bin targets — use a source build."
elif [ "$IS_PUBLISHED" = "false" ] && command -v npm >/dev/null 2>&1; then
	RATIONALE="Package '$PKG_NAME' is not on the npm registry — no registry tarball to wrap. Use a source build."
else
	RATIONALE="npm unavailable — could not check the registry. Re-run with npm on PATH (devbox run -- ...) before choosing this route."
fi

SIGNALS_JSON="[]"
if [ -s "$signals_file" ]; then
	SIGNALS_JSON=$(jq -R . "$signals_file" | jq -s 'map(split("|") | {signal: .[0], source: .[1], detail: .[2]})')
fi

jq -n \
	--arg pkg_name "$PKG_NAME" \
	--arg local_version "$PKG_VERSION" \
	--arg published_version "$PUBLISHED_VERSION" \
	--arg tarball_url "$TARBALL_URL" \
	--arg node_engine "$NODE_ENGINE" \
	--arg rationale "$RATIONALE" \
	--argjson has_bin "$HAS_BIN" \
	--argjson is_published "$IS_PUBLISHED" \
	--argjson bin_targets_exist "$BIN_TARGETS_EXIST" \
	--argjson bin_targets_are_typescript "$BIN_TS" \
	--argjson tarball_has_compiled_output "$HAS_COMPILED_OUTPUT" \
	--argjson tarball_has_lockfile "$HAS_LOCKFILE" \
	--argjson tarball_has_gypfile "$HAS_GYPFILE" \
	--argjson native_deps "$(json_array_from_file "$NATIVE_DEPS_FILE")" \
	--argjson signals "$SIGNALS_JSON" \
	--argjson eligible "$ELIGIBLE" \
	'{
	  applicable: true,
	  pkg_name: $pkg_name,
	  local_version: $local_version,
	  published_version: $published_version,
	  tarball_url: $tarball_url,
	  node_engine: $node_engine,
	  has_bin: $has_bin,
	  is_published: $is_published,
	  bin_targets_exist: $bin_targets_exist,
	  bin_targets_are_typescript: $bin_targets_are_typescript,
	  tarball_has_compiled_output: $tarball_has_compiled_output,
	  tarball_has_lockfile: $tarball_has_lockfile,
	  tarball_has_gypfile: $tarball_has_gypfile,
	  native_deps: $native_deps,
	  signals: $signals,
	  npm_registry_tarball_eligible: $eligible,
	  rationale: $rationale
	}'

if [ -n "$VERBOSE" ]; then
	echo "---" >&2
	vlog "is_published=$IS_PUBLISHED bin_targets_exist=$BIN_TARGETS_EXIST bin_ts=$BIN_TS"
	vlog "compiled_output=$HAS_COMPILED_OUTPUT lockfile=$HAS_LOCKFILE gypfile=$HAS_GYPFILE"
	vlog "native_deps: $(tr '\n' ' ' <"$NATIVE_DEPS_FILE")"
	vlog "eligible=$ELIGIBLE"
fi
