#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Initialize a new skill with proper directory structure and template files.

Usage:
    uv run --script init_skill.py <skill-name> --path <output-directory>
    python init_skill.py <skill-name> --path <output-directory>

Examples:
    # Create in the skills-src repo (public profile)
    python init_skill.py pdf-rotator --path ~/p/gh/levonk/skills-src/src/current/skills/cad

    # Create in the skills-src repo (private profile)
    python init_skill.py internal-tool --path ~/p/gh/levonk/skills-src/src/private/skills/business

    # Create in the current project
    python init_skill.py project-skill --path ./.agents/skills/general

    # Create in the user directory
    python init_skill.py personal-skill --path ~/.agents/skills/general

The --path argument accepts nested paths; all parent directories are created
automatically. Tilde (~) is expanded to the user's home directory.
"""

import argparse
import os
import shutil
import subprocess
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
    # Already inside devbox shell?
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return None

    # devbox
    if shutil.which("devbox") and _walk_up_find("devbox.json"):
        return "devbox run --"

    # mise
    if shutil.which("mise") and _walk_up_find(".mise.toml", ".mise/config.toml"):
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
    r = resolve_tool("devbox")
    # Actually check if devbox wrapper is active for this dir
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return _walk_up_find("devbox.json") is not None


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Backward compat: run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


def is_rtk_available() -> bool:
    """Backward compat: check if rtk is available."""
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    """Backward compat: run a command through rtk if available, otherwise through devbox/direct."""
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)



def get_script_dir() -> Path:
    """Get the directory where this script is located."""
    return Path(__file__).parent.parent


def load_template(template_name: str) -> str:
    """Load a template file from the templates directory."""
    script_dir = get_script_dir()
    template_path = script_dir / "templates" / template_name

    if not template_path.exists():
        print(f"Error: Template file not found: {template_path}")
        sys.exit(1)

    with open(template_path, "r") as f:
        return f.read()


def load_skill_md_template() -> str:
    """Load references/skill-template.md — the single source of truth for
    the scaffolded SKILL.md. The whole file IS the template; init_skill.py
    substitutes <skill-name>, <YYYY-MM-DD>, and <Skill Title> placeholders.
    """
    script_dir = get_script_dir()
    ref_path = script_dir / "references" / "skill-template.md"

    if not ref_path.exists():
        print(f"Error: skill-template.md not found: {ref_path}")
        sys.exit(1)

    with open(ref_path, "r") as f:
        return f.read()


def create_skill_structure(skill_name: str, output_path: str) -> None:
    """Create the skill directory structure with template files.

    The output_path may be a nested path (e.g. a skills-src profile path like
    ``src/current/skills/<category>``). All parent directories are created
    automatically. Tilde (~) is expanded to the user's home directory.
    """
    # Expand ~ and resolve to an absolute path so nested skills-src paths work
    expanded_path = os.path.expanduser(output_path)
    output_dir = Path(expanded_path)
    skill_dir = output_dir / skill_name

    if skill_dir.exists():
        print(f"Error: Directory {skill_dir} already exists")
        sys.exit(1)

    # Create parent directories of the output path if they don't exist,
    # then the skill directory itself (parents=True handles both)
    os.makedirs(str(output_dir), exist_ok=True)
    skill_dir.mkdir(parents=True, exist_ok=True)
    (skill_dir / "scripts").mkdir(exist_ok=True)
    (skill_dir / "references").mkdir(exist_ok=True)
    (skill_dir / "assets").mkdir(exist_ok=True)
    (skill_dir / "evals").mkdir(exist_ok=True)

    # Load and render templates
    created_date = datetime.now().strftime('%Y-%m-%d')
    skill_title = skill_name.replace('-', ' ').title()

    # Create SKILL.md from the template embedded in references/skill-template.md
    # The reference file is the single source of truth for skill structure.
    skill_md_template = load_skill_md_template()
    skill_md_content = skill_md_template.replace("<skill-name>", skill_name)
    skill_md_content = skill_md_content.replace("<YYYY-MM-DD>", created_date)
    skill_md_content = skill_md_content.replace("<Skill Title>", skill_title)

    with open(skill_dir / "SKILL.md", "w") as f:
        f.write(skill_md_content)

    # Create example script from template
    example_script_template = load_template("example-script.py.template")
    with open(skill_dir / "scripts" / "example.py", "w") as f:
        f.write(example_script_template)

    # Create example reference from template
    example_reference_template = load_template("example-reference.md.template")
    with open(skill_dir / "references" / "example.md", "w") as f:
        f.write(example_reference_template)

    # Create evals template
    evals_template = load_template("evals.json.template")
    evals_content = evals_template.replace('{{ .skill_name | default \"\" }}', skill_name)
    with open(skill_dir / "evals" / "evals.json", "w") as f:
        f.write(evals_content)

    # Create .gitignore from template
    gitignore_template = load_template("gitignore.template")
    with open(skill_dir / ".gitignore", "w") as f:
        f.write(gitignore_template)

    print(f"✓ Skill created at: {skill_dir}")
    print(f"✓ Directory structure:")
    print(f"  - SKILL.md (main skill file)")
    print(f"  - scripts/ (executable code)")
    print(f"  - references/ (documentation)")
    print(f"  - assets/ (output resources)")
    print(f"  - evals/ (test cases)")
    print(f"\nNext steps:")
    print(f"1. Edit SKILL.md to add skill content")
    print(f"2. Add scripts/references/assets as needed")
    print(f"3. Delete example files you don't need")
    print(f"4. Test with evals/evals.json")
    print(f"5. Package with: devbox run -- python scripts/package_skill.py {skill_dir}")
    print(f"   (or: python scripts/package_skill.py {skill_dir} if devbox is unavailable)")


def main():
    parser = argparse.ArgumentParser(description="Initialize a new skill")
    parser.add_argument("skill_name", help="Name of the skill (use kebab-case)")
    parser.add_argument("--path", default=".", help="Output directory for the skill")

    args = parser.parse_args()

    # Validate skill name
    if not args.skill_name.replace("-", "").isalnum():
        print("Error: Skill name should use kebab-case (letters, numbers, hyphens only)")
        sys.exit(1)

    create_skill_structure(args.skill_name, args.path)


if __name__ == "__main__":
    main()
