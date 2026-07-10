#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Discover existing AI agent skills matching a query across local skills-src,
skills.sh, and GitHub. Used by the ai-skill-upsert research phase to find
existing skills before creating a new one.

Usage:
    uv run --script discover_skills.py "pdf rotation tool"
    ./scripts/discover_skills.py "skill comparison" --verbose
    python scripts/discover_skills.py "code review" --sources local,skills.sh

Output (stdout): JSON object with arrays of found skills per source.

    {
      "query": "pdf rotation tool",
      "local": [{"name": "...", "path": "...", "description": "...", "tags": [...]}],
      "skills_sh": [{"name": "...", "url": "...", "description": "...", "installs": 1234}],
      "github": [{"name": "...", "repo": "owner/repo", "url": "...", "description": "...", "stars": 42}]
    }

Quiet by default; --verbose prints progress to stderr; --dry-run prints what
would be searched without making API calls.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Devbox detection — use `devbox run --` to execute commands when devbox
# is available and a devbox.json exists, unless already inside a devbox shell.
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
# RTK detection — use rtk as a proxy for git/gh to reduce token consumption.
# See: https://github.com/rtk-ai/rtk
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


# ---------------------------------------------------------------------------
# Frontmatter parsing
# ---------------------------------------------------------------------------
def parse_frontmatter(content: str) -> dict:
    """Parse YAML frontmatter from a SKILL.md file content. Returns a dict.

    Handles simple key-value pairs and list items. Does not handle nested
    objects or multi-line block scalars (use extract_description for those).
    Keys with hyphens (e.g., see-also, last-used) are matched correctly.
    """
    if not content.startswith("---"):
        return {}
    parts = content.split("---", 2)
    if len(parts) < 3:
        return {}
    fm_text = parts[1].strip()
    result: dict = {}
    for line in fm_text.splitlines():
        line = line.rstrip()
        if not line or line.startswith("#"):
            continue
        # Match top-level keys (including hyphenated keys like see-also)
        m = re.match(r"^([\w-]+):\s*(.*)$", line)
        if m:
            key, val = m.group(1), m.group(2).strip()
            if val and not val.startswith("|") and not val.startswith(">"):
                val = val.strip('"').strip("'")
                result[key] = val
            else:
                # Empty value or block scalar marker — initialize key so
                # subsequent list items attach to the correct key
                result[key] = [] if not val else val
        elif line.startswith("  - ") and result:
            last_key = list(result.keys())[-1]
            if not isinstance(result.get(last_key), list):
                result[last_key] = [result[last_key]] if last_key in result else []
            result[last_key].append(line.strip("- ").strip('"').strip("'"))
    return result


def extract_description(content: str) -> str:
    """Extract the description from frontmatter, handling multi-line YAML."""
    if not content.startswith("---"):
        return ""
    parts = content.split("---", 2)
    if len(parts) < 3:
        return ""
    fm_text = parts[1]
    # Handle block scalars (>- or |)
    m = re.search(r"^description:\s*>-?\s*\n((?:  .+\n?)+)", fm_text, re.MULTILINE)
    if m:
        lines = [l.strip() for l in m.group(1).strip().splitlines()]
        return " ".join(lines)
    m = re.search(r"^description:\s*(.+)$", fm_text, re.MULTILINE)
    if m:
        return m.group(1).strip().strip('"').strip("'")
    return ""


