# Next-Day Planning Methodology

Guidance for producing a prioritized, calendar-aware task list for
tomorrow during Phase 8 of the sign-off skill.

## Methodology

### Step 1: Compile the Task Pool

Gather tasks from all phases:

| Source | Tasks |
|--------|-------|
| Phase 5 (Ticket Updates) | Continuation tasks — work that is mid-flight and needs to resume |
| Phase 3 (AI Session Review) | Improvement candidates — skill updates, new skills, knowledge gaps |
| Phase 2 (Repo Health) | Health issues — failing tests, dependency drift, stale branches |
| Phase 7 (Calendar Review) | Prep tasks — pre-reading, document prep, demo setup |
| Existing backlog | Any open tickets or tasks not yet started |

### Step 2: Prioritize with task-triage

Run the `task-triage` skill on the compiled pool. It applies the 26-tier
prioritization framework:

- **Tier 1-5**: Critical / urgent / blocking — do first thing tomorrow.
- **Tier 6-13**: Important / scheduled / time-sensitive — do in the
  morning or before relevant meetings.
- **Tier 14-20**: Normal / routine / maintenance — do in available gaps.
- **Tier 21-26**: Low priority / nice-to-have / defer — only if time
  permits.

### Step 3: Adjust for Calendar Constraints

Map the prioritized list against tomorrow's calendar:

1. **Identify focus blocks** — gaps >90 minutes between meetings. These
   are for deep work (Tier 1-8 tasks).
2. **Identify shallow windows** — gaps <60 minutes or meeting-heavy
   periods. These are for shallow work (email, reviews, minor fixes,
   Tier 14-20 tasks).
3. **Schedule prep tasks before meetings** — if a 2pm meeting needs
   pre-reading, schedule the prep task at 1:30pm.
4. **Don't over-schedule** — leave 20% buffer for interruptions and
   context switching. If the calendar has 4 hours of meetings, plan
   only 3 hours of focused work, not 4.

### Step 4: Produce the Plan

Format the plan as a time-ordered list:

```markdown
## Tomorrow's Plan — YYYY-MM-DD

### Morning (focus block: 9:00-11:30)
1. [Tier 3] Payment retry logic implementation (#130) — 2h deep work
2. [Tier 7] Review PR #48 — 15min

### Midday (meeting: 11:30-12:00)
- Team standup

### Afternoon (shallow: 12:00-2:00)
3. [Tier 12] Fix failing test in checkout service (#125) — 30min
4. [Tier 15] Update README for auth feature — 20min
5. [Tier 18] Clean stale branches in skills-src — 15min

### Late afternoon (meeting: 2:00-3:00)
- Architecture review — prep: read ADR-045 (15min before)

### End of day (focus block: 3:00-5:00)
6. [Tier 5] Deploy staging environment — 1h
7. [Tier 9] Start API documentation draft — 1h

### Carry-over (if time permits)
- [Tier 20] Investigate slow query in user dashboard
- [Tier 22] Clean up old feature flags
```

## Prioritization Heuristics

When two tasks are the same tier, use these tiebreakers:

1. **Continuation before new**: A mid-flight task finishes faster than
   starting fresh (context is already loaded).
2. **Blocking before independent**: If task A blocks someone else, do it
   before task B that only affects you.
3. **Time-sensitive before flexible**: A deploy window closing at 3pm
   beats a doc update with no deadline.
4. **Prep before meeting**: Always schedule prep immediately before the
   meeting it supports, not in the morning.

## Anti-Patterns

- **Planning 8 hours of work on a meeting-heavy day** — you'll fail and
  feel demoralized. Plan for the actual available focus time.
- **Putting deep work in 30-minute gaps** — context switching kills deep
  work. Save it for 90+ minute blocks.
- **Ignoring prep tasks** — showing up to a meeting unprepared is worse
  than missing a low-priority task.
- **No buffer** — interruptions happen. Plan 80% capacity, not 100%.
- **Vague tasks** — "work on payments" is not actionable. "Implement
  retry logic for failed payments in `payment_service.py`" is.
