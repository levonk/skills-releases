<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **content** · Status: ready · Version: 1.4.0

Extract and analyze YouTube video transcripts and metadata, including bulk fetching entire channels or video lists with batched rate-limited downloads and weighted term-over-time (word river) summaries for compact content placement. Use when needing to fetch video transcripts (with or without timestamps), analyze video content, extract video information, process YouTube content for further LLM analysis, bulk-download a channel's transcripts, or generate a word river summary of a channel's topical evolution. Triggers on requests like 'get transcript', 'analyze YouTube video', 'extract video content', 'fetch video metadata', 'bulk fetch channel', 'download all transcripts', or 'word river'. Do NOT trigger on general video playback questions, downloading video files, non-YouTube platforms, or video editing tasks.

## Metadata

| Field | Value |
|-------|-------|
| Name | `youtube-content-analysis` |
| Category | `content` |
| Version | `1.4.0` |
| Status | `ready` |
| Owner | https://github.com/levonk |

## Tags
- `ai/skill`
- `content-creation`
- `video-analysis`
- `transcript-processing`
- `bulk-fetch`
- `word-river`

## Related Skills
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/content/youtube/SKILL.md`](skills/content/youtube/SKILL.md)
- **Install**: `pnpm dlx skills add levonk/skills-releases`
- **Generated**: 2026-10-18T02:39:36Z