# ---------------------------------------------------------------------------
# Local skill discovery
# ---------------------------------------------------------------------------
def discover_local(query: str, skills_src_path: str | None = None, verbose: bool = False) -> list[dict]:
    """Scan local skills-src repository for SKILL.md files matching the query."""
    candidates: list[str] = []
    if skills_src_path:
        candidates.append(skills_src_path)
    else:
        default = Path.home() / "p" / "gh" / "levonk" / "skills-src"
        if default.exists():
            candidates.append(str(default))

    # Also check common project-level and user-level skill directories
    for env_path in [
        os.environ.get("CLAUDE_PROJECT_SKILLS", ""),
        str(Path.home() / ".agents" / "skills"),
        str(Path.cwd() / ".agents" / "skills"),
    ]:
        if env_path and Path(env_path).exists():
            candidates.append(env_path)

    results: list[dict] = []
    query_lower = query.lower()
    query_words = set(re.findall(r"\w+", query_lower))

    for base in candidates:
        base_path = Path(base)
        if verbose:
            print(f"  Scanning local: {base_path}", file=sys.stderr)
        for skill_md in base_path.rglob("SKILL.md"):
            try:
                content = skill_md.read_text(errors="replace")
            except OSError:
                continue
            fm = parse_frontmatter(content)
            desc = extract_description(content)
            name = fm.get("name", skill_md.parent.name)
            tags = fm.get("tags", [])
            if isinstance(tags, str):
                tags = [tags]

            # Score by keyword overlap
            searchable = f"{name} {desc} {' '.join(tags)}".lower()
            searchable_words = set(re.findall(r"\w+", searchable))
            overlap = len(query_words & searchable_words)
            if overlap == 0:
                # Check substring match as fallback
                if query_lower not in searchable:
                    continue
                overlap = 1

            results.append({
                "name": name,
                "path": str(skill_md),
                "description": desc[:200] if desc else "",
                "tags": tags if isinstance(tags, list) else [],
                "match_score": overlap,
                "source": "local",
            })

    results.sort(key=lambda x: x["match_score"], reverse=True)
    return results[:20]


# ---------------------------------------------------------------------------
# skills.sh discovery
# ---------------------------------------------------------------------------
def discover_skills_sh(query: str, verbose: bool = False, dry_run: bool = False) -> list[dict]:
    """Search skills.sh for skills matching the query."""
    if dry_run:
        if verbose:
            print("  [dry-run] Would search skills.sh API", file=sys.stderr)
        return []

    # skills.sh has a search API: https://www.skills.sh/docs/api
    # Use curl to fetch search results
    import urllib.request
    import urllib.parse

    encoded = urllib.parse.quote(query)
    url = f"https://www.skills.sh/api/search?q={encoded}"

    if verbose:
        print(f"  Fetching: {url}", file=sys.stderr)

    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json", "User-Agent": "discover_skills.py/1.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
    except Exception as e:
        if verbose:
            print(f"  skills.sh API error: {e}", file=sys.stderr)
        # Fallback: try the CLI if available
        return discover_skills_sh_cli(query, verbose)

    skills = data if isinstance(data, list) else data.get("skills", data.get("results", []))
    results: list[dict] = []
    for skill in skills[:20]:
        results.append({
            "name": skill.get("name", skill.get("title", "unknown")),
            "url": skill.get("url", skill.get("link", "")),
            "description": (skill.get("description", "") or "")[:200],
            "installs": skill.get("installs", skill.get("installCount", 0)),
            "source": "skills.sh",
        })
    return results


def discover_skills_sh_cli(query: str, verbose: bool = False) -> list[dict]:
    """Fallback: use `npx skills find` CLI if available."""
    npx = shutil.which("npx")
    if not npx:
        return []
    if verbose:
        print(f"  Falling back to: npx skills find", file=sys.stderr)
    try:
        proc = devbox_run(
            [npx, "skills", "find", query, "--json"],
            capture_output=True, text=True, timeout=30,
        )
        if proc.returncode != 0:
            return []
        data = json.loads(proc.stdout)
        skills = data if isinstance(data, list) else data.get("skills", [])
        return [{
            "name": s.get("name", "unknown"),
            "url": s.get("url", ""),
            "description": (s.get("description", "") or "")[:200],
            "installs": s.get("installs", 0),
            "source": "skills.sh",
        } for s in skills[:20]]
    except Exception:
        return []


