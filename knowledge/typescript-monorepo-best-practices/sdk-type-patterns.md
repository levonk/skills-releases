---
type: Practice
title: SDK Type Patterns — Import SDK Types Directly, No Duplicate Interfaces
description: When integrating external SDKs, import and use the SDK's own types directly — never define duplicate interfaces that shadow the SDK's types, never use `as any` to bridge the gap, and re-export SDK types through a thin boundary module so the rest of the codebase never imports the SDK directly.
tags: [typescript, sdk, type-safety, import-type, no-duplicate-types, sdk-interop, boundary-module]
date:
  created: "2026-08-10"
  knowledge-basis: "2026-08-10"
  last-used: "2026-08-10"
sources:
  - id: archon-sdk-type-patterns
    resource: https://github.com/coleam00/archon/blob/main/AGENTS.md
    title: 'archon AGENTS.md — SDK Type Patterns section'
  - id: archon-providers-types
    resource: https://github.com/coleam00/archon/blob/main/packages/providers/src/types.ts
    title: 'archon packages/providers/src/types.ts — contract layer with zero SDK deps'
---

# SDK Type Patterns — Import SDK Types Directly, No Duplicate Interfaces

## Failure Mode

When integrating an external SDK (Claude Agent SDK, Stripe SDK, AWS SDK), the
developer defines a local interface that "represents" the SDK's type. The local
interface has a subset of the SDK's fields, slightly different names, or
slightly different types. Every SDK update risks a silent mismatch: the SDK
adds a required field, the local interface doesn't include it, and the code
that uses the local interface never passes it through.

The `as any` cast bridges the gap between the local interface and the SDK's
actual type — but it also disables all type checking at the bridge point.
When the SDK changes its response shape, the cast hides the breakage until
runtime.

Symptoms:

1. **Duplicate interfaces**: `interface MyQueryOptions { cwd: string }` shadows
   the SDK's `Options` type with a subset of its fields.
2. **`as any` bridges**: `query({ prompt, options: options as any })` — the
   cast disables type checking, so SDK changes are invisible.
3. **Stale types**: The SDK adds a new required field; the local interface
   doesn't include it; code that constructs the local interface omits it;
   the SDK call fails at runtime.
4. **SDK coupling spread**: Every module that uses the SDK imports it
   directly, making the SDK impossible to swap or mock without touching every
   file.

## Practice

### Import SDK Types Directly

Use `import type` to bring the SDK's types into your code. Construct SDK
objects using those types directly. Never define a parallel interface that
duplicates the SDK's shape.

```typescript
// ✅ Correct — import and use SDK types directly
import { query, type Options } from '@anthropic-ai/claude-agent-sdk';

const options: Options = {
  cwd,
  permissionMode: 'bypassPermissions',
};

// ❌ Avoid — duplicate interface shadows the SDK's type
interface MyQueryOptions {
  cwd: string;
}
const options: MyQueryOptions = { cwd };
query({ prompt, options: options as any }); // `as any` hides mismatches
```

### Thin Boundary Module

If you need to decouple your codebase from the SDK (for testing, swapping
providers, or isolating SDK deps), define a thin boundary module that:

1. Imports the SDK types and re-exports them.
2. Defines a contract interface that the rest of the codebase depends on
   (not the SDK types directly).
3. Contains all SDK-specific code in one place — the rest of the codebase
   never imports the SDK.

The contract interface should be SDK-agnostic (it describes *what* the
provider does, not *how* the SDK does it). The boundary module implements
the contract using the SDK's types internally.

### Type Assertions After Validation

When the SDK returns an opaque or `any`-typed response, use a type assertion
only after you have validated the shape at runtime (see
[Type-Safe Data Interchange](type-safe-data-interchange.md)):

```typescript
// ✅ Correct — validate first, then assert
const result = responseSchema.safeParse(rawResponse);
if (!result.success) throw new Error('Invalid response');
const data = result.data; // already typed, no assertion needed

// ❌ Avoid — blind assertion without validation
const message = msg as { message: { content: ContentBlock[] } };
```

