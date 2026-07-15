#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Scaffold a new CLI script or tool.

Usage:
    uv run --script scaffold_cli.py <name> --language <lang> [--tier <embedded|full>] --path <dir>
    ./scaffold_cli.py <name> --language <lang> [--tier <embedded|full>] --path <dir>

Examples:
    # Embedded Python script in a skill's scripts/ dir
    uv run --script scaffold_cli.py my-script --language python --tier embedded --path ./scripts

    # Embedded bash script
    uv run --script scaffold_cli.py check-status --language bash --tier embedded --path ./scripts

    # Full CLI tool (prints boilerplate instructions — does not run copier)
    uv run --script scaffold_cli.py my-tool --language rust --tier full --path ./my-tool

Quiet by default; --verbose prints full detail; --dry-run prints what would
happen without making changes.
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path



import json
import os
import shutil
import subprocess
from pathlib import Path


def _walk_up_find(*patterns: str) -> Path | None:
    """Walk up from cwd looking for any of the given filenames. Return the dir containing the first match."""
    cwd = Path.cwd()
    for d in [cwd, *cwd.parents]:
        for p in patterns:
            if (d / p).is_file():
                return d
    return None


def _detect_wrapper() -> str | None:
    """Detect an environment wrapper for the current directory. Returns the wrapper prefix or None."""
    # Already inside a wrapper shell — skip (single source of truth for env vars)
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return None
    if os.environ.get("MISE_SHELL"):
        return None
    if os.environ.get("FLOX_ACTIVE"):
        return None
    if os.environ.get("DIRENV_DIR"):
        return None
    if os.environ.get("IN_NIX_SHELL"):
        return None

    # devbox
    if shutil.which("devbox") and _walk_up_find("devbox.json"):
        return "devbox run --"

    # mise
    if shutil.which("mise") and _walk_up_find(".mise.toml", ".mise/config.toml", "mise.toml"):
        return "mise exec --"

    # flox
    if shutil.which("flox") and _walk_up_find("flox.nix"):
        return "flox activate --"

    # direnv
    if shutil.which("direnv") and _walk_up_find(".envrc"):
        return "direnv export &&"

    # nix
    if shutil.which("nix"):
        nix_root = _walk_up_find("flake.nix", "shell.nix")
        if nix_root:
            if (nix_root / "flake.nix").is_file():
                return "nix develop --command"
            return "nix-shell --run"

    return None


