# Sign-Off Process

Detailed phase-by-phase process for the sign-off skill. Each phase has
inputs, steps, decision points, and outputs.

## Phase 1: Git Global Sweep

**Goal**: Fetch, prune, and refresh all repos across the workspace.

**Script**: `scripts/git-global-sweep.sh`

### Steps

1. Run `scripts/git-global-sweep.sh` (via `devbox run --` if the current
   repo has `devbox.json`).
2. Parse the structured output:
   - **DIRTY REPOS** — repos with uncommitted changes. For each:
     - If the changes are clearly mid-task (partial implementation, WIP):
       defer with a handoff note (Phase 5 will capture this).
     - If the changes are config drift, scratch files, or trivial: commit
       via `git-repository-management` or clean them.
     - If unsure: ask the user.
   - **UNPUSHED** — repos with commits ahead of upstream. Note these in
     the sign-off document. Do NOT auto-push (guardrail).
   - **UNPULLED** — repos with commits behind upstream. Note these for
     tomorrow's start-of-day.
   - **DEVBOX UPDATED** — repos where devbox refresh ran. Note any
     lockfile changes.
   - **ERRORS** — repos where fetch failed. Note the error for follow-up.

### Decision: Dirty repos

| Situation | Action |
|-----------|--------|
| Config drift, scratch files | Commit or clean via `git-repository-management` |
| Mid-task WIP | Defer — create a handoff note for tomorrow |
| Untracked files that look important | Ask the user |
| Untracked files that are build artifacts | Add to `.gitignore` via `ignorefile-manager` or clean |

### Output

- A list of dirty repos with their disposition (committed / deferred /
  cleaned).
- A list of unpushed and unpulled repos for the sign-off document.

## Phase 1b: Stale Branch Detection

**Goal**: Identify local branches that haven't been touched in N days.

**Script**: `scripts/stale-branches.sh`

### Steps

1. Run `scripts/stale-branches.sh --days 30` (adjustable).
2. For each stale branch:
   - Check if it's been merged into main/master: `git branch --merged main`
   - If merged: suggest deletion (`git branch -d <name>`).
   - If unmerged: note it in the sign-off document as a candidate for
     review or deletion.

### Output

- A list of stale branches with merge status and recommended action.

## Phase 2: Repo Health Sweep

**Goal**: Flag repos with failing tests, dependency drift, or other
health issues.

### Steps

1. For each repo that was flagged in Phase 1 (dirty, errors, or
   unpulled), run a quick health check:
   - Check if tests pass: look for `just test`, `make test`, `npm test`,
     etc. Use `cli-tool-discovery.sh` to find the right command.
   - Check for dependency drift: `devbox update --dry-run` or equivalent.
   - Check for submodule drift: `just check-submodule-drift` (if
     available).
2. If a repo has failing tests or health issues:
   - Create a task/ticket for the issue.
   - Note it in the sign-off document.
   - If the issue is severe (security, broken build), flag it for
     immediate attention tomorrow morning.
3. For repos that pass, no action needed — note "all green" in the
   summary.

### Decision: When to run full repository-health-review

If a repo has multiple issues (failing tests + outdated deps + stale
branches), suggest running the full `repository-health-review` skill on
it. This is a deeper audit — don't run it on every repo every day.

### Output

- A list of repos with health issues and their severity.
- Tasks/tickets created for issues that need follow-up.

## Phase 3: AI Session Review + AI Coach

**Goal**: Review today's AI sessions for skill-improvement opportunities,
patterns to extract, and lessons learned — **and** act as an AI coach
that reviews the user's AI usage over a rolling 30-day window, audits
their intelligence layer, and recommends improvements.

**Reference**: `references/ai-session-review.md`

### Steps

#### Part 1: Daily Session Review (every run)

1. Identify today's AI sessions:
   - Check `.agents/handoffs/` for handoffs created today.
   - Check git commit messages for AI-assisted commits (look for
     co-author patterns or session references).
   - Check the user's AI tool session logs if available.
2. For each session, review:
   - **Skill improvement opportunities**: Did the AI struggle with
     something a skill could help with? Did it repeat a pattern that
     could be extracted into a new skill or added to an existing one?
   - **Knowledge gaps**: Were there questions the AI couldn't answer
     that should be captured in a knowledge bundle?
   - **Process improvements**: Did the session reveal a workflow
     bottleneck or a step that could be automated?
   - **Lessons learned**: What went well? What didn't? What should be
     done differently next time?
3. Compile findings into a list of improvement candidates.
4. For each candidate, categorize:
   - **New skill**: A pattern that should become a skill.
   - **Skill update**: An existing skill that needs improvement.
   - **Knowledge bundle**: Knowledge that should be captured.
   - **Process change**: A workflow that should be adjusted.
