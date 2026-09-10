---
okf_version: "0.2"
---

# Go Best Practices

A compounding knowledge base documenting modern Go programming practices —
collections, loops, error handling, context patterns, strings and bytes,
concurrency, JSON encoding, generics, testing, HTTP routing, formatting
utilities, and time utilities. Each concept captures specific guidelines sourced
from the JetBrains go-modern-guidelines project, covering Go 1.0 through Go 1.27.

## Concepts

* [Overview](overview.md) - Synthesis of the full Go best-practice set
* [Collections: Slices and Maps](collections-slices-maps.md) - slices.Contains, slices.Sort, slices.SortFunc, slices.Index, slices.Reverse, slices.Compact, slices.Clone, slices.Clip, slices.Max/Min, maps.Clone, maps.Copy, maps.DeleteFunc, maps.Keys/Values iter, slices.Collect, slices.Sorted, min/max builtins, clear builtin (Go 1.21-1.23)
* [Loops and Iterators](loops-iterators.md) - range over int, loop variable capture semantics (Go 1.22)
* [Error Handling](error-handling.md) - errors.Is, errors.Join, errors.AsType[T] (Go 1.13-1.26)
* [Context Patterns](context-patterns.md) - context.AfterFunc, context.WithTimeoutCause/WithDeadlineCause, context.WithCancelCause, testing.T.Context (Go 1.20-1.24)
* [Strings and Bytes](strings-bytes.md) - strings.Cut/bytes.Cut, strings.CutPrefix/CutSuffix, strings.CutLast/bytes.CutLast, strings.Clone/bytes.Clone, strings.SplitSeq (Go 1.18-1.27)
* [Sync and Concurrency](sync-concurrency.md) - sync.OnceFunc/OnceValue, sync.WaitGroup.Go, atomic types (Go 1.19-1.25)
* [JSON Encoding](json-encoding.md) - encoding/json/v2, json omitzero tag (Go 1.24-1.27)
* [Types and Generics](types-generics.md) - any, generic methods, promoted field literals, reflect.TypeFor, new expression (Go 1.18-1.27)
* [Testing and Benchmarks](testing-benchmarks.md) - testing.T.Context, testing B.Loop (Go 1.24)
* [HTTP Routing](http-routing.md) - http.ServeMux method-aware patterns and path values (Go 1.22)
* [Fmt Utilities](fmt-utilities.md) - fmt.Appendf, cmp.Or (Go 1.19-1.22)
* [Time and Utilities](time-utilities.md) - time.Until, time.Since, time.Tick GC, stdlib uuid, url.Clone (Go 1.0-1.27)