def _get_repo_root() -> Path | None:
    """Get git repo root if available."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, check=True,
        )
        return Path(result.stdout.strip())
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def _search_dirs() -> list[Path]:
    """Build the list of directories to search, tech-stack-aware."""
    home = Path.home()
    dirs: list[Path] = []

    # Universal user-local and system dirs
    xdg_bin = os.environ.get("XDG_BIN_HOME")
    if xdg_bin:
        dirs.append(Path(xdg_bin))
    dirs.extend([
        home / ".local/bin",
        home / ".nix-profile/bin",
        Path("/nix/var/nix/profiles/default/bin"),
        home / "bin",
        Path("/usr/local/bin"),
        Path("/usr/local/sbin"),
        Path("/usr/sbin"),
        Path("/usr/bin"),
        Path("/sbin"),
        Path("/bin"),
    ])
    # Homebrew: only check the prefix for the current arch.
    # A Time Machine restore across arches can leave a stale directory
    # with non-universal binaries that won't run.
    import platform
    arch = platform.machine()
    if arch == "arm64":
        dirs.extend([Path("/opt/homebrew/bin"), Path("/opt/homebrew/sbin")])
    elif arch in ("x86_64", "i386"):
        dirs.extend([Path("/usr/local/bin"), Path("/usr/local/sbin")])
    # MacPorts (both arches use /opt/local)
    dirs.append(Path("/opt/local/bin"))
    dirs.extend([Path("/snap/bin"), Path("/run/current-system/sw/bin")])

    # Language/runtime-specific dirs
    dirs.extend([
        home / ".cargo/bin",
        home / ".bun/bin",
        home / ".deno/bin",
        home / ".volta/bin",
        home / "go/bin",
        home / ".rbenv/shims",
        home / ".pyenv/shims",
        home / ".pixi/bin",
        home / ".krew/bin",
        home / ".foundry/bin",
    ])

    # nvm: all installed versions
    nvm_node = home / ".nvm/versions/node"
    if nvm_node.is_dir():
        for v in nvm_node.iterdir():
            b = v / "bin"
            if b.is_dir():
                dirs.append(b)

    # mise/rtx managed tool installs
    for base in [home / ".local/share/mise/installs", home / ".local/share/rtx/installs"]:
        if base.is_dir():
            for inst in base.iterdir():
                b = inst / "bin"
                if b.is_dir():
                    dirs.append(b)

    # Tech-stack-specific repo-local dirs
    repo = _get_repo_root()
    if repo:
        if (repo / "package.json").is_file():
            dirs.extend([repo / "node_modules/.bin", repo / ".bin"])
        if (repo / "Cargo.toml").is_file():
            dirs.extend([repo / "target/release", repo / "target/debug"])
        if (repo / "go.mod").is_file():
            dirs.extend([repo / "bin", repo / ".bin"])
        if (repo / "pyproject.toml").is_file() or (repo / "requirements.txt").is_file():
            dirs.extend([repo / ".venv/bin", repo / ".local/bin"])
        if (repo / "Gemfile").is_file():
            dirs.extend([repo / "bin", repo / ".bundle/bin"])
        if (repo / "composer.json").is_file():
            dirs.append(repo / "vendor/bin")
        dirs.extend([repo / "bin", repo / "scripts", repo / ".local/bin"])

    return dirs


def resolve_tool(tool: str) -> dict:
    """Resolve a CLI tool. Returns a dict with 'status' and 'path' or 'wrapper'.

    Return values:
        {"status": "found", "path": "/usr/local/bin/go"}
        {"status": "wrapper", "wrapper": "devbox run --"}
        {"status": "not_found"}
    """
    # 1. Already on PATH?
    path = shutil.which(tool)
    if path:
        return {"status": "found", "path": path}

    # 2. Environment wrapper
    wrapper = _detect_wrapper()
    if wrapper:
        return {"status": "wrapper", "wrapper": wrapper}

    # 3. Standard PATH locations
    for d in _search_dirs():
        candidate = d / tool
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return {"status": "found", "path": str(candidate)}

    # 4. Package manager lookup
    if shutil.which("brew"):
        try:
            subprocess.run(["brew", "list", tool], capture_output=True, check=True)
            prefix = subprocess.run(
                ["brew", "--prefix", tool], capture_output=True, text=True
            ).stdout.strip()
            if prefix:
                p = Path(prefix) / "bin" / tool
                if p.is_file() and os.access(p, os.X_OK):
                    return {"status": "found", "path": str(p)}
            brew_prefix = subprocess.run(
                ["brew", "--prefix"], capture_output=True, text=True
            ).stdout.strip()
            p = Path(brew_prefix) / "bin" / tool
            if p.is_file() and os.access(p, os.X_OK):
                return {"status": "found", "path": str(p)}
        except (subprocess.CalledProcessError, FileNotFoundError):
            pass

    if shutil.which("mise"):
        try:
            result = subprocess.run(
                ["mise", "which", tool], capture_output=True, text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                return {"status": "found", "path": result.stdout.strip()}
        except FileNotFoundError:
            pass

    if shutil.which("asdf"):
        try:
            result = subprocess.run(
                ["asdf", "which", tool], capture_output=True, text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                return {"status": "found", "path": result.stdout.strip()}
        except FileNotFoundError:
            pass

    return {"status": "not_found"}


def run_tool(tool: str, args: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Resolve a tool and run it. If a wrapper is detected, runs through the wrapper.

    Uses subprocess.run (captures output only if kwargs request it).
    For exec (replace process), use run_tool_exec instead.
    """
    result = resolve_tool(tool)
    status = result["status"]

    if status == "found":
        return subprocess.run([result["path"], *args], **kwargs)
    elif status == "wrapper":
        wrapper = result["wrapper"]
        if wrapper == "devbox run --":
            return subprocess.run(["devbox", "run", "--", tool, *args], **kwargs)
        elif wrapper == "mise exec --":
            return subprocess.run(["mise", "exec", "--", tool, *args], **kwargs)
        elif wrapper == "flox activate --":
            return subprocess.run(["flox", "activate", "--", tool, *args], **kwargs)
        elif wrapper == "direnv export &&":
            # direnv needs eval — fall back to running direnv export then the tool
            export = subprocess.run(
                ["direnv", "export", "bash"], capture_output=True, text=True
            )
            # Can't easily eval in Python; just run the tool and hope PATH is set
            return subprocess.run([tool, *args], **kwargs)
        elif wrapper == "nix develop --command":
            return subprocess.run(["nix", "develop", "--command", tool, *args], **kwargs)
        elif wrapper == "nix-shell --run":
            return subprocess.run(
                ["nix-shell", "--run", " ".join([tool, *args])], **kwargs
            )
        else:
            raise RuntimeError(f"Unknown wrapper: {wrapper}")
    else:
        raise FileNotFoundError(f"Tool not found: {tool}")