# ---------------------------------------------------------------------------
# GitHub discovery
# ---------------------------------------------------------------------------
def discover_github(query: str, verbose: bool = False, dry_run: bool = False) -> list[dict]:
    """Search GitHub for repositories containing SKILL.md files matching the query."""
    if dry_run:
        if verbose:
            print("  [dry-run] Would search GitHub for SKILL.md files", file=sys.stderr)
        return []

    gh = shutil.which("gh")
    if not gh:
        if verbose:
            print("  gh CLI not found, skipping GitHub search", file=sys.stderr)
        return []

    # Search for SKILL.md files with the query keywords
    search_query = f'"{query}" filename:SKILL.md'
    if verbose:
        print(f"  GitHub code search: {search_query}", file=sys.stderr)

    try:
        proc = rtk_wrap(
            "gh", "api", "search/code",
            "-f", f"q={search_query}",
            "-f", "per_page=20",
            "--jq", ".items[] | {repo: .repository.full_name, path: .path, url: .html_url}",
            capture_output=True, text=True, timeout=30,
        )
        if proc.returncode != 0:
            if verbose:
                print(f"  GitHub code search failed: {proc.stderr[:200]}", file=sys.stderr)
            return discover_github_repos(query, verbose)
        # Parse JSON lines output
        results: list[dict] = []
        for line in proc.stdout.strip().splitlines():
            if not line.strip():
                continue
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue
            repo = item.get("repo", "")
            results.append({
                "name": repo.split("/")[-1] if repo else "unknown",
                "repo": repo,
                "url": item.get("url", f"https://github.com/{repo}" if repo else ""),
                "description": "",
                "source": "github",
            })
        # Enrich with repo metadata
        for r in results[:10]:
            r.update(fetch_github_repo_meta(r["repo"], verbose))
        return results[:20]
    except Exception as e:
        if verbose:
            print(f"  GitHub search error: {e}", file=sys.stderr)
        return discover_github_repos(query, verbose)


def discover_github_repos(query: str, verbose: bool = False) -> list[dict]:
    """Fallback: search GitHub repositories (not code search) for skill repos."""
    search_query = f"{query} agent skill SKILL.md"
    if verbose:
        print(f"  GitHub repo search: {search_query}", file=sys.stderr)
    try:
        proc = rtk_wrap(
            "gh", "api", "search/repositories",
            "-f", f"q={search_query}",
            "-f", "sort=stars",
            "-f", "per_page=20",
            "--jq", ".items[] | {name: .name, repo: .full_name, url: .html_url, description: .description, stars: .stargazers_count}",
            capture_output=True, text=True, timeout=30,
        )
        if proc.returncode != 0:
            return []
        results: list[dict] = []
        for line in proc.stdout.strip().splitlines():
            if not line.strip():
                continue
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue
            results.append({
                "name": item.get("name", "unknown"),
                "repo": item.get("repo", ""),
                "url": item.get("url", ""),
                "description": (item.get("description", "") or "")[:200],
                "stars": item.get("stars", 0),
                "source": "github",
            })
        return results[:20]
    except Exception:
        return []


def fetch_github_repo_meta(repo: str, verbose: bool = False) -> dict:
    """Fetch stars and description for a GitHub repo."""
    if not repo:
        return {}
    try:
        proc = rtk_wrap(
            "gh", "api", f"repos/{repo}",
            "--jq", "{description: .description, stars: .stargazers_count, language: .language, topics: .topics, pushed_at: .pushed_at, license: .license.key}",
            capture_output=True, text=True, timeout=10,
        )
        if proc.returncode != 0:
            return {}
        return json.loads(proc.stdout.strip())
    except Exception:
        return {}


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    parser = argparse.ArgumentParser(
        description="Discover existing AI agent skills matching a query."
    )
    parser.add_argument("query", help="Search query (skill description or keywords)")
    parser.add_argument("--sources", default="local,skills.sh,github",
                        help="Comma-separated list of sources to search (default: local,skills.sh,github)")
    parser.add_argument("--skills-src-path", default=None,
                        help="Path to local skills-src repository (default: ~/p/gh/levonk/skills-src)")
    parser.add_argument("--verbose", action="store_true", help="Print progress to stderr")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be searched without API calls")
    args = parser.parse_args()

    sources = [s.strip() for s in args.sources.split(",")]
    result: dict = {"query": args.query}

    if "local" in sources:
        if args.verbose:
            print("Searching local skills...", file=sys.stderr)
        result["local"] = discover_local(args.query, args.skills_src_path, args.verbose)

    if "skills.sh" in sources:
        if args.verbose:
            print("Searching skills.sh...", file=sys.stderr)
        result["skills_sh"] = discover_skills_sh(args.query, args.verbose, args.dry_run)

    if "github" in sources:
        if args.verbose:
            print("Searching GitHub...", file=sys.stderr)
        result["github"] = discover_github(args.query, args.verbose, args.dry_run)

    # Summary counts
    total = sum(len(v) for k, v in result.items() if k != "query")
    if args.verbose:
        print(f"\nFound {total} skills across {len([k for k in result if k != 'query'])} sources", file=sys.stderr)

    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
