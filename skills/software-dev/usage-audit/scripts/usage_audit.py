#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# ///
"""
Usage audit — parse local coding-agent session data and produce usage
diagnoses, reports, and shareable summaries.

Supports multiple coding agents via a parser interface. Each agent parser
reads that agent's local data and produces common SessionRecord objects.
The analysis layer (audit, forensics, report, share) works on merged data
from all detected agents.

Currently supported agents:
  - Devin CLI   (~/.local/share/devin/cli/)
  - Claude Code (~/.claude/projects/)  [planned — stub]

Stdlib only. No network connections. No packages to install.

Usage:
  usage_audit.py audit [--days N] [--csv PATH] [--panel] [--agent NAME]
  usage_audit.py forensics <csv> [--day YYYY-MM-DD] [--at YYYY-MM-DDTHH:MM]
  usage_audit.py report [--days N] [--html PATH] [--agent NAME]
  usage_audit.py share [--days N] [--agent NAME]
  usage_audit.py panel [--days N] [--agent NAME]
  usage_audit.py --dump-sample [--agent NAME]
  usage_audit.py --doctor
  usage_audit.py --list-agents
"""

import argparse
import csv
import glob
import html as html_mod
import json
import os
import sqlite3
import sys
from collections import defaultdict, Counter
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any

# ---------------------------------------------------------------------------
# Model rates (USD per 1M tokens, approximate)
# Used for cost estimation only — not authoritative.
# ---------------------------------------------------------------------------

MODEL_RATES = {
    # prompt / completion / cached per 1M tokens
    "glm-5-2":         {"prompt": 0.50, "completion": 2.00, "cached": 0.05},
    "glm-5-2-high":    {"prompt": 0.50, "completion": 2.00, "cached": 0.05},
    "gpt-5":           {"prompt": 5.00, "completion": 15.00, "cached": 1.25},
    "gpt-5-mini":      {"prompt": 0.30, "completion": 1.20, "cached": 0.075},
    "claude-sonnet-4": {"prompt": 3.00, "completion": 15.00, "cached": 0.30},
    "claude-opus-4":   {"prompt": 15.00, "completion": 75.00, "cached": 1.50},
    "default":         {"prompt": 1.00, "completion": 5.00, "cached": 0.10},
}

def get_rates(model: str) -> Dict[str, float]:
    model_lower = model.lower().strip()
    for key in MODEL_RATES:
        if key != "default" and key in model_lower:
            return MODEL_RATES[key]
    return MODEL_RATES["default"]

def estimate_cost(prompt_tokens: int, completion_tokens: int, cached_tokens: int, model: str) -> float:
    rates = get_rates(model)
    cost = (
        (prompt_tokens - cached_tokens) * rates["prompt"] / 1_000_000
        + completion_tokens * rates["completion"] / 1_000_000
        + cached_tokens * rates["cached"] / 1_000_000
    )
    return round(cost, 4)

# ---------------------------------------------------------------------------
# Session record — the common data model for all agents
# ---------------------------------------------------------------------------

class SessionRecord:
    """Common session record produced by all agent parsers."""

    def __init__(self):
        self.session_id = ""
        self.agent = ""            # "devin", "claude-code", etc.
        self.model = ""
        self.agent_mode = ""
        self.title = ""
        self.working_directory = ""
        self.created_at = 0        # unix timestamp
        self.last_activity_at = 0
        self.prompt_tokens = 0
        self.completion_tokens = 0
        self.cached_tokens = 0
        self.total_steps = 0
        self.source = ""           # parser-specific source label

    @property
    def total_tokens(self) -> int:
        return self.prompt_tokens + self.completion_tokens

    @property
    def uncached_prompt(self) -> int:
        return max(0, self.prompt_tokens - self.cached_tokens)

    @property
    def cache_ratio(self) -> float:
        if self.prompt_tokens == 0:
            return 0.0
        return self.cached_tokens / self.prompt_tokens

    @property
    def created_dt(self) -> datetime:
        return datetime.fromtimestamp(self.created_at, tz=timezone.utc)

    @property
    def last_activity_dt(self) -> datetime:
        return datetime.fromtimestamp(self.last_activity_at, tz=timezone.utc)

    @property
    def duration_seconds(self) -> int:
        return max(0, self.last_activity_at - self.created_at)

    @property
    def duration_minutes(self) -> float:
        return self.duration_seconds / 60.0

    @property
    def project_name(self) -> str:
        if self.working_directory:
            return os.path.basename(self.working_directory.rstrip("/")) or self.working_directory
        return "(unknown)"

    @property
    def cost_estimate(self) -> float:
        return estimate_cost(self.prompt_tokens, self.completion_tokens, self.cached_tokens, self.model)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "session_id": self.session_id,
            "agent": self.agent,
            "model": self.model,
            "agent_mode": self.agent_mode,
            "title": self.title,
            "working_directory": self.working_directory,
            "project": self.project_name,
            "created_at": self.created_at,
            "last_activity_at": self.last_activity_at,
            "created_iso": self.created_dt.isoformat() if self.created_at else "",
            "last_activity_iso": self.last_activity_dt.isoformat() if self.last_activity_at else "",
            "duration_minutes": round(self.duration_minutes, 1),
            "prompt_tokens": self.prompt_tokens,
            "completion_tokens": self.completion_tokens,
            "cached_tokens": self.cached_tokens,
            "uncached_prompt": self.uncached_prompt,
            "total_tokens": self.total_tokens,
            "cache_ratio": round(self.cache_ratio, 4),
            "total_steps": self.total_steps,
            "cost_estimate": self.cost_estimate,
        }

# ---------------------------------------------------------------------------
# Agent parser interface
# ---------------------------------------------------------------------------

class AgentParser:
    """Base class for agent-specific data parsers."""

    name = "base"
    display_name = "Base Agent"
    data_paths: List[str] = []

    def is_available(self) -> bool:
        """Check if this agent's data exists on this machine."""
        home = Path(os.environ.get("HOME", "~")).expanduser()
        for p in self.data_paths:
            if (home / p).exists():
                return True
        return False

    def load_sessions(self) -> List[SessionRecord]:
        """Load all sessions for this agent."""
        raise NotImplementedError

    def dump_sample(self) -> None:
        """Dump a sample of this agent's data structure for verification."""
        raise NotImplementedError

    def doctor(self) -> None:
        """Verify data sources and report status."""
        raise NotImplementedError

# ---------------------------------------------------------------------------
# Devin CLI parser
# ---------------------------------------------------------------------------

