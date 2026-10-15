#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Fetch YouTube transcripts and metadata — single video, bulk channel/list, or mixed.

Unified entry point that accepts any mix of YouTube URLs/IDs as positional
arguments. The script deterministically classifies each input as a video,
channel, or playlist based on its URL pattern, expands channels/playlists
into their constituent videos via yt-dlp --flat-playlist, deduplicates by
video ID, then fetches everything in one batched pass.

  Classification (deterministic, no network needed):
    youtu.be/<11>           → video
    youtube.com/watch?v=<>  → video
    youtube.com/shorts/<11> → video
    youtube.com/embed/<11>  → video
    youtube.com/@handle     → channel
    youtube.com/c/<name>    → channel
    youtube.com/channel/UC… → channel
    youtube.com/playlist?list=PL… → playlist
    bare 11-char string     → video ID
    anything else           → try yt-dlp --flat-playlist (it figures it out)

  Single video:  Skips flat-playlist, goes straight to fetch. No batching.
  Bulk (2+):     Batched fetch with configurable sleeps to respect Google
                 rate limits. Failed downloads retry once with 2x sleep.
  Resume:        index.yaml tracks per-video status; re-run skips done items.
  River:         --word-river computes a weighted term-over-time matrix
                 (ThemeRiver/streamgraph) so the AI can understand topical
                 evolution in one compact read instead of opening every
                 transcript.

Usage:
    uv run --script bulk-fetch.py <url1> [<url2> ...] --output-dir <dir> [options]
    uv run --script bulk-fetch.py --videos-file <path> --output-dir <dir> [options]

Quiet by default; --verbose prints full detail; --dry-run prints what would
happen without making changes.

Examples:
    # Single video
    uv run --script bulk-fetch.py "https://youtu.be/dQw4w9WgXcQ" --output-dir ./out

    # Channel (all videos)
    uv run --script bulk-fetch.py "https://youtube.com/@channel" --output-dir ./out

    # Mixed: two channels + a specific video + a playlist
    uv run --script bulk-fetch.py \\
        "https://youtube.com/@channel1" \\
        "https://youtube.com/@channel2" \\
        "https://youtu.be/dQw4w9WgXcQ" \\
        "https://youtube.com/playlist?list=PLxxxx" \\
        --output-dir ./out --word-river

    # From a file of URLs (one per line, # comments allowed)
    uv run --script bulk-fetch.py --videos-file urls.txt --output-dir ./out

    # Custom batching: 3 per batch, 5s sleep, 2s jitter
    uv run --script bulk-fetch.py "https://youtube.com/@channel" --output-dir ./out \\
        --batch-size 3 --sleep 5 --sleep-jitter 2
"""
from __future__ import annotations

import argparse
import json
import os
import random
import re
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

STOPWORDS: frozenset[str] = frozenset(
    """
    a about above after again against all am an and any are aren't as at be
    because been before being below between both but by can can't cannot could
    couldn't did didn't do does doesn't doing don't down during each few for
    from further had hadn't has hasn't have haven't having he he'd he'll he's
    her here here's hers herself him himself his how how's i i'd i'll i'm i've
    if in into is isn't it it's its itself let's me more most mustn't my myself
    no nor not of off on once only or other ought our ours ourselves out over
    own same shan't she she'd she'll she's should shouldn't so some such than
    that that's the their theirs them themselves then there there's these they
    they'd they'll they're they've this those through to too under until up
    very was wasn't we we'd we'll we're we've were weren't what what's when
    when's where where's which while who who's whom why why's with won't would
    wouldn't you you'd you'll you're you've your yours yourself yourselves
    gonna wanna gotta yeah okay ok like just really actually basically literally
    thing things stuff lot lots kind sort maybe probably right well also even
    much many still now then here there today tomorrow yesterday
    """.split()
)

MIN_TERM_LEN = 3
MAX_TERMS_PER_BUCKET = 40
MAX_OVERALL_TERMS = 60
WORD_RIVER_THRESHOLD_WEEKLY = 24  # <= this many videos → weekly buckets


# ---------------------------------------------------------------------------
# Devbox detection (canonical pattern from script-execution-standards.md)
# ---------------------------------------------------------------------------

def is_devbox_available() -> bool:
    """Check if devbox is available and a devbox.json exists (and not already in shell)."""
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False  # Already inside devbox shell — binaries are on PATH
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs: Any) -> subprocess.CompletedProcess[str]:
    """Run a command via devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


