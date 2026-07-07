---
name: handoff
description: Capture and restore AI conversation context for seamless work continuation across sessions. Use when needing to preserve conversation state, decisions made, and work progress to start a fresh AI session with full context without requiring re-explanation.
version: 2.0.0
date:
  created: "2026-05-25"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags:
  - "ai/skill"
  - "handoff"
  - "context-continuity"
  - "session-management"
aliases:
  - conversation-continuity
see-also:
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Handoff

A skill for capturing and restoring AI conversation context for seamless work continuation across sessions.

## Handoff-Specific Guidelines

This section provides handoff-specific guidance that complements the universal creation framework included above.

### What Handoff Provides

1. **Context Preservation** - Captures comprehensive conversation state for continuation
2. **Structured Documentation** - Creates well-formatted handoff documents with consistent structure
3. **Artifact References** - References existing artifacts (PRDs, plans, ADRs, issues, commits, diffs) instead of duplicating content
4. **Security** - Redacts sensitive information (API keys, passwords, PII)
5. **Skill Suggestions** - Includes suggested skills for the next session

### Handoff Storage Location

Handoff documents are stored in `{REPO_ROOT}/.agents/handoffs/YYYY/MM/YYYYMMDDHHmm-handoffslug.md` where:
- `YYYY` - 4-digit year
- `MM` - 2-digit month
- `DD` - 2-digit day
- `HH` - 2-digit hour (24-hour format)
- `mm` - 2-digit minute
- `handoffslug` - kebab-case descriptive slug for the handoff

**Example**: `~/p/gh/levonk/myproject/.agents/handoffs/2026/06/202606251430-feature-auth-implementation.md`

### When to Use

Use this skill when:
- Ending a session and wanting to continue work later
- Handing off to another AI agent
- Switching between different AI platforms
- Preserving context for complex multi-session work
- Creating a checkpoint before a major change

### Context Capture Process

#### 1. Gather Essential Context

**Always include:**
- **Project/Objective**: What are we working on?
- **Current State**: Where are we in the process?
- **Key Decisions**: What decisions have been made?
- **Next Steps**: What needs to be done next?
- **Success Criteria**: How do we know when we're done?

**Include when available:**
- **Technical Stack**: Tools, languages, frameworks in use
- **Constraints**: Limitations, requirements, must-haves
- **Open Questions**: Unresolved issues or ambiguities
- **Files/Artifacts**: Key files created or modified
- **Environment Setup**: Special configuration or setup steps

**Optional (include if relevant):**
- **Conversation History**: Key exchanges that led to current state
- **Rejected Approaches**: What we tried and why it didn't work
- **User Preferences**: Specific ways the user likes to work
- **Stakeholders**: Other people involved or affected

#### 2. Reference Existing Artifacts

**Do not duplicate content** already captured in:
- PRDs (Product Requirements Documents)
- Plans and design documents
- ADRs (Architecture Decision Records)
- GitHub issues
- Git commits
- Code diffs

Instead, reference them by path or URL:
```markdown
See PRD: `docs/prd/feature-x.md`
See ADR: `docs/adr/2024-01-15-jwt-auth.md`
See issue: https://github.com/user/repo/issues/123
See commit: abc123def456
```

#### 3. Structure the Handoff Document

Use the standard handoff template for consistency. The template includes sections for Current State (completed/blocking), Project Overview, Key Decisions, Technical Context, Next Steps, Success Criteria, Open Questions, Do Not, Suggested Skills, and Additional Context.

See: [`references/handoff-template.md`](references/handoff-template.md)

#### 4. Redact Sensitive Information

**Always redact:**
- API keys and tokens
- Passwords and credentials
- Personally identifiable information (PII)
- Secret configuration values
- Private keys or certificates

**Replace with placeholders:**
```markdown
API_KEY: [REDACTED]
password: [REDACTED]
user@example.com: [REDACTED]
```

#### 5. Save Handoff Document

