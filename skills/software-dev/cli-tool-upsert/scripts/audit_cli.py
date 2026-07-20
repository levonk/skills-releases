#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Audit an existing CLI script or tool for AXI compliance.

Usage:
    uv run --script audit_cli.py --path <target> [--suggest-tier] [--json]
    ./audit_cli.py --path <target> [--suggest-tier] [--json]

Scans the target for CLI scripts/tools, checks AXI compliance, and outputs
a structured assessment.

Quiet by default; --verbose prints full detail; --dry-run prints what would
happen without making changes.
"""

import argparse
import json
import os
import re
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


def ensure_devbox_package(pkg: str) -> bool:
    """Ensure a package is listed in the nearest devbox.json."""
    devbox_dir = _walk_up_find("devbox.json")
    if not devbox_dir:
        return False
    devbox_json = devbox_dir / "devbox.json"
    try:
        with open(devbox_json, "r") as f:
            data = json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return False
    packages = data.get("packages", {})
    if isinstance(packages, dict):
        if pkg not in packages:
            packages[pkg] = ""
            data["packages"] = packages
        else:
            return True
    elif isinstance(packages, list):
        if pkg not in packages:
            packages.append(pkg)
            data["packages"] = packages
        else:
            return True
    else:
        return False
    try:
        with open(devbox_json, "w") as f:
            json.dump(data, f, indent=2)
            f.write("\n")
    except OSError:
        return False
    return True


def resolve_tool(tool: str) -> dict:
    """Resolve a CLI tool. Returns a dict with 'status' and 'path' or 'wrapper'.

    Return values:
        {"status": "found", "path": "/usr/local/bin/go"}
        {"status": "wrapper", "wrapper": "devbox run --"}
        {"status": "fallback", "fallback": "pip", "runner": "..."}
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

    # 5. uv fallback: ensure uv is recorded in devbox.json, then fall back to pip.
    if tool == "uv":
        ensure_devbox_package("uv")
        pip_cmd = None
        if shutil.which("pip3"):
            pip_cmd = "pip3"
        elif shutil.which("pip"):
            pip_cmd = "pip"
        elif shutil.which("python3"):
            pip_cmd = "python3 -m pip"
        if pip_cmd:
            return {
                "status": "fallback",
                "fallback": "pip",
                "runner": pip_cmd,
                "message": (
                    "uv not found; pip is available as a fallback for Python "
                    f"package operations. Consider installing uv with '{pip_cmd} install --user uv'."
                ),
            }

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
    elif status == "fallback":
        if tool == "uv" and result.get("fallback") == "pip":
            runner = result.get("runner", "pip3")
            print(f"[cli-tool-discovery] uv not found; installing uv via {runner}", file=sys.stderr)
            subprocess.run([*runner.split(), "install", "--user", "uv"], check=False)
            if shutil.which("uv"):
                return subprocess.run(["uv", *args], **kwargs)
            raise FileNotFoundError(f"uv could not be installed; {runner} is available as fallback")
        raise FileNotFoundError(f"Tool not found: {tool}")
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
    elif status == "fallback":
        if tool == "uv" and result.get("fallback") == "pip":
            runner = result.get("runner", "pip3")
            print(f"[cli-tool-discovery] uv not found; installing uv via {runner}", file=sys.stderr)
            subprocess.run([*runner.split(), "install", "--user", "uv"], check=False)
            if shutil.which("uv"):
                os.execvp("uv", ["uv", *args])
            raise FileNotFoundError(f"uv could not be installed; {runner} is available as fallback")
        raise FileNotFoundError(f"Tool not found: {tool}")
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


# --- Runner mode: resolve the ad-hoc runner for an ecosystem ---
# Mirrors `cli-tool-discovery.sh --runner <ecosystem>`. Returns a dict with
# the binary, the script runner (for PEP 723-style inline-metadata files),
# the package runner (for ad-hoc package execution), the fallback, and a
# recommendation when the binary is not found.
#
# Supported ecosystems: python, node, rust, go.
# The mapping is the single source of truth for "how do I invoke an ad-hoc
# command in ecosystem X?" — detect-package-manager.py (future) and the
# python-services-practices/standalone-scripts.md knowledge page both
# delegate to this.