## Concrete Instances

### TypeScript / Claude Agent SDK

```typescript
// boundary module: packages/providers/src/claude/types.ts
import type { Options, ContentBlock } from '@anthropic-ai/claude-agent-sdk';

// Re-export SDK types for internal use
export type { Options, ContentBlock };

// Contract interface — SDK-agnostic, no SDK imports in the signature
export interface IAgentProvider {
  sendQuery(options: SendQueryOptions): AsyncIterable<MessageChunk>;
}
```

The rest of the codebase depends on `IAgentProvider`, not on the Claude SDK.
The Claude provider implementation imports the SDK and implements the
contract. Swapping to a different SDK (e.g. Codex) means writing a new
provider implementation — no other file changes.

### Rust / SDK FFI Bindings

```rust
// The SDK's types are defined in the SDK crate; import them, don't redefine
use some_sdk::{Client, ClientConfig, Response};

fn create_client() -> Client {
    let config = ClientConfig::builder()
        .timeout(std::time::Duration::from_secs(30))
        .build();
    Client::new(config)
}

// Define a trait (contract) that abstracts over the SDK
trait AgentProvider {
    async fn send_query(&self, prompt: &str) -> Result<String>;
}

struct SdkProvider { client: Client }

impl AgentProvider for SdkProvider {
    async fn send_query(&self, prompt: &str) -> Result<String> {
        let response: Response = self.client.query(prompt).await?;
        Ok(response.text)
    }
}
```

The `Response` type comes from the SDK crate. The `AgentProvider` trait is
SDK-agnostic. The rest of the codebase depends on the trait, not on `Client`.

### Python / SDK Type Stubs

```python
from anthropic import Anthropic
from anthropic.types import Message, ContentBlock

# Use SDK types directly — never redefine
def create_message(client: Anthropic, prompt: str) -> Message:
    return client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=1024,
        messages=[{"role": "user", "content": prompt}],
    )

# The return type is the SDK's Message type, not a local duplicate
def extract_text(msg: Message) -> str:
    for block in msg.content:
        if isinstance(block, ContentBlock) and block.type == "text":
            return block.text
    return ""
```

Python SDK type stubs (via `py.typed` marker) provide the same static type
information that TypeScript SDKs provide. Import and use them; never define
a `TypedDict` that shadows the SDK's model.

## Rationale

- **No drift**: When you use the SDK's types directly, SDK updates propagate
  automatically. A new required field surfaces as a type error, not a
  runtime crash.
- **No `as any`**: When the types match, there is no need for unsafe casts.
  The type checker catches mismatches at compile time.
- **Boundary isolation**: A thin boundary module lets you swap SDKs, mock
  providers in tests, and isolate SDK dependency weight — without the rest
  of the codebase knowing which SDK is behind the boundary.
- **Cross-language consistency**: The pattern (import SDK types, define a
  contract trait/interface, isolate SDK code in one module) applies
  identically in TypeScript, Rust, and Python.

## Consequences

### Positive

- SDK updates are type-checked automatically — no manual sync of duplicate
  interfaces.
- `as any` casts are eliminated at the SDK boundary.
- Provider swapping and mocking are localized to one boundary module.

### Negative

- The boundary module adds a layer of indirection — but this is the cost of
  decoupling, and it pays for itself the first time you swap or mock a
  provider.
- SDK types can be complex or poorly documented; `import type` brings the
  full complexity into your type namespace. Mitigate by re-exporting only
  the types the codebase actually uses.

## Related Concepts

- [Type-Safe Data Interchange](type-safe-data-interchange.md) — validate SDK
  responses at the boundary before trusting their types.
- [Linter Zero-Tolerance](linter-zero-tolerance.md) — `no-explicit-any` is
  enforceable because SDK types provide the correct types that replace `any`.
- [Typed API Route Registration](typed-api-route-registration.md) — the
  generated OpenAPI client types are an SDK; consume them the same way.