5. Present the candidates to the user. Do not auto-apply — the user
   decides which to pursue (possibly via `ai-guidance-improver` or
   `ai-upsert` tomorrow).

#### Part 2: AI Coach Review (weekly cadence — every 7 days)

Check `.agents/handoffs/human/summary/.last-coach-run`. If the file
is missing or the date in it is older than 7 days, run the coach
review. Otherwise, skip with a note.

The coach review is a **rolling 30-day coaching pass**. See
`references/ai-session-review.md` Part 2 for the full methodology.
Summary of what it covers:

1. **Gather 30 days of AI sessions** — handoffs, git commits, session
   logs, skill invocations.
2. **Identify usage patterns** — back-and-forth threads (high prompt
   counts), abandoned threads (ended without resolution), re-explanation
   patterns (same context provided in multiple sessions).
3. **Audit the intelligence layer** — read all AGENTS.md files,
   knowledge bundles, skills, rules, and developer guides. Identify:
   - Which files are **thin or empty** (under 20 lines or frontmatter
     only).
   - Which files are **most in need of an update** (stale, contradict
     actual workflow, missing coverage for jobs the user does).
   - Anything the user **keeps re-explaining** is a file that should
     exist but does not — prescribe the exact file path to create.
4. **Five weakest prompting habits** — for each, quote an actual prompt
   from the 30-day window, explain why it's weak, and give a specific
   fix (a rewritten prompt or a habit change).
5. **Skills or knowledge bundles to build next** — based on jobs the
   user keeps doing manually. For each, quote 2+ sessions as evidence,
   describe what the artifact would contain, and assign priority
   (High/Medium/Low).
6. **Unused capabilities** — installed skills, knowledge bundles, MCP
   servers, or CLI tools that fit how the user works but are not being
   used. For each, quote a session where the user did manually what
   the capability would automate, and give the specific next step to
   start using it.

After the coach review completes, write today's date to
`.agents/handoffs/human/summary/.last-coach-run`.

### Output

- **Daily**: A list of improvement candidates with category,
  description, and suggested action.
- **Weekly (when coach review runs)**: The full AI coach report
  covering thin/empty files, files needing updates, five weakest
  prompting habits (with quoted prompts and fixes), skills/bundles to
  build next, and unused capabilities.

## Phase 4: Daily Summary

**Goal**: Compile a factual summary of what was accomplished today.

**Script**: `scripts/daily-activity.sh`

### Steps

1. Run `scripts/daily-activity.sh` to get today's git commits across all
   repos.
2. Augment the git log with:
   - Merged PRs (check `gh pr list --state merged --merged-at today`).
   - Closed tickets/issues (check `gh issue list --state closed` or the
     ticket system).
   - AI session outcomes (from Phase 3).
3. Organize by project/repo:
   - For each repo with activity, list the commits with their subjects.
   - Group related commits into accomplishments (e.g., "Implemented
     user authentication: 3 commits across login, session, and tests").
4. Write the summary as a section of the sign-off document.

### Output

- A structured daily summary organized by project, with concrete
  accomplishments (not vague intentions).

## Phase 5: Ticket Updates

**Goal**: Update tickets with progress and continuation notes.

### Steps

1. Identify tickets that were worked on today (from the daily summary).
2. For each ticket:
   - Add a progress comment: what was done, what remains.
   - Update status if appropriate (e.g., in-progress → review, or
     in-progress → blocked).
   - Add continuation notes: what the next session should pick up.
3. For tickets that were not touched but are still open:
   - Note them as "not started" or "deferred" in the sign-off document.
4. If using GitHub issues: `gh issue comment <num> --body "..."`.
   If using a local ticket system (tk, ticketr): use its CLI.

### Output

- Updated tickets with progress comments and continuation notes.

## Phase 6: Scrum Update

**Goal**: Craft a scrum update ready to paste into Slack/email/standup.

**Reference**: `references/scrum-update.md`

### Steps

1. Compile from the daily summary (Phase 4) and ticket updates (Phase 5):
   - **What I did**: 2-5 bullets covering the day's accomplishments.
   - **What I'm doing next**: 1-3 bullets covering tomorrow's priorities.
   - **Blockers**: Any blockers or help needed.
2. Match the team's scrum format (see `references/scrum-update.md` for
   format options).
3. Present the update to the user for review before posting.

### Output

- A scrum update ready to paste.

## Phase 7: Calendar Review

**Goal**: Review tomorrow's calendar and identify prep needs and
conflicts.

### Steps

1. If calendar integration is available (e.g., `icalBuddy`, Google
   Calendar CLI, Outlook CLI):
   - List tomorrow's events: times, titles, attendees.
   - Identify prep needs: meetings that require pre-reading, documents
     to prepare, demos to set up.
   - Identify conflicts: overlapping meetings, back-to-back meetings
     with no buffer.
   - Identify focus blocks: gaps between meetings that are long enough
     for deep work.
