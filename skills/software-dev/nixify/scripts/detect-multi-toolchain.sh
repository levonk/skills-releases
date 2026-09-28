#!/usr/bin/env bash
# detect-multi-toolchain.sh — detect multi-toolchain desktop app frameworks
# Usage: detect-multi-toolchain.sh [project-dir] [--verbose]
#
# Detects projects that combine multiple toolchains (Rust + Node/Bun, Go + web,
# etc.) coordinated by a desktop app framework. These projects exceed the
# single-language nixify templates and need a framework-specific template
# (e.g. source-build/tauri.md) instead of source-build/rust.md or
# source-build/node-complex.md.
#
# Currently detects:
#   - Tauri (src-tauri/tauri.conf.json + Cargo.toml with tauri dep)
#   - Wails (wails.json + go.mod with wails dep) — detected but no template yet
#   - Electron-with-native (electron + native addon via node-gyp) — detected
#     but routed to node-complex.md with a note
#
# Output: JSON with:
#   - is_multi_toolchain:      true if a multi-toolchain framework is detected
#   - framework:               "tauri" | "wails" | "electron-native" | "none"
#   - toolchains:              array of toolchain names (e.g. ["rust","node","bun"])
#   - recommended_template:    "source-build/tauri.md" or "" (empty if none)
#   - signals:                 array of { signal, source, detail }
#   - needs_subagent_validation: true if non-deterministic checks are required
#   - subagent_checks:         array of strings for the subagent to verify
#   - rationale:               short human-readable summary
#
# The script is conservative: it only reports a framework when it finds
# concrete signals. When is_multi_toolchain=true, the agent MUST use the
# recommended_template instead of the single-language templates.
#
# Use --verbose for full scan details.

set -euo pipefail

DIR="${1:-.}"
VERBOSE=""
if [ "${2:-}" = "--verbose" ]; then
	VERBOSE="--verbose"
fi

if [ ! -d "$DIR" ]; then
	echo "error: directory '$DIR' not found" >&2
	exit 1
fi

signals_file=$(mktemp)
trap 'rm -f "$signals_file"' EXIT

# Format: signal|source|detail
add_signal() {
	echo "$1|$2|$3" >>"$signals_file"
}

framework="none"
toolchains_json="[]"
recommended_template=""
needs_subagent="false"
subagent_checks="[]"
rationale="No multi-toolchain desktop app framework detected. Proceed with single-language template routing."

# ── 1. Tauri detection ───────────────────────────────────────────────────────
# Tauri projects have:
#   - A src-tauri/ directory (or similar) containing tauri.conf.json
#   - A Cargo.toml with a tauri dependency
#   - A frontend (Svelte, React, Vue, etc.) built with a JS package manager
tauri_found=0
tauri_conf=""
tauri_cargo=""

# Search for tauri.conf.json at common depths
while IFS= read -r conf; do
	case "$conf" in
	*/node_modules/*) continue ;;
	*/.git/*) continue ;;
	*/target/*) continue ;;
	esac
	tauri_conf="$conf"
	tauri_found=1
	add_signal "tauri.conf.json" "$conf" "Tauri configuration file found"
	break
done < <(find "$DIR" -maxdepth 3 -name "tauri.conf.json" -not -path "*/node_modules/*" -not -path "*/target/*" 2>/dev/null || true)

if [ "$tauri_found" -eq 1 ]; then
	# Verify Cargo.toml has a tauri dependency
	tauri_dir=$(dirname "$tauri_conf")
	tauri_cargo="$tauri_dir/Cargo.toml"
	if [ -f "$tauri_cargo" ]; then
		if grep -qi '^\s*tauri\s*=' "$tauri_cargo" 2>/dev/null || grep -qi '^\s*tauri\s*=' "$tauri_cargo" 2>/dev/null; then
			add_signal "tauri dependency" "$tauri_cargo" "Cargo.toml depends on tauri"
		else
			# tauri.conf.json exists but no tauri dep in the adjacent Cargo.toml
			# — might be a subdirectory; search wider
			if grep -rqi 'tauri\s*=' "$DIR"/**/Cargo.toml 2>/dev/null | head -1 | grep -q .; then
				add_signal "tauri dependency" "Cargo.toml (search)" "tauri dependency found in a Cargo.toml"
			else
				# tauri.conf.json without a tauri cargo dep — probably not Tauri
				tauri_found=0
			fi
		fi
	else
		# tauri.conf.json without an adjacent Cargo.toml — unusual but count it
		add_signal "tauri.conf.json without adjacent Cargo.toml" "$tauri_conf" "Config exists but no Cargo.toml in the same directory"
	fi