# ---------------------------------------------------------------------------
# Helpers — subprocess
# ---------------------------------------------------------------------------

_VERBOSE = False


def _log(msg: str) -> None:
    """Print to stderr (always — progress goes to stderr per quiet-by-default convention)."""
    print(msg, file=sys.stderr)


def _vlog(msg: str) -> None:
    """Print to stderr only in --verbose mode."""
    if _VERBOSE:
        print(msg, file=sys.stderr)


def _run(cmd: list[str], **kw: Any) -> subprocess.CompletedProcess[str]:
    """Run a command via devbox-aware wrapper, return CompletedProcess."""
    _vlog(f"[cmd] {' '.join(cmd)}")
    kw.setdefault("text", True)
    kw.setdefault("capture_output", True)
    kw.setdefault("check", False)
    return devbox_run(cmd, **kw)


def _yt_dlp_base() -> list[str]:
    """Return the yt-dlp invocation prefix (devbox wrapper handled by devbox_run)."""
    return ["yt-dlp"]


def _vid_transcripts_base() -> list[str]:
    """Return the python3 invocation for vid-transcripts.py."""
    return [sys.executable]


# ---------------------------------------------------------------------------
# Helpers — slugify
# ---------------------------------------------------------------------------

def _slugify(title: str, video_id: str, max_len: int = 60) -> str:
    """Create a filesystem-safe slug from a video title + ID."""
    slug = re.sub(r"[^\w\s-]", "", title.lower())
    slug = re.sub(r"[\s_-]+", "-", slug).strip("-")
    if len(slug) > max_len:
        slug = slug[:max_len].rsplit("-", 1)[0] or slug[:max_len]
    if not slug:
        slug = "untitled"
    return f"{slug}-{video_id}"


def _extract_video_id(url_or_id: str) -> str:
    """Extract an 11-char YouTube video ID from a URL or return input if already an ID."""
    m = re.search(r"(?:v=|youtu\.be/|/embed/|/shorts/)([\w-]{11})", url_or_id)
    if m:
        return m.group(1)
    if re.fullmatch(r"[\w-]{11}", url_or_id):
        return url_or_id
    return ""


def classify_url(url: str) -> str:
    """Deterministically classify a YouTube URL/ID as video, channel, playlist, or unknown.

    This is a pure pattern-matching function — no network calls. yt-dlp's
    --flat-playlist handles anything that doesn't match a known pattern.
    """
    # Bare 11-char video ID
    if re.fullmatch(r"[\w-]{11}", url):
        return "video"
    # youtu.be/<11> — always a video
    if re.match(r"https?://youtu\.be/[\w-]{11}", url):
        return "video"
    # youtube.com/watch?v=<11> — video
    if re.match(r"https?://(?:www\.)?youtube\.com/watch\?v=[\w-]{11}", url):
        return "video"
    # youtube.com/shorts/<11> — video
    if re.match(r"https?://(?:www\.)?youtube\.com/shorts/[\w-]{11}", url):
        return "video"
    # youtube.com/embed/<11> — video
    if re.match(r"https?://(?:www\.)?youtube\.com/embed/[\w-]{11}", url):
        return "video"
    # youtube.com/playlist?list=... — playlist
    if re.match(r"https?://(?:www\.)?youtube\.com/playlist\?list=", url):
        return "playlist"
    # youtube.com/@handle — channel (with optional /videos, /streams, etc.)
    if re.match(r"https?://(?:www\.)?youtube\.com/@[\w.-]+", url):
        return "channel"
    # youtube.com/c/<name> — channel
    if re.match(r"https?://(?:www\.)?youtube\.com/c/[\w.-]+", url):
        return "channel"
    # youtube.com/channel/UC... — channel
    if re.match(r"https?://(?:www\.)?youtube\.com/channel/UC[\w-]+", url):
        return "channel"
    # youtube.com/user/<name> — channel
    if re.match(r"https?://(?:www\.)?youtube\.com/user/[\w.-]+", url):
        return "channel"
    return "unknown"


# ---------------------------------------------------------------------------
# Phase 1 — Index (expand channels/playlists → video list)
# ---------------------------------------------------------------------------

