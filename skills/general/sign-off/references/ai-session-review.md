# AI Session Review

Guidance for reviewing today's AI sessions during Phase 3 of the
sign-off skill. The goal is to identify patterns worth promoting into
skills, knowledge bundles, or process improvements — and to act as an
**AI coach** that reviews the user's AI usage over a rolling window,
surfaces weak prompting habits, and recommends intelligence-layer
investments.

## Two Review Modes

Phase 3 always runs the daily session review. It also runs the AI
coach review when it is due (weekly, every 7 days):

1. **Daily session review** — scan today's sessions for immediate
   improvement opportunities (the original Phase 3 scope). Runs every
   sign-off.
2. **AI coach review** — a rolling 30-day coaching pass that audits the
   user's intelligence layer, identifies prompting habits, and
   recommends skills/knowledge bundles to build next. Runs on a weekly
   cadence (every 7 days) to avoid re-doing the same analysis nightly.
   Track the last coach run date in
   `.agents/handoffs/human/summary/.last-coach-run` (a single-line
   YYYY-MM-DD file). If the file is missing or older than 7 days, run
   the coach review. Otherwise, skip with a note: "AI coach review
   skipped — last run YYYY-MM-DD (next due YYYY-MM-DD)."

## Part 1: Daily Session Review

### Session Sources

1. **Handoff documents** — check `.agents/handoffs/todo/` and
   `.agents/handoffs/archive/` for files created or modified today.
2. **Git commits** — look for commits made today that were AI-assisted
   (check commit messages for session references, co-author patterns,
   or the skill that produced them).
3. **AI tool session logs** — if the AI tool keeps session transcripts
   or logs, review today's entries.
4. **Skill invocations** — check if any skills were invoked today
   (skills update their `last-used` date on invocation).

### What to Look For

#### Skill Improvement Opportunities

- **Repeated patterns**: Did the AI perform the same multi-step sequence
  multiple times today? That sequence might be a skill or a skill
  improvement.
- **Struggles**: Did the AI struggle with something — get confused, need
  multiple attempts, or require extensive user guidance? A skill could
  codify the correct approach.
- **Missing skills**: Did the user ask for something that no skill
  covers? That's a candidate for a new skill.
- **Skill gaps**: Did an existing skill not cover a scenario it should
  have? That's a candidate for a skill update.

#### Knowledge Gaps

- **Unanswered questions**: Did the AI not know something that would be
  useful to capture in a knowledge bundle?
- **Project-specific knowledge**: Did the AI need project context that
  wasn't available? Consider capturing it in a knowledge bundle or
  AGENTS.md.
- **Tool-specific knowledge**: Did the AI need to look up tool
  documentation that should be bundled for offline use?

#### Process Improvements

- **Workflow bottlenecks**: Did a particular step take longer than
  expected? Could it be automated or streamlined?
- **Missing automation**: Did the AI do something manually that could be
  a script?
- **Communication gaps**: Did the AI and user miscommunicate about
  expectations? Could a skill or workflow clarify the process?

#### Lessons Learned

- **What went well**: Patterns that worked — consider codifying them.
- **What didn't**: Patterns that failed — consider adding guardrails or
  calibration to prevent recurrence.
- **Surprises**: Unexpected situations — consider documenting them in a
  knowledge bundle or AGENTS.md.

### How to Categorize Findings

For each finding, assign a category and suggested action:

| Category | Description | Suggested Action |
|----------|-------------|-----------------|
| **New skill** | A repeatable procedure the AI should follow | Create via `ai-upsert` (Mode A) |
| **Skill update** | An existing skill needs improvement | Update via `ai-upsert` (Mode C) |
| **Knowledge bundle** | Knowledge that should be captured and referenced | Create/ingest via `ai-upsert` (KB Mode A/B) |
| **Process change** | A workflow or convention should be adjusted | Update AGENTS.md or workflow |
| **Script** | A manual step that could be automated | Create via `cli-tool-upsert` |
| **Guardrail** | A pattern that failed and needs prevention | Add to skill guardrails or AGENTS.md |

## Part 2: AI Coach Review (Rolling 30-Day)

When the coach review is due (see cadence rule above), run the full
coaching pass. This is the core value of the sign-off skill for users
who want to compound their AI usage over time.

### Coach Mindset

You are an **AI coach**, not a cheerleader. Your job is to make the user
better at using AI by:

- Quoting their **actual prompts** back at them — not paraphrasing.
- Being **specific** — "you re-explained the deploy process 3 times"
  not "you repeat yourself sometimes."