2. If no calendar integration:
   - Ask the user to paste tomorrow's schedule, or
   - Skip with a note: "Calendar review skipped — no integration
     available."
3. Note prep tasks in the next-day plan (Phase 8).

### Output

- Tomorrow's schedule with prep needs, conflicts, and focus blocks
  identified.

## Phase 8: Next-Day Planning

**Goal**: Produce a prioritized task list for tomorrow.

**Reference**: `references/next-day-planning.md`

### Steps

1. Compile the task pool:
   - Continuation tasks from ticket updates (Phase 5).
   - Improvement candidates from AI session review (Phase 3).
   - Health issues from repo health sweep (Phase 2).
   - Prep tasks from calendar review (Phase 7).
   - Any existing backlog items.
2. Run `task-triage` to prioritize the pool using the 26-tier framework.
3. Adjust for calendar constraints:
   - If the morning is free: schedule the highest-priority deep-work task.
   - If the afternoon is meeting-heavy: schedule shallow tasks (email,
     reviews, minor fixes).
   - If there's a prep task for a meeting: schedule it before the
     meeting.
4. Present the prioritized plan to the user for approval.

### Output

- A prioritized task list for tomorrow, calendar-aware.

## Phase 9: Long-Running Work Identification

**Goal**: Identify tasks suitable for overnight background execution and
prompt the user to approve launching them.

### Steps

1. Scan the task pool for candidates that meet all three criteria:
   - **Long-running**: estimated >30 minutes of autonomous work.
   - **Independent**: no user input needed during execution.
   - **Safe to run unattended**: no destructive operations, no
     irreversible changes, no external side effects (emails, payments,
     API calls with real-world impact).
2. For each candidate, prepare a summary:
   - Task description.
   - Estimated duration.
   - Why it's safe to run unattended.
   - What repo/branch it would work on.
   - What the expected output is (PR, test results, report).
3. Present candidates to the user one at a time with a yes/no prompt.
4. For each approved candidate:
   - Launch via cloud Devin handoff (`cloud_handoff` tool) or background
     subagent.
   - Note the launch in the sign-off document.
5. For rejected candidates: note them as "identified but not launched."

### Output

- A list of overnight work candidates with their approval status and
  launch details (if launched).

## Phase 10: Sign-Off Document

**Goal**: Write and commit a sign-off document capturing all phase
outputs.

### Steps

1. Derive the document slug from the day's primary accomplishment or
   theme. If the day had one dominant task, use a 2-4 word kebab-case
   slug (e.g., `auth-flow`, `fix-build-errors`, `sign-off-skill-update`).
   If the day was mixed, use `mixed-activity`. If the day was light,
   use `light-day`.
2. Create the document at
   `.agents/handoffs/human/summary/YYYY/MM/YYYYMMDDHHmm-signoff-{slug}.md`
   (create the directory structure if it doesn't exist). The timestamp
   is the current time in `YYYYMMDDHHmm` format (e.g., `202608281430`
   for Aug 28, 2026 at 14:30).
3. Structure the document:
   ```markdown
   # Sign-Off: YYYY-MM-DD

   ## Git Sweep
   - Dirty repos: <list with disposition>
   - Unpushed: <list>
   - Unpulled: <list>
   - Devbox updated: <list>
   - Stale branches: <list with recommended action>

   ## Repo Health
   - Issues found: <list with severity>
   - All green: <repos that passed>

   ## AI Session Review
   - Daily review: <improvement candidates with category>
   - AI coach review: <full coach report if due, or "skipped — last run YYYY-MM-DD">

   ## Daily Summary
   <accomplishments organized by project>

   ## Ticket Updates
   - Updated: <list with status>
   - Not touched: <list>

   ## Scrum Update
   <ready-to-paste scrum update>

   ## Calendar (Tomorrow)
   - Events: <list with times>
   - Prep needed: <list>
   - Focus blocks: <list>

   ## Next-Day Plan
   <prioritized task list>

   ## Long-Running Work
   - Launched: <list with details>
   - Identified but not launched: <list>

   ## Notes
   <any additional notes for tomorrow>
   ```
4. Commit the document to the default branch:
   ```bash
   git add .agents/handoffs/human/summary/YYYY/MM/YYYYMMDDHHmm-signoff-{slug}.md
   git commit -m "Sign off for YYYY-MM-DD"
   ```
5. Do NOT push unless the user explicitly asks.

### Output

- A committed sign-off document at
  `.agents/handoffs/human/summary/YYYY/MM/YYYYMMDDHHmm-signoff-{slug}.md`.