def expand_playlist(url: str, url_type: str) -> list[dict[str, Any]]:
    """Use yt-dlp --flat-playlist to expand a channel/playlist/unknown URL into videos."""
    cmd = _yt_dlp_base() + [
        "--flat-playlist",
        "--print", "%(id)s\t%(title)s\t%(upload_date)s\t%(duration)s",
        "--no-warnings",
        url,
    ]
    _log(f"[phase1] Expanding {url_type}: {url}")
    result = _run(cmd)
    if result.returncode != 0:
        _log(f"[phase1] ERROR: yt-dlp failed: {result.stderr[:500]}")
        return []

    videos: list[dict[str, Any]] = []
    for line in result.stdout.strip().splitlines():
        parts = line.split("\t")
        if len(parts) < 1 or not parts[0].strip():
            continue
        vid_id = parts[0].strip()
        title = parts[1].strip() if len(parts) > 1 else "Untitled"
        upload_date = parts[2].strip() if len(parts) > 2 else ""
        duration = parts[3].strip() if len(parts) > 3 else ""
        videos.append({
            "id": vid_id,
            "url": f"https://www.youtube.com/watch?v={vid_id}",
            "title": title,
            "upload_date": upload_date,
            "duration": duration,
        })
    _log(f"[phase1]   → {len(videos)} videos from {url_type}")
    return videos


def make_video_entry(url_or_id: str) -> dict[str, Any] | None:
    """Create a video entry dict from a URL or bare ID. Returns None if not a video."""
    vid_id = _extract_video_id(url_or_id)
    if not vid_id:
        return None
    return {
        "id": vid_id,
        "url": f"https://www.youtube.com/watch?v={vid_id}",
        "title": "Untitled",
        "upload_date": "",
        "duration": "",
    }


def resolve_inputs(urls: list[str], videos_file: str | None) -> list[dict[str, Any]]:
    """Phase 1: classify each input URL, expand channels/playlists, deduplicate by video ID.

    Returns a deduplicated list of video entry dicts.
    """
    # Collect all raw inputs
    all_inputs: list[str] = list(urls)
    if videos_file:
        for line in Path(videos_file).read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                all_inputs.append(line)

    if not all_inputs:
        return []

    _log("=" * 60)
    _log("PHASE 1: Index — classify + expand + deduplicate")
    _log("=" * 60)
    _log(f"[phase1] {len(all_inputs)} input(s):")
    for inp in all_inputs:
        t = classify_url(inp)
        _log(f"  [{t:8s}] {inp}")

    # Classify and expand
    seen_ids: set[str] = set()
    videos: list[dict[str, Any]] = []

    for inp in all_inputs:
        url_type = classify_url(inp)

        if url_type == "video":
            entry = make_video_entry(inp)
            if entry and entry["id"] not in seen_ids:
                seen_ids.add(entry["id"])
                videos.append(entry)

        elif url_type in ("channel", "playlist", "unknown"):
            # Expand via yt-dlp --flat-playlist
            expanded = expand_playlist(inp, url_type)
            for v in expanded:
                if v["id"] not in seen_ids:
                    seen_ids.add(v["id"])
                    videos.append(v)
            if not expanded and url_type == "unknown":
                # Fallback: maybe it's a video ID we didn't recognize
                entry = make_video_entry(inp)
                if entry and entry["id"] not in seen_ids:
                    seen_ids.add(entry["id"])
                    videos.append(entry)
                    _log(f"[phase1]   → treated as video: {inp}")

        else:
            _log(f"[phase1] WARNING: could not classify: {inp}")

    _log(f"[phase1] Total unique videos: {len(videos)}")
    return videos