def _in_container() -> bool:
    """Detect whether we are inside a container. Used by runner mode to pick
    bunx (container) vs pnpm dlx (host) for node."""
    if Path("/.dockerenv").exists():
        return True
    if os.environ.get("DOCKER_CONTAINER"):
        return True
    cgroup = Path("/proc/1/cgroup")
    if cgroup.is_file():
        try:
            text = cgroup.read_text()
            if any(marker in text for marker in ("docker", "containerd", "lxc", "kubepods")):
                return True
        except OSError:
            pass
    return False


_RUNNER_MAP = {
    "python": {
        "binary": "uv",
        "script": "uv run --script",
        "package": "uvx",
        "fallback": "pip install + python3",
        "fallback_runner": "python3",
    },
    "node": {
        # node is special: the binary and package runner depend on container vs host.
        # _resolve_node_runner below handles the split; this entry is a placeholder.
        "binary": "",
        "script": "",
        "package": "",
        "fallback": "",
        "fallback_runner": "",
    },
    "rust": {
        "binary": "cargo",
        "script": "",
        "package": "cargo binstall -y",
        "fallback": "cargo install",
        "fallback_runner": "cargo",
    },
    "go": {
        "binary": "go",
        "script": "",
        "package": "go install",
        "fallback": "",
        "fallback_runner": "",
    },
}


def resolve_runner(ecosystem: str) -> dict:
    """Resolve the ad-hoc runner for an ecosystem. Returns a dict with:
        ecosystem, binary, binary_status, binary_path, wrapper,
        script, package, fallback, fallback_runner, recommendation.

    binary_status is one of: found, wrapper, not_found.
    When not_found, recommendation tells the caller what to do (add to
    devbox.json, use fallback, or install manually).
    """
    eco = ecosystem.lower()
    if eco not in _RUNNER_MAP:
        raise ValueError(
            f"Unknown ecosystem: {ecosystem} (supported: {', '.join(_RUNNER_MAP)})"
        )

    # node: container vs host split
    if eco == "node":
        if _in_container():
            spec = {"binary": "bun", "script": "", "package": "bunx",
                    "fallback": "", "fallback_runner": ""}
        else:
            spec = {"binary": "pnpm", "script": "", "package": "pnpm dlx",
                    "fallback": "", "fallback_runner": ""}
    else:
        spec = _RUNNER_MAP[eco]

    binary = spec["binary"]
    result = resolve_tool(binary)
    binary_status = result["status"]
    # The bash version treats FALLBACK (uv→pip) as not_found for runner purposes;
    # the caller uses fallback/fallback_runner instead of the binary.
    if binary_status == "fallback":
        binary_status = "not_found"

    binary_path = result.get("path", "") if binary_status == "found" else ""
    wrapper = result.get("wrapper", "") if binary_status == "wrapper" else ""

    recommendation = ""
    if binary_status == "not_found":
        if _walk_up_find("devbox.json"):
            recommendation = f"add {binary} to devbox.json (run: devbox add {binary})"
        elif spec.get("fallback_runner"):
            recommendation = f"use {spec['fallback_runner']} as fallback"
        else:
            recommendation = (
                f"{binary} not found; install before running {eco} ad-hoc commands"
            )

    return {
        "ecosystem": eco,
        "binary": binary,
        "binary_status": binary_status,
        "binary_path": binary_path,
        "wrapper": wrapper,
        "script": spec["script"],
        "package": spec["package"],
        "fallback": spec["fallback"],
        "fallback_runner": spec["fallback_runner"],
        "recommendation": recommendation,
    }



# ---------------------------------------------------------------------------
# Detection
# ---------------------------------------------------------------------------

def detect_language(path: Path) -> str | None:
    """Detect the language of a CLI script or tool."""
    if path.is_file():
        if path.suffix == ".py":
            return "python"
        if path.suffix == ".sh":
            return "bash"
        if path.suffix == ".rs":
            return "rust"
        if path.suffix == ".go":
            return "go"
        if path.suffix in (".ts", ".js"):
            return "typescript"
        return None

    if path.is_dir():
        if (path / "Cargo.toml").exists():
            return "rust"
        if (path / "pyproject.toml").exists() or (path / "setup.py").exists():
            return "python"
        if (path / "go.mod").exists():
            return "go"
        if (path / "package.json").exists():
            return "typescript"
        if (path / "Makefile").exists():
            return "unknown"
        return None

    return None


def detect_tier(path: Path) -> str:
    """Suggest whether the target is an embedded script or full CLI tool."""
    if path.is_file():
        return "embedded"
    if path.is_dir():
        # Full CLI tool indicators
        for indicator in ["Cargo.toml", "pyproject.toml", "go.mod", "package.json",
                          "Dockerfile", "justfile", "Justfile", "Makefile",
                          "devbox.json", ".envrc", "project.json"]:
            if (path / indicator).exists():
                return "full"
        return "embedded"
    return "embedded"


