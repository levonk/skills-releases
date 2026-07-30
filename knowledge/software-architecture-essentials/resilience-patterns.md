---
type: Practice
title: Resilience Patterns
description: Four classes of overload protection — internal concurrency limiters, connection poolers, RPC circuit breakers, and adaptive concurrency — all require a central choke point with metrics and a registry. No single library covers all four across all languages; use a service mesh for cross-language control plus per-language libraries for internal fan-out.
tags: [architecture, resilience, circuit-breaker, concurrency-limit, connection-pool, adaptive-concurrency, service-mesh, backpressure, envoy, istio, linkerd, hystrix, resilience4j, gobreaker, tower, polly, opossum, pybreaker]
date:
  created: "2026-07-29"
  knowledge-basis: "2026-07-29"
  last-used: "2026-07-29"
sources:
  - id: system-design-primer-resilience
    resource: "https://github.com/donnemartin/system-design-primer"
    title: "The System Design Primer — load balancing, back pressure, fail-over"
  - id: envoy-adaptive-concurrency
    resource: "https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/concurrency/adaptive_concurrency"
    title: "Envoy Adaptive Concurrency filter"
  - id: resilience4j-docs
    resource: "https://resilience4j.readme.io/"
    title: "Resilience4j — circuit breaker, bulkhead, rate limiter, retry"
  - id: hystrix-wiki
    resource: "https://github.com/Netflix/Hystrix/wiki"
    title: "Netflix Hystrix — latency and fault tolerance for distributed systems"
---

# Resilience Patterns

## The Choke-Point Principle

All overload protections share one architectural requirement: **a single,
authoritative place where work enters or leaves the system so you can measure
it, limit it, and apply backpressure.**

You cannot:

- Limit concurrency if you do not know how many things are running.
- Limit connections if you do not know who is dialing.
- Break circuits if you do not know which calls are failing.
- Adapt concurrency if you do not know latency and success rates.

A **registry + metrics + a choke point** is the shared foundation. Every
resilience tool sits at such a choke point:

- Hystrix wraps every RPC call.
- Envoy sits in front of every service.
- Adaptive concurrency lives in the mesh.
- Internal concurrency limiters wrap every fan-out site.

Centralization of control is not optional. Scatter the calls and you lose the
ability to measure, limit, and break.

## The Four Classes

| Class | Scope | What it prevents | Cross-language? |
|-------|-------|------------------|-----------------|
| **Internal Concurrency Limiters (ICL)** | In-process fan-out | Thread/goroutine/task exhaustion from unbounded parallelism | No — language-specific |
| **Connection Poolers (CP)** | Outbound transport | Socket exhaustion, slow-dial cascades, TCP port depletion | No — stack-specific |
| **RPC Circuit Breakers (RPC-CB)** | Outbound calls to a dependency | Cascading failure when a downstream is degraded | No — language-specific |
| **Adaptive Concurrency (AC)** | Inbound or mesh-level | Overload under variable latency — sheds load before the queue fills | Yes — mesh-level |

### 1. Internal Concurrency Limiters (ICL)

Limit how many units of work run concurrently **inside one process**. This is
the innermost defense. Without it, a single request that fans out to 1000
sub-tasks can exhaust the runtime's scheduler, memory, or file descriptors.

### 2. Connection Poolers (CP)

Limit and reuse outbound connections. Without pooling, every call dials a new
socket — slow under load, and fatal at high fan-out because TCP ports exhaust
(~65k per source IP).

### 3. RPC Circuit Breakers (RPC-CB)

Stop calling a dependency that is failing. After a threshold of errors or
timeouts, the breaker opens; calls fail fast instead of waiting. After a cool
down, a probe call tests whether the dependency has recovered.

### 4. Adaptive Concurrency (AC)

Adjust the concurrency limit dynamically based on observed latency and success
rate. Unlike a static limit, AC tightens when latency rises (the system is
saturated) and loosens when latency falls (headroom available). This is the
only class that responds to the system's live state rather than a configured
constant.

## No Universal Library

No single library handles all four classes across all languages. This is not a
gap in the ecosystem — it is structural:

- **Concurrency models differ.** Go has goroutines and channels. Java has
  thread pools and virtual threads. Rust has async executors and ownership
  rules. Node has an event loop and promises. Python has the GIL and asyncio.
  .NET has async/await and a thread pool. A universal concurrency limiter
  cannot exist across these models.
- **Networking stacks differ.** Go has built-in connection pooling. Node has
  none built in. Python's `requests` pools, but `asyncio` does not. Rust's
  `hyper`/`tokio` stack is fully manual. Java has Netty, HttpClient, OkHttp.
  A universal connection-pool limiter cannot exist across these stacks.
- **Failure semantics differ.** Exceptions, errors, panics, `Result<T, E>`.
  Sync, async, green threads. A universal circuit breaker cannot exist across
  these semantics.

## The Stack (What You Actually Need)

Cover all four classes with a **stack**, not a single library:

### Cross-language layer: Service Mesh

A service mesh (Envoy, Istio, Linkerd) is the closest thing to a universal
solution because it sits **outside** your code. It handles:

- Connection limits.
- Pending request limits.
- Retry budgets.
- Circuit breaking.
- Adaptive concurrency.
- Outlier detection.
- Timeouts.
- mTLS.
- Metrics.