def write_index_yaml(
    output_dir: Path,
    videos: list[dict[str, Any]],
    channel_url: str | None,
    channel_name: str | None,
) -> Path:
    """Write the index.yaml manifest with all video entries and status fields."""
    index_path = output_dir / "index.yaml"
    lines: list[str] = []
    lines.append(f"fetched_at: {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}")
    if channel_url:
        lines.append(f"channel_url: {json.dumps(channel_url)}")
    if channel_name:
        lines.append(f"channel_name: {json.dumps(channel_name)}")
    lines.append(f"total_videos: {len(videos)}")
    lines.append("videos:")
    for v in videos:
        slug = _slugify(v.get("title", "untitled"), v["id"])
        lines.append(f"  - id: {v['id']}")
        lines.append(f"    url: {json.dumps(v['url'])}")
        lines.append(f"    title: {json.dumps(v.get('title', 'Untitled'))}")
        lines.append(f"    upload_date: {json.dumps(v.get('upload_date', ''))}")
        lines.append(f"    duration: {json.dumps(v.get('duration', ''))}")
        lines.append(f"    slug: {json.dumps(slug)}")
        lines.append(f"    status: {json.dumps(v.get('status', 'pending'))}")
        lines.append(f"    transcript_path: {json.dumps(f'{slug}/transcript.md')}")
        lines.append(f"    metadata_path: {json.dumps(f'{slug}/metadata.json')}")
        if v.get("error"):
            lines.append(f"    error: {json.dumps(v['error'])}")
    index_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    _log(f"[phase1] Wrote index: {index_path}")
    return index_path


def read_index_yaml(path: Path) -> list[dict[str, Any]]:
    """Parse a previously written index.yaml back into video dicts (simple parser)."""
    if not path.exists():
        return []
    videos: list[dict[str, Any]] = []
    current: dict[str, Any] | None = None
    for line in path.read_text(encoding="utf-8").splitlines():
        stripped = line.strip()
        if stripped.startswith("- id:"):
            if current:
                videos.append(current)
            current = {"id": stripped.split(":", 1)[1].strip()}
        elif current and ":" in stripped:
            key, _, val = stripped.partition(":")
            key = key.strip()
            val = val.strip().strip('"')
            if key in ("url", "title", "upload_date", "duration", "slug", "status",
                       "transcript_path", "metadata_path", "error"):
                current[key] = val
    if current:
        videos.append(current)
    return videos


# ---------------------------------------------------------------------------
# Phase 2 — Fetch individual videos
# ---------------------------------------------------------------------------

def fetch_video_metadata(url: str) -> dict[str, Any] | None:
    """Fetch full metadata for a single video via yt-dlp --dump-json."""
    cmd = _yt_dlp_base() + ["--dump-json", "--no-warnings", url]
    result = _run(cmd)
    if result.returncode != 0 or not result.stdout.strip():
        return None
    try:
        data = json.loads(result.stdout.strip().splitlines()[0])
    except (json.JSONDecodeError, IndexError):
        return None
    return {
        "id": data.get("id", ""),
        "title": data.get("title", "Untitled"),
        "uploader": data.get("uploader", ""),
        "channel": data.get("channel", ""),
        "upload_date": data.get("upload_date", ""),
        "duration": data.get("duration", 0),
        "description": data.get("description", ""),
        "tags": data.get("tags", []),
        "view_count": data.get("view_count", 0),
        "like_count": data.get("like_count", 0),
        "categories": data.get("categories", []),
        "chapters": data.get("chapters", []),
    }


def fetch_video_transcript(
    url: str,
    video_dir: Path,
    lang: str,
) -> tuple[Path | None, dict[str, Any] | None]:
    """Download VTT captions and return (vtt_path, metadata_for_obsidian).

    Returns (None, None) if no transcript is available.
    """
    vtt_path = video_dir / f"captions.{lang}.vtt"
    cmd = _yt_dlp_base() + [
        "--write-auto-sub",
        "--sub-lang", lang,
        "--skip-download",
        "--sub-format", "vtt",
        "-o", str(video_dir / "%(title)s"),
        "--no-warnings",
        url,
    ]
    result = _run(cmd)
    # yt-dlp writes the VTT with a modified filename — find it
    vtt_files = list(video_dir.glob(f"*.{lang}.vtt")) + list(video_dir.glob("*.vtt"))
    if not vtt_files:
        return None, None
    # Move/rename to our canonical name
    src = vtt_files[0]
    if src != vtt_path:
        src.rename(vtt_path)
    # Also grab metadata for the obsidian note
    meta = fetch_video_metadata(url)
    return vtt_path, meta