- Giving **one concrete fix** per finding, not a list of vague advice.
- Naming **files by path** — "`.agents/knowledge/developer.md` is 12
  lines" not "some knowledge file is thin."

### Step 1: Gather 30 Days of AI Sessions

Collect the last 30 days of AI usage from all available sources:

1. **Handoff documents** — scan `.agents/handoffs/todo/`,
   `.agents/handoffs/archive/`, and `.agents/handoffs/human/summary/`
   for files modified in the last 30 days.
2. **Git commit history** — `git log --since="30 days ago" --all
   --grep="Co-Authored"` or similar patterns across all repos in the
   workspace. Also check for skill-invocation patterns in commit
   messages.
3. **AI tool session logs** — if the AI tool exposes session history
   (Devin, Claude, Cursor, etc.), pull the last 30 days. Look for:
   - Session count and duration
   - Prompts per session (high count = back-and-forth)
   - Abandoned threads (sessions that ended without a resolution)
   - Re-explanation patterns (same context provided multiple times
     across different sessions)
4. **Skill invocation log** — check `last-used` dates across all
   installed skills to see which were active in the window.

### Step 2: Identify Usage Patterns

Analyze the 30-day window for these specific signals:

#### Back-and-Forth Threads

Sessions with unusually high prompt counts (e.g., 15+ messages) where
the user kept correcting or redirecting the AI. For each:

- **Quote the first prompt** and the **first correction** — show the
  gap between what the user asked and what the AI did.
- **Diagnose the root cause**: Was the prompt too vague? Did the AI lack
  context? Was a skill missing that would have provided the right
  framing?
- **Prescribe a fix**: A specific change to a prompt template, a new
  skill, or a knowledge bundle entry that would prevent the
  back-and-forth next time.

#### Abandoned Threads

Sessions that ended without reaching a conclusion — the user stopped
responding, or the session was interrupted. For each:

- **Quote the last prompt** and the AI's last response.
- **Diagnose**: Did the AI go down a wrong path? Was the task too
  ambitious for one session? Did the user lose confidence?
- **Prescribe**: Should this be a handoff document? A smaller-scoped
  skill? A guardrail that prevents the AI from over-reaching?

#### Re-Explanation Patterns

Topics the user explained from scratch in multiple sessions — the same
context, project background, or constraint repeated across different
threads on different days. For each:

- **Quote the explanation** from 2+ sessions (show the repetition).
- **Diagnose**: This is a file that **should exist but does not**. The
  user is manually providing context that should be in a knowledge
  bundle, AGENTS.md, or skill reference.
- **Prescribe**: The exact file path to create and what it should
  contain. Example: "Create
  `src/current/knowledge/deploy-practices/overview.md` capturing the
  staging deploy process you explained on Aug 12, Aug 19, and Aug 25."

### Step 3: Audit the Intelligence Layer

The user's "intelligence layer" is the collection of files that give AI
agents context about how the user works. The exact paths depend on the
user's environment — resolve them at runtime:

### Context Declaration

| Variable | Meaning | How to resolve |
|----------|---------|----------------|
| `${REPO_ROOT}` | The current repo root | `git rev-parse --show-toplevel` or `$PWD` |
| `${GLOBAL_AGENTS}` | Global AI rules | `$HOME/.config/devin/AGENTS.md` (or equivalent for the AI tool in use) |
| `${SKILLS_DIR}` | Installed skills | `$HOME/.config/devin/skills/` (or equivalent) |
| `${AGENT_ORG_SKILLS_DIR}` | Agent-org skills | `$HOME/.agents/skills/` (or equivalent) |

### Intelligence Layer Files

- `${GLOBAL_AGENTS}` (global rules)
- `${REPO_ROOT}/AGENTS.md` (repo root)
- `${REPO_ROOT}/.agents/knowledge/*.md` (developer guide)
- `${REPO_ROOT}/src/current/knowledge/*/` (knowledge bundles)
- `${REPO_ROOT}/src/current/skills/*/SKILL.md.tmpl` (skills)
- `${REPO_ROOT}/src/current/rules/*.md` (rules)
- `${SKILLS_DIR}/*/SKILL.md` (installed skills)
- `${AGENT_ORG_SKILLS_DIR}/*/SKILL.md` (agent-org skills)

Read each file and assess:

#### Thin or Empty Files

For each file in the intelligence layer, check:

- **Line count** — files under 20 lines (excluding frontmatter) are
  "thin." Files that are only frontmatter with no body are "empty."
