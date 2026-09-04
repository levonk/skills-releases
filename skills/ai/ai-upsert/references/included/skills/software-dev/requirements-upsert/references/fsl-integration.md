# FSL Integration — Formal Verification for Provability-Critical Requirements

This reference documents how FSL (AI-Native Formal Specification Language) is
integrated into the requirements-upsert skill for the provability-critical
subset of requirements. It covers what FSL is, when to use it, the
write→verify→repair loop, installation (with a verified Docker fallback),
syntax overview, spec placement, a working example, and how FSL relates to
the other formal languages in the stack.

## 1. What FSL Is

FSL (AI-Native Formal Specification Language) is a domain-specific language
for specifying system behavior that can be machine-verified with Z3 bounded
model checking. The `fslc` compiler/verifier:

- Parses `.fsl` specs (Lark grammar)
- Translates behavioral properties into Z3 SMT constraints
- Runs bounded model checking (BMC) and k-induction to prove properties or
  find counterexamples
- Emits JSON diagnostics with counterexample traces, solver statistics, and
  verification results
- Generates test scaffolds from verified specs (`fslc scenarios`)

When a property is violated, FSL returns a **counterexample** — a concrete
trace of states and transitions that reaches the violating condition. This
enables a write→verify→repair loop: write the spec, verify, read the
counterexample if one exists, repair the spec or the requirement, re-verify.

FSL is used **only** for the provability-critical subset of requirements —
those where a bug would be catastrophic. It is not a general-purpose
requirements format.

## 2. When to Use FSL (and When NOT To)

### USE FSL for

- **Idempotency guarantees** — e.g., a payment API that must not double-charge
  on retry
- **Money-moving logic** — e.g., transfer, refund, settlement flows where
  incorrect state transitions cause financial loss
- **Auth / permission checks** — e.g., access control state machines where a
  missing transition grants unauthorized access
- **Concurrency safety** — e.g., distributed lock acquisition, resource
  arbitration where race conditions corrupt state
- **Safety-critical invariants** — e.g., medical device state machines,
  emergency shutdown sequences

### DO NOT USE FSL for

- **UI requirements** — layout, interaction, accessibility (EARS is sufficient)
- **Documentation requirements** — content, structure, tone
- **General feature logic** — most CRUD operations, list views, filters
- **Most requirements** — EARS-constrained prose + Gherkin acceptance criteria
  is sufficient for the vast majority of requirements

### Cost / benefit

FSL adds a parallel `.fsl` spec that must be maintained alongside the
requirement. Every change to the requirement's behavioral properties requires
a corresponding change to the `.fsl` spec and a re-verification run. This is
only worth it when a bug in the requirement would be catastrophic — financial
loss, security breach, safety incident, or data corruption. For ordinary
requirements, the maintenance cost exceeds the verification benefit.

## 3. The Write→Verify→Repair Loop

The core FSL workflow is a tight loop between spec authoring and machine
verification:

