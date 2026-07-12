#!/usr/bin/env bash
# cli-tool-discovery.sh — resolve a CLI tool through environment wrappers and standard PATH locations
#
# Usage:
#   cli-tool-discovery.sh <tool-name> [--json]          # resolve only, print result
#   cli-tool-discovery.sh -- <tool-name> [args...]      # resolve and exec the tool
#
# Output (resolve mode, text): FOUND: <path> | WRAPPER: <wrapper-cmd> | NOT_FOUND: <tool>
# Output (resolve mode, json): {"status":"found|wrapper|not_found", "path": "...", "wrapper": "...", "tool": "..."}
# Output (exec mode): the tool's own stdout/stderr/exit code
#
# Resolution order:
#   1. Already on PATH (command -v)
#   2. Environment wrappers (devbox, mise, flox, direnv, nix) — walks up from cwd
#   3. Tech-stack-aware standard PATH locations (30+ dirs)
#   4. Package manager lookup (brew, mise, asdf)
#   5. Reports NOT_FOUND with what was checked
set -euo pipefail

# --- Parse args: exec mode vs resolve mode ---
exec_mode=0
json_output=0
tool=""
tool_args=()

if [[ "${1:-}" == "--" ]]; then
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
    tool="${1:?Usage: cli-tool-discovery.sh <tool-name> [--json] | -- <tool-name> [args...]}"
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
        if walk_up .mise.toml .mise/config.toml >/dev/null 2>&1; then
            echo "WRAPPER:mise exec --"
            return 0
        fi
    fi
    # flox
    if command -v flox >/dev/null 2>&1; then
        if walk_up flox.nix >/dev/null 2>&1; then
            echo "WRAPPER:flox activate --"
            return 0
        fi
    fi
    # direnv
    if command -v direnv >/dev/null 2>&1; then
        if walk_up .envrc >/dev/null 2>&1; then
            echo "WRAPPER:direnv export &&"
            return 0
        fi
    fi
    # nix
    if command -v nix >/dev/null 2>&1; then
        if nix_root="$(walk_up shell.nix flake.nix 2>/dev/null)"; then
            if [[ -f "$nix_root/flake.nix" ]]; then
                echo "WRAPPER:nix develop --command"
            else
                echo "WRAPPER:nix-shell --run"
            fi
            return 0
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

    # 5. Not found
    echo "NOT_FOUND:"
    return 1
}

# --- Main ---
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