def run_tool_exec(tool: str, args: list[str]) -> None:
    """Resolve a tool and exec it (replaces the current process). Never returns."""
    result = resolve_tool(tool)
    status = result["status"]

    if status == "found":
        os.execv(result["path"], [tool, *args])
    elif status == "wrapper":
        wrapper = result["wrapper"]
        if wrapper == "devbox run --":
            os.execvp("devbox", ["devbox", "run", "--", tool, *args])
        elif wrapper == "mise exec --":
            os.execvp("mise", ["mise", "exec", "--", tool, *args])
        elif wrapper == "flox activate --":
            os.execvp("flox", ["flox", "activate", "--", tool, *args])
        elif wrapper == "direnv export &&":
            os.execvp(tool, [tool, *args])
        elif wrapper == "nix develop --command":
            os.execvp("nix", ["nix", "develop", "--command", tool, *args])
        elif wrapper == "nix-shell --run":
            os.execvp("nix-shell", ["nix-shell", "--run", " ".join([tool, *args])])
        else:
            raise RuntimeError(f"Unknown wrapper: {wrapper}")
    else:
        raise FileNotFoundError(f"Tool not found: {tool}")


# --- Convenience wrappers (backward-compatible with old devbox_run/rtk_wrap) ---

def is_devbox_available() -> bool:
    """Backward compat: check if devbox wrapper would be used."""
    return _detect_wrapper() == "devbox run --"


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Backward compat: run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


def is_rtk_available() -> bool:
    """Check if rtk is available (resolved via cli-tool-discovery, not just PATH)."""
    r = resolve_tool("rtk")
    return r["status"] in ("found", "wrapper")


def _rtk_supports(tool: str, args: list[str]) -> bool:
    """Check if rtk supports a command by probing `rtk rewrite`.
    Exit codes: 0=allow, 1=not supported, 2=deny, 3=ask. 0 and 3 mean supported."""
    if not is_rtk_available():
        return False
    try:
        result = subprocess.run(
            ["rtk", "rewrite", "--", tool, *args],
            capture_output=True, text=True,
        )
        return result.returncode in (0, 3)
    except (subprocess.SubprocessError, FileNotFoundError):
        return False


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    """Run a command through rtk if supported, otherwise through devbox/direct.
    Uses `rtk rewrite` to check coverage — no hardcoded list of supported commands."""
    if _rtk_supports(tool, list(args)):
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)



