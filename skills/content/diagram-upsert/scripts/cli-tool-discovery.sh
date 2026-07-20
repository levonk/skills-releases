#!/usr/bin/env bash
# cli-tool-discovery.sh — resolve a CLI tool through environment wrappers and standard PATH locations
#
# Usage:
#   cli-tool-discovery.sh <tool-name> [--json]          # resolve only, print result
#   cli-tool-discovery.sh -- <tool-name> [args...]      # resolve and exec the tool
#   cli-tool-discovery.sh --runner <ecosystem>          # resolve the ad-hoc runner for an ecosystem
#
# Output (resolve mode, text): FOUND: <path> | WRAPPER: <wrapper-cmd> | NOT_FOUND: <tool>
# Output (resolve mode, json): {"status":"found|wrapper|not_found", "path": "...", "wrapper": "...", "tool": "..."}
# Output (exec mode): the tool's own stdout/stderr/exit code
# Output (runner mode, json only):
#   {"ecosystem":"python","binary":"uv","binary_status":"found|wrapper|not_found",
#    "binary_path":"...","wrapper":"...","script":"uv run --script","package":"uvx",
#    "fallback":"...","fallback_runner":"...","recommendation":"..."}
#
# Resolution order (resolve/exec mode):
#   1. Already on PATH (command -v)
#   2. Environment wrappers (devbox, mise, flox, direnv, nix) — walks up from cwd
#   3. Tech-stack-aware standard PATH locations (30+ dirs)
#   4. Package manager lookup (brew, mise, asdf)
#   5. Reports NOT_FOUND with what was checked
#
# Runner mode (--runner <ecosystem>):
#   Resolves the canonical ad-hoc runner for an ecosystem per the tech-stack table.
#   Supported ecosystems: python, node, rust, go.
#   - python: uv (script: `uv run --script`, package: `uvx`); fallback pip+python3
#   - node:   pnpm on host (`pnpm dlx`), bun in container (`bunx`); no fallback (install pnpm)
#   - rust:   cargo (`cargo binstall` preferred, `cargo install` fallback); no fallback
#   - go:     go (`go install <pkg>@latest`); no fallback
#   When the binary is not_found and a devbox.json exists up the tree, the
#   `recommendation` field tells the caller to add the binary to devbox.json.
set -euo pipefail

# --- Parse args: runner mode vs exec mode vs resolve mode ---
exec_mode=0
json_output=0
runner_mode=0
runner_ecosystem=""
tool=""
tool_args=()

if [[ "${1:-}" == "--runner" ]]; then
    runner_mode=1
    shift
    runner_ecosystem="${1:?Usage: cli-tool-discovery.sh --runner <python|node|rust|go>}"
    shift
elif [[ "${1:-}" == "--" ]]; then
    exec_mode=1
    shift
    tool="${1:?Usage: cli-tool-discovery.sh -- <tool-name> [args...]}"
    shift
    tool_args=("$@")
elif [[ "${1:-}" == "--json" ]]; then
    json_output=1
    shift
    tool="${1:?Usage: cli-tool-discovery.sh --json <tool-name>}"
else
    tool="${1:?Usage: cli-tool-discovery.sh <tool-name> [--json] | -- <tool-name> [args...] | --runner <ecosystem>}"
    shift
    [[ "${1:-}" == "--json" ]] && json_output=1
fi

repo_root=""
if command -v git >/dev/null 2>&1; then
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi

# --- Walk up from cwd looking for config files ---
walk_up() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        for pattern in "$@"; do
            if [[ -f "$dir/$pattern" ]]; then echo "$dir"; return 0; fi
        done
        dir="$(dirname "$dir")"
    done
    return 1
}

