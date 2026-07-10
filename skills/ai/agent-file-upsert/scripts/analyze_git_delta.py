#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Analyze repository changes since an AGENTS.md file was last updated.

Produces a structured JSON report of commits, new/deleted files, new
directories, revert/removal commits (anti-pattern candidates), and dependency
changes. The report is consumed by a subagent that interprets it to extract
positive findings (to add to AGENTS.md), negative findings (anti-patterns),
and improvement candidates.

Determines the "last updated" cutoff from:
  1. The date.updated field in the AGENTS.md frontmatter (if present)
  2. The last git commit that modified the AGENTS.md file (fallback)

Usage:
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md --verbose
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md --path src/auth/
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md --json
"""

import argparse
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path


@dataclass
class CommitInfo:
    """Summary of a single commit."""
    hash: str
    date: str
    author: str
    subject: str


@dataclass
class DeltaReport:
    """Structured report of repository changes since a cutoff date."""
    repo_root: str
    agents_file: str
    cutoff_date: str
    cutoff_source: str  # "frontmatter" or "git-history"
    commit_count: int = 0
    date_range: str = ""
    top_contributors: list[str] = field(default_factory=list)
    new_files: list[str] = field(default_factory=list)
    deleted_files: list[str] = field(default_factory=list)
    new_directories: list[str] = field(default_factory=list)
    new_test_files: list[str] = field(default_factory=list)
    new_config_files: list[str] = field(default_factory=list)
    revert_removal_commits: list[CommitInfo] = field(default_factory=list)
    new_dependencies: list[str] = field(default_factory=list)
    removed_dependencies: list[str] = field(default_factory=list)


def run_git(repo: Path, args: list[str]) -> str:
    """Run a git command and return stdout. Raises on non-zero exit."""
    result = subprocess.run(
        ["git", "-C", str(repo), *args],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


def extract_frontmatter_date(agents_path: Path) -> str | None:
    """Extract date.updated from AGENTS.md YAML frontmatter.

    Looks for a frontmatter block delimited by --- lines, then parses the
    date.updated field. Returns YYYY-MM-DD or None.
    """
    if not agents_path.exists():
        return None
    text = agents_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    in_fm = False
    for line in lines[1:]:
        if line.strip() == "---":
            break
        in_fm = True
        # Match: updated: "YYYY-MM-DD" or updated: YYYY-MM-DD
        m = re.match(r'^updated:\s*["\']?(\d{4}-\d{2}-\d{2})["\']?', line.strip())
        if m:
            return m.group(1)
    return None


def get_last_commit_date_for_file(repo: Path, file_path: str) -> str | None:
    """Get the date of the last commit that modified a file."""
    try:
        # %cI = committer date, ISO 8601
        out = run_git(repo, ["log", "-1", "--format=%cI", "--", file_path])
        date_str = out.strip()
        if not date_str:
            return None
        # Trim to YYYY-MM-DD
        return date_str[:10]
    except subprocess.CalledProcessError:
        return None


def determine_cutoff(repo: Path, agents_file: str) -> tuple[str, str]:
    """Determine the cutoff date and its source.

    Returns (cutoff_date, source) where source is "frontmatter" or
    "git-history".
    """
    agents_path = repo / agents_file
    fm_date = extract_frontmatter_date(agents_path)
    if fm_date:
        return fm_date, "frontmatter"
    git_date = get_last_commit_date_for_file(repo, agents_file)
    if git_date:
        return git_date, "git-history"
    # No cutoff determinable — use epoch (all history)
    return "1970-01-01", "no-history"


def get_commits_since(repo: Path, cutoff: str, path: str | None) -> list[CommitInfo]:
    """Get commits since the cutoff date, optionally scoped to a path."""
    args = ["log", f"--since={cutoff}", "--format=%H|%cI|%an|%s"]
    if path:
        args.extend(["--", path])
    try:
        out = run_git(repo, args)
    except subprocess.CalledProcessError:
        return []
    commits: list[CommitInfo] = []
    for line in out.strip().splitlines():
        parts = line.split("|", 3)
        if len(parts) == 4:
            commits.append(CommitInfo(
                hash=parts[0],
                date=parts[1],
                author=parts[2],
                subject=parts[3],
            ))
    return commits


def get_changed_files_since(repo: Path, cutoff: str, path: str | None) -> tuple[list[str], list[str]]:
    """Get files added and deleted since the cutoff.

    Returns (added, deleted) lists of relative paths.
    """
    args = ["log", f"--since={cutoff}", "--name-status", "--format="]
    if path:
        args.extend(["--", path])
    try:
        out = run_git(repo, args)
    except subprocess.CalledProcessError:
        return [], []
    added: list[str] = []
    deleted: list[str] = []
    for line in out.strip().splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        status, filepath = parts[0], parts[1]
        # A = added, D = deleted, R = renamed (treat old as deleted, new as added)
        if status.startswith("A"):
            added.append(filepath)
        elif status.startswith("D"):
            deleted.append(filepath)
        elif status.startswith("R") and len(parts) >= 3:
            deleted.append(parts[1])
            added.append(parts[2])
    return added, deleted


def extract_new_directories(added_files: list[str]) -> list[str]:
    """Extract new top-level directories from added file paths."""
    seen: set[str] = set()
    dirs: list[str] = []
    for f in added_files:
        parts = f.split("/")
        if len(parts) > 1:
            top = parts[0]
            if top not in seen and not top.startswith("."):
                seen.add(top)
                dirs.append(top)
    return sorted(dirs)


def filter_test_files(files: list[str]) -> list[str]:
    """Filter for test files (test_*, *_test.*, *.spec.*, *.test.*)."""
    test_patterns = [
        r"test_.+\.\w+$",
        r".+_test\.\w+$",
        r".+\.test\.\w+$",
        r".+\.spec\.\w+$",
        r".+\.test\.\w+$",
    ]
    return sorted(
        f for f in files
        if any(re.search(p, f) for p in test_patterns)
    )


def filter_config_files(files: list[str]) -> list[str]:
    """Filter for config files."""
    config_names = {
        "package.json", "tsconfig.json", "Cargo.toml", "pyproject.toml",
        "devbox.json", "Justfile", "justfile", "Makefile", ".envrc",
        "nx.json", "pnpm-workspace.yaml", "go.mod", "go.sum",
        "docker-compose.yml", "Dockerfile", ".eslintrc.json",
    }
    return sorted(
        f for f in files
        if Path(f).name in config_names or f.endswith(".config.ts")
        or f.endswith(".config.js") or f.endswith(".config.json")
    )


def filter_revert_removal_commits(commits: list[CommitInfo]) -> list[CommitInfo]:
    """Filter commits that indicate reverts, removals, or replacements.

    These are anti-pattern candidates — practices that were abandoned.
    """
    keywords = [
        "revert", "remove", "delete", "switch from", "replace",
        "deprecate", "rollback", "undo", "stop using", "drop",
        "get rid of", "no longer",
    ]
    result: list[CommitInfo] = []
    for c in commits:
        subject_lower = c.subject.lower()
        if any(kw in subject_lower for kw in keywords):
            result.append(c)
    return result


def extract_dependency_changes(
    repo: Path, cutoff: str, path: str | None,
) -> tuple[list[str], list[str]]:
    """Extract dependency changes from package.json / Cargo.toml / pyproject.toml.

    Compares the current version of the file against the version at the cutoff
    date. Returns (new_deps, removed_deps) as a list of strings.
    """
    new_deps: list[str] = []
    removed_deps: list[str] = []

    dep_files = ["package.json", "Cargo.toml", "pyproject.toml", "go.mod"]
    search_paths = [path] if path else [""]
    for dep_file in dep_files:
        for sp in search_paths:
            fpath = f"{sp}/{dep_file}" if sp else dep_file
            try:
                old_content = run_git(repo, ["show", f"{cutoff}:{fpath}"])
            except subprocess.CalledProcessError:
                old_content = ""  # file didn't exist at cutoff
            curr_path = repo / fpath
            if not curr_path.exists():
                continue
            new_content = curr_path.read_text(encoding="utf-8")
            old_deps = extract_deps(dep_file, old_content)
            new_deps_set = extract_deps(dep_file, new_content)
            for dep in sorted(new_deps_set - old_deps):
                new_deps.append(f"{fpath}: +{dep}")
            for dep in sorted(old_deps - new_deps_set):
                removed_deps.append(f"{fpath}: -{dep}")
    return new_deps, removed_deps


def extract_deps(dep_file: str, content: str) -> set[str]:
    """Extract dependency names from a package manifest file."""
    deps: set[str] = set()
    if dep_file == "package.json":
        try:
            data = json.loads(content)
            for section in ("dependencies", "devDependencies", "peerDependencies"):
                deps.update((data.get(section) or {}).keys())
        except (json.JSONDecodeError, KeyError):
            pass
    elif dep_file == "Cargo.toml":
        in_deps = False
        for line in content.splitlines():
            if line.strip().startswith("[dependencies]") or line.strip().startswith("[dev-dependencies]"):
                in_deps = True
                continue
            if line.strip().startswith("["):
                in_deps = False
                continue
            if in_deps:
                m = re.match(r"^([a-zA-Z_][\w-]*)\s*=", line.strip())
                if m:
                    deps.add(m.group(1))
    elif dep_file == "pyproject.toml":
        in_deps = False
        for line in content.splitlines():
            if "dependencies" in line and "=" in line and "[" in line:
                in_deps = True
                continue
            if in_deps and line.strip() == "]":
                in_deps = False
                continue
            if in_deps:
                m = re.match(r'^["\']([^"\']+)["\']', line.strip())
                if m:
                    deps.add(m.group(1))
    elif dep_file == "go.mod":
        in_deps = False
        for line in content.splitlines():
            if line.strip() == "require (":
                in_deps = True
                continue
            if in_deps and line.strip() == ")":
                in_deps = False
                continue
            if in_deps:
                parts = line.strip().split()
                if len(parts) >= 2:
                    deps.add(parts[0])
    return deps


def analyze(repo: Path, agents_file: str, path: str | None, verbose: bool) -> DeltaReport:
    """Run the full delta analysis and return a structured report."""
    cutoff, cutoff_source = determine_cutoff(repo, agents_file)
    if verbose:
        print(f"  Cutoff date: {cutoff} (source: {cutoff_source})")

    commits = get_commits_since(repo, cutoff, path)
    added, deleted = get_changed_files_since(repo, cutoff, path)
    new_deps, removed_deps = extract_dependency_changes(repo, cutoff, path)

    # Top contributors (by commit count)
    contributor_counts: dict[str, int] = {}
    for c in commits:
        contributor_counts[c.author] = contributor_counts.get(c.author, 0) + 1
    top_contribs = sorted(contributor_counts, key=lambda a: -contributor_counts[a])[:5]

    # Date range
    date_range = ""
    if commits:
        dates = [c.date[:10] for c in commits]
        date_range = f"{dates[-1]} to {dates[0]}"

    report = DeltaReport(
        repo_root=str(repo),
        agents_file=agents_file,
        cutoff_date=cutoff,
        cutoff_source=cutoff_source,
        commit_count=len(commits),
        date_range=date_range,
        top_contributors=top_contribs,
        new_files=sorted(added),
        deleted_files=sorted(deleted),
        new_directories=extract_new_directories(added),
        new_test_files=filter_test_files(added),
        new_config_files=filter_config_files(added),
        revert_removal_commits=filter_revert_removal_commits(commits),
        new_dependencies=new_deps,
        removed_dependencies=removed_deps,
    )
    return report


def print_verbose(report: DeltaReport) -> None:
    """Print a human-readable summary of the report."""
    print(f"\nRepository: {report.repo_root}")
    print(f"AGENTS file: {report.agents_file}")
    print(f"Cutoff: {report.cutoff_date} (source: {report.cutoff_source})")
    print(f"Commits since cutoff: {report.commit_count}")
    if report.date_range:
        print(f"Date range: {report.date_range}")
    if report.top_contributors:
        print(f"Top contributors: {', '.join(report.top_contributors)}")
    print(f"\nNew files: {len(report.new_files)}")
    for f in report.new_files[:20]:
        print(f"  + {f}")
    if len(report.new_files) > 20:
        print(f"  ... and {len(report.new_files) - 20} more")
    print(f"\nDeleted files: {len(report.deleted_files)}")
    for f in report.deleted_files[:20]:
        print(f"  - {f}")
    if len(report.deleted_files) > 20:
        print(f"  ... and {len(report.deleted_files) - 20} more")
    print(f"\nNew directories: {report.new_directories}")
    print(f"New test files: {len(report.new_test_files)}")
    print(f"New config files: {len(report.new_config_files)}")
    print(f"\nRevert/removal commits (anti-pattern candidates): {len(report.revert_removal_commits)}")
    for c in report.revert_removal_commits[:20]:
        print(f"  {c.hash[:8]} {c.date[:10]} {c.subject}")
    if len(report.revert_removal_commits) > 20:
        print(f"  ... and {len(report.revert_removal_commits) - 20} more")
    print(f"\nNew dependencies: {len(report.new_dependencies)}")
    for d in report.new_dependencies:
        print(f"  {d}")
    print(f"\nRemoved dependencies: {len(report.removed_dependencies)}")
    for d in report.removed_dependencies:
        print(f"  {d}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Analyze repository changes since an AGENTS.md was last updated",
    )
    parser.add_argument("project_root", type=Path, help="Path to the project root")
    parser.add_argument("--agents-file", default="AGENTS.md", help="Agent file to analyze (default: AGENTS.md)")
    parser.add_argument("--path", default=None, help="Scope to a specific path (e.g., src/auth/)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Print human-readable summary")
    parser.add_argument("--json", action="store_true", help="Output JSON only (no human-readable output)")
    args = parser.parse_args()

    project_root = args.project_root.resolve()
    if not project_root.is_dir():
        print(f"ERROR: {project_root} is not a directory", file=sys.stderr)
        return 2

    # Verify it's a git repo
    try:
        run_git(project_root, ["rev-parse", "--is-inside-work-tree"])
    except subprocess.CalledProcessError:
        print(f"ERROR: {project_root} is not a git repository", file=sys.stderr)
        return 2

    report = analyze(project_root, args.agents_file, args.path, args.verbose)

    if args.json:
        print(json.dumps(asdict(report), indent=2))
    else:
        print_verbose(report)
        if args.verbose:
            print("\n--- JSON ---")
            print(json.dumps(asdict(report), indent=2))

    return 0


if __name__ == "__main__":
    sys.exit(main())