# ---------------------------------------------------------------------------
# Templates
# ---------------------------------------------------------------------------

BASH_TEMPLATE = '''#!/usr/bin/env bash
set -euo pipefail

# {description}
#
# Usage:
#   ./{name}.sh <args>
#   bash {name}.sh <args>
#
# Quiet by default; --verbose prints full detail; --dry-run prints what would
# happen without making changes.

# --- XDG paths ---
CACHE_DIR="${{XDG_CACHE_HOME:-$HOME/.cache}}/{name}"
DATA_DIR="${{XDG_DATA_HOME:-$HOME/.local/share}}/{name}"
CONFIG_DIR="${{XDG_CONFIG_HOME:-$HOME/.config}}/{name}"

# --- Helpers ---
fail() {{
    echo "error: $1"
    if [[ -n "${{2:-}}" ]]; then
        echo "help: $2"
    fi
    exit "${{3:-1}}"
}}

# --- Args ---
VERBOSE=0
DRY_RUN=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --verbose|-v) VERBOSE=1; shift ;;
        --dry-run) DRY_RUN=1; shift ;;
        --help|-h)
            echo "Usage: $(basename "$0") [--verbose] [--dry-run] <args>"
            echo ""
            echo "Options:"
            echo "  --verbose, -v  Print full detail"
            echo "  --dry-run      Print what would happen without making changes"
            echo "  --help, -h     Show this help"
            exit 0
            ;;
        --*)
            fail "unknown flag $1" "Run with --help to see valid flags" 2
            ;;
        *)
            break
            ;;
    esac
done

# --- Main ---
mkdir -p "$CACHE_DIR" "$DATA_DIR"

# TODO: Implement script logic
echo "ok"
'''

PYTHON_TEMPLATE = '''#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     # "requests>=2.31.0",  # uncomment and list third-party deps here
# ]
# ///
"""
{description}

Usage:
    uv run --script {name}.py <args>
    ./{name}.py <args>          # if uv is on PATH

Quiet by default; --verbose prints full detail; --dry-run prints what would
happen without making changes.
"""

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Devbox detection
# ---------------------------------------------------------------------------
def is_devbox_available() -> bool:
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


# ---------------------------------------------------------------------------
# RTK detection
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


# ---------------------------------------------------------------------------
# XDG paths
# ---------------------------------------------------------------------------
def cache_dir(tool: str) -> Path:
    base = os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache"))
    return Path(base) / tool

def data_dir(tool: str) -> Path:
    base = os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local" / "share"))
    return Path(base) / tool

def config_dir(tool: str) -> Path:
    base = os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))
    return Path(base) / tool


# ---------------------------------------------------------------------------
# AXI output helpers
# ---------------------------------------------------------------------------
def fail(msg: str, suggestion: str = "", exit_code: int = 1) -> None:
    """Print structured error to stdout and exit."""
    print(f"error: {{msg}}")
    if suggestion:
        print(f"help: {{suggestion}}")
    sys.exit(exit_code)

def empty_state(context: str) -> None:
    """Print definitive empty state to stdout."""
    print(f"items: 0 {{context}}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    parser = argparse.ArgumentParser(
        description="{description}",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Print full detail")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would happen without making changes")
    # TODO: Add command-specific arguments

    args = parser.parse_args()

    # Ensure XDG dirs exist
    cache_dir("{name}").mkdir(parents=True, exist_ok=True)
    data_dir("{name}").mkdir(parents=True, exist_ok=True)

    # TODO: Implement script logic
    if args.dry_run:
        print("Would do: <action>")
        return

    print("ok")


if __name__ == "__main__":
    main()
'''


# ---------------------------------------------------------------------------
# Scaffolding
# ---------------------------------------------------------------------------