It works for any language that speaks HTTP or TCP. **But it cannot handle
internal fan-out inside your code.** Only your language runtime can do that.

### Per-language layer: Internal libraries

| Language | ICL | Connection Pool | Circuit Breaker | Notes |
|----------|-----|-----------------|-----------------|-------|
| **Go** | `errgroup.SetLimit`, `golang.org/x/sync/semaphore` | `http.Transport` (built-in) | `gobreaker` (sony/gobreaker) | Transport pool is built in; tune `MaxIdleConnsPerHost` |
| **Java** | Resilience4j `Bulkhead` | OkHttp / Netty pools | Resilience4j `CircuitBreaker` | Resilience4j supersedes Hystrix (Netflix archived Hystrix) |
| **Rust** | `tokio::sync::Semaphore` | `hyper` client pool | `tower` middleware (`tower::limit`, `tower::retry`) | Tower composes all four as middleware layers |
| **Node** | `p-limit`, `bottleneck` | `agentkeepalive` | `opossum` (circuit breaker) | No built-in connection pooling; `agentkeepalive` is mandatory for HTTP |
| **Python** | `asyncio.Semaphore` | `aiohttp.TCPConnector` | `pybreaker` | `requests` pools by default; `asyncio` does not |
| **.NET** | `Channel<T>` + `SemaphoreSlim` | `HttpClientFactory` | `Polly` | `HttpClientFactory` manages pool lifetime; Polly handles CB + retry |

### Observability layer: OpenTelemetry

Combine **OpenTelemetry metrics** (cross-language) with the per-language
libraries above. This gives a consistent observability layer across all
services, even though the control layer remains language-specific.

## Decision Checklist

1. **Is the call crossing a process or network boundary?** Yes → the service
   mesh handles connection limits, circuit breaking, and adaptive concurrency
   at the choke point. No → you need an in-process ICL.
2. **Does the code fan out internally?** (One request triggers N sub-calls.)
   Yes → wrap the fan-out site in an ICL. The mesh cannot see internal
   parallelism.
3. **Is the dependency unreliable or slow under load?** Yes → add an RPC
   circuit breaker in code, and let the mesh handle outlier detection at the
   network level.
4. **Does load vary unpredictably?** Yes → enable adaptive concurrency in the
   mesh. Static limits under-provision at peak and over-provision at trough.
5. **Are you in a polyglot environment?** Yes → the service mesh is your
   cross-language control plane; accept that internal fan-out control stays
   per-language.
6. **Is there no service mesh?** Then every service must implement its own
   connection limits, circuit breakers, and timeouts in code. This is
   duplicative and error-prone — the strongest argument for adopting a mesh.

## Anti-Patterns

- **No choke point.** Calls scattered across the codebase with no central
  wrapper. You cannot measure, limit, or break what you cannot see.
- **Static concurrency limit only.** A fixed limit of 100 is wrong at both low
  load (over-provisioned) and high load (under-provisioned). Pair static limits
  with adaptive concurrency.
- **Circuit breaker without a retry budget.** A breaker that opens on 5 errors
  but allows unlimited retries on every call will retry-storm the downstream
  the moment it recovers. Use retry budgets (max retries per second) alongside
  breakers.
- **Connection pool sized for average load.** Pools must be sized for peak
  burst, not average. A pool of 10 on a service that bursts to 100 concurrent
  calls will queue 90 of them.
- **Relying on the mesh for internal fan-out.** The mesh sees network calls,
  not goroutines or async tasks. Internal fan-out without an ICL can exhaust
  the runtime even when the mesh reports green.

## See Also

- [Load Balancing and Reverse Proxy](load-balancing-and-proxy.md) — the
  service mesh handles east-west load balancing alongside circuit breaking.
- [Application Layer and Microservices](application-layer-microservices.md) —
  service mesh deployment and when to adopt one.
- [Asynchronism and Queues](asynchronism-and-queues.md) — back pressure is the
  queue-level analog of adaptive concurrency.
- [CAP, Consistency, and Availability](cap-consistency-availability.md) —
  availability patterns (fail-over, replication) complement resilience
  patterns (circuit breaking, shedding).
- [Cost-Aware System Design](cost-aware-system-design.md) — cap-and-shed is the
  cost analog of adaptive concurrency.
- [System Security Basics](system-security-basics.md) — mTLS and observability
  (OpenTelemetry) are shared concerns with the service mesh.
- [Tech Decision Risk Assessment](tech-decision-risk-assessment.md) — the risk
  hierarchy for evaluating whether to adopt a service mesh (level 6: running a
  3rd-party service) vs. per-language libraries (level 11-12: new 3rd-party
  package).

## Sources

- [The System Design Primer](https://github.com/donnemartin/system-design-primer)
  — load balancing, back pressure, fail-over.
- [Envoy Adaptive Concurrency](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/concurrency/adaptive_concurrency)
  — mesh-level adaptive concurrency filter.
- [Resilience4j](https://resilience4j.readme.io/) — Java resilience primitives
  (circuit breaker, bulkhead, rate limiter, retry).
- [Netflix Hystrix](https://github.com/Netflix/Hystrix/wiki) — the original
  circuit breaker library (archived; use Resilience4j for new work).