def process_transcript(
    vtt_path: Path,
    video_dir: Path,
    video_id: str,
    title: str,
    metadata: dict[str, Any] | None,
    lang: str,
    vid_transcripts_script: Path,
) -> Path | None:
    """Run vid-transcripts.py --format obsidian on the VTT to produce transcript.md."""
    if not vid_transcripts_script.exists():
        _log(f"[phase2] WARNING: vid-transcripts.py not found at {vid_transcripts_script}")
        return None

    # Write info-json for chapter resolution if we have metadata
    info_json_path: Path | None = None
    if metadata:
        info_json_path = video_dir / "video.info.json"
        info_json_path.write_text(json.dumps(metadata), encoding="utf-8")

    transcript_path = video_dir / "transcript.md"
    cmd = _vid_transcripts_base() + [
        str(vid_transcripts_script),
        "--format", "obsidian",
        "--video-id", video_id,
        "--title", title,
        "--lang", lang,
    ]
    if info_json_path:
        cmd += ["--info-json", str(info_json_path)]
    cmd += [str(vtt_path), str(transcript_path)]

    result = _run(cmd)
    if result.returncode != 0:
        _log(f"[phase2] WARNING: vid-transcripts.py failed: {result.stderr[:300]}")
        return None
    return transcript_path


def fetch_single_video(
    video: dict[str, Any],
    output_dir: Path,
    vid_transcripts_script: Path,
    lang: str,
) -> dict[str, Any]:
    """Fetch metadata + transcript for one video. Returns updated video dict with status."""
    vid_id = video["id"]
    url = video["url"]
    slug = _slugify(video.get("title", "untitled"), vid_id)
    video_dir = output_dir / slug
    video_dir.mkdir(parents=True, exist_ok=True)

    # Check if already fetched (resume)
    meta_path = video_dir / "metadata.json"
    transcript_path = video_dir / "transcript.md"
    if meta_path.exists() and transcript_path.exists():
        video["status"] = "skipped"
        video["slug"] = slug
        _log(f"[phase2] SKIP (already fetched): {slug}")
        return video

    _log(f"[phase2] Fetching: {slug}")

    # Fetch full metadata
    metadata = fetch_video_metadata(url)
    if metadata:
        meta_path.write_text(json.dumps(metadata, indent=2, ensure_ascii=False),
                             encoding="utf-8")
        # Update title from metadata if we had a placeholder
        if video.get("title") in ("Untitled", "") and metadata.get("title"):
            video["title"] = metadata["title"]
            slug = _slugify(video["title"], vid_id)
            new_dir = output_dir / slug
            if new_dir != video_dir:
                video_dir.rename(new_dir)
                video_dir = new_dir
                meta_path = video_dir / "metadata.json"
                transcript_path = video_dir / "transcript.md"
    else:
        metadata = None

    # Fetch transcript
    vtt_path, vtt_meta = fetch_video_transcript(url, video_dir, lang)
    if vtt_path is None:
        video["status"] = "no_transcript"
        video["slug"] = slug
        video["error"] = "No captions available for this video"
        _log(f"[phase2] NO TRANSCRIPT: {slug}")
        return video

    # Use the better metadata source for obsidian note
    obsidian_meta = metadata or vtt_meta
    obsidian_title = (obsidian_meta or {}).get("title", video.get("title", "Untitled"))

    # Process VTT → transcript.md
    result_path = process_transcript(
        vtt_path, video_dir, vid_id, obsidian_title, obsidian_meta, lang,
        vid_transcripts_script,
    )
    if result_path is None:
        video["status"] = "failed"
        video["slug"] = slug
        video["error"] = "vid-transcripts.py processing failed"
        _log(f"[phase2] FAILED: {slug}")
        return video

    video["status"] = "fetched"
    video["slug"] = slug
    _log(f"[phase2] OK: {slug}")
    return video


