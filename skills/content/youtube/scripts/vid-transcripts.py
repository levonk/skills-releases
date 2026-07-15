#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Process video transcript VTT files: dedup, filter, and format conversion.

YouTube auto-captions use a 2-line progressive display where each VTT cue
overlaps ~80% with the previous one. This tool can deduplicate, filter by
time range, keep or drop flicker transitions, and output in multiple formats
(plain text, TOON, SRT, VTT).

Defaults: TOON format, unix milliseconds, dedup on, flicker off, no timestamps
in text mode. Use flags to override any of these.

Usage:
    vid-transcripts.py [options] <input.vtt> [output]

Examples:
    # Defaults: TOON + dedup + unix-ms + no flicker
    vid-transcripts.py captions.vtt

    # Plain text with timestamps shown (HH:MM:SS)
    vid-transcripts.py --format text --timestamps --hhmmss captions.vtt

    # TOON format, only 5min-10min range
    vid-transcripts.py --from 00:05:00 --to 00:10:00 captions.vtt

    # Clean VTT output with flicker transitions kept
    vid-transcripts.py --format vtt --keep-flicker captions.vtt out.vtt

    # SRT subtitles
    vid-transcripts.py --format srt captions.vtt out.srt
"""
from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

def _to_sec(t: str) -> float:
    """Parse 'HH:MM:SS.mmm', 'MM:SS.mmm', or seconds string → float."""
    parts = t.split(":")
    if len(parts) == 3:
        h, m, s = parts
        return int(h) * 3600 + int(m) * 60 + float(s)
    if len(parts) == 2:
        m, s = parts
        return int(m) * 60 + float(s)
    return float(parts[0])


def _fmt_ts(sec: float, sep: str = ":") -> str:
    """Format seconds → HH:MM:SS."""
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    return f"{h:02d}{sep}{m:02d}{sep}{s:02d}"


def _fmt_ms(sec: float) -> str:
    """Format seconds → integer milliseconds string (e.g. '1500')."""
    return str(int(round(sec * 1000)))


def _fmt_srt_time(sec: float) -> str:
    """Format seconds → SRT timestamp 'HH:MM:SS,mmm'."""
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    ms = int((sec - int(sec)) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def _fmt_vtt_time(sec: float) -> str:
    """Format seconds → VTT timestamp 'HH:MM:SS.mmm'."""
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    ms = int((sec - int(sec)) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d}.{ms:03d}"


def _decode_entities(s: str) -> str:
    return (
        s.replace("&gt;", ">")
        .replace("&lt;", "<")
        .replace("&amp;", "&")
        .replace("&#39;", "'")
        .replace("&quot;", '"')
    )


def parse_vtt(vtt_path: str) -> list[dict]:
    """Parse a VTT file into a list of cue dicts with start, end, text."""
    content = Path(vtt_path).read_text(encoding="utf-8")
    cues: list[dict] = []
    lines = content.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if "-->" in line:
            times = line.split("-->")
            start_sec = _to_sec(times[0].strip())
            end_str = times[1].strip().split(" ")[0]
            end_sec = _to_sec(end_str)

            text_lines: list[str] = []
            i += 1
            while i < len(lines) and lines[i].strip():
                clean = re.sub(r"<[^>]+>", "", lines[i]).strip()
                if clean:
                    text_lines.append(clean)
                i += 1
            full_text = _decode_entities(" ".join(text_lines))
            cues.append({
                "start_sec": start_sec,
                "end_sec": end_sec,
                "text": full_text,
            })
        else:
            i += 1
    return cues


# ---------------------------------------------------------------------------
# Transforms
# ---------------------------------------------------------------------------

def filter_time(
    cues: list[dict], from_sec: float | None, to_sec: float | None
) -> list[dict]:
    """Keep only cues within [from_sec, to_sec] by start time."""
    result = cues
    if from_sec is not None:
        result = [c for c in result if c["start_sec"] >= from_sec]
    if to_sec is not None:
        result = [c for c in result if c["start_sec"] <= to_sec]
    return result


def filter_flicker(cues: list[dict], keep_flicker: bool) -> list[dict]:
    """Drop ultra-short transition cues (< 0.1s) unless keep_flicker."""
    if keep_flicker:
        return [c for c in cues if c["text"].strip()]
    duration = lambda c: c["end_sec"] - c["start_sec"]
    return [c for c in cues if duration(c) >= 0.1 and c["text"].strip()]


def dedup(cues: list[dict]) -> list[dict]:
    """Extract only the genuinely new text from each progressive cue.

    YouTube auto-captions overlap consecutive cues ~80%. This strips the
    overlapping prefix (or suffix-overlap) and keeps only new text, preserving
    the original start/end times.
    """
    result: list[dict] = []
    prev_full_text = ""
    for c in cues:
        text = c["text"].strip()
        if not text:
            continue
        if prev_full_text and text.startswith(prev_full_text):
            new_part = text[len(prev_full_text):].strip()
        else:
            overlap = 0
            min_len = min(len(prev_full_text), len(text))
            for j in range(min_len, 0, -1):
                if prev_full_text.endswith(text[:j]):
                    overlap = j
                    break
            new_part = text[overlap:].strip() if overlap > 10 else text
        if new_part:
            result.append({
                "start_sec": c["start_sec"],
                "end_sec": c["end_sec"],
                "text": new_part,
            })
        prev_full_text = text
    return result


# ---------------------------------------------------------------------------
# Output formatters
# ---------------------------------------------------------------------------

def _toon_quote(s: str, delimiter: str) -> str:
    """Quote a string for TOON if it contains the delimiter or special chars."""
    needs_quote = (
        not s
        or s in ("true", "false", "null")
        or s.startswith("-")
        or delimiter in s
        or ":" in s
        or '"' in s
        or "\\" in s
        or s != s.strip()
    )
    if not needs_quote:
        return s
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def format_text(segments: list[dict], timestamps: bool, unix_time: bool = True) -> str:
    lines = []
    for s in segments:
        if timestamps:
            ts = _fmt_ms(s["start_sec"]) if unix_time else _fmt_ts(s["start_sec"])
            lines.append(f"[{ts}] {s['text']}")
        else:
            lines.append(s["text"])
    return "\n".join(lines) + "\n"


def format_toon(segments: list[dict], timestamps: bool = False, unix_time: bool = True) -> str:
    """Encode segments as a TOON tabular array with pipe delimiter."""
    n = len(segments)
    if n == 0:
        return "segments: []\n"
    if timestamps:
        header = f"segments[{n}|]{{start|end|text}}:"
        rows = []
        for s in segments:
            if unix_time:
                start = _fmt_ms(s["start_sec"])
                end = _fmt_ms(s["end_sec"])
            else:
                start = _fmt_ts(s["start_sec"])
                end = _fmt_ts(s["end_sec"])
            text = _toon_quote(s["text"], "|")
            rows.append(f"  {start}|{end}|{text}")
    else:
        header = f"segments[{n}|]{{text}}:"
        rows = []
        for s in segments:
            text = _toon_quote(s["text"], "|")
            rows.append(f"  {text}")
    return header + "\n" + "\n".join(rows) + "\n"


def format_srt(segments: list[dict], timestamps: bool = False) -> str:
    blocks = []
    for idx, s in enumerate(segments, 1):
        if timestamps:
            start = _fmt_srt_time(s["start_sec"])
            end = _fmt_srt_time(s["end_sec"])
            blocks.append(f"{idx}\n{start} --> {end}\n{s['text']}")
        else:
            blocks.append(f"{idx}\n{s['text']}")
    return "\n\n".join(blocks) + "\n"


def format_vtt(segments: list[dict], timestamps: bool = False) -> str:
    blocks = []
    for s in segments:
        if timestamps:
            start = _fmt_vtt_time(s["start_sec"])
            end = _fmt_vtt_time(s["end_sec"])
            blocks.append(f"{start} --> {end}\n{s['text']}")
        else:
            blocks.append(s["text"])
    return "WEBVTT\n\n" + "\n\n".join(blocks) + "\n"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="vid-transcripts.py",
        description="Process video transcript VTT files: dedup, filter, and format conversion.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Defaults: TOON format, unix milliseconds, dedup on, flicker off, no timestamps in text mode.\n"
               "Output formats: toon (default), text, srt, vtt\n"
               "If no output file is given, writes to stdout.",
    )
    p.add_argument("input", help="Input VTT file path")
    p.add_argument("output", nargs="?", default=None, help="Output file (default: stdout)")
    p.add_argument(
        "--format", choices=["toon", "text", "srt", "vtt"], default="toon",
        help="Output format (default: toon)",
    )
    p.add_argument("--no-dedup", action="store_true", help="Disable deduplication")
    p.add_argument("--timestamps", action="store_true", help="Show timestamps in all formats (off by default)")
    p.add_argument("--keep-flicker", action="store_true", help="Keep ultra-short transition cues (< 0.1s)")
    p.add_argument("--from", dest="from_time", default=None, help="Start time (HH:MM:SS or seconds)")
    p.add_argument("--to", dest="to_time", default=None, help="End time (HH:MM:SS or seconds)")
    p.add_argument(
        "--hhmmss", action="store_true",
        help="Use HH:MM:SS timestamps instead of unix milliseconds (all formats)",
    )
    return p


def main() -> int:
    args = build_parser().parse_args()

    from_sec = _to_sec(args.from_time) if args.from_time else None
    to_sec = _to_sec(args.to_time) if args.to_time else None

    cues = parse_vtt(args.input)
    cues = filter_time(cues, from_sec, to_sec)
    cues = filter_flicker(cues, args.keep_flicker)
    if not args.no_dedup:
        segments = dedup(cues)
    else:
        segments = [c for c in cues if c["text"].strip()]

    if args.format == "text":
        out = format_text(segments, args.timestamps, not args.hhmmss)
    elif args.format == "toon":
        out = format_toon(segments, args.timestamps, not args.hhmmss)
    elif args.format == "srt":
        out = format_srt(segments, args.timestamps)
    elif args.format == "vtt":
        out = format_vtt(segments, args.timestamps)
    else:
        print(f"Unknown format: {args.format}", file=sys.stderr)
        return 1

    if args.output:
        Path(args.output).write_text(out, encoding="utf-8")
    else:
        sys.stdout.write(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
