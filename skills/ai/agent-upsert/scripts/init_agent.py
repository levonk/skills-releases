#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Initialize a new agent definition file from the standard agent template.

Creates:
  <output-dir>/<agent-name>.md

The file is scaffolded from the agent template at
``templates/meta/agent-template.md.tmpl`` (rendered to strip Go
``text/template`` directives) with TODO placeholders for the agent-specific
fields.

Usage:
    uv run --script init_agent.py <agent-name> --path <output-directory>
    python init_agent.py <agent-name> --path <output-directory>

Examples:
    # Create in the standard internal-docs/agents/ directory
    python init_agent.py tax-strategist --path ./internal-docs/agents

    # Create in a project-specific agents directory
    python init_agent.py code-reviewer --path ./.agents/agents

    # Create in the user directory
    python init_agent.py spiritual-advisor --path ~/.agents/agents

The --path argument accepts nested paths; all parent directories are created
automatically. Tilde (~) is expanded to the user's home directory.
"""

import argparse
import os
import re
import sys
from datetime import datetime
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



def get_script_dir() -> Path:
    """Get the directory where this script is located."""
    return Path(__file__).parent.parent


def load_agent_template() -> str:
    """Load the agent template from the references directory.

    The canonical agent template lives at
    ``templates/meta/agent-template.md.tmpl`` in the skills-src repo. A copy
    is bundled in this skill's ``references/agent-template.md.tmpl`` so the
    skill is self-contained after distribution. We prefer the bundled copy
    and fall back to the canonical location if the bundled copy is missing.
    """
    script_dir = get_script_dir()
    bundled_path = script_dir / "references" / "agent-template.md.tmpl"

    if bundled_path.exists():
        with open(bundled_path, "r") as f:
            return f.read()

    # Fallback: canonical location in the skills-src repo
    # (skills-src/src/current/skills/ai/agent-upsert/scripts/ ->
    #  skills-src/src/current/templates/meta/agent-template.md.tmpl)
    canonical_path = (
        script_dir.parent.parent.parent.parent
        / "templates"
        / "meta"
        / "agent-template.md.tmpl"
    )
    if canonical_path.exists():
        with open(canonical_path, "r") as f:
            return f.read()

    print(f"Error: Agent template not found at {bundled_path} or {canonical_path}")
    sys.exit(1)


def strip_template_directives(content: str) -> str:
    """Remove Go text/template include directives from the template.

    The agent template uses Go text/template include directives (triple-brace
    `include` syntax) to pull
    in shared markdown header/footer templates. When scaffolding a
    standalone agent file, we replace those with TODO comments so the author
    can fill in the header/footer manually or remove them.
    """
    # Replace include directives with a TODO comment
    pattern = re.compile(r"\{\{\{\s*include\s+\"[^\"]+\"\s*\.\s*\}\}\}")
    content = pattern.sub("<!-- TODO: Add standard markdown header/footer -->", content)
    return content


def create_agent_file(agent_name: str, output_path: str) -> None:
    """Create the agent definition file from the template.

    The output_path may be a nested path. All parent directories are created
    automatically. Tilde (~) is expanded to the user's home directory.
    """
    expanded_path = os.path.expanduser(output_path)
    output_dir = Path(expanded_path)
    agent_file = output_dir / f"{agent_name}.md"

    if agent_file.exists():
        print(f"Error: Agent file already exists: {agent_file}")
        sys.exit(1)

    # Create parent directories if they don't exist
    os.makedirs(str(output_dir), exist_ok=True)

    # Load and process the template
    template_content = load_agent_template()
    template_content = strip_template_directives(template_content)

    # Substitute placeholders
    created_date = datetime.now().strftime("%Y-%m-%d")
    agent_title = agent_name.replace("-", " ").title()

    # The template has empty fields; we leave them as TODOs for the author.
    # We only set the date fields since those are deterministic.
    template_content = template_content.replace('created: ""', f'created: "{created_date}"')
    template_content = template_content.replace('updated: ""', f'updated: "{created_date}"')

    agent_file.write_text(template_content)

    print(f"✓ Agent created at: {agent_file}")
    print(f"\nNext steps:")
    print(f"1. Edit the frontmatter — fill in agent, description, use, personality,")
    print(f"   categories, capabilities, model-level, tools, tags")
    print(f"2. Fill in the body sections — Goal, Role, i/o, Primary Workflow,")
    print(f"   Tools, Instructions, Templates, Guardrails, Design By Contract")
    print(f"3. Set date.last-used to the current date (YYYY-MM-DD)")
    print(f"4. Validate the agent definition against domain standards")
    print(f"5. Test the agent with a sample task")


def main():
    parser = argparse.ArgumentParser(
        description="Initialize a new agent definition from the standard template"
    )
    parser.add_argument(
        "agent_name",
        help="Name of the agent (use kebab-case, e.g., tax-strategist)",
    )
    parser.add_argument(
        "--path",
        default="internal-docs/agents",
        help="Output directory for the agent file (default: internal-docs/agents)",
    )

    args = parser.parse_args()

    # Validate agent name
    if not args.agent_name.replace("-", "").isalnum():
        print("Error: Agent name should use kebab-case (letters, numbers, hyphens only)")
        sys.exit(1)

    create_agent_file(args.agent_name, args.path)


if __name__ == "__main__":
    main()