# --- Ensure a package is listed in devbox.json, walking up from cwd ---
# Uses `devbox add` if devbox is on PATH, otherwise falls back to a Python
# or jq edit. Idempotent — does nothing if the package is already present.
# Returns 0 if devbox.json was found and updated (or already contains pkg),
# 1 if no devbox.json was found.
ensure_devbox_package() {
    local pkg="$1"
    local devbox_dir
    if ! devbox_dir="$(walk_up devbox.json)"; then
        return 1
    fi
    local devbox_json="$devbox_dir/devbox.json"

    # If devbox is available, prefer `devbox add` (idempotent in devbox).
    if command -v devbox >/dev/null 2>&1; then
        (cd "$devbox_dir" && devbox add "$pkg" >/dev/null 2>&1) || true
        return 0
    fi

    # Fallback: edit devbox.json in place.
    if command -v python3 >/dev/null 2>&1; then
        python3 - "$pkg" "$devbox_json" <<'PY'
import json, sys, os
pkg, path = sys.argv[1], sys.argv[2]
with open(path, 'r') as f:
    data = json.load(f)
packages = data.get('packages', {})
if isinstance(packages, dict):
    if pkg not in packages:
        packages[pkg] = ""
        data['packages'] = packages
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
            f.write('\n')
elif isinstance(packages, list):
    if pkg not in packages:
        packages.append(pkg)
        data['packages'] = packages
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
            f.write('\n')
PY
        return 0
    fi

    # Last resort: simple grep check, then append (assumes trailing object/map).
    if ! grep -qE "\"$pkg\"|'$pkg'" "$devbox_json" 2>/dev/null; then
        # Insert before the final closing brace. This is a best-effort edit.
        local tmp
        tmp="$(mktemp)"
        if tail -c 20 "$devbox_json" | grep -q '}' 2>/dev/null; then
            python3 -c "
import json, sys
with open('$devbox_json', 'r') as f: data=json.load(f)
pkgs = data.setdefault('packages', {})
if isinstance(pkgs, dict) and '$pkg' not in pkgs: pkgs['$pkg'] = ''
if isinstance(pkgs, list) and '$pkg' not in pkgs: pkgs.append('$pkg')
with open('$devbox_json', 'w') as f: json.dump(data, f, indent=2); f.write('\n')
" 2>/dev/null || return 0
        fi
        rm -f "$tmp"
    fi
    return 0
}

# --- Detect whether we are inside a container ---
# Used by runner mode to pick bunx (container) vs pnpm dlx (host) for node.
# Signals: /.dockerenv file, $DOCKER_CONTAINER env var, or cgroup v1/v2 container markers.
in_container() {
    [[ -f /.dockerenv ]] && return 0
    [[ -n "${DOCKER_CONTAINER:-}" ]] && return 0
    if [[ -f /proc/1/cgroup ]]; then
        if grep -qE '(docker|containerd|lxc|kubepods)' /proc/1/cgroup 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# --- Resolve the ad-hoc runner for an ecosystem (runner mode) ---
# Prints JSON to stdout describing the binary, the script runner, the package
# runner, the fallback, and a recommendation when the binary is not found.
#
# Ecosystems: python, node, rust, go. See the script header for the mapping.
resolve_runner() {
    local eco="$1"
    local binary="" script_runner="" package_runner="" fallback="" fallback_runner=""
    case "$eco" in
        python)
            binary="uv"
            script_runner="uv run --script"
            package_runner="uvx"
            fallback="pip install + python3"
            fallback_runner="python3"
            ;;
        node)
            if in_container; then
                binary="bun"
                package_runner="bunx"
                script_runner=""
                fallback=""
                fallback_runner=""
            else
                binary="pnpm"
                package_runner="pnpm dlx"
                script_runner=""
                fallback=""
                fallback_runner=""
            fi
            ;;
        rust)
            binary="cargo"
            script_runner=""
            package_runner="cargo binstall -y"
            fallback="cargo install"
            fallback_runner="cargo"
            ;;
        go)
            binary="go"
            script_runner=""
            package_runner="go install"
            fallback=""
            fallback_runner=""
            ;;
        *)
            echo "ERROR: unknown ecosystem: $eco (supported: python, node, rust, go)" >&2
            exit 2
            ;;
    esac

    # Resolve the binary via the existing resolve_tool path.
    # Temporarily set $tool so resolve_tool picks it up.
    tool="$binary"
    local result status value
    result="$(resolve_tool)" || true
    status="${result%%:*}"
    value="${result#*:}"

    local binary_status="" binary_path="" wrapper=""
    case "$status" in
        FOUND)
            binary_status="found"
            binary_path="$value"
            ;;
        WRAPPER)
            binary_status="wrapper"
            wrapper="$value"
            ;;
        FALLBACK)
            # uv → pip fallback already resolved by resolve_tool.
            # Treat as not_found for runner purposes; the caller uses
            # fallback/fallback_runner instead of the binary.
            binary_status="not_found"
            ;;
        NOT_FOUND)
            binary_status="not_found"
            ;;
    esac

    # Build recommendation when the binary is not found.
    local recommendation=""
    if [[ "$binary_status" == "not_found" ]]; then
        if walk_up devbox.json >/dev/null 2>&1; then
            recommendation="add ${binary} to devbox.json (run: devbox add ${binary})"
        elif [[ -n "$fallback_runner" ]]; then
            recommendation="use ${fallback_runner} as fallback"
        else
            recommendation="${binary} not found; install before running ${eco} ad-hoc commands"
        fi
    fi

    # Emit JSON. Empty fields are emitted as empty strings; callers can check
    # binary_status to decide which field to use.
    # Escape any double quotes in paths/recommendation (rare but safe).
    local esc_path="${binary_path//\"/\\\"}"
    local esc_rec="${recommendation//\"/\\\"}"
    printf '{"ecosystem":"%s","binary":"%s","binary_status":"%s","binary_path":"%s","wrapper":"%s","script":"%s","package":"%s","fallback":"%s","fallback_runner":"%s","recommendation":"%s"}\n' \
        "$eco" "$binary" "$binary_status" "$esc_path" "$wrapper" \
        "$script_runner" "$package_runner" "$fallback" "$fallback_runner" "$esc_rec"
}