class DevinParser(AgentParser):
    name = "devin"
    display_name = "Devin CLI"
    data_paths = [".local/share/devin/cli"]

    def data_dir(self) -> Path:
        home = Path(os.environ.get("HOME", "~")).expanduser()
        return home / ".local" / "share" / "devin" / "cli"

    def transcripts_dir(self) -> Path:
        return self.data_dir() / "transcripts"

    def sessions_db_path(self) -> Path:
        return self.data_dir() / "sessions.db"

    def load_sessions(self) -> List[SessionRecord]:
        db_recs = self._load_from_db()
        tx_recs = self._load_from_transcripts()
        return self._merge(db_recs, tx_recs)

    def _load_from_db(self) -> Dict[str, SessionRecord]:
        records = {}
        db = self.sessions_db_path()
        if not db.exists():
            return records
        try:
            conn = sqlite3.connect(str(db))
            conn.row_factory = sqlite3.Row
            cursor = conn.execute(
                "SELECT id, working_directory, backend_type, model, agent_mode, "
                "created_at, last_activity_at, title, metadata FROM sessions"
            )
            for row in cursor:
                rec = SessionRecord()
                rec.agent = self.name
                rec.session_id = row["id"]
                rec.working_directory = row["working_directory"] or ""
                rec.model = row["model"] or ""
                rec.agent_mode = row["agent_mode"] or ""
                rec.created_at = row["created_at"]
                rec.last_activity_at = row["last_activity_at"]
                rec.title = row["title"] or ""
                rec.source = "db"
                records[rec.session_id] = rec
            conn.close()
        except sqlite3.Error as e:
            print(f"Warning: could not read Devin sessions.db: {e}", file=sys.stderr)
        return records

    def _load_from_transcripts(self) -> Dict[str, SessionRecord]:
        records = {}
        tdir = self.transcripts_dir()
        if not tdir.exists():
            return records
        for fpath in sorted(tdir.glob("*.json")):
            try:
                with open(fpath) as f:
                    data = json.load(f)
                sid = data.get("session_id", fpath.stem)
                fm = data.get("final_metrics", {})
                rec = SessionRecord()
                rec.agent = self.name
                rec.session_id = sid
                rec.prompt_tokens = fm.get("total_prompt_tokens", 0)
                rec.completion_tokens = fm.get("total_completion_tokens", 0)
                rec.cached_tokens = fm.get("total_cached_tokens", 0)
                rec.total_steps = fm.get("total_steps", 0)
                rec.source = "transcript"
                agent_info = data.get("agent", {})
                rec.model = agent_info.get("model_name", "")
                records[sid] = rec
            except (json.JSONDecodeError, KeyError):
                continue
        return records

    def _merge(self, db_recs: Dict, tx_recs: Dict) -> List[SessionRecord]:
        merged = {}
        all_ids = set(db_recs.keys()) | set(tx_recs.keys())
        for sid in all_ids:
            db_rec = db_recs.get(sid)
            tx_rec = tx_recs.get(sid)
            if db_rec and tx_rec:
                rec = db_rec
                rec.prompt_tokens = tx_rec.prompt_tokens
                rec.completion_tokens = tx_rec.completion_tokens
                rec.cached_tokens = tx_rec.cached_tokens
                rec.total_steps = tx_rec.total_steps
                if not rec.model:
                    rec.model = tx_rec.model
                rec.source = "both"
            elif db_rec:
                rec = db_rec
            else:
                rec = tx_rec
                rec.created_at = 0
                rec.last_activity_at = 0
            merged[sid] = rec
        return list(merged.values())

    def dump_sample(self) -> None:
        tdir = self.transcripts_dir()
        if not tdir.exists():
            print(f"Devin transcripts directory not found: {tdir}")
            return
        files = sorted(tdir.glob("*.json"))
        if not files:
            print("No Devin transcript files found.")
            return
        print(f"Devin sample transcript: {files[0].name}")
        print(f"{'=' * 60}")
        try:
            with open(files[0]) as f:
                data = json.load(f)
            print(f"Top-level keys: {list(data.keys())}")
            print(f"Schema version: {data.get('schema_version', 'unknown')}")
            print(f"Session ID: {data.get('session_id', 'unknown')}")
            agent = data.get("agent", {})
            print(f"Agent name: {agent.get('name', 'unknown')}")
            print(f"Model: {agent.get('model_name', 'unknown')}")
            fm = data.get("final_metrics", {})
            print(f"\nfinal_metrics:")
            for k, v in fm.items():
                print(f"  {k}: {v}")
            steps = data.get("steps", [])
            print(f"\nSteps: {len(steps)}")
            if steps:
                s = steps[0]
                print(f"Step[0] keys: {list(s.keys())}")
                print(f"Step[0] source: {s.get('source')}")
        except (json.JSONDecodeError, KeyError) as e:
            print(f"Error reading file: {e}")

    def doctor(self) -> None:
        tdir = self.transcripts_dir()
        db = self.sessions_db_path()
        print(f"\nDevin CLI:")
        print(f"  Transcripts: {tdir}")
        if tdir.exists():
            files = list(tdir.glob("*.json"))
            print(f"    Status: FOUND ({len(files)} files)")
            if files:
                try:
                    with open(files[0]) as f:
                        data = json.load(f)
                    fm = data.get("final_metrics", {})
                    has_metrics = bool(fm)
                    print(f"    Has final_metrics: {has_metrics}")
                    if has_metrics:
                        for field in ["total_prompt_tokens", "total_completion_tokens", "total_cached_tokens", "total_steps"]:
                            print(f"      {field}: {fm.get(field, 'MISSING')}")
                except (json.JSONDecodeError, KeyError) as e:
                    print(f"    ⚠ Could not parse sample: {e}")
        else:
            print(f"    Status: NOT FOUND")
        print(f"  Sessions DB: {db}")
        if db.exists():
            try:
                conn = sqlite3.connect(str(db))
                count = conn.execute("SELECT COUNT(*) FROM sessions").fetchone()[0]
                print(f"    Status: FOUND ({count} sessions)")
                conn.close()
            except sqlite3.Error as e:
                print(f"    ⚠ Could not read: {e}")
        else:
            print(f"    Status: NOT FOUND")

# ---------------------------------------------------------------------------
# Claude Code parser (planned — stub for now)
# ---------------------------------------------------------------------------