def find_cli_files(path: Path) -> list[Path]:
    """Find CLI script files in a directory."""
    if path.is_file():
        return [path]

    cli_files = []
    for ext in [".py", ".sh", ".rs", ".go", ".ts", ".js"]:
        cli_files.extend(path.rglob(f"*{ext}"))

    # Filter out common non-CLI files
    exclude_patterns = ["test_", "_test.", "spec_", "_spec.", ".test.", ".spec."]
    filtered = []
    for f in cli_files:
        rel = str(f.relative_to(path))
        if any(p in rel for p in exclude_patterns):
            continue
        if "node_modules" in rel or ".git" in rel or "vendor" in rel:
            continue
        filtered.append(f)

    return filtered


# ---------------------------------------------------------------------------
# AXI compliance checks
# ---------------------------------------------------------------------------

def check_output_discipline(content: str, language: str) -> dict:
    """Check stdout/stderr separation."""
    issues = []
    if language == "python":
        if "print(" in content and "stderr" not in content and "file=sys.stderr" not in content:
            # Check if all prints go to stdout (no stderr routing)
            pass  # This is a heuristic, not definitive
    if language == "bash":
        if "echo " in content and ">&2" not in content:
            issues.append("no stderr output found — all output may go to stdout")
    return {"passed": len(issues) == 0, "issues": issues}


def check_structured_errors(content: str, language: str) -> dict:
    """Check for structured error format."""
    issues = []
    has_error_format = False

    if language == "python":
        if re.search(r'print.*["\']error:', content):
            has_error_format = True
        if re.search(r'sys\.exit\s*\(', content) and not has_error_format:
            issues.append("sys.exit() used but no structured error format (print 'error: ...')")
    if language == "bash":
        if re.search(r'echo.*["\']error:', content):
            has_error_format = True
        if "exit " in content and not has_error_format:
            issues.append("exit used but no structured error format (echo 'error: ...')")

    if not has_error_format:
        issues.append("no structured error format found (expected 'error: <msg>' on stdout)")

    return {"passed": len(issues) == 0, "issues": issues}


def check_exit_codes(content: str, language: str) -> dict:
    """Check for proper exit codes."""
    issues = []
    if language == "python":
        if "sys.exit(2)" not in content and "sys.exit(1)" in content:
            issues.append("no exit code 2 for usage errors — add sys.exit(2) for invalid args")
    if language == "bash":
        if "exit 2" not in content and "exit 1" in content:
            issues.append("no exit code 2 for usage errors — add exit 2 for invalid args")
    return {"passed": len(issues) == 0, "issues": issues}


def check_no_interactive_prompts(content: str, language: str) -> dict:
    """Check for interactive prompts."""
    issues = []
    if language == "python":
        if re.search(r'\binput\s*\(', content):
            issues.append("input() found — no interactive prompts allowed in agent mode")
    if language == "bash":
        if re.search(r'\bread\s+', content):
            issues.append("read found — no interactive prompts allowed in agent mode")
    return {"passed": len(issues) == 0, "issues": issues}


def check_xdg_paths(content: str, language: str) -> dict:
    """Check for XDG path usage."""
    issues = []
    has_xdg = False
    if "XDG_CACHE_HOME" in content or "XDG_DATA_HOME" in content or "XDG_CONFIG_HOME" in content:
        has_xdg = True
    if not has_xdg:
        # Check for non-XDG paths
        if re.search(r'~/\.\w+', content) and "config" not in content.lower():
            issues.append("no XDG path usage found — use ${XDG_CACHE_HOME:-$HOME/.cache} etc.")
    return {"passed": len(issues) == 0, "issues": issues}


def check_pep723(content: str, language: str) -> dict:
    """Check for PEP 723 header (Python only)."""
    if language != "python":
        return {"passed": True, "issues": []}
    issues = []
    if "# /// script" not in content:
        issues.append("no PEP 723 header found — add '# /// script' block for uv run --script")
    return {"passed": len(issues) == 0, "issues": issues}