def fetch_all_videos(
    videos: list[dict[str, Any]],
    output_dir: Path,
    vid_transcripts_script: Path,
    batch_size: int,
    sleep_sec: float,
    sleep_jitter: float,
    max_videos: int | None,
    force: bool,
    lang: str,
) -> list[dict[str, Any]]:
    """Phase 2: iterate over videos in batches with sleeps. Returns updated video list."""
    if force:
        for v in videos:
            v["status"] = "pending"

    if max_videos is not None:
        videos = videos[:max_videos]

    total = len(videos)
    fetched = 0
    skipped = 0
    failed = 0

    for i, video in enumerate(videos):
        # Batch boundary: sleep after every batch_size videos (not before the first)
        if i > 0 and i % batch_size == 0:
            jitter = random.uniform(0, sleep_jitter) if sleep_jitter > 0 else 0
            wait = sleep_sec + jitter
            _log(f"[phase2] Batch boundary ({i}/{total}) — sleeping {wait:.1f}s")
            time.sleep(wait)

        video = fetch_single_video(video, output_dir, vid_transcripts_script, lang)

        # Retry once on failure with 2x sleep
        if video.get("status") in ("failed",) and not force:
            wait = (sleep_sec * 2) + random.uniform(0, sleep_jitter)
            _log(f"[phase2] Retrying {video['id']} after {wait:.1f}s")
            time.sleep(wait)
            video["status"] = "pending"
            video = fetch_single_video(video, output_dir, vid_transcripts_script, lang)

        status = video.get("status", "pending")
        if status == "fetched":
            fetched += 1
        elif status == "skipped":
            skipped += 1
        else:
            failed += 1

    _log(f"\n[phase2] Done: {fetched} fetched, {skipped} skipped, {failed} failed "
          f"(total {total})")
    return videos


# ---------------------------------------------------------------------------
# Word River — weighted term-over-time matrix
# ---------------------------------------------------------------------------

def _tokenize(text: str) -> list[str]:
    """Tokenize text into lowercase words, filtering stopwords and short tokens."""
    tokens = re.findall(r"[a-z][a-z0-9'-]*", text.lower())
    return [t for t in tokens if len(t) >= MIN_TERM_LEN and t not in STOPWORDS]


def _period_key(upload_date: str, use_weekly: bool) -> str:
    """Convert YYYYMMDD to a period key (YYYY-Www or YYYY-MM)."""
    if not upload_date or len(upload_date) < 8:
        return "unknown"
    try:
        year = int(upload_date[:4])
        month = int(upload_date[4:6])
        day = int(upload_date[6:8])
    except ValueError:
        return "unknown"
    if use_weekly:
        # ISO week number
        date_obj = datetime(year, month, day)
        iso_year, iso_week, _ = date_obj.isocalendar()
        return f"{iso_year}-W{iso_week:02d}"
    return f"{year:04d}-{month:02d}"


