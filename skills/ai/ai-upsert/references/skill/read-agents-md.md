# Reading Repository AGENTS.md

Before creating or updating any skill or knowledge bundle in a repository,
**read the repository's AGENTS.md** (or equivalent agent guidance file) for
important project context, conventions, and constraints.

Different coding agents use different filenames for the same purpose:
- `AGENTS.md` — used by Devin, Cursor, and others
- `CLAUDE.md` — used by Claude Code
- `AGENT.md` — used by some tools
- `.cursor/rules/` — used by Windsurf/Codeium

**Procedure:**
1. Check the target repository root for `AGENTS.md`, `CLAUDE.md`, `AGENT.md`,
   or `.cursor/rules/` — read whichever exists.
2. If multiple exist, read all of them (some repos use `@AGENTS.md` includes
   to alias one to another).
3. Follow the repository's conventions for file placement, naming, build
   commands, testing, and commit standards.
4. If the repository has project-specific rules (e.g., "always use devbox",
   "never hardcode IPs", "use pnpm dlx not npx"), apply them to the skill or
   knowledge bundle being created.

**Why this matters:** A skill or knowledge bundle that ignores the host
repository's conventions will create friction. The AGENTS.md file is the
binding contract for that repository's subtree — it documents the build
commands, testing procedures, code style, and constraints that the skill or
bundle must respect.