- **Content density** — a file can be 100 lines but say nothing useful
  (boilerplate, TODOs, placeholder text). Flag these.
- **Stale sections** — sections that reference tools, versions, or
  processes that no longer match reality.

Output format:

```markdown
### Thin or Empty Files

| File | Lines | Issue |
|------|-------|-------|
| `.agents/knowledge/developer.md` | 12 | Only covers commit conventions, missing testing/debugging |
| `src/current/rules/commit-style.md` | 0 | Frontmatter only, no body |
```

#### Files Most in Need of an Update

Rank the intelligence-layer files by how outdated they are relative to
the user's actual workflow (as observed in the 30-day session review).
A file is "in need of update" if:

- The user's sessions show they're doing work the file doesn't cover.
- The file references tools/versions that have changed.
- The file's guidance contradicts what the user actually does (as
  evidenced by their prompts).

Output format:

```markdown
### Files Most in Need of Update

1. **`.agents/knowledge/developer.md`** — Last updated 2026-06-15.
   Sessions show you've adopted `just bats` for skill script testing
   (Aug 3, Aug 10, Aug 22), but the developer guide still says "run
   tests manually." Update the testing section.

2. **`src/current/knowledge/dev-environment-practices/overview.md`** —
   References devbox 0.10.x. You're on devbox 0.13.x (seen in session
   from Aug 18). The `devbox run` syntax changed for plugin commands.
```

### Step 4: Five Weakest Prompting Habits

Identify the user's five weakest prompting habits from the 30-day
window. For each:

1. **Name the habit** — a short label (e.g., "Vague task scoping").
2. **Quote an actual prompt** that demonstrates it — verbatim, from a
   real session.
3. **Explain why it's weak** — what went wrong as a result.
4. **Give a specific fix** — a rewrite of the prompt or a habit change.

Output format:

```markdown
### Five Weakest Prompting Habits

#### 1. Vague task scoping

**Your prompt (Aug 14):**
> "fix the build"

**Why it's weak:** The AI had to guess which build (there are 3 repos
with builds), which failure (there were 2 failing tests), and which
fix you wanted (quick patch vs. root cause). This led to 8 messages
of back-and-forth before the actual work started.

**Fix:** Scope the prompt to repo + failure + goal:
> "fix the failing test `test_sign_off_writes_document` in
> skills-src — the test expects the sign-off doc at
> `.agents/handoffs/human/summary/` but the slug derivation is wrong.
> Update the test to use the `YYYYMMDDHHmm-signoff-{slug}.md` format."

#### 2. Re-explaining context instead of referencing a file

**Your prompt (Aug 20):**
> "I need you to update the sign-off skill. The sign-off skill runs
> at end of day and does git sweep, AI review, daily summary, scrum
> update, calendar review, and next-day planning. It writes to
> `.agents/handoffs/human/summary/YYYY/MM/YYYYMMDDHHmm-signoff-{slug}.md`.
> The phases are..."

**Why it's weak:** You explained the entire skill from memory instead
of saying "read `src/current/skills/general/sign-off/SKILL.md.tmpl`
and update Phase 3." The AI may have missed details you forgot to
mention.

**Fix:** Reference the file, then state the delta:
> "Read `src/current/skills/general/sign-off/SKILL.md.tmpl`. Update
> Phase 3 to add an AI coach review that covers 30-day usage
> patterns."

(Repeat for habits 3-5.)
```

### Step 5: Skills or Knowledge Bundles to Build Next

Based on the jobs the user keeps doing (identified in Step 2's
re-explanation and repeated-pattern analysis), recommend skills or
knowledge bundles to build next. For each:

1. **Name the artifact** — skill or knowledge bundle, with a proposed
   slug.
2. **Evidence** — quote 2+ sessions where the user did this job
   manually.
3. **What it would contain** — 2-3 sentences on the scope.
4. **Priority** — High (doing it weekly), Medium (monthly), Low
   (occasionally).

Output format:

```markdown
### Skills / Knowledge Bundles to Build Next

#### 1. [High] Skill: `deploy-staging`

**Evidence:**
- Aug 5: "deploy to staging" — 12-message session, you walked the AI
  through the deploy steps manually.
- Aug 12: "push the staging deploy" — 8-message session, same steps.
- Aug 19: "deploy staging again" — 9-message session, same steps.

**What it would contain:** A skill that wraps the staging deploy
process: run tests, build, push to staging, smoke test. One command
instead of a 10-message conversation.

#### 2. [Medium] Knowledge bundle: `deploy-practices`

**Evidence:**
- Aug 5, Aug 12, Aug 19: You explained the staging deploy process
  from scratch each time (see re-explanation patterns above).

**What it would contain:** The staging deploy runbook, environment
variables, rollback procedure, and smoke test checklist.
```

