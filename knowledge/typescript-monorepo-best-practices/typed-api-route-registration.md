---
type: Practice
title: Typed API Route Registration — Schema-Validated Request/Response Cycles
description: Register every HTTP route with a schema that validates the request body, query params, and response shape, so the type checker, the runtime validator, and the OpenAPI spec are derived from one definition — never hand-write route handlers that accept untyped payloads.
tags: [typescript, api, openapi, hono, zod, route-registration, schema-validation, fastapi, actix]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-registerOpenApiRoute
    resource: https://github.com/coleam00/archon/blob/main/AGENTS.md
    title: 'archon AGENTS.md — registerOpenApiRoute convention'
  - id: archon-api-routes
    resource: https://github.com/coleam00/archon/blob/main/packages/server/src/routes/api.ts
    title: 'archon packages/server/src/routes/api.ts — createRoute + registerOpenApiRoute usage'
  - id: hono-zod-openapi
    resource: https://github.com/honojs/middleware
    title: '@hono/zod-openapi — Hono + Zod + OpenAPI integration'
---

# Typed API Route Registration — Schema-Validated Request/Response Cycles

## Failure Mode

Route handlers that accept `any` or loosely-typed request bodies. The handler
trusts the caller to send the right shape; invalid data propagates into
business logic and fails with a cryptic error far from the entry point.
Meanwhile, the OpenAPI spec (if it exists at all) is maintained separately
from the code and drifts — the spec says `string`, the code expects `number`,
and clients built against the spec break at runtime.

Symptoms:

1. **Untyped handlers**: `app.post('/api/workflows', (c) => { const body = await c.req.json(); ... })` — `body` is `any`, typos in field names are invisible.
2. **Spec drift**: The OpenAPI spec is written by hand or generated from a
   different source than the handler's actual validation logic.
3. **Silent malformed responses**: The handler returns an object that doesn't
   match what the client expects; no validation catches it.
4. **Inconsistent error shapes**: One route returns `{ error: string }`,
   another returns `{ message: string, code: number }` — clients must
   special-case every endpoint.

## Practice

**Register every route with a single schema definition that drives the type
checker, the runtime validator, and the OpenAPI spec.**

1. **Define the route schema**: Declare the request body, query params, path
   params, and response shapes (including error responses) as schemas.
2. **Register through a typed route builder**: Use a framework primitive that
   connects the schema to the handler — the handler receives fully-typed
   inputs and its return type is checked against the response schema.
3. **Standardize error responses**: Every route declares the same error
   response shape (e.g. `{ error: string }`) for 4xx/5xx codes.
4. **Narrow, documented exceptions**: If a route cannot use the typed builder
   (e.g. it serves non-JSON content, or accepts multipart uploads that JSON
   schemas can't describe), it deviates with an explanatory comment — never
   silently.

## Concrete Instances

### TypeScript / @hono/zod-openapi

```typescript
import { OpenAPIHono, createRoute, z } from '@hono/zod-openapi';

const getWorkflowRoute = createRoute({
  method: 'get',
  path: '/api/workflows/:name',
  tags: ['Workflows'],
  request: {
    params: z.object({ name: z.string() }),
  },
  responses: {
    200: {
      content: { 'application/json': { schema: workflowSchema } },
      description: 'Workflow definition',
    },
    404: jsonError('Workflow not found'),
    500: jsonError('Server error'),
  },
});

app.openapi(getWorkflowRoute, (c) => {
  const { name } = c.req.valid('param');
  // ... handler logic ...
  return c.json(workflow, 200);
});
```

The handler's `c.req.valid('param')` returns a typed object; the return type
is checked against `workflowSchema`. The OpenAPI spec is generated from the
same `createRoute` definition.

**Multipart exception**: Routes that accept multipart-or-JSON bodies register
through the typed builder but drop `request.body` from the route config — the
handler parses both content types manually. This is a documented, narrow
deviation, not a silent bypass.

### Python / FastAPI

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

class WorkflowResponse(BaseModel):
    name: str
    nodes: list[dict]

app = FastAPI()

@app.get("/api/workflows/{name}", response_model=WorkflowResponse)
async def get_workflow(name: str):
    workflow = db.get_workflow(name)
    if not workflow:
        raise HTTPException(status_code=404, detail="Workflow not found")
    return workflow
```

FastAPI derives the OpenAPI spec from the `response_model` and validates the
path parameter automatically. The Pydantic model is the single source of truth.

### Rust / actix-web + serde

```rust
use actix_web::{web, HttpResponse, Responder};
use serde::Deserialize;

#[derive(Deserialize)]
struct WorkflowPath {
    name: String,
}

async fn get_workflow(path: web::Path<WorkflowPath>) -> impl Responder {
    let workflow = db::get_workflow(&path.name);
    match workflow {
        Some(w) => HttpResponse::Ok().json(w),
        None => HttpResponse::NotFound().json(serde_json::json!({ "error": "Workflow not found" })),
    }
}
```

`actix-web` deserializes the path parameter into `WorkflowPath` via serde
before the handler runs. Invalid paths never reach the handler.

## Rationale

- **One definition, three consumers**: The schema drives TypeScript types,
  runtime validation, and the OpenAPI spec. No drift is possible.
- **Fail fast at the boundary**: Invalid requests are rejected before the
  handler body runs — the handler never sees malformed data.
- **Client ergonomics**: Generated OpenAPI specs are accurate, so client SDKs
  (e.g. `openapi-typescript`) produce types that match the server's actual
  behavior.
- **Cross-language consistency**: The pattern (schema → typed route →
  auto-generated spec) is identical in Hono, FastAPI, and actix-web. The
  framework changes; the discipline does not.

## Consequences

### Positive

- Zero-cost type safety for request/response cycles.
- Always-accurate OpenAPI documentation.
- Consistent error shapes across all endpoints.

### Negative

- Routes with non-JSON responses (file downloads, SSE streams, multipart
  uploads) require documented exceptions to the typed-builder pattern.
- Initial setup cost is higher than `app.get(path, handler)` — but the cost
  is paid once, while the benefit compounds on every request.

## Related Concepts

- [Type-Safe Data Interchange](type-safe-data-interchange.md) — the general
  principle this page applies to the HTTP route boundary specifically.
- [SDK Type Patterns](sdk-type-patterns.md) — consume the generated OpenAPI
  types on the client side; never duplicate them.
- [ESLint Composition API](eslint-composition-api.md) — lint rules that
  enforce `no-explicit-any` make typed route handlers the path of least
  resistance.