def check_verbose_dry_run(content: str, language: str) -> dict:
    """Check for --verbose and --dry-run flags."""
    issues = []
    has_verbose = "--verbose" in content or '"verbose"' in content or "'verbose'" in content
    has_dry_run = "--dry-run" in content or '"dry_run"' in content or "'dry_run'" in content
    if not has_verbose:
        issues.append("no --verbose flag found")
    if not has_dry_run:
        issues.append("no --dry-run flag found")
    return {"passed": len(issues) == 0, "issues": issues}


def check_definitive_empty_states(content: str, language: str) -> dict:
    """Check for definitive empty state output."""
    issues = []
    has_empty_state = bool(re.search(r'0\s+(results|items|found|tasks|entries)', content, re.I))
    if not has_empty_state:
        issues.append("no definitive empty state found (e.g., '0 items found')")
    return {"passed": len(issues) == 0, "issues": issues}


# ---------------------------------------------------------------------------
# Audit
# ---------------------------------------------------------------------------

def audit_file(path: Path, verbose: bool) -> dict:
    """Audit a single CLI file."""
    content = path.read_text(errors="replace")
    language = detect_language(path) or "unknown"

    checks = {
        "output_discipline": check_output_discipline(content, language),
        "structured_errors": check_structured_errors(content, language),
        "exit_codes": check_exit_codes(content, language),
        "no_interactive_prompts": check_no_interactive_prompts(content, language),
        "xdg_paths": check_xdg_paths(content, language),
        "pep723": check_pep723(content, language),
        "verbose_dry_run": check_verbose_dry_run(content, language),
        "definitive_empty_states": check_definitive_empty_states(content, language),
    }

    passed = sum(1 for c in checks.values() if c["passed"])
    total = len(checks)

    return {
        "file": str(path),
        "language": language,
        "tier": detect_tier(path),
        "compliance": f"{passed}/{total}",
        "checks": checks,
    }


def audit_directory(path: Path, verbose: bool) -> dict:
    """Audit a directory for CLI files."""
    cli_files = find_cli_files(path)

    if not cli_files:
        return {
            "path": str(path),
            "tier": detect_tier(path),
            "files": [],
            "summary": "no CLI files found",
        }

    results = [audit_file(f, verbose) for f in cli_files]

    return {
        "path": str(path),
        "tier": detect_tier(path),
        "files": results,
        "summary": f"{len(results)} CLI file(s) found",
    }


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Audit an existing CLI for AXI compliance",
    )
    parser.add_argument("--path", "-p", required=True,
                        help="Path to CLI file or directory")
    parser.add_argument("--suggest-tier", action="store_true",
                        help="Suggest tier (embedded vs full) and exit")
    parser.add_argument("--json", action="store_true",
                        help="Output as JSON")
    parser.add_argument("--verbose", "-v", action="store_true",
                        help="Print full detail")
    parser.add_argument("--dry-run", action="store_true",
                        help="Print what would happen without making changes")

    args = parser.parse_args()

    target = Path(args.path).expanduser()

    if not target.exists():
        print(f"error: path not found: {target}")
        print(f"help: check the path and try again")
        sys.exit(1)

    if args.suggest_tier:
        tier = detect_tier(target)
        if args.json:
            print(json.dumps({"suggested_tier": tier}))
        else:
            print(f"suggested_tier: {tier}")
        return

    if args.dry_run:
        print(f"Would audit: {target}")
        print(f"Mode: {'directory' if target.is_dir() else 'file'}")
        return

    if target.is_dir():
        result = audit_directory(target, args.verbose)
    else:
        result = audit_file(target, args.verbose)

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        if "files" in result:
            # Directory output
            print(f"path: {result['path']}")
            print(f"tier: {result['tier']}")
            print(f"summary: {result['summary']}")
            for f in result["files"]:
                print(f"")
                print(f"  file: {f['file']}")
                print(f"  language: {f['language']}")
                print(f"  compliance: {f['compliance']}")
                if args.verbose:
                    for name, check in f["checks"].items():
                        status = "pass" if check["passed"] else "FAIL"
                        print(f"    {name}: {status}")
                        for issue in check["issues"]:
                            print(f"      - {issue}")
        else:
            # Single file output
            print(f"file: {result['file']}")
            print(f"language: {result['language']}")
            print(f"tier: {result['tier']}")
            print(f"compliance: {result['compliance']}")
            if args.verbose:
                for name, check in result["checks"].items():
                    status = "pass" if check["passed"] else "FAIL"
                    print(f"  {name}: {status}")
                    for issue in check["issues"]:
                        print(f"    - {issue}")


if __name__ == "__main__":
    main()