# --- Resolve tool: prints "FOUND: <path>" or "WRAPPER: <cmd>" to stdout, returns 0/1 ---
resolve_tool() {
    # 1. Already on PATH?
    if path="$(command -v "$tool" 2>/dev/null || true)" && [[ -n "$path" ]]; then
        echo "FOUND:$path"
        return 0
    fi

    # 2. Environment wrappers
    # devbox
    if command -v devbox >/dev/null 2>&1; then
        if [[ -z "${DEVBOX_SHELL:-}" && -z "${IN_DEVBOX_SHELL:-}" ]]; then
            if walk_up devbox.json >/dev/null 2>&1; then
                echo "WRAPPER:devbox run --"
                return 0
            fi
        fi
    fi
    # mise
    if command -v mise >/dev/null 2>&1; then
        if [[ -z "${MISE_SHELL:-}" ]]; then
            if walk_up .mise.toml .mise/config.toml mise.toml >/dev/null 2>&1; then
                echo "WRAPPER:mise exec --"
                return 0
            fi
        fi
    fi
    # flox
    if command -v flox >/dev/null 2>&1; then
        if [[ -z "${FLOX_ACTIVE:-}" ]]; then
            if walk_up flox.nix >/dev/null 2>&1; then
                echo "WRAPPER:flox activate --"
                return 0
            fi
        fi
    fi
    # direnv
    if command -v direnv >/dev/null 2>&1; then
        if [[ -z "${DIRENV_DIR:-}" ]]; then
            if walk_up .envrc >/dev/null 2>&1; then
                echo "WRAPPER:direnv export &&"
                return 0
            fi
        fi
    fi
    # nix
    if command -v nix >/dev/null 2>&1; then
        if [[ -z "${IN_NIX_SHELL:-}" ]]; then
            if nix_root="$(walk_up shell.nix flake.nix 2>/dev/null)"; then
                if [[ -f "$nix_root/flake.nix" ]]; then
                    echo "WRAPPER:nix develop --command"
                else
                    echo "WRAPPER:nix-shell --run"
                fi
                return 0
            fi
        fi
    fi

    # 3. Tech-stack-aware directory search
    local arch=""
    arch="$(uname -m 2>/dev/null || true)"
    local search_dirs=()
    search_dirs+=(
        "${XDG_BIN_HOME:-}"
        "$HOME/.local/bin"
        "$HOME/.nix-profile/bin"
        "/nix/var/nix/profiles/default/bin"
        "$HOME/bin"
        "/usr/local/bin"
        "/usr/local/sbin"
        "/usr/sbin"
        "/usr/bin"
        "/sbin"
        "/bin"
    )
    # Homebrew: only check the prefix for the current arch.
    # A Time Machine restore across arches can leave a stale directory
    # with non-universal binaries that won't run.
    case "$arch" in
        arm64)      search_dirs+=("/opt/homebrew/bin" "/opt/homebrew/sbin") ;;
        #x86_64|i386) search_dirs+=("/usr/local/bin" "/usr/local/sbin") ;;
    esac
    # MacPorts (both arches use /opt/local)
    search_dirs+=("/opt/local/bin")
    search_dirs+=("/snap/bin" "/run/current-system/sw/bin")
    search_dirs+=(
        "$HOME/.cargo/bin"
        "$HOME/.bun/bin"
        "$HOME/.deno/bin"
        "$HOME/.volta/bin"
        "$HOME/go/bin"
        "$HOME/.rbenv/shims"
        "$HOME/.pyenv/shims"
        "$HOME/.pixi/bin"
        "$HOME/.krew/bin"
        "$HOME/.foundry/bin"
    )
    if [[ -d "$HOME/.nvm/versions/node" ]]; then
        for nv in "$HOME/.nvm/versions/node"/*/bin; do
            [[ -d "$nv" ]] && search_dirs+=("$nv")
        done
    fi
    for inst_dir in "$HOME/.local/share/mise/installs"/*/bin "$HOME/.local/share/rtx/installs"/*/bin; do
        [[ -d "$inst_dir" ]] && search_dirs+=("$inst_dir")
    done
    if [[ -n "$repo_root" ]]; then
        if [[ -f "$repo_root/package.json" ]]; then
            search_dirs+=("$repo_root/node_modules/.bin" "$repo_root/.bin")
        fi
        if [[ -f "$repo_root/Cargo.toml" ]]; then
            search_dirs+=("$repo_root/target/release" "$repo_root/target/debug")
        fi
        if [[ -f "$repo_root/go.mod" ]]; then
            search_dirs+=("$repo_root/bin" "$repo_root/.bin")
        fi
        if [[ -f "$repo_root/pyproject.toml" || -f "$repo_root/requirements.txt" ]]; then
            search_dirs+=("$repo_root/.venv/bin" "$repo_root/.local/bin")
        fi
        if [[ -f "$repo_root/Gemfile" ]]; then
            search_dirs+=("$repo_root/bin" "$repo_root/.bundle/bin")
        fi
        if [[ -f "$repo_root/composer.json" ]]; then
            search_dirs+=("$repo_root/vendor/bin")
        fi
        search_dirs+=("$repo_root/bin" "$repo_root/scripts" "$repo_root/.local/bin")
    fi
    for d in "${search_dirs[@]}"; do
        [[ -z "$d" ]] && continue
        if [[ -x "$d/$tool" ]]; then
            echo "FOUND:$d/$tool"
            return 0
        fi
    done

    # 4. Package manager lookup
    if command -v brew >/dev/null 2>&1; then
        if brew list "$tool" >/dev/null 2>&1; then
            local prefix
            prefix="$(brew --prefix "$tool" 2>/dev/null || true)"
            if [[ -n "$prefix" && -x "$prefix/bin/$tool" ]]; then
                echo "FOUND:$prefix/bin/$tool"
                return 0
            fi
            local brew_prefix
            brew_prefix="$(brew --prefix)/bin"
            if [[ -x "$brew_prefix/$tool" ]]; then
                echo "FOUND:$brew_prefix/$tool"
                return 0
            fi
        fi
    fi
    if command -v mise >/dev/null 2>&1; then
        if mise_path="$(mise which "$tool" 2>/dev/null || true)" && [[ -n "$mise_path" ]]; then
            echo "FOUND:$mise_path"
            return 0
        fi
    fi
    if command -v asdf >/dev/null 2>&1; then
        if asdf_path="$(asdf which "$tool" 2>/dev/null || true)" && [[ -n "$asdf_path" ]]; then
            echo "FOUND:$asdf_path"
            return 0
        fi
    fi

    # 5. uv fallback: if uv is not found, ensure it is recorded in
    # devbox.json (so devbox can provide it next time) and fall back to
    # pip/pip3/python3 -m pip for Python package operations.
    if [[ "$tool" == "uv" ]]; then
        # Add uv to the nearest devbox.json if one exists.
        ensure_devbox_package uv >/dev/null 2>&1 || true

        # Fall back to pip if available.
        local pip_cmd=""
        for candidate in pip3 pip "python3 -m pip"; do
            if command -v "$candidate" >/dev/null 2>&1; then
                pip_cmd="$candidate"
                break
            fi
        done
        # For the compound command "python3 -m pip", command -v on the whole
        # string fails. Check its components separately.
        if [[ -z "$pip_cmd" ]]; then
            if command -v python3 >/dev/null 2>&1; then
                pip_cmd="python3 -m pip"
            fi
        fi
        if [[ -n "$pip_cmd" ]]; then
            echo "FALLBACK:pip:$pip_cmd"
            return 0
        fi
    fi

    # 6. Not found
    echo "NOT_FOUND:"
    return 1
}

# --- Main ---
if [[ "$runner_mode" -eq 1 ]]; then
    resolve_runner "$runner_ecosystem"
    exit 0
fi

result="$(resolve_tool)" || true
status="${result%%:*}"
value="${result#*:}"

if [[ "$exec_mode" -eq 1 ]]; then
    case "$status" in
        FOUND)
            exec "$value" "${tool_args[@]}"
            ;;
        WRAPPER)
            # Wrapper commands need different arg passing
            case "$value" in
                "devbox run --")        exec devbox run -- "$tool" "${tool_args[@]}" ;;
                "mise exec --")         exec mise exec -- "$tool" "${tool_args[@]}" ;;
                "flox activate --")     exec flox activate -- "$tool" "${tool_args[@]}" ;;
                "direnv export &&")     eval "$(direnv export bash)" && exec "$tool" "${tool_args[@]}" ;;
                "nix develop --command") exec nix develop --command "$tool" "${tool_args[@]}" ;;
                "nix-shell --run")      exec nix-shell --run "$tool ${tool_args[*]}" ;;
                *) echo "Unknown wrapper: $value" >&2; exit 1 ;;
            esac
            ;;
        FALLBACK)
            # Fallback mode: for uv with pip fallback, install uv then exec it.
            if [[ "$tool" == "uv" ]]; then
                local pip_cmd="${value#pip:}"
                if [[ -n "$pip_cmd" ]]; then
                    echo "[cli-tool-discovery] uv not found; installing uv via $pip_cmd" >&2
                    $pip_cmd install --user uv >/dev/null 2>&1 || true
                    # Try to find uv again after install
                    if path="$(command -v uv 2>/dev/null || true)" && [[ -n "$path" ]]; then
                        exec "$path" "${tool_args[@]}"
                    fi
                    # If install failed or uv still not on PATH, try pip directly
                    echo "[cli-tool-discovery] uv install failed; running through pip directly is not supported" >&2
                    exit 127
                fi
            fi
            echo "NOT_FOUND: $tool" >&2
            exit 127
            ;;
        NOT_FOUND)
            echo "NOT_FOUND: $tool" >&2
            echo "Checked: PATH, devbox, mise, flox, direnv, nix, standard locations, package managers" >&2
            exit 127
            ;;
    esac
else
    case "$status" in
        FOUND)
            if [[ "$json_output" -eq 1 ]]; then
                printf '{"status":"found","path":"%s","tool":"%s"}\n' "$value" "$tool"
            else
                echo "FOUND: $value"
            fi
            ;;
        WRAPPER)
            if [[ "$json_output" -eq 1 ]]; then
                printf '{"status":"wrapper","wrapper":"%s","tool":"%s"}\n' "$value $tool" "$tool"
            else
                echo "WRAPPER: $value $tool"
            fi
            ;;
        FALLBACK)
            # Fallback mode: uv → pip
            if [[ "$tool" == "uv" ]]; then
                local pip_cmd="${value#pip:}"
                if [[ "$json_output" -eq 1 ]]; then
                    printf '{"status":"fallback","tool":"%s","fallback":"pip","runner":"%s","message":"uv not found; %s is available as a fallback for Python package operations. Consider running `devbox install` or `%s install --user uv` to install uv."}\n' "$tool" "$pip_cmd" "$pip_cmd" "$pip_cmd"
                else
                    echo "FALLBACK: pip ($pip_cmd) — uv not found; use pip for Python package operations or install uv with '$pip_cmd install --user uv'"
                fi
            else
                if [[ "$json_output" -eq 1 ]]; then
                    printf '{"status":"fallback","tool":"%s","fallback":"%s"}\n' "$tool" "$value"
                else
                    echo "FALLBACK: $value"
                fi
            fi
            ;;
        NOT_FOUND)
            if [[ "$json_output" -eq 1 ]]; then
                printf '{"status":"not_found","tool":"%s","checked":["PATH","devbox","mise","flox","direnv","nix","standard_locations","package_managers"]}\n' "$tool"
            else
                echo "NOT_FOUND: $tool"
                echo "Checked: PATH, devbox, mise, flox, direnv, nix, standard locations, package managers"
            fi
            exit 1
            ;;
    esac
fi

