---
type: Practice
title: Structured Logging — Event Naming, Field Discipline, Log Levels, Never Log Secrets
description: Emit structured key/value events with a stable domain.action_state naming convention, consistent field names, correct log levels, and an absolute prohibition on logging secrets — so logs are machine-parseable, filterable, and safe.
tags: [typescript, logging, pino, structured-logs, event-naming, log-levels, field-discipline, secrets, tracing, structlog]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-logger
    resource: https://github.com/coleam00/archon/blob/main/packages/paths/src/logger.ts
    title: 'archon packages/paths/src/logger.ts — Pino-based structured logger with module binding'
  - id: archon-log-events
    resource: https://github.com/coleam00/archon/blob/main/packages/server/src/adapters/web/pg-notify-listener.ts
    title: 'archon pg-notify-listener.ts — domain.action_state event naming examples'
  - id: rust-structured-logging
    resource: https://github.com/levonk/skills-src/blob/main/src/current/knowledge/rust-development-practices/structured-logging-tracing.md
    title: 'Rust structured logging with tracing — cross-reference'
---

# Structured Logging — Event Naming, Field Discipline, Log Levels, Never Log Secrets

## Failure Mode

Free-form `console.log` strings that grep-only tools cannot slice. Log messages
like `"got error from db"` contain no structured fields — no rule ID, no
correlation ID, no duration — so dashboards aggregate noise instead of
signal. Inconsistent event names (`"db error"`, `"database failed"`,
`"DB_ERROR"`) make filtering unreliable. Secrets (API keys, tokens, passwords)
leak into log lines because the developer interpolated a whole object to
"debug quickly."

Symptoms:

1. **Unparseable logs**: `console.log("workflow failed for " + id)` — a log
   aggregator sees a string, not a filterable field.
2. **Inconsistent naming**: One module logs `"session_started"`, another logs
   `"session start"`, a third logs `"SessionStart"` — no single query catches
   them all.
3. **Wrong levels**: `log.error("starting server")` — a normal lifecycle
   event logged at error level triggers pager alerts.
4. **Secret leakage**: `log.info({ config })` where `config` contains
  `api_key` — the key is now in the log stream permanently.

## Practice

### Event Naming: domain.action_state

Use a `domain.action_state` convention for event messages. The domain is the
subsystem, the action is what happened, and the state is the outcome.

- `session.started` — a session began successfully
- `session.failed` — a session failed to start
- `pg_notify.listening` — the Postgres LISTEN channel connected
- `pg_notify.connect_failed` — the connection attempt failed
- `dashboard_poller.started` — the poller began its interval
- `dashboard_poller.drain_failed` — draining the event queue failed

This makes log queries predictable: `*session.*` catches all session events;
`*.failed` catches all failures across every domain.

### Field Discipline

Pass context as structured key/value fields, not interpolated strings. Pick
stable field names so consumers can filter reliably across modules:

- `conversationId` / `sessionId` — correlation IDs
- `err` — the error object (most loggers serialize it automatically)
- `duration.ms` — elapsed time for a phase
- `module` — the emitting module (bound via child logger, not repeated manually)

Never embed a field value inside the message string. The message is the event
name; the fields carry the data.

### Log Levels

| Level | When to use |
|-------|-------------|
| `fatal` | Process cannot continue — exit imminent |
| `error` | Failures needing immediate attention |
| `warn` | Degraded behavior, fallbacks, retries |
| `info` | Key user-visible events (default level) |
| `debug` | Internal details, tool calls, state transitions |
| `trace` | Fine-grained diagnostic output |
| `silent` | Disables all output (e.g. CLI `--json` mode) |

Default to `info`. Let an environment variable (`LOG_LEVEL`, `RUST_LOG`) override
at startup. Do not add a parallel `--verbose` flag that fights the env var.

### Never Log Secrets

This is an absolute rule, not a preference. Secrets include API keys, OAuth
tokens, passwords, session tokens, private keys, and any PII regulated by
your compliance regime.

- Never log a whole config object or request object — log only the specific
  non-secret fields you need.
- If a library logs request headers by default, configure it to redact
  `Authorization`, `Cookie`, and `Set-Cookie`.
- Treat `log.info({ obj })` as dangerous as `console.log(obj)` — both serialize
  every enumerable property.

## Concrete Instances

### TypeScript / Pino

```typescript
import { createLogger } from '@archon/paths';

const log = createLogger('orchestrator');

// ✅ Correct — structured fields, domain.action_state naming
log.info({ conversationId }, 'session.started');
log.error({ err, conversationId }, 'session.failed');

// ❌ Wrong — interpolated string, no fields, secret leak
log.info(`session started for ${conversationId} with token ${token}`);
```

Pino emits newline-delimited JSON in production (machine-parseable) and
pretty-prints when stdout is a TTY (human-readable in dev). Child loggers
bind `module` once so every event from that module includes it.

### Rust / tracing

```rust
use tracing::{info, warn, instrument};

#[instrument(fields(file.path = %path.display()))]
fn check_file(&self, path: &std::path::Path) {
    info!(rule.id = "no-bare-println", severity = "warn", "violation");
}
```

The `tracing` crate provides spans that carry context across await points and
events that attach to the active span. See
[Structured Logging with Tracing](https://github.com/levonk/skills-releases/blob/main/knowledge/rust-development-practices/structured-logging-tracing.md)
in the Rust bundle for the full Rust-specific treatment.

### Python / structlog

```python
import structlog

log = structlog.get_logger()

log.info("session.started", conversation_id=conv_id)
log.error("session.failed", conversation_id=conv_id, error=str(err))
```

`structlog` produces structured key/value events that can be rendered as JSON
for production or colored output for development. The event name is the first
positional argument; all context is passed as keyword arguments.

## Rationale

- **Machine-parseable**: Structured JSON logs are queryable by field, not just
  by grep pattern. Dashboards, alerts, and audit trails depend on this.
- **Stable naming**: `domain.action_state` makes log queries predictable
  across modules and teams. No one has to guess whether the event is called
  `"db error"` or `"database_failed"`.
- **Level discipline**: Correct levels mean `error` actually means "page me"
  and `info` actually means "track this." Misleveled logs either flood
  dashboards or hide real incidents.
- **Secret safety**: Logs are often shipped to third-party observability
  platforms. A leaked token in a log line is a credential breach.

## Consequences

### Positive

- Logs are filterable, aggregatable, and safe to ship to any log platform.
- Incident response is faster — queries like `*.failed` surface every
  failure across every domain in one search.
- No risk of credential exposure through log streams.

### Negative

- Developers must think about field names and event names instead of writing
  a quick string — but the cost is seconds per log call, while the benefit
  compounds over the lifetime of the log stream.

## Related Concepts

- [Type-Safe Data Interchange](type-safe-data-interchange.md) — log validated
  boundary events; the schema determines which fields are safe to log.
- [Typed API Route Registration](typed-api-route-registration.md) — route
  handlers should log structured events, not `console.log` the request body.
- [Rust: Structured Logging with Tracing](https://github.com/levonk/skills-releases/blob/main/knowledge/rust-development-practices/structured-logging-tracing.md)
  — the Rust-specific treatment of this principle using the `tracing` crate.