Generate filename with timestamp:
```bash
TIMESTAMP=$(date +%Y%m%d%H%M)
SLUG="descriptive-handoff-slug"
HANDOFF_PATH="{REPO_ROOT}/.agents/handoffs/$(date +%Y)/$(date +%m)/${TIMESTAMP}-${SLUG}.md"
```

Create directory if needed and save:
```bash
mkdir -p "$(dirname "$HANDOFF_PATH")"
# Write handoff content to $HANDOFF_PATH
```

### Context Restoration Process

#### 1. Analyze the Handoff Document

When presented with a handoff document:

1. **Read and understand** the current state
2. **Identify the next immediate action** from the Next Steps list
3. **Check for blockers** in Open Questions/Blocking Issues
4. **Verify success criteria** are clear and measurable
5. **Review suggested skills** and invoke if appropriate

#### 2. Begin Work

Start with: "I understand the context. Based on the handoff document, I'm continuing work on [project]. The next step is [first next step]. Let me begin."

Then proceed with the first next step without asking questions unless:
- Critical information is missing
- Success criteria are unclear
- There are conflicting requirements

#### 3. Update Handoff

After completing each major step:
1. Update the status in the handoff document
2. Mark completed next steps
3. Add any new decisions made
4. Update open questions
5. Add new files/artifacts created

### Best Practices

#### When Capturing Context
- **Be comprehensive but concise** - Include everything needed, avoid fluff
- **Use specific file paths** - Don't say "the config file", say "`.envrc` in project root"
- **Quantify progress** - Use percentages or completion status
- **Preserve user voice** - Keep quotes of important user requirements
- **Reference artifacts** - Link to existing documentation instead of duplicating
- **Redact sensitive info** - Always remove API keys, passwords, PII

#### When Restoring Context
- **Acknowledge receipt** - Confirm you've understood the context
- **Start with action** - Begin with the first next step, not questions
- **Update incrementally** - Keep the handoff document current as you work
- **Ask only when necessary** - If something is truly missing, ask specifically
- **Invoke suggested skills** - Use the skills recommended in the handoff

#### File Management
- **Use consistent naming**: `YYYYMMDDHHmm-handoffslug.md`
- **Organize by date**: Store in `YYYY/MM/` subdirectories
- **Keep in repo**: Commit handoff documents to `.agents/handoffs/`
- **Reference in git**: Handoff documents should be tracked in version control

### Usage Patterns

#### End of Day/Session
```
User: "That's all for today. Can you capture the context so we can continue tomorrow?"
AI: "I'll create a handoff document for continuation."
[Generates handoff at .agents/handoffs/2026/06/202606251430-feature-x.md]
"Created handoff document. Tomorrow, reference this file to continue work."
```

#### Handoff to Another AI
```
User: "I need to switch to a different AI. Here's the context from our work: [pastes document]"
AI: "I understand the context. Based on the handoff document, I'm continuing work on [project]. The next step is [first next step]. Let me begin."
[Proceeds with work]
```

#### Complex Projects
```
User: "We're working on feature X. Can you capture the context?"
AI: "I'll create a comprehensive handoff document with all decisions, next steps, and suggested skills."
[Generates detailed handoff with suggested skills for the next session]
```

### Example Handoff Structure

Based on the infrahub example, a good handoff for complex projects includes sections for Target Architecture, Required Tasks (with investigation items and files to check), Success Criteria, and Files Modified This Session.

For the full extended example template, see: [`references/handoff-template.md`](references/handoff-template.md)

---
## Context Declaration

### File Paths
- Main skill: `config/ai/skills/ai/handoff/SKILL.md`
- Handoff template: `references/handoff-template.md`
- Handoff storage: `{REPO_ROOT}/.agents/handoffs/YYYY/MM/`

### Related Skills
- base-ai-guidance (base-framework) — Shared framework for all AI guidance types
- base-frontmatter (structure-standard) — Standard frontmatter template

### External Resources
- Matt Pocock's handoff skill: https://github.com/mattpocock/skills/blob/main/skills/productivity/handoff/SKILL.md

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
- Owner: levonk
