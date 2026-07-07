---
name: youtube-content-analysis
description: Extract and analyze YouTube video transcripts and metadata. Use when needing to fetch video transcripts (with or without timestamps), analyze video content, extract video information, or process YouTube content for further LLM analysis. Triggers on requests like 'get transcript', 'analyze YouTube video', 'extract video content', or 'fetch video metadata'.
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2025-02-01"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "content-creation", "video-analysis", "transcript-processing"]
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: node
    name: youtube-transcript-api
    url: https://www.npmjs.com/package/youtube-transcript-api
  - type: node
    name: mcp-sdk
    url: https://www.npmjs.com/package/mcp-sdk
  - type: node
    name: typescript
    url: https://www.typescriptlang.org/
  - type: url
    name: YouTube Data API
    url: https://developers.google.com/youtube/v3
---

{{{ include "includes/base-ai-guidance.md" . }}}

# YouTube Content Analysis Skill

This skill enables AI agents to interact with YouTube content by extracting transcripts and metadata. It is a TypeScript-based implementation of the YouTube Transcript MCP, designed to be lightweight and fast.

## Principles

1. **Direct Access**: Use standard YouTube transcript APIs without requiring heavy browser automation where possible.
2. **Structured Output**: Return transcripts in formats suitable for further LLM processing (plain text or timed snippets).
3. **Efficiency**: Use TypeScript for performance and type safety.

## Tools

- `get_transcript`: Fetches the full text transcript of a video.
- `get_timed_transcript`: Fetches transcript snippets with start times and durations.
- `get_video_info`: Retrieves video metadata (title, description, duration, etc.).

## Implementation

The logic is implemented in `index.mts` and executed via a shebang script. It leverages `youtube-transcript-api` (or equivalent) and `mcp-sdk`.

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/content/youtube/SKILL.md`
- Scripts: `index.mts`, `youtube-tool`
- Package: `package.json`

### Related Skills
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