def scaffold_embedded(name: str, language: str, output_dir: Path, description: str,
                      dry_run: bool, verbose: bool) -> None:
    """Scaffold an embedded CLI script."""
    if language == "bash":
        ext = ".sh"
        template = BASH_TEMPLATE
    elif language == "python":
        ext = ".py"
        template = PYTHON_TEMPLATE
    else:
        print(f"error: unsupported embedded language: {language}")
        print(f"help: supported languages for embedded: bash, python")
        sys.exit(2)

    content = template.format(name=name, description=description)
    output_file = output_dir / f"{name}{ext}"

    if dry_run:
        print(f"Would create: {output_file}")
        print(f"Language: {language}")
        print(f"Tier: embedded")
        return

    output_dir.mkdir(parents=True, exist_ok=True)
    output_file.write_text(content)
    if language == "bash":
        output_file.chmod(0o755)

    print(f"created: {output_file}")
    if verbose:
        print(f"language: {language}")
        print(f"tier: embedded")
        print(f"lines: {len(content.splitlines())}")


def scaffold_full(name: str, language: str, output_dir: Path, description: str,
                  dry_run: bool, verbose: bool) -> None:
    """Print instructions for scaffolding a full CLI tool from boilerplate."""
    boilerplate_path = "levonk-base-boilerplate/boilerplate/apps/cli"

    print(f"Full CLI tool scaffolding requires the copier wrapper.")
    print(f"")
    print(f"Steps:")
    print(f"1. Prepare copier answers:")
    print(f'   cat > copier-answers.yml <<EOF')
    print(f'   project_name: {name}')
    print(f'   package_slug: {name}')
    print(f'   description: "{description}"')
    print(f'   EOF')
    print(f"")
    print(f"2. Generate the project:")
    print(f"   devbox run -- rtk ./boilerplate/copier-wrapper.sh copy \\")
    print(f"     ./{boilerplate_path}/{language}/core \\")
    print(f"     ./{output_dir} \\")
    print(f"     --data @copier-answers.yml")
    print(f"")
    print(f"3. Post-scaffold — add AXI compliance:")
    print(f"   - Structured errors on stdout")
    print(f"   - Definitive empty states")
    print(f"   - No interactive prompts in agent mode")
    print(f"   - Exit codes: 0 success, 1 error, 2 usage")
    print(f"   - XDG paths for cache/data/config")
    print(f"   - TOON output mode (--toon)")
    print(f"   - Session hooks (--install-agent-hooks)")
    print(f"   - Content-first no-args")
    print(f"   - Contextual disclosure (help[])")
    print(f"")
    print(f"See references/axi-principles.md and references/cli-best-practices.md")
    print(f"for detailed implementation guidance.")

    if dry_run:
        print(f"")
        print(f"(dry-run: no files created)")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Scaffold a new CLI script or tool",
    )
    parser.add_argument("name", help="CLI name (kebab-case)")
    parser.add_argument("--language", "-l", default="python",
                        choices=["bash", "python", "rust", "go", "typescript"],
                        help="Language (default: python)")
    parser.add_argument("--tier", "-t", default="embedded",
                        choices=["embedded", "full"],
                        help="Tier: embedded script or full CLI tool (default: embedded)")
    parser.add_argument("--path", "-p", default=".",
                        help="Output directory")
    parser.add_argument("--description", "-d", default="A CLI tool",
                        help="One-line description")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Print full detail")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would happen without making changes")

    args = parser.parse_args()

    # Validate name
    if not args.name.replace("-", "").replace("_", "").isalnum():
        print(f"error: invalid name '{args.name}'")
        print(f"help: use kebab-case (letters, numbers, hyphens)")
        sys.exit(2)

    output_dir = Path(args.path).expanduser()

    if args.tier == "embedded":
        scaffold_embedded(args.name, args.language, output_dir,
                          args.description, args.dry_run, args.verbose)
    else:
        scaffold_full(args.name, args.language, output_dir,
                      args.description, args.dry_run, args.verbose)


if __name__ == "__main__":
    main()