class ClaudeCodeParser(AgentParser):
    name = "claude-code"
    display_name = "Claude Code"
    data_paths = [".claude/projects"]

    def projects_dir(self) -> Path:
        home = Path(os.environ.get("HOME", "~")).expanduser()
        return home / ".claude" / "projects"

    def load_sessions(self) -> List[SessionRecord]:
        """Parse Claude Code JSONL session logs.

        Claude Code stores per-request usage in ~/.claude/projects/**/*.jsonl.
        Each entry contains message.usage with input_tokens, output_tokens,
        cache_creation_input_tokens, cache_read_input_tokens.

        TODO: implement full parser. The format is documented in tare's
        ccaudit.py and provides per-request granularity that Devin doesn't.
        """
        # Stub — return empty for now
        # When implemented, this will:
        # 1. Walk ~/.claude/projects/**/*.jsonl
        # 2. Parse each JSONL line for message.usage
        # 3. Deduplicate (Claude Code repeats usage per content block)
        # 4. Aggregate per session
        # 5. Return SessionRecord list with agent="claude-code"
        return []

    def dump_sample(self) -> None:
        pdir = self.projects_dir()
        if not pdir.exists():
            print(f"Claude Code projects directory not found: {pdir}")
            return
        files = sorted(pdir.rglob("*.jsonl"))
        if not files:
            print("No Claude Code JSONL files found.")
            return
        print(f"Claude Code sample file: {files[0]}")
        print(f"{'=' * 60}")
        print("(parser not yet implemented — showing first JSONL line)")
        try:
            with open(files[0]) as f:
                first_line = f.readline().strip()
            data = json.loads(first_line)
            print(f"Keys: {list(data.keys())}")
            # Look for usage
            msg = data.get("message", {})
            usage = msg.get("usage", {})
            if usage:
                print(f"message.usage: {json.dumps(usage, indent=2)}")
            else:
                print("No message.usage found in first line")
        except (json.JSONDecodeError, KeyError) as e:
            print(f"Error reading file: {e}")

    def doctor(self) -> None:
        pdir = self.projects_dir()
        print(f"\nClaude Code:")
        print(f"  Projects: {pdir}")
        if pdir.exists():
            files = list(pdir.rglob("*.jsonl"))
            print(f"    Status: FOUND ({len(files)} JSONL files)")
            print(f"    Parser: NOT YET IMPLEMENTED (stub)")
        else:
            print(f"    Status: NOT FOUND")

# ---------------------------------------------------------------------------
# Agent registry
# ---------------------------------------------------------------------------

ALL_PARSERS = [DevinParser(), ClaudeCodeParser()]

def get_parser(name: str) -> Optional[AgentParser]:
    for p in ALL_PARSERS:
        if p.name == name:
            return p
    return None

def detected_agents() -> List[AgentParser]:
    """Return parsers for agents whose data is present on this machine."""
    return [p for p in ALL_PARSERS if p.is_available()]

# ---------------------------------------------------------------------------
# Data loading (multi-agent)
# ---------------------------------------------------------------------------

def load_all_sessions(agent_filter: Optional[str] = None) -> List[SessionRecord]:
    """Load sessions from all detected agents (or one if filtered)."""
    if agent_filter:
        parser = get_parser(agent_filter)
        if not parser:
            print(f"Error: unknown agent '{agent_filter}'", file=sys.stderr)
            print(f"Available: {', '.join(p.name for p in ALL_PARSERS)}", file=sys.stderr)
            sys.exit(1)
        if not parser.is_available():
            print(f"Warning: agent '{agent_filter}' data not found", file=sys.stderr)
            return []
        sessions = parser.load_sessions()
    else:
        sessions = []
        for parser in detected_agents():
            sessions.extend(parser.load_sessions())
    sessions = [s for s in sessions if s.total_tokens > 0 or s.created_at > 0]
    sessions.sort(key=lambda s: s.last_activity_at)
    return sessions

def filter_by_days(sessions: List[SessionRecord], days: int) -> List[SessionRecord]:
    cutoff = datetime.now(tz=timezone.utc) - timedelta(days=days)
    cutoff_ts = int(cutoff.timestamp())
    return [s for s in sessions if s.last_activity_at >= cutoff_ts]

# ---------------------------------------------------------------------------
# Formatting helpers
# ---------------------------------------------------------------------------

def fmt_tokens(n: int) -> str:
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}K"
    return str(n)

def fmt_duration(minutes: float) -> str:
    if minutes < 60:
        return f"{minutes:.0f}m"
    hours = minutes / 60
    if hours < 24:
        return f"{hours:.1f}h"
    days = hours / 24
    return f"{days:.1f}d"

def fmt_cost(c: float) -> str:
    if c < 0.01:
        return f"${c:.4f}"
    return f"${c:.2f}"

def fmt_date(ts: int) -> str:
    if ts == 0:
        return "(unknown)"
    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%d")

def fmt_datetime(ts: int) -> str:
    if ts == 0:
        return "(unknown)"
    return datetime.fromtimestamp(ts, tz=timezone.utc).strftime("%Y-%m-%d %H:%M")

# ---------------------------------------------------------------------------
# CSV output
# ---------------------------------------------------------------------------

CSV_FIELDS = [
    "session_id", "agent", "model", "agent_mode", "title", "project",
    "working_directory", "created_at", "last_activity_at",
    "created_iso", "last_activity_iso",
    "duration_minutes", "prompt_tokens", "completion_tokens",
    "cached_tokens", "uncached_prompt", "total_tokens",
    "cache_ratio", "total_steps", "cost_estimate",
]

