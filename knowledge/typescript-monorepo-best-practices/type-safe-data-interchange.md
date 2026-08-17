---
type: Practice
title: Type-Safe Data Interchange — Validate at Boundary, Derive Types from Schema
description: Define a schema at every trust boundary (API request, DB row, external response), validate incoming data against it, and derive all types from the schema — never write parallel hand-crafted interfaces that can drift from the runtime shape.
tags: [typescript, type-safety, zod, schema-validation, boundary-validation, type-derivation, pydantic, serde]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-zod-conventions
    resource: https://github.com/coleam00/archon/blob/main/AGENTS.md
    title: 'archon AGENTS.md — Zod Schema Conventions'
  - id: archon-core-schemas
    resource: https://github.com/coleam00/archon/blob/main/packages/core/src/schemas/index.ts
    title: 'archon packages/core/src/schemas/ — one file per data shape, z.infer derivation'
  - id: zod-docs
    resource: https://zod.dev/
    title: 'Zod — TypeScript-first schema validation with static type inference'
---

# Type-Safe Data Interchange — Validate at Boundary, Derive Types from Schema

## Failure Mode

Hand-crafted interfaces that describe external data shapes (API responses,
database rows, config files) drift from the runtime data. The type checker is
satisfied because the interface matches what the code *expects*, but the actual
data has extra fields, missing fields, or wrong types. The error surfaces at
runtime — often deep in a function that trusted the interface — instead of at
the boundary where it could be caught early.

Symptoms:

1. **Silent `undefined` access**: A DB column was renamed upstream; the
   hand-crafted interface still lists the old name; code reads `row.oldName`
   and gets `undefined` with no error.
2. **Extra fields ignored**: An API response adds a required field; the
   interface doesn't include it; the code never reads it and produces
   incorrect behavior.
3. **Type lies**: `as any` or `as MyInterface` casts bypass validation
   entirely — the data is never checked, only asserted.
4. **Parallel maintenance**: A schema exists in one place (e.g. a migration
   file) and an interface exists in another; every change requires updating
   both, and humans forget.

## Practice

**Validate at every trust boundary; derive types from the schema.**

A trust boundary is any point where data enters your process from an external
source: an HTTP request body, a database row, a file on disk, an environment
variable, a response from an external API. At each boundary:

1. **Define a schema** — a runtime-validatable description of the expected
   shape (fields, types, constraints).
2. **Validate on entry** — parse the incoming data through the schema before
   any code touches it. If validation fails, surface the error immediately
   (fail fast).
3. **Derive the type** — use the schema as the single source of truth for the
   TypeScript type. Never write a parallel `interface` that duplicates the
   schema's shape.

### One File per Data Shape

Group schemas by data shape, not by feature. Each distinct shape (conversation,
message, user, codebase, session) gets its own file. An `index.ts` re-exports
all schemas and derived types so consumers import from a single entry point.
This prevents schema sprawl — when a shape changes, there is exactly one file
to update.

### Record Schemas: Explicit Key Type

When defining map-like schemas, always pass an explicit key type. The
single-argument form (`z.record(valueSchema)`) was dropped in Zod v4 and is
ambiguous in other libraries. Use `z.record(z.string(), valueSchema)`.

## Concrete Instances

### TypeScript / Zod

```typescript
import { z } from '@hono/zod-openapi';

// Schema is the single source of truth
export const conversationRowSchema = z.object({
  id: z.string(),
  platform_type: z.string(),
  platform_conversation_id: z.string(),
  codebase_id: z.string().nullable(),
  hidden: z.boolean(),
  created_at: z.date(),
});

// Type is DERIVED — never hand-crafted
export type Conversation = z.infer<typeof conversationRowSchema>;
```

At the boundary (API handler, DB query result), validate:

```typescript
const result = conversationRowSchema.safeParse(rawRow);
if (!result.success) {
  throw new Error(`Invalid conversation row: ${result.error.message}`);
}
// result.data is now typed as Conversation
```

### Python / Pydantic

```python
from pydantic import BaseModel

class Conversation(BaseModel):
    id: str
    platform_type: str
    platform_conversation_id: str
    codebase_id: str | None = None
    hidden: bool
    created_at: datetime

# Validate at boundary — raises ValidationError on mismatch
conv = Conversation.model_validate(raw_dict)
```

Pydantic models serve as both the schema and the type; there is no separate
interface to drift.

### Rust / serde

```rust
use serde::Deserialize;

#[derive(Deserialize)]
struct Conversation {
    id: String,
    platform_type: String,
    platform_conversation_id: String,
    codebase_id: Option<String>,
    hidden: bool,
    created_at: chrono::DateTime<chrono::Utc>,
}

// Validate at boundary — returns Err on mismatch
let conv: Conversation = serde_json::from_str(&raw_json)?;
```

`serde` derives the deserialization logic from the struct definition. The struct
is the schema; the type and the parser cannot drift.

## Rationale

- **Single source of truth**: The schema is the only description of the shape.
  The type is derived from it, so they cannot diverge.
- **Fail fast**: Invalid data is rejected at the boundary, not three call
  sites deeper where the stack trace is meaningless.
- **No `as any`**: When the type is derived from the schema, there is no
  temptation to cast — the validated data is already correctly typed.
- **Cross-language portability**: The principle (schema → validate → derive)
  applies identically in TypeScript (Zod), Python (Pydantic), Rust (serde),
  and Go (struct tags + encoding/json). The library changes; the discipline
  does not.

## Consequences

### Positive

- Runtime shape mismatches are caught at the boundary, not in production logic.
- Types and schemas never drift — one change updates both.
- New team members can read the schema to understand the data shape without
  tracing through code.

### Negative

- Schema definitions add a layer of indirection at every boundary.
- Libraries like Zod add a runtime cost to validation (mitigated by
  validating once at the boundary, not on every access).

## Related Concepts

- [Typed API Route Registration](typed-api-route-registration.md) — applies
  this principle to HTTP route handlers with schema-validated request/response
  cycles.
- [Structured Logging](structured-logging.md) — log validated boundary events
  with stable field names.
- [Linter Zero-Tolerance](linter-zero-tolerance.md) — `no-explicit-any` is
  enforceable because schemas provide the types that replace `any`.
