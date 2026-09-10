# Directory Update Log

## 2026-09-04

* **Initialization**: Created the `go-best-practices` knowledge bundle to consolidate modern Go programming practices from the JetBrains go-modern-guidelines project.
* **Creation**: Authored 12 concept pages covering Go 1.0 through Go 1.27.
  - [collections-slices-maps.md](collections-slices-maps.md) — slices.Contains, slices.Sort, slices.SortFunc, slices.Index, slices.Reverse, slices.Compact, slices.Clone, slices.Clip, slices.Max/Min, maps.Clone, maps.Copy, maps.DeleteFunc, maps.Keys/Values iter, slices.Collect, slices.Sorted, min/max builtins, clear builtin (Go 1.21-1.23)
  - [loops-iterators.md](loops-iterators.md) — range over int, loop variable capture semantics (Go 1.22)
  - [error-handling.md](error-handling.md) — errors.Is, errors.Join, errors.AsType[T] (Go 1.13-1.26)
  - [context-patterns.md](context-patterns.md) — context.AfterFunc, context.WithTimeoutCause/WithDeadlineCause, context.WithCancelCause, testing.T.Context (Go 1.20-1.24)
  - [strings-bytes.md](strings-bytes.md) — strings.Cut/bytes.Cut, strings.CutPrefix/CutSuffix, strings.CutLast/bytes.CutLast, strings.Clone/bytes.Clone, strings.SplitSeq (Go 1.18-1.27)
  - [sync-concurrency.md](sync-concurrency.md) — sync.OnceFunc/OnceValue, sync.WaitGroup.Go, atomic types (Go 1.19-1.25)
  - [json-encoding.md](json-encoding.md) — encoding/json/v2, json omitzero tag (Go 1.24-1.27)
  - [types-generics.md](types-generics.md) — any, generic methods, promoted field literals, reflect.TypeFor, new expression (Go 1.18-1.27)
  - [testing-benchmarks.md](testing-benchmarks.md) — testing.T.Context, testing B.Loop (Go 1.24)
  - [http-routing.md](http-routing.md) — http.ServeMux method-aware patterns and path values (Go 1.22)
  - [fmt-utilities.md](fmt-utilities.md) — fmt.Appendf, cmp.Or (Go 1.19-1.22)
  - [time-utilities.md](time-utilities.md) — time.Until, time.Since, time.Tick GC, stdlib uuid, url.Clone (Go 1.0-1.27)
* **Creation**: Established [overview.md](overview.md) synthesis and [index.md](index.md) directory listing.
* **Note**: Concepts extracted from FEATURES.md in JetBrains/go-modern-guidelines (50+ guidelines covering Go 1.0 through 1.27).