def compute_word_river(
    videos: list[dict[str, Any]],
    output_dir: Path,
) -> dict[str, Any] | None:
    """Compute the weighted term-over-time matrix from fetched transcripts."""
    use_weekly = len(videos) <= WORD_RIVER_THRESHOLD_WEEKLY

    # Collect term frequencies per period + per-video
    period_data: dict[str, dict[str, Any]] = {}  # period → {total_freq, terms: {term: freq}}
    video_summaries: list[dict[str, Any]] = []
    grand_total = 0
    all_terms: dict[str, int] = {}

    for v in videos:
        if v.get("status") != "fetched":
            continue
        slug = v.get("slug", "")
        transcript_path = output_dir / slug / "transcript.md"
        if not transcript_path.exists():
            continue
        text = transcript_path.read_text(encoding="utf-8")
        # Strip frontmatter and code blocks to get just the transcript text
        text = re.sub(r"^---\n.*?\n---\n", "", text, flags=re.DOTALL)
        text = re.sub(r"```[a-z]*\n.*?```", " ", text, flags=re.DOTALL)
        text = re.sub(r"\[.*?\]\(.*?\)", " ", text)  # strip markdown links

        tokens = _tokenize(text)
        if not tokens:
            continue

        video_freq: dict[str, int] = {}
        for token in tokens:
            video_freq[token] = video_freq.get(token, 0) + 1

        period = _period_key(v.get("upload_date", ""), use_weekly)
        if period not in period_data:
            period_data[period] = {"total_freq": 0, "terms": {}, "video_count": 0}
        pd = period_data[period]
        pd["video_count"] += 1
        for term, freq in video_freq.items():
            pd["terms"][term] = pd["terms"].get(term, 0) + freq
            pd["total_freq"] += freq
            all_terms[term] = all_terms.get(term, 0) + freq
            grand_total += freq

        # Per-video top 3 terms
        top3 = sorted(video_freq.items(), key=lambda x: -x[1])[:3]
        video_summaries.append({
            "id": v["id"],
            "title": v.get("title", "Untitled"),
            "upload_date": v.get("upload_date", ""),
            "period": period,
            "word_count": len(tokens),
            "top_terms": [t[0] for t in top3],
        })

    if not period_data or grand_total == 0:
        return None

    # Build the river: sorted periods with weighted terms
    periods_sorted = sorted(period_data.keys())
    river_periods: list[dict[str, Any]] = []
    for period in periods_sorted:
        pd = period_data[period]
        total = pd["total_freq"]
        terms = pd["terms"]
        # Weight = term freq / period total (relative contribution within period)
        weighted = [
            {"term": t, "weight": round(f / total, 4), "frequency": f}
            for t, f in sorted(terms.items(), key=lambda x: -x[1])[:MAX_TERMS_PER_BUCKET]
        ]
        river_periods.append({
            "date": period,
            "video_count": pd["video_count"],
            "total_frequency": total,
            "relative_frequency": round(total / grand_total, 4),
            "terms": weighted,
        })

    # Overall top terms across all periods
    overall_top = [
        {"term": t, "total_frequency": f, "appearances": sum(
            1 for p in period_data.values() if t in p["terms"]
        )}
        for t, f in sorted(all_terms.items(), key=lambda x: -x[1])[:MAX_OVERALL_TERMS]
    ]

    # Determine date range
    valid_dates = [v.get("upload_date", "") for v in videos
                   if v.get("status") == "fetched" and v.get("upload_date")]
    date_range = {}
    if valid_dates:
        valid_dates.sort()
        date_range = {"start": valid_dates[0], "end": valid_dates[-1]}

    return {
        "channel": next(
            (v.get("channel") for v in videos if v.get("channel")), None
        ),
        "date_range": date_range,
        "total_videos": sum(1 for v in videos if v.get("status") == "fetched"),
        "total_words": grand_total,
        "bucket_granularity": "weekly" if use_weekly else "monthly",
        "periods": river_periods,
        "overall_top_terms": overall_top,
        "per_video": video_summaries,
    }


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="bulk-fetch.py",
        description="Fetch YouTube transcripts and metadata — single video, bulk channel/list, or mixed.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Accepts any mix of video URLs, channel URLs, playlist URLs, and bare "
               "video IDs as positional arguments. Channels/playlists are expanded via "
               "yt-dlp --flat-playlist. All videos are deduplicated by ID and fetched "
               "in one batched pass. Optional --word-river produces a weighted "
               "term-over-time JSON summary.",
    )
    # Input — positional URLs (any mix of videos, channels, playlists)
    p.add_argument("urls", nargs="*", default=[],
                   help="YouTube URLs/IDs — any mix of videos, channels, playlists")
    p.add_argument("--videos-file", default=None,
                   help="Path to a file with one URL/ID per line (# comments allowed). "
                        "Combined with positional URLs.")

    # Output
    p.add_argument("--output-dir", required=True,
                   help="Output directory for all fetched content")

    # Batching + rate limiting
    p.add_argument("--batch-size", type=int, default=5,
                   help="Number of videos to fetch per batch before sleeping (default: 5)")
    p.add_argument("--sleep", type=float, default=3.0,
                   help="Seconds to sleep between batches (default: 3)")
    p.add_argument("--sleep-jitter", type=float, default=1.0,
                   help="Random jitter seconds added to sleep (default: 1)")
    p.add_argument("--max-videos", type=int, default=None,
                   help="Cap total videos to fetch (useful for testing or large channels)")

    # Behavior
    p.add_argument("--force", action="store_true",
                   help="Re-fetch all videos even if already present (ignore resume)")
    p.add_argument("--word-river", action="store_true",
                   help="After fetching, compute a weighted term-over-time JSON summary")
    p.add_argument("--lang", default="en",
                   help="Language code for transcripts (default: en)")
    p.add_argument("--vid-transcripts-script", default=None,
                   help="Path to vid-transcripts.py (default: auto-detect alongside this script)")
    p.add_argument("--verbose", action="store_true",
                   help="Print full detail including every command run")
    p.add_argument("--dry-run", action="store_true",
                   help="Print what would happen without making any changes")
    return p