def write_csv(sessions: List[SessionRecord], path: str) -> None:
    with open(path, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for s in sessions:
            writer.writerow(s.to_dict())
    print(f"CSV written to {path} ({len(sessions)} sessions)", file=sys.stderr)

# ---------------------------------------------------------------------------
# Audit — text summary
# ---------------------------------------------------------------------------

def cmd_audit(args) -> None:
    sessions = load_all_sessions(args.agent)
    if args.days:
        sessions = filter_by_days(sessions, args.days)

    if not sessions:
        print("No session data found.")
        agents = detected_agents()
        if agents:
            print(f"Detected agents: {', '.join(p.name for p in agents)}")
        else:
            print("No coding agent data detected on this machine.")
            print(f"Checked: {', '.join(p.name + ' (' + ', '.join(p.data_paths) + ')' for p in ALL_PARSERS)}")
        return

    total_prompt = sum(s.prompt_tokens for s in sessions)
    total_completion = sum(s.completion_tokens for s in sessions)
    total_cached = sum(s.cached_tokens for s in sessions)
    total_tokens = total_prompt + total_completion
    total_cost = sum(s.cost_estimate for s in sessions)

    # Agent breakdown
    by_agent = defaultdict(lambda: {"sessions": 0, "tokens": 0})
    for s in sessions:
        by_agent[s.agent]["sessions"] += 1
        by_agent[s.agent]["tokens"] += s.total_tokens

    print(f"Usage Audit — last {args.days} days")
    print(f"{'=' * 60}")
    print(f"Sessions:          {len(sessions)}")
    if len(by_agent) > 1:
        for agent, stats in sorted(by_agent.items()):
            print(f"  {agent:<16} {stats['sessions']:>8} sessions  {stats['tokens']:>12,} tokens")
    print()
    print(f"Total tokens:      {total_tokens:,}")
    print(f"  Prompt:          {total_prompt:,}")
    print(f"  Completion:      {total_completion:,}")
    print(f"  Cached:          {total_cached:,}")
    if total_prompt > 0:
        print(f"  Cache ratio:     {total_cached / total_prompt:.1%}")
    print(f"  Est. API cost:   {fmt_cost(total_cost)}")
    print()

    # By model
    by_model = defaultdict(lambda: {"sessions": 0, "tokens": 0, "cost": 0.0})
    for s in sessions:
        by_model[s.model]["sessions"] += 1
        by_model[s.model]["tokens"] += s.total_tokens
        by_model[s.model]["cost"] += s.cost_estimate
    if by_model:
        print("By Model:")
        print(f"  {'Model':<25} {'Sessions':>8} {'Tokens':>12} {'Est Cost':>10}")
        for model, stats in sorted(by_model.items(), key=lambda x: x[1]["tokens"], reverse=True):
            print(f"  {model:<25} {stats['sessions']:>8} {stats['tokens']:>12,} {fmt_cost(stats['cost']):>10}")
        print()

    # By project
    by_project = defaultdict(lambda: {"sessions": 0, "tokens": 0, "cost": 0.0})
    for s in sessions:
        by_project[s.project_name]["sessions"] += 1
        by_project[s.project_name]["tokens"] += s.total_tokens
        by_project[s.project_name]["cost"] += s.cost_estimate
    if by_project:
        print("By Project (top 10):")
        print(f"  {'Project':<30} {'Sessions':>8} {'Tokens':>12} {'Est Cost':>10}")
        for proj, stats in sorted(by_project.items(), key=lambda x: x[1]["tokens"], reverse=True)[:10]:
            proj_display = proj[:28] if len(proj) > 28 else proj
            print(f"  {proj_display:<30} {stats['sessions']:>8} {stats['tokens']:>12,} {fmt_cost(stats['cost']):>10}")
        print()

    # By day
    by_day = defaultdict(lambda: {"sessions": 0, "tokens": 0, "prompt": 0, "completion": 0, "cached": 0, "cost": 0.0})
    for s in sessions:
        day = fmt_date(s.last_activity_at)
        by_day[day]["sessions"] += 1
        by_day[day]["tokens"] += s.total_tokens
        by_day[day]["prompt"] += s.prompt_tokens
        by_day[day]["completion"] += s.completion_tokens
        by_day[day]["cached"] += s.cached_tokens
        by_day[day]["cost"] += s.cost_estimate
    if by_day:
        print("By Day:")
        print(f"  {'Date':<12} {'Sessions':>8} {'Total':>12} {'Prompt':>12} {'Cached':>12} {'Cost':>10}")
        for day in sorted(by_day.keys()):
            stats = by_day[day]
            print(f"  {day:<12} {stats['sessions']:>8} {stats['tokens']:>12,} {stats['prompt']:>12,} {stats['cached']:>12,} {fmt_cost(stats['cost']):>10}")
        print()

    # Top sessions by tokens
    top_sessions = sorted(sessions, key=lambda s: s.total_tokens, reverse=True)[:10]
    if top_sessions:
        print("Top Sessions by Tokens:")
        print(f"  {'Session ID':<25} {'Agent':<12} {'Tokens':>12} {'Steps':>6} {'Duration':>10} {'Project':>20}")
        for s in top_sessions:
            sid = s.session_id[:23]
            proj = s.project_name[:20]
            print(f"  {sid:<25} {s.agent:<12} {s.total_tokens:>12,} {s.total_steps:>6} {fmt_duration(s.duration_minutes):>10} {proj:>20}")
        print()

    if args.csv:
        write_csv(sessions, args.csv)

    if args.panel:
        print()
        cmd_panel_impl(sessions)

# ---------------------------------------------------------------------------
# Panel — at-a-glance
# ---------------------------------------------------------------------------

def cmd_panel(args) -> None:
    sessions = load_all_sessions(args.agent)
    if args.days:
        sessions = filter_by_days(sessions, args.days)
    cmd_panel_impl(sessions)

def cmd_panel_impl(sessions: List[SessionRecord]) -> None:
    if not sessions:
        print("No session data.")
        return

    total_prompt = sum(s.prompt_tokens for s in sessions)
    total_completion = sum(s.completion_tokens for s in sessions)
    total_cached = sum(s.cached_tokens for s in sessions)
    total_tokens = total_prompt + total_completion
    total_cost = sum(s.cost_estimate for s in sessions)

    now = datetime.now(tz=timezone.utc)
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    today_ts = int(today_start.timestamp())
    today_sessions = [s for s in sessions if s.last_activity_at >= today_ts]
    today_tokens = sum(s.total_tokens for s in today_sessions)

    five_hours_ago_ts = int((now - timedelta(hours=5)).timestamp())
    recent_sessions = [s for s in sessions if s.last_activity_at >= five_hours_ago_ts]
    recent_tokens = sum(s.total_tokens for s in recent_sessions)

    agents_present = sorted(set(s.agent for s in sessions))

    print("┌─────────────────────────────────────────────────┐")
    print("│ Usage Panel                                     │")
    print("├─────────────────────────────────────────────────┤")
    print(f"│ Agents:           {', '.join(agents_present):>28} │")
    print(f"│ Total sessions:    {len(sessions):>28} │")
    print(f"│ Total tokens:      {total_tokens:>28,} │")
    print(f"│   Prompt:          {total_prompt:>28,} │")
    print(f"│   Completion:      {total_completion:>28,} │")
    print(f"│   Cached:          {total_cached:>28,} │")
    if total_prompt > 0:
        ratio = total_cached / total_prompt
        print(f"│   Cache ratio:     {ratio:>27.1%} │")
    print(f"│ Est. API cost:     {fmt_cost(total_cost):>28} │")
    print("├─────────────────────────────────────────────────┤")
    print(f"│ Today:             {len(today_sessions):>28} │")
    print(f"│   Today tokens:    {today_tokens:>28,} │")
    print(f"│ Last 5 hours:      {len(recent_sessions):>28} │")
    print(f"│   5h tokens:       {recent_tokens:>28,} │")
    print("└─────────────────────────────────────────────────┘")

    by_project = defaultdict(int)
    for s in sessions:
        by_project[s.project_name] += s.total_tokens
    if by_project:
        top_proj = max(by_project.items(), key=lambda x: x[1])
        print(f"\nTop project: {top_proj[0]} ({top_proj[1]:,} tokens)")

    by_model = defaultdict(int)
    for s in sessions:
        by_model[s.model] += s.total_tokens
    if by_model:
        top_model = max(by_model.items(), key=lambda x: x[1])
        print(f"Top model:   {top_model[0]} ({top_model[1]:,} tokens)")

# ---------------------------------------------------------------------------
# Forensics — deeper analysis from CSV
# ---------------------------------------------------------------------------

def cmd_forensics(args) -> None:
    if not os.path.isfile(args.csv):
        print(f"Error: CSV file not found: {args.csv}", file=sys.stderr)
        sys.exit(1)

    sessions = []
    with open(args.csv) as f:
        reader = csv.DictReader(f)
        for row in reader:
            s = SessionRecord()
            s.session_id = row["session_id"]
            s.agent = row.get("agent", "")
            s.model = row["model"]
            s.agent_mode = row.get("agent_mode", "")
            s.title = row.get("title", "")
            s.working_directory = row.get("working_directory", "")
            s.created_at = int(row["created_at"]) if row.get("created_at") else 0
            s.last_activity_at = int(row["last_activity_at"]) if row.get("last_activity_at") else 0
            s.prompt_tokens = int(row["prompt_tokens"])
            s.completion_tokens = int(row["completion_tokens"])
            s.cached_tokens = int(row["cached_tokens"])
            s.total_steps = int(row["total_steps"]) if row.get("total_steps") else 0
            sessions.append(s)

    if not sessions:
        print("No sessions in CSV.")
        return

    agents_present = sorted(set(s.agent for s in sessions))
    print(f"Forensics — {len(sessions)} sessions ({', '.join(agents_present)})")
    print(f"{'=' * 60}")

    # Daily table
    by_day = defaultdict(lambda: {"sessions": 0, "tokens": 0, "prompt": 0, "cached": 0, "cost": 0.0})
    for s in sessions:
        day = fmt_date(s.last_activity_at)
        by_day[day]["sessions"] += 1
        by_day[day]["tokens"] += s.total_tokens
        by_day[day]["prompt"] += s.prompt_tokens
        by_day[day]["cached"] += s.cached_tokens
        by_day[day]["cost"] += s.cost_estimate

    print("\nDaily breakdown:")
    print(f"  {'Date':<12} {'Sessions':>8} {'Total':>12} {'Prompt':>12} {'Cached':>12} {'Cache%':>7} {'Cost':>10}")
    for day in sorted(by_day.keys()):
        stats = by_day[day]
        cache_pct = (stats["cached"] / stats["prompt"] * 100) if stats["prompt"] > 0 else 0
        print(f"  {day:<12} {stats['sessions']:>8} {stats['tokens']:>12,} {stats['prompt']:>12,} {stats['cached']:>12,} {cache_pct:>6.1f}% {fmt_cost(stats['cost']):>10}")

    # Discontinuity detection
    days_sorted = sorted(by_day.keys())
    if len(days_sorted) >= 2:
        print("\nDiscontinuity check:")
        prev_tokens = 0
        found_spike = False
        for day in days_sorted:
            stats = by_day[day]
            if prev_tokens > 0 and stats["tokens"] > prev_tokens * 3:
                ratio = stats["tokens"] / prev_tokens if prev_tokens > 0 else 0
                print(f"  ⚠ {day}: {stats['tokens']:,} tokens — {ratio:.1f}x the previous day ({prev_tokens:,})")
                found_spike = True
            prev_tokens = stats["tokens"]
        if not found_spike:
            print("  No 3x+ day-over-day spikes detected.")

    # Session shape analysis
    print("\nSession shape:")
    durations = [s.duration_minutes for s in sessions if s.duration_minutes > 0]
    steps = [s.total_steps for s in sessions if s.total_steps > 0]
    if durations:
        durations_sorted = sorted(durations)
        median_dur = durations_sorted[len(durations_sorted) // 2]
        avg_dur = sum(durations) / len(durations)
        print(f"  Duration: median {fmt_duration(median_dur)}, avg {fmt_duration(avg_dur)}, max {fmt_duration(max(durations))}")
    if steps:
        steps_sorted = sorted(steps)
        median_steps = steps_sorted[len(steps_sorted) // 2]
        print(f"  Steps:    median {median_steps}, max {max(steps)}")

    # Concurrency detection
    print("\nConcurrency analysis:")
    by_hour = defaultdict(list)
    for s in sessions:
        if s.created_at > 0:
            dt = datetime.fromtimestamp(s.created_at, tz=timezone.utc)
            hour_key = dt.strftime("%Y-%m-%d %H:00")
            by_hour[hour_key].append(s)
    peak_concurrency = 0
    peak_hour = ""
    for hour, sess_list in by_hour.items():
        if len(sess_list) > peak_concurrency:
            peak_concurrency = len(sess_list)
            peak_hour = hour
    print(f"  Peak sessions started in one hour: {peak_concurrency} at {peak_hour}")

    short_sessions = [s for s in sessions if 0 < s.duration_minutes < 5 and s.total_steps < 10]
    if len(short_sessions) > 10:
        print(f"  ⚠ {len(short_sessions)} very short sessions (<5min, <10 steps) — possible automation/swarm pattern")

    # Concentration analysis
    print("\nConcentration:")
    by_project = defaultdict(int)
    for s in sessions:
        by_project[s.project_name] += s.total_tokens
    total_tokens = sum(s.total_tokens for s in sessions)
    if by_project and total_tokens > 0:
        top_proj = max(by_project.items(), key=lambda x: x[1])
        pct = top_proj[1] / total_tokens * 100
        print(f"  Top project: {top_proj[0]} — {pct:.1f}% of all tokens ({top_proj[1]:,})")
        if pct > 90:
            print(f"  ⚠ Single project dominates (>90% of tokens)")

    by_model = defaultdict(int)
    for s in sessions:
        by_model[s.model] += s.total_tokens
    if by_model and total_tokens > 0:
        top_model = max(by_model.items(), key=lambda x: x[1])
        pct = top_model[1] / total_tokens * 100
        print(f"  Top model:   {top_model[0]} — {pct:.1f}% of all tokens ({top_model[1]:,})")

    by_agent = defaultdict(int)
    for s in sessions:
        by_agent[s.agent] += s.total_tokens
    if len(by_agent) > 1 and total_tokens > 0:
        print(f"  By agent:")
        for agent, tokens in sorted(by_agent.items(), key=lambda x: x[1], reverse=True):
            pct = tokens / total_tokens * 100
            print(f"    {agent:<16} {pct:>5.1f}% ({tokens:,})")

    # Window analysis
    if args.day and args.at:
        cmd_window(sessions, args.day, args.at)
    else:
        now = datetime.now(tz=timezone.utc)
        cmd_window(sessions, now.strftime("%Y-%m-%d"), now.strftime("%Y-%m-%dT%H:%M"))

def cmd_window(sessions: List[SessionRecord], day: str, at: str) -> None:
    try:
        at_dt = datetime.fromisoformat(at).replace(tzinfo=timezone.utc)
    except ValueError:
        print(f"Error: invalid --at format: {at}", file=sys.stderr)
        return

    window_start_ts = int((at_dt - timedelta(hours=5)).timestamp())
    at_ts = int(at_dt.timestamp())

    window_sessions = [
        s for s in sessions
        if s.last_activity_at >= window_start_ts and s.last_activity_at <= at_ts
    ]
    window_tokens = sum(s.total_tokens for s in window_sessions)

    peak_window_tokens = 0
    all_timestamps = sorted([s.last_activity_at for s in sessions if s.last_activity_at > 0])
    if all_timestamps:
        for ts in all_timestamps:
            wstart = ts - 5 * 3600
            w_tokens = sum(s.total_tokens for s in sessions if wstart <= s.last_activity_at <= ts)
            if w_tokens > peak_window_tokens:
                peak_window_tokens = w_tokens

    print(f"\n5-hour window at {at}:")
    print(f"  Sessions in window: {len(window_sessions)}")
    print(f"  Tokens in window:   {window_tokens:,}")
    if peak_window_tokens > 0:
        pct = window_tokens / peak_window_tokens * 100
        print(f"  vs observed peak:   {pct:.1f}% ({peak_window_tokens:,})")
    oldest = min((s.last_activity_at for s in window_sessions), default=0)
    if oldest > 0:
        age_min = (at_ts - oldest) / 60
        print(f"  Oldest activity:    {age_min:.0f} min before checkpoint")

# ---------------------------------------------------------------------------
# Report — HTML
# ---------------------------------------------------------------------------

def cmd_report(args) -> None:
    sessions = load_all_sessions(args.agent)
    if args.days:
        sessions = filter_by_days(sessions, args.days)

    if not sessions:
        print("No session data to report.")
        return

    total_prompt = sum(s.prompt_tokens for s in sessions)
    total_completion = sum(s.completion_tokens for s in sessions)
    total_cached = sum(s.cached_tokens for s in sessions)
    total_tokens = total_prompt + total_completion
    total_cost = sum(s.cost_estimate for s in sessions)

    by_agent = defaultdict(lambda: {"sessions": 0, "tokens": 0, "cost": 0.0})
    for s in sessions:
        by_agent[s.agent]["sessions"] += 1
        by_agent[s.agent]["tokens"] += s.total_tokens
        by_agent[s.agent]["cost"] += s.cost_estimate

    by_model = defaultdict(lambda: {"sessions": 0, "tokens": 0, "cost": 0.0})
    for s in sessions:
        by_model[s.model]["sessions"] += 1
        by_model[s.model]["tokens"] += s.total_tokens
        by_model[s.model]["cost"] += s.cost_estimate

    by_project = defaultdict(lambda: {"sessions": 0, "tokens": 0, "cost": 0.0})
    for s in sessions:
        by_project[s.project_name]["sessions"] += 1
        by_project[s.project_name]["tokens"] += s.total_tokens
        by_project[s.project_name]["cost"] += s.cost_estimate

    by_day = defaultdict(lambda: {"sessions": 0, "tokens": 0, "prompt": 0, "completion": 0, "cached": 0, "cost": 0.0})
    for s in sessions:
        day = fmt_date(s.last_activity_at)
        by_day[day]["sessions"] += 1
        by_day[day]["tokens"] += s.total_tokens
        by_day[day]["prompt"] += s.prompt_tokens
        by_day[day]["completion"] += s.completion_tokens
        by_day[day]["cached"] += s.cached_tokens
        by_day[day]["cost"] += s.cost_estimate

    top_sessions = sorted(sessions, key=lambda s: s.total_tokens, reverse=True)[:20]

    html_parts = []
    html_parts.append("<!DOCTYPE html>")
    html_parts.append("<html lang='en'><head><meta charset='utf-8'>")
    html_parts.append(f"<title>Usage Report — {args.days} days</title>")
    html_parts.append("<style>")
    html_parts.append("""
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; margin: 2em; background: #fafafa; color: #222; }
        h1 { border-bottom: 2px solid #666; padding-bottom: 0.3em; }
        h2 { color: #444; margin-top: 1.5em; }
        table { border-collapse: collapse; width: 100%; margin: 1em 0; background: white; }
        th, td { border: 1px solid #ddd; padding: 6px 10px; text-align: left; }
        th { background: #f0f0f0; font-weight: 600; }
        td.num { text-align: right; font-variant-numeric: tabular-nums; }
        tr:hover { background: #f5f5f5; }
        .summary { background: white; padding: 1em; border-radius: 8px; margin: 1em 0; }
        .metric { display: inline-block; margin-right: 2em; }
        .metric .value { font-size: 1.4em; font-weight: 700; }
        .metric .label { font-size: 0.85em; color: #666; }
        .warning { color: #c0392b; font-weight: 600; }
        footer { margin-top: 2em; color: #999; font-size: 0.85em; }
    """)
    html_parts.append("</style></head><body>")

    html_parts.append(f"<h1>Coding Agent Usage Report</h1>")
    agents_list = ', '.join(sorted(set(s.agent for s in sessions)))
    html_parts.append(f"<p>Agents: {html_mod.escape(agents_list)} · Period: last {args.days} days · Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}</p>")

    html_parts.append("<div class='summary'>")
    html_parts.append(f"<div class='metric'><div class='value'>{len(sessions)}</div><div class='label'>Sessions</div></div>")
    html_parts.append(f"<div class='metric'><div class='value'>{fmt_tokens(total_tokens)}</div><div class='label'>Total Tokens</div></div>")
    html_parts.append(f"<div class='metric'><div class='value'>{fmt_tokens(total_prompt)}</div><div class='label'>Prompt</div></div>")
    html_parts.append(f"<div class='metric'><div class='value'>{fmt_tokens(total_completion)}</div><div class='label'>Completion</div></div>")
    html_parts.append(f"<div class='metric'><div class='value'>{fmt_tokens(total_cached)}</div><div class='label'>Cached</div></div>")
    if total_prompt > 0:
        html_parts.append(f"<div class='metric'><div class='value'>{total_cached/total_prompt:.0%}</div><div class='label'>Cache Ratio</div></div>")
    html_parts.append(f"<div class='metric'><div class='value'>{fmt_cost(total_cost)}</div><div class='label'>Est. API Cost</div></div>")
    html_parts.append("</div>")

    # By agent (only if multiple)
    if len(by_agent) > 1:
        html_parts.append("<h2>By Agent</h2>")
        html_parts.append("<table><tr><th>Agent</th><th class='num'>Sessions</th><th class='num'>Tokens</th><th class='num'>Cost</th></tr>")
        for agent, stats in sorted(by_agent.items(), key=lambda x: x[1]["tokens"], reverse=True):
            html_parts.append(f"<tr><td>{html_mod.escape(agent)}</td><td class='num'>{stats['sessions']}</td><td class='num'>{stats['tokens']:,}</td><td class='num'>{fmt_cost(stats['cost'])}</td></tr>")
        html_parts.append("</table>")

    # By day
    html_parts.append("<h2>Daily Breakdown</h2>")
    html_parts.append("<table><tr><th>Date</th><th class='num'>Sessions</th><th class='num'>Total</th><th class='num'>Prompt</th><th class='num'>Completion</th><th class='num'>Cached</th><th class='num'>Cache%</th><th class='num'>Cost</th></tr>")
    for day in sorted(by_day.keys()):
        stats = by_day[day]
        cache_pct = f"{stats['cached']/stats['prompt']*100:.1f}%" if stats["prompt"] > 0 else "—"
        html_parts.append(f"<tr><td>{html_mod.escape(day)}</td><td class='num'>{stats['sessions']}</td><td class='num'>{stats['tokens']:,}</td><td class='num'>{stats['prompt']:,}</td><td class='num'>{stats['completion']:,}</td><td class='num'>{stats['cached']:,}</td><td class='num'>{cache_pct}</td><td class='num'>{fmt_cost(stats['cost'])}</td></tr>")
    html_parts.append("</table>")

    # By model
    html_parts.append("<h2>By Model</h2>")
    html_parts.append("<table><tr><th>Model</th><th class='num'>Sessions</th><th class='num'>Tokens</th><th class='num'>Cost</th></tr>")
    for model, stats in sorted(by_model.items(), key=lambda x: x[1]["tokens"], reverse=True):
        html_parts.append(f"<tr><td>{html_mod.escape(model)}</td><td class='num'>{stats['sessions']}</td><td class='num'>{stats['tokens']:,}</td><td class='num'>{fmt_cost(stats['cost'])}</td></tr>")
    html_parts.append("</table>")

    # By project
    html_parts.append("<h2>By Project</h2>")
    html_parts.append("<table><tr><th>Project</th><th class='num'>Sessions</th><th class='num'>Tokens</th><th class='num'>Cost</th></tr>")
    for proj, stats in sorted(by_project.items(), key=lambda x: x[1]["tokens"], reverse=True):
        html_parts.append(f"<tr><td>{html_mod.escape(proj)}</td><td class='num'>{stats['sessions']}</td><td class='num'>{stats['tokens']:,}</td><td class='num'>{fmt_cost(stats['cost'])}</td></tr>")
    html_parts.append("</table>")

    # Top sessions
    html_parts.append("<h2>Top Sessions by Tokens</h2>")
    html_parts.append("<table><tr><th>Session ID</th><th>Agent</th><th>Model</th><th>Project</th><th class='num'>Tokens</th><th class='num'>Steps</th><th class='num'>Duration</th><th class='num'>Cost</th><th>Last Active</th></tr>")
    for s in top_sessions:
        html_parts.append(f"<tr><td>{html_mod.escape(s.session_id)}</td><td>{html_mod.escape(s.agent)}</td><td>{html_mod.escape(s.model)}</td><td>{html_mod.escape(s.project_name)}</td><td class='num'>{s.total_tokens:,}</td><td class='num'>{s.total_steps}</td><td class='num'>{fmt_duration(s.duration_minutes)}</td><td class='num'>{fmt_cost(s.cost_estimate)}</td><td>{fmt_datetime(s.last_activity_at)}</td></tr>")
    html_parts.append("</table>")

    html_parts.append(f"<footer>Generated by usage-audit skill</footer>")
    html_parts.append("</body></html>")

    output = "\n".join(html_parts)
    out_path = args.html or "usage-report.html"
    with open(out_path, "w") as f:
        f.write(output)
    print(f"HTML report written to {out_path}", file=sys.stderr)
    print(out_path)

# ---------------------------------------------------------------------------
# Share — redacted summary
# ---------------------------------------------------------------------------

def cmd_share(args) -> None:
    sessions = load_all_sessions(args.agent)
    if args.days:
        sessions = filter_by_days(sessions, args.days)

    if not sessions:
        print("No session data to share.")
        return

    total_prompt = sum(s.prompt_tokens for s in sessions)
    total_completion = sum(s.completion_tokens for s in sessions)
    total_cached = sum(s.cached_tokens for s in sessions)
    total_tokens = total_prompt + total_completion
    total_cost = sum(s.cost_estimate for s in sessions)

    by_agent = defaultdict(lambda: {"sessions": 0, "tokens": 0})
    for s in sessions:
        by_agent[s.agent]["sessions"] += 1
        by_agent[s.agent]["tokens"] += s.total_tokens

    by_model = defaultdict(lambda: {"sessions": 0, "tokens": 0})
    for s in sessions:
        by_model[s.model]["sessions"] += 1
        by_model[s.model]["tokens"] += s.total_tokens

    by_day = defaultdict(lambda: {"sessions": 0, "tokens": 0})
    for s in sessions:
        day = fmt_date(s.last_activity_at)
        by_day[day]["sessions"] += 1
        by_day[day]["tokens"] += s.total_tokens

    durations = [s.duration_minutes for s in sessions if s.duration_minutes > 0]
    steps = [s.total_steps for s in sessions if s.total_steps > 0]

    print(f"# Coding Agent Usage Summary (redacted) — {args.days} days")
    print()
    print(f"**This summary contains only aggregate counts, dates, agent names, and model names.**")
    print(f"No session IDs, project names, file paths, prompts, or titles are included.")
    print()
    print(f"## Totals")
    print(f"- Sessions: {len(sessions)}")
    print(f"- Total tokens: {total_tokens:,}")
    print(f"- Prompt tokens: {total_prompt:,}")
    print(f"- Completion tokens: {total_completion:,}")
    print(f"- Cached tokens: {total_cached:,}")
    if total_prompt > 0:
        print(f"- Cache ratio: {total_cached/total_prompt:.1%}")
    print(f"- Estimated API cost: {fmt_cost(total_cost)} (approximate, based on public rates)")
    print()
    if len(by_agent) > 1:
        print(f"## By Agent")
        for agent, stats in sorted(by_agent.items(), key=lambda x: x[1]["tokens"], reverse=True):
            print(f"- {agent}: {stats['sessions']} sessions, {stats['tokens']:,} tokens")
        print()
    print(f"## By Model")
    for model, stats in sorted(by_model.items(), key=lambda x: x[1]["tokens"], reverse=True):
        print(f"- {model}: {stats['sessions']} sessions, {stats['tokens']:,} tokens")
    print()
    print(f"## By Day")
    for day in sorted(by_day.keys()):
        stats = by_day[day]
        print(f"- {day}: {stats['sessions']} sessions, {stats['tokens']:,} tokens")
    print()
    if durations:
        durations_sorted = sorted(durations)
        median_dur = durations_sorted[len(durations_sorted) // 2]
        print(f"## Session Shape")
        print(f"- Median duration: {fmt_duration(median_dur)}")
        print(f"- Max duration: {fmt_duration(max(durations))}")
    if steps:
        steps_sorted = sorted(steps)
        median_steps = steps_sorted[len(steps_sorted) // 2]
        print(f"- Median steps: {median_steps}")
        print(f"- Max steps: {max(steps)}")
    print()
    print(f"---")
    print(f"Generated by usage-audit skill on {datetime.now().strftime('%Y-%m-%d')}")

# ---------------------------------------------------------------------------
# Doctor — verify all agent data sources
# ---------------------------------------------------------------------------

def cmd_doctor() -> None:
    print("Usage Audit — Doctor")
    print(f"{'=' * 60}")

    any_available = False
    for parser in ALL_PARSERS:
        parser.doctor()
        if parser.is_available():
            any_available = True

    print(f"\nPython: {sys.version.split()[0]} (requires >=3.9)")

    print(f"\n{'=' * 60}")
    if any_available:
        available = [p.name for p in ALL_PARSERS if p.is_available()]
        print(f"✓ Data sources available for: {', '.join(available)}")
    else:
        print("✗ No agent data sources found.")
        print(f"  Checked for: {', '.join(p.name for p in ALL_PARSERS)}")

# ---------------------------------------------------------------------------
# List agents
# ---------------------------------------------------------------------------

def cmd_list_agents() -> None:
    print("Supported coding agents:")
    print(f"{'=' * 60}")
    for parser in ALL_PARSERS:
        status = "AVAILABLE" if parser.is_available() else "not found"
        impl = "implemented" if parser.name == "devin" else "stub"
        print(f"  {parser.name:<16} {parser.display_name:<20} {status:<12} ({impl})")

# ---------------------------------------------------------------------------
# Dump sample
# ---------------------------------------------------------------------------

def cmd_dump_sample(args) -> None:
    if args.agent:
        parser = get_parser(args.agent)
        if not parser:
            print(f"Unknown agent: {args.agent}")
            return
        parser.dump_sample()
    else:
        for parser in detected_agents():
            parser.dump_sample()
            print()

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Usage audit — parse local coding-agent session data and produce usage diagnoses."
    )
    sub = parser.add_subparsers(dest="command")

    p_audit = sub.add_parser("audit", help="Full audit — text summary with breakdowns")
    p_audit.add_argument("--days", type=int, default=30, help="Number of days to analyze (default: 30)")
    p_audit.add_argument("--csv", type=str, help="Write CSV to this path")
    p_audit.add_argument("--panel", action="store_true", help="Also show the at-a-glance panel")
    p_audit.add_argument("--agent", type=str, help="Filter to one agent (e.g., devin, claude-code)")

    p_forensics = sub.add_parser("forensics", help="Deeper analysis from a CSV file")
    p_forensics.add_argument("csv", type=str, help="Path to CSV file from audit --csv")
    p_forensics.add_argument("--day", type=str, help="Specific day to analyze (YYYY-MM-DD)")
    p_forensics.add_argument("--at", type=str, help="Specific time for window analysis (YYYY-MM-DDTHH:MM)")

    p_report = sub.add_parser("report", help="Generate HTML report")
    p_report.add_argument("--days", type=int, default=7, help="Number of days (default: 7)")
    p_report.add_argument("--html", type=str, help="Output HTML path (default: usage-report.html)")
    p_report.add_argument("--agent", type=str, help="Filter to one agent")

    p_share = sub.add_parser("share", help="Generate redacted shareable summary")
    p_share.add_argument("--days", type=int, default=30, help="Number of days (default: 30)")
    p_share.add_argument("--agent", type=str, help="Filter to one agent")

    p_panel = sub.add_parser("panel", help="At-a-glance usage panel")
    p_panel.add_argument("--days", type=int, default=1, help="Number of days (default: 1)")
    p_panel.add_argument("--agent", type=str, help="Filter to one agent")

    parser.add_argument("--dump-sample", action="store_true", help="Dump sample data structure")
    parser.add_argument("--doctor", action="store_true", help="Verify all agent data sources")
    parser.add_argument("--list-agents", action="store_true", help="List supported agents and detection status")
    parser.add_argument("--agent", type=str, help="Agent to use with --dump-sample")

    args = parser.parse_args()

    if args.list_agents:
        cmd_list_agents()
        return
    if args.doctor:
        cmd_doctor()
        return
    if args.dump_sample:
        cmd_dump_sample(args)
        return
    if args.command == "audit":
        cmd_audit(args)
    elif args.command == "forensics":
        cmd_forensics(args)
    elif args.command == "report":
        cmd_report(args)
    elif args.command == "share":
        cmd_share(args)
    elif args.command == "panel":
        cmd_panel(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