1. **Write the `.fsl` spec** alongside the requirement. The spec lives at
   `internal-docs/reqs/current/{proj}/{module}/{proj}_{module}_{slug}.fsl`
   (see [Parallel .fsl Spec Placement](#6-parallel-fsl-spec-placement)).

2. **Run `fslc verify`** via Docker (see
   [Installation](#4-installation-3-tier-strategy)):
   ```bash
   docker run --rm \
     -v /tmp/fslc-linux-x64:/usr/local/bin/fslc:ro \
     -v "$(pwd)":/work \
     -w /work \
     ubuntu:24.04 \
     fslc verify spec.fsl --engine induction --deadlock ignore
   ```

3. **If `result: "proved"`** — the spec is consistent. All policies and goals
   hold within the bounded instance count. Done.

4. **If `result: "counterexample"`** — read the JSON trace in the diagnostics
   output. The trace shows the exact sequence of states and transitions that
   violates a policy or goal. Identify the violating state, then either:
   - **Repair the spec** — the spec is wrong (missing transition, wrong
     policy); fix it and re-verify.
   - **Repair the requirement** — the spec is correct and reveals a flaw in
     the requirement's intended behavior; update the requirement and the spec
     together, then re-verify.

5. **If `result: "error"`** (parse or type error) — fix the FSL syntax or type
   error and re-verify. The error message points to the line and column.

6. **Generate test scaffolds** — once the spec is proved, run
   `fslc scenarios spec.fsl` to generate test scaffolds from the verified
   properties. Task Verify commands for this requirement should reference
   these FSL-generated scenarios rather than re-deriving test cases manually.

## 4. Installation (3-Tier Strategy)

FSL verification requires the `fslc` binary. Three installation tiers are
available, tried in order.

### Tier 1 — Native binary (NOT available on Intel macOS)

FSL v4.4.1 explicitly rejects Intel macOS (x86_64). Only Apple Silicon macOS
is supported natively. If you are on Apple Silicon, check the latest release
at <https://github.com/ymm-oss/fsl/releases> for a macOS binary. As of v4.4.1,
no macOS binary was published for Intel x86_64.

If a native macOS binary is available for your architecture, download it,
make it executable, and run `fslc --version` to confirm. This is the fastest
path — no container overhead.

### Tier 2 — Docker container (VERIFIED WORKING)

This tier was tested and confirmed working with FSL v4.4.1 on an Intel macOS
host. The Linux x64 binary runs inside an `ubuntu:24.04` container (glibc
2.39+). The binary bundles Z3 4.16 — no separate solver install needed.

```bash
# Download the Linux x64 binary + checksum
curl -fsSL -o /tmp/fslc-linux-x64 \
  "https://github.com/ymm-oss/fsl/releases/download/v4.4.1/fslc-linux-x64"
curl -fsSL -o /tmp/fslc-linux-x64.sha256 \
  "https://github.com/ymm-oss/fsl/releases/download/v4.4.1/fslc-linux-x64.sha256"

# Verify checksum
cd /tmp && shasum -a 256 -c fslc-linux-x64.sha256

# Make executable
chmod +x /tmp/fslc-linux-x64

# Run fslc via Docker (ubuntu:24.04 has glibc 2.39+)
docker run --rm \
  -v /tmp/fslc-linux-x64:/usr/local/bin/fslc:ro \
  -v "$(pwd)":/work \
  -w /work \
  ubuntu:24.04 \
  fslc verify spec.fsl --engine induction --deadlock ignore
```

The container is ephemeral (`--rm`) — no Dockerfile or persistent image is
needed. JSON diagnostics flow back through stdout. The working directory is
mounted at `/work`, so relative paths in the spec resolve correctly.

**No devbox.json change required.** The Docker approach uses the host's Docker
installation, not the devbox environment. Do not add `fslc` to `devbox.json`
when using Tier 2.

### Tier 3 — Python pip (unverified)

FSL may have a Python package distribution. This tier was not verified — the
package name on PyPI may differ from `fsl`. Check
<https://github.com/ymm-oss/fsl> for the canonical install path.

```bash
# FSL may have a Python package — check PyPI
pip install fsl
# or via uv:
uv tool install fsl
```

This pulls Lark + Z3 as Python dependencies. Slower than the native binary
but works anywhere Python + pip work. If this is the chosen path and both
Tier 1 and Tier 2 are unavailable, add `fsl` to `devbox.json` so the
environment reproducibly includes it.

### Decision rule

1. Try **Tier 1** first (Apple Silicon macOS only). If a native binary is
   available, use it — fastest, no container overhead.
2. If on Intel macOS or Tier 1 fails, use **Tier 2** (Docker). This is the
   verified fallback for Intel macOS hosts.
3. If Docker is not available, try **Tier 3** (pip). If Tier 3 is the chosen
   path, add `fsl` to `devbox.json`.
4. If all three tiers fail, mark the FSL integration as `[!]` blocked in the
   requirement's Verification table, with the specific failure mode recorded
   in the Rationale field.

## 5. FSL Syntax Overview

FSL v4.x uses a declarative grammar (parsed by Lark). The key constructs:

| Construct | Purpose |
|-----------|---------|
| `business <Name> { ... }` | Top-level spec block — contains all entities, processes, policies, goals |
| `actor <Name>, <Name>` | Participants that drive transitions |
| `entity <Name>` | A domain entity with a state machine |
| `process <Entity> { ... }` | State machine definition for an entity |
| `stages <S1>, <S2>, ...` | Enumerate the states of the process |
| `initial <State>` | The starting state |
| `transition <label> <From> -> <To> by <Actor>` | A state transition labeled with its trigger and actor |
| `kpi <name> = count <Entity> in <State>` | Quantitative metric over entity states |
| `policy <ID> "description" <temporal formula>` | A property that must always hold |
| `goal <ID> "description" <reachability formula>` | A property that must be achievable |
| `verify { instances <Entity> = <N> }` | Verification config — bounded instance count for BMC |

Temporal formulas use LTL-style operators:
- `every <Entity> in <State> must eventually be <State>` — liveness
- `some <Entity> can reach <State>` — reachability (goals)

### Minimal example

```fsl
business CancelFlow {
  actor Customer, System
  entity Sub
  process Sub {
    stages Active, CancelRequested, OfferShown, Retained, Churned
    initial Active
    transition request_cancel Active          -> CancelRequested by Customer
    transition show_offer     CancelRequested -> OfferShown      by System
    transition accept_offer   OfferShown      -> Retained        by Customer
    transition decline_offer  OfferShown      -> Churned         by Customer
  }
  kpi churned  = count Sub in Churned
  kpi retained = count Sub in Retained
  policy POL-1 "A cancellation request must always be met with a retention offer"
    every Sub in CancelRequested must eventually be OfferShown
  policy POL-2 "A shown offer must always be resolved by acceptance or decline"
    every Sub in OfferShown must eventually be Retained or Churned
  goal CanRetain "There exists a case that reaches retention via a retention offer"
    some Sub can reach Retained
  goal CanChurn "There also exists a case that declines and reaches cancellation"
    some Sub can reach Churned
}
verify {
  instances Sub = 3
}
```

## 6. Parallel .fsl Spec Placement

FSL specs live alongside their requirements in the ledger directory structure:

| Artifact | Path |
|----------|------|
| Requirement | `internal-docs/reqs/current/{proj}/{module}/{proj}_{module}_{slug}.md` |
| FSL spec | `internal-docs/reqs/current/{proj}/{module}/{proj}_{module}_{slug}.fsl` |

The `.fsl` file is **optional**. Only requirements in the provability-critical
subset (idempotency, money-moving, auth, concurrency, safety-critical) have
one. The requirement's Verification table should reference the `.fsl` spec and
the `fslc verify` command when one exists.

## 7. Example .fsl Spec

The following spec models a subscription cancellation flow with retention
offers. It was verified to work with `fslc` v4.4.1 via the Docker Tier 2
approach described above.

```fsl
business CancelFlow {
  actor Customer, System
  entity Sub
  process Sub {
    stages Active, CancelRequested, OfferShown, Retained, Churned
    initial Active
    transition request_cancel Active          -> CancelRequested by Customer
    transition show_offer     CancelRequested -> OfferShown      by System
    transition accept_offer   OfferShown      -> Retained        by Customer
    transition decline_offer  OfferShown      -> Churned         by Customer
  }
  kpi churned  = count Sub in Churned
  kpi retained = count Sub in Retained
  policy POL-1 "A cancellation request must always be met with a retention offer"
    every Sub in CancelRequested must eventually be OfferShown
  policy POL-2 "A shown offer must always be resolved by acceptance or decline"
    every Sub in OfferShown must eventually be Retained or Churned
  goal CanRetain "There exists a case that reaches retention via a retention offer"
    some Sub can reach Retained
  goal CanChurn "There also exists a case that declines and reaches cancellation"
    some Sub can reach Churned
}
verify {
  instances Sub = 3
}
```

**Verify command:**

```bash
docker run --rm \
  -v /tmp/fslc-linux-x64:/usr/local/bin/fslc:ro \
  -v "$(pwd)":/work \
  -w /work \
  ubuntu:24.04 \
  fslc verify cancel_flow.fsl --engine induction --deadlock ignore
```

**Expected result:** `"result": "proved"` — all policies and goals hold
within the bounded instance count of 3. The JSON diagnostics include solver
statistics, verification time, and per-property results.

### Adapting for an idempotency requirement

To model an idempotency guarantee (e.g., a payment API that must not
double-charge on retry), define the entity's state machine so that the
"charge" transition can only fire once per request ID:

```fsl
business PaymentIdempotency {
  actor Client, PaymentService
  entity PaymentRequest
  process PaymentRequest {
    stages Pending, Charged, DuplicateDetected
    initial Pending
    transition charge          Pending         -> Charged          by PaymentService
    transition retry_charge    Charged         -> DuplicateDetected by Client
    transition return_idempotent DuplicateDetected -> Charged      by PaymentService
  }
  policy IDP-1 "A payment request must be charged exactly once"
    every PaymentRequest in Pending must eventually be Charged
  policy IDP-2 "A retried charge must not result in a second charge"
    every PaymentRequest in DuplicateDetected must eventually be Charged
  verify {
    instances PaymentRequest = 2
  }
}
```

This spec asserts that a retried charge returns the original result
(`DuplicateDetected → Charged`) rather than creating a new charge. Verify it
with the same `fslc verify` command.

## 8. Relationship to Other Tools

### FSL vs EARS

EARS constrains **authoring syntax** for all requirements — every requirement
uses one of five fixed sentence templates with **SHALL**. FSL verifies
**internal consistency** for the provability-critical subset only — it proves
that the behavioral properties of a spec are free of contradictions within a
bounded scope. They operate at different layers and do not overlap:

- EARS: every requirement (authoring discipline)
- FSL: provability-critical subset only (machine-checked consistency)

### FSL scenarios vs task Verify commands

If a requirement has a `.fsl` spec, `fslc scenarios` generates test scaffolds
from the verified properties. Task Verify commands for that requirement should
**reference** the FSL-generated scenarios, not re-derive test cases manually.
The `.fsl` spec is the source of truth for provability-critical requirements;
Verify commands call into `fslc` rather than duplicating the proof logic. See
[formal-languages-overview.md §6.5](formal-languages-overview.md) for the
non-redundancy rule.

### FSL is NOT a replacement for the requirements ledger

FSL is a **parallel verification artifact** for a subset of requirements. The
requirements ledger (Markdown files with EARS-constrained statements) remains
the single source of truth for all requirements. The `.fsl` spec is an
optional companion that provides machine-checked proof for requirements where
that proof is worth the maintenance cost. Requirements without a `.fsl` spec
are still valid — they are simply verified through EARS + Gherkin + scripts
rather than Z3 bounded model checking.