### Step 6: Unused Capabilities

Review the user's installed skills, knowledge bundles, and tool
capabilities (MCP servers, CLI tools, etc.) and identify any that:

1. **Fit how the user actually works** — based on the 30-day session
   review, the user does jobs this capability would help with.
2. **Are not being used** — the skill's `last-used` date is old or
   missing, or the tool was never invoked in any session.

For each unused capability:

- **Name it** — skill/bundle/tool name.
- **Why it fits** — quote a session where the user did manually what
  this capability would automate.
- **How to start using it** — a specific next step (invoke command,
   install instruction, or add to a workflow).

Output format:

```markdown
### Unused Capabilities

#### 1. Skill: `repository-health-review`

**Why it fits:** On Aug 15, you spent 20 minutes manually checking
repos for failing tests, stale branches, and dependency drift —
exactly what this skill automates.

**How to start:** Invoke it during the next sign-off Phase 2 (Repo
Health Sweep) instead of the manual check. Command: "run
repository-health-review on skills-src."

#### 2. MCP server: `linear`

**Why it fits:** You referenced Linear tickets in 8 sessions but
never used the Linear MCP integration. You manually pasted ticket
URLs and descriptions each time.

**How to start:** Install the Linear MCP server and add it to your
Devin config. Then "read ticket ENG-123" becomes a single tool call
instead of a paste-and-explain.
```

### Step 7: Compile the Coach Report

Combine all six steps into a single section for the sign-off document:

```markdown
## AI Coach Review — YYYY-MM-DD (rolling 30-day: YYYY-MM-DD to YYYY-MM-DD)

### Sessions Analyzed
- Total sessions: N
- Total prompts: N
- Avg prompts/session: N
- Abandoned threads: N
- Re-explanation instances: N

### Thin or Empty Files
(table from Step 3)

### Files Most in Need of Update
(ranked list from Step 3)

### Five Weakest Prompting Habits
(habits 1-5 from Step 4, each with quoted prompt + fix)

### Skills / Knowledge Bundles to Build Next
(ranked list from Step 5)

### Unused Capabilities
(list from Step 6)

### Daily Session Review (today)
(findings from Part 1 — the original daily review)
```

## Output Format (Combined)

Present both parts as a structured list in the sign-off document:

```markdown
## AI Session Review — YYYY-MM-DD

### Daily Review (today)
- Handoff: .agents/handoffs/todo/202608281400-auth-impl.md
- Commits: 8 AI-assisted commits across 3 repos
- Skills invoked: ai-upsert, git-repository-management, handoff

#### Improvement Candidates
1. **[New skill]** The AI repeatedly ran a 5-step sequence to validate
   PRs before merge. This could be a `pr-validation` skill.
   - Suggested action: Create via `ai-upsert` tomorrow.

2. **[Skill update]** The `handoff` skill didn't handle the case where
   the session ended with a failing test. Add a "known failures" section
   to the handoff template.
   - Suggested action: Update via `ai-upsert` (Mode C) tomorrow.

### AI Coach Review (rolling 30-day)
(full coach report from Step 7, if coach review is due this run)
— or —
AI coach review skipped — last run 2026-08-21 (next due 2026-08-28).
```

## What NOT to Do

- **Don't auto-apply improvements.** Present candidates to the user.
  They decide what to pursue and when.
- **Don't fabricate findings.** If the sessions were routine with no
  issues, say "no improvement opportunities found."
- **Don't review every session in detail.** Focus on sessions where
  something notable happened (struggles, repetitions, surprises).
- **Don't create tasks for every finding.** Only create tasks for
  findings the user approves. Unapproved findings go in the sign-off
  document as notes.
- **Don't paraphrase prompts.** Quote them verbatim — the user needs to
  see their actual words to recognize the habit.
- **Don't give vague advice.** "Be more specific in your prompts" is
  useless. "Instead of 'fix the build,' say 'fix test
  `test_sign_off_writes_document` in skills-src'" is actionable.
- **Don't skip the intelligence layer audit.** Even if no sessions were
  notable, the file audit may reveal thin or stale files.
- **Don't run the coach review nightly.** It's a 7-day cadence —
  running it every night wastes time and produces repetitive findings.