fi

# Detect toolchains for Tauri projects
if [ "$tauri_found" -eq 1 ]; then
	framework="tauri"
	recommended_template="source-build/tauri.md"
	toolchains_list="rust"

	# Check for Node.js / pnpm / npm / yarn
	if [ -f "$DIR/package.json" ] || [ -f "$DIR/pnpm-lock.yaml" ] || [ -f "$DIR/package-lock.json" ] || [ -f "$DIR/yarn.lock" ]; then
		toolchains_list="$toolchains_list,node"
		add_signal "node toolchain" "$DIR/package.json or lockfile" "JS package manager present for frontend build"
	fi

	# Check for Bun (separate from Node — Tauri projects sometimes use bun for sidecars)
	bun_found=0
	if [ -f "$DIR/bun.lock" ] || [ -f "$DIR/bun.lockb" ]; then
		bun_found=1
	else
		# Check subdirectories for bun lockfiles (sidecar packages)
		while IFS= read -r bunlock; do
			case "$bunlock" in
			*/node_modules/*) continue ;;
			*/.git/*) continue ;;
			esac
			bun_found=1
			add_signal "bun toolchain" "$bunlock" "Bun lockfile found in subdirectory (likely a sidecar)"
			break
		done < <(find "$DIR" -maxdepth 3 \( -name "bun.lock" -o -name "bun.lockb" \) -not -path "*/node_modules/*" 2>/dev/null || true)
	fi
	if [ "$bun_found" -eq 1 ]; then
		toolchains_list="$toolchains_list,bun"
	fi

	# Check for package.json scripts that invoke bun (hard requirement signal)
	if [ -f "$DIR/package.json" ]; then
		if grep -q '"bun"' "$DIR/package.json" 2>/dev/null; then
			if [ "$bun_found" -eq 0 ]; then
				toolchains_list="$toolchains_list,bun"
				bun_found=1
			fi
			add_signal "bun in package.json" "$DIR/package.json" "package.json references bun"
		fi
	fi

	# Check for git dependencies in Cargo.toml (common in Tauri projects)
	git_deps=0
	if [ -f "$tauri_cargo" ]; then
		if grep -q 'git\s*=' "$tauri_cargo" 2>/dev/null; then
			git_deps=1
			add_signal "git cargo dependencies" "$tauri_cargo" "Cargo.toml has git= dependencies (need cargoLock.outputHashes)"
		fi
	fi

	# Check for vendored crates
	if find "$tauri_dir" -maxdepth 2 -type d -name "vendor" 2>/dev/null | grep -q .; then
		add_signal "vendored crates" "$tauri_dir/vendor/" "Vendored crate directory found (path patch in Cargo.toml)"
	fi

	# Check for code signing / updater config in tauri.conf.json
	if [ -f "$tauri_conf" ]; then
		if grep -q 'createUpdaterArtifacts' "$tauri_conf" 2>/dev/null && grep -q 'true' "$tauri_conf" 2>/dev/null; then
			add_signal "updater artifacts" "$tauri_conf" "createUpdaterArtifacts is true — must disable for Nix builds"
		fi
	fi

	toolchains_json="[$(echo "$toolchains_list" | sed 's/\([^,]*\)/"\1"/g')]"

	# Subagent checks for Tauri
	needs_subagent="true"
	subagent_checks='['
	need_comma=0

	subagent_checks="$subagent_checks\"Verify the exact build order required by the project (e.g. SDK → bun sidecar → vite frontend → cargo/tauri). The Tauri build.rs may stage resources from sibling directories — confirm the order matches scripts/build.mjs or equivalent.\""
	need_comma=1

	if [ "$need_comma" -eq 1 ]; then subagent_checks="$subagent_checks,"; fi
	subagent_checks="$subagent_checks\"Verify whether bun is a hard requirement for the build (some Tauri projects use bun only for sidecar bundling and could substitute esbuild). If bun is required, confirm bun2nix or an equivalent Nix packaging approach is available.\""

	if [ "$git_deps" -eq 1 ]; then
		if [ "$need_comma" -eq 1 ]; then subagent_checks="$subagent_checks,"; fi
		subagent_checks="$subagent_checks\"Discover the outputHashes for each git cargo dependency: set hash = \\\"sha256-AAA...\\\" (fake), run nix build, copy the correct hash from the error output, replace, rebuild. List each git dep and its repo URL for the subagent to catalog.\""
	fi

	subagent_checks="$subagent_checks]"

	bun_sidecar_note=""
	if [ "$bun_found" -eq 1 ]; then
		bun_sidecar_note=" + Bun sidecar"
	fi
	rationale="Detected Tauri desktop app framework (Rust + JS frontend${bun_sidecar_note}). Use source-build/tauri.md (cargo-tauri.hook + pnpm.fetchDeps + bun2nix). Subagent validation required for build order, bun requirement, and git cargo dep hashes."
fi

# ── 2. Wails detection (Go + web frontend) ───────────────────────────────────
# Wails projects have wails.json and a go.mod with a wails dependency.
# Detected but no template yet — routed to source-build/go.md with a note.
wails_found=0
if [ -f "$DIR/wails.json" ]; then
	wails_found=1
	add_signal "wails.json" "$DIR/wails.json" "Wails configuration file found"
	if [ -f "$DIR/go.mod" ] && grep -qi 'wails' "$DIR/go.mod" 2>/dev/null; then
		add_signal "wails dependency" "$DIR/go.mod" "go.mod depends on wails"
	else
		wails_found=0
	fi
fi

if [ "$wails_found" -eq 1 ] && [ "$tauri_found" -eq 0 ]; then
	framework="wails"
	toolchains_json='["go","node"]'
	recommended_template=""  # No Wails template yet — fall through to go.md
	needs_subagent="true"
	subagent_checks='["Wails projects combine Go + web frontend. No dedicated Wails template exists yet — use source-build/go.md as a base and manually handle the frontend build in preBuild. Document the gap in the PR body."]'
	rationale="Detected Wails desktop app framework (Go + web frontend). No dedicated template yet — use source-build/go.md as a base with manual frontend build handling."
fi

# ── 3. Electron-with-native detection ────────────────────────────────────────
# Electron projects with native addons (node-gyp) are multi-toolchain in the
# sense that they need native compilation beyond standard Node.js packaging.
# Routed to node-complex.md with a note.
electron_found=0
if [ -f "$DIR/package.json" ]; then
	if grep -qi '"electron"' "$DIR/package.json" 2>/dev/null; then
		electron_found=1
		add_signal "electron dependency" "$DIR/package.json" "package.json depends on electron"
	fi
fi

if [ "$electron_found" -eq 1 ] && [ "$tauri_found" -eq 0 ] && [ "$wails_found" -eq 0 ]; then
	framework="electron-native"
	toolchains_json='["node"]'
	recommended_template=""  # Use node-complex.md — no separate template
	needs_subagent="true"
	subagent_checks='["Electron with native addons: use source-build/node-complex.md. Verify native addon rebuild hooks (npm rebuild, node-gyp) work in the Nix sandbox. Electron itself may need to be provided via nixpkgs.electron rather than npm-installed.\"]'
	rationale="Detected Electron with native addons. Use source-build/node-complex.md with attention to native addon rebuilds and Electron packaging."
fi

# ── Build signals JSON ───────────────────────────────────────────────────────
signals_json="[]"
if [ -s "$signals_file" ]; then
	signals_json="["
	first=1
	while IFS='|' read -r signal source detail; do
		if [ "$first" -eq 0 ]; then signals_json="$signals_json,"; fi
		first=0
		detail_esc="${detail//\"/\\\"}"
		signals_json="$signals_json{\"signal\":\"$signal\",\"source\":\"$source\",\"detail\":\"$detail_esc\"}"
	done <"$signals_file"
	signals_json="$signals_json]"
fi

# ── Output ───────────────────────────────────────────────────────────────────
is_multi="false"
if [ "$framework" != "none" ]; then
	is_multi="true"
fi

# Escape rationale for JSON
rationale_esc="${rationale//\"/\\\"}"

cat <<EOF
{
  "is_multi_toolchain": $is_multi,
  "framework": "$framework",
  "toolchains": $toolchains_json,
  "recommended_template": "$recommended_template",
  "signals": $signals_json,
  "needs_subagent_validation": $needs_subagent,
  "subagent_checks": $subagent_checks,
  "rationale": "$rationale_esc"
}
EOF

if [ -n "$VERBOSE" ]; then
	echo "---" >&2
	echo "Scan details:" >&2
	echo "  framework: $framework" >&2
	echo "  is_multi_toolchain: $is_multi" >&2
	echo "  toolchains: $toolchains_json" >&2
	echo "  recommended_template: $recommended_template" >&2
	if [ -s "$signals_file" ]; then
		echo "  signals:" >&2
		while IFS='|' read -r signal source detail; do
			echo "    - $signal ($source) — $detail" >&2
		done <"$signals_file"
	fi
fi
