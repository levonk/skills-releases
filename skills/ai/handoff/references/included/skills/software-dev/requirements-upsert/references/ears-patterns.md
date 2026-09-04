# EARS Patterns Reference Card

EARS (Easy Approach to Requirements Syntax) gives every requirement a
deterministic sentence structure so reviewers and tests know exactly what to
check. Every EARS sentence uses **SHALL** as the modal verb — never "should",
"must", or "will".

## The 5 Templates

### 1. Ubiquitous

**Structure**: `The {system} shall {response}.`

**When to use**: The behavior is always true — no trigger, no state, no
condition. It is an invariant of the system.

**Example**: The API gateway shall accept requests over HTTPS only.

**Implied test shape**: An invariant assertion — verify the property holds on
every invocation, not just under a specific condition.

---

### 2. Event-driven

**Structure**: `When {trigger}, the {system} shall {response}.`

**When to use**: The system reacts to an external event or input. The trigger
is something that happens, not a state that persists.

**Example**: When a webhook payload is received, the ingestion service shall
validate the signature before processing.

**Implied test shape**: A handler test — send the trigger, assert the response
fires exactly once.

---

### 3. State-driven

**Structure**: `While {state}, the {system} shall {response}.`

**When to use**: The behavior is active for the entire duration a condition or
state holds, and stops when the state ends.

**Example**: While the database is in read-only mode, the API shall return 503
for all write endpoints.

**Implied test shape**: A state-machine test — enter the state, verify the
response is continuous; exit the state, verify the response stops.

---

### 4. Unwanted

**Structure**: `If {condition}, then the {system} shall {response}.`

**When to use**: The system handles an error, edge case, or otherwise unwanted
situation. The condition is something you'd prefer not to happen but must
defend against.

**Example**: If the upstream provider returns a 5xx, then the proxy shall
retry with exponential backoff up to 3 attempts.

**Implied test shape**: An error-path test — inject the unwanted condition,
assert the defensive response.

---

### 5. Optional

**Structure**: `Where {feature is included}, the {system} shall {response}.`

**When to use**: The behavior applies only when an optional feature or
configuration is present (feature flag, plan tier, build variant).

**Example**: Where audit logging is enabled, the service shall record every
mutation with actor, timestamp, and payload hash.

**Implied test shape**: A feature-flagged path test — run with the feature on
and off; assert the response only appears when the feature is included.

---

## Modal Verb

**SHALL** is the required modal verb in every EARS sentence.

| Word | Verdict |
|------|---------|
| shall | Correct — use this |
| should | Wrong — implies a suggestion, not a requirement |
| must | Wrong — ambiguous (RFC 2119 conformance vs. obligation) |
| will | Wrong — describes future intent, not a binding requirement |

## Scope: EARS vs. Gherkin

EARS applies to the **requirements ledger** — durable constraints that govern
the system across releases. Each requirement is a single EARS sentence that
stays stable as implementation evolves.

Gherkin (`Given`/`When`/`Then`) applies to **acceptance criteria in task
stories** — concrete scenarios that prove a specific increment satisfies a
ledger requirement. These are short-lived: once the story ships, the scenario
becomes a regression test.

The two tiers coexist:

| Tier | Artifact | Syntax | Lifespan |
|------|----------|--------|----------|
| Requirements ledger | `requirement-template.md` | EARS (SHALL) | Durable — spans releases |
| Task story acceptance | Gherkin scenarios | Given/When/Then | Ephemeral — per-increment |

Do not write Gherkin in the requirements ledger, and do not write EARS
sentences as task-story acceptance criteria. Each tier has its own grammar.