def main() -> int:
    global _VERBOSE
    args = build_parser().parse_args()
    _VERBOSE = args.verbose
    output_dir = Path(args.output_dir)

    # Locate vid-transcripts.py
    if args.vid_transcripts_script:
        vid_script = Path(args.vid_transcripts_script)
    else:
        vid_script = Path(__file__).parent / "vid-transcripts.py"

    # --- Collect inputs ---
    urls: list[str] = list(args.urls)
    if not urls and not args.videos_file:
        _log("Error: must provide at least one URL (positional) or --videos-file")
        return 1

    # --- Dry-run mode ---
    if args.dry_run:
        _log("[dry-run] Would fetch to output dir: " + str(output_dir))
        all_inputs = list(urls)
        if args.videos_file:
            for line in Path(args.videos_file).read_text(encoding="utf-8").splitlines():
                line = line.strip()
                if line and not line.startswith("#"):
                    all_inputs.append(line)
        _log(f"[dry-run] {len(all_inputs)} input(s):")
        for inp in all_inputs:
            t = classify_url(inp)
            _log(f"  [{t:8s}] {inp}")
        _log(f"[dry-run] Batch size: {args.batch_size}, sleep: {args.sleep}s, jitter: {args.sleep_jitter}s")
        if args.max_videos:
            _log(f"[dry-run] Max videos: {args.max_videos}")
        if args.word_river:
            _log("[dry-run] Would compute word river after fetching")
        _log("[dry-run] Would classify, expand channels/playlists, deduplicate, then fetch.")
        _log("[dry-run] No changes made.")
        return 0

    output_dir.mkdir(parents=True, exist_ok=True)

    # --- Phase 1: Classify + expand + deduplicate ---
    videos = resolve_inputs(urls, args.videos_file)
    if not videos:
        _log("[phase1] No videos found. Exiting.")
        return 1

    # Apply max-videos cap
    if args.max_videos is not None:
        videos = videos[:args.max_videos]
        _log(f"[phase1] Capped to {len(videos)} videos (--max-videos)")

    is_single = len(videos) == 1

    # Check for existing index (resume)
    index_path = output_dir / "index.yaml"
    if index_path.exists() and not args.force:
        existing = read_index_yaml(index_path)
        if existing:
            existing_ids = {v["id"]: v for v in existing}
            for v in videos:
                if v["id"] in existing_ids:
                    ex = existing_ids[v["id"]]
                    if ex.get("status") in ("fetched", "skipped", "no_transcript"):
                        v["status"] = ex["status"]
                    if ex.get("title") and v.get("title") in ("Untitled", ""):
                        v["title"] = ex["title"]
                    if ex.get("upload_date") and not v.get("upload_date"):
                        v["upload_date"] = ex["upload_date"]

    write_index_yaml(output_dir, videos, None, None)

    # --- Phase 2: Fetch ---
    if is_single:
        _log("=" * 60)
        _log("PHASE 2: Fetch (single video — no batching)")
        _log("=" * 60)
    else:
        _log("=" * 60)
        _log("PHASE 2: Fetch (batched with sleeps)")
        _log("=" * 60)

    videos = fetch_all_videos(
        videos,
        output_dir,
        vid_script,
        batch_size=args.batch_size,
        sleep_sec=args.sleep,
        sleep_jitter=args.sleep_jitter,
        max_videos=args.max_videos,
        force=args.force,
        lang=args.lang,
    )

    # Update index with final statuses
    write_index_yaml(output_dir, videos, None, None)

    # --- Optional: Word River ---
    if args.word_river:
        _log("=" * 60)
        _log("WORD RIVER: Computing term-over-time matrix")
        _log("=" * 60)
        river = compute_word_river(videos, output_dir)
        if river:
            river_path = output_dir / "word-river.json"
            river_path.write_text(json.dumps(river, indent=2, ensure_ascii=False),
                                  encoding="utf-8")
            _log(f"[river] Wrote {river_path} "
                  f"({river['total_videos']} videos, {river['total_words']} words, "
                  f"{len(river['periods'])} periods)")
        else:
            _log("[river] No fetched transcripts found to analyze")

    # --- Summary ---
    fetched = sum(1 for v in videos if v.get("status") == "fetched")
    skipped = sum(1 for v in videos if v.get("status") == "skipped")
    failed = sum(1 for v in videos if v.get("status") not in ("fetched", "skipped"))
    _log(f"\nSUMMARY: {fetched} fetched, {skipped} skipped, {failed} failed "
          f"(total {len(videos)})")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
