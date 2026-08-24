---
type: Practice
title: Consulting Problem-Solving Frameworks
description: The McKinsey-style consulting problem-solving toolkit — the 7-step process (define, disaggregate, prioritize, workplan, analyze, synthesize, communicate), hypothesis-driven problem solving with Day 1 Answers and falsifiable hypotheses, issue trees (driver, process, option, hypothesis) with MECE branch design, the 80/20 prioritization scoring model, MECE validation gates, and strategic analysis frameworks (Porter's Five Forces, McKinsey 7S, SWOT, BCG Matrix) with accurate attribution. Cross-references the Minto Pyramid Principle for communication and Case Interviews for the interview format.
tags: [consulting, problem-solving, hypothesis-driven, issue-tree, mece, 80-20, pareto, porter-five-forces, mckinsey-7s, swot, bcg-matrix, strategic-analysis, structured-thinking, case-interview]
date:
  created: "2026-08-21"
  knowledge-basis: "2026-08-21"
  last-used: "2026-08-21"
sources:
  - id: minto-pyramid-principle
    resource: "Barbara Minto, The Pyramid Principle (2009 revised edition)"
    title: "The Pyramid Principle: Logic in Writing and Thinking — MECE, issue trees, and hypothesis-driven thinking originated in Minto's work at McKinsey"
  - id: fleurytian-awesome-claude-skills
    resource: "https://github.com/fleurytian/awesome-claude-skills"
    title: "fleurytian/awesome-claude-skills (mckinsey-consultant) — staged problem-solving workflow, problem boundary definition, issue tree construction, hypothesis formation, dummy page design, page dependency types"
  - id: santos-sanz-lifeskills-hypothesis
    resource: "https://github.com/santos-sanz/lifeskills"
    title: "santos-sanz/lifeskills (consulting-hypothesis-driven-80-20) — falsifiable hypothesis format (If X then Y because Z), confirming/disconfirming signals, kill thresholds, 80/20 scoring model (Impact × Confidence / Effort × Speed), parallel testing rules, kill documentation"
  - id: santos-sanz-lifeskills-issue-tree
    resource: "https://github.com/santos-sanz/lifeskills"
    title: "santos-sanz/lifeskills (consulting-issue-tree-mece) — tree type selection (driver/process/option/hypothesis), starter formulas, branch design rules, MECE validation gates (mutual exclusivity, collective exhaustiveness, level integrity, clarity, usefulness), failure patterns"
  - id: uxderrick-mece-skill
    resource: "https://github.com/uxderrick/mece-skill"
    title: "uxderrick/mece-skill — MECE validation and decomposition modes, numeric scoring model, self-test before presenting, domain-aware validation, boundary definition, decomposition depth limits"
  - id: kangarooking-cognitive-dividend
    resource: "https://github.com/kangarooking/cognitive-dividend-skill"
    title: "kangarooking/cognitive-dividend-skill (structured-thinking) — purpose determines structure, planar cuts, two-way/three-way splits, structured thinking vs systems thinking, boundary conditions, failure modes"
  - id: yoichiojima-2-consultant
    resource: "https://github.com/yoichiojima-2/consultant"
    title: "yoichiojima-2/consultant — MECE common structures table, issue tree examples, hypothesis tree vs issue tree comparison, McKinsey 7-step problem solving process, Day 1 Answer, Porter's Five Forces, McKinsey 7S, SWOT, BCG Matrix"
  - id: ericgandrade-claude-superskills
    resource: "https://github.com/ericgandrade/claude-superskills"
    title: "ericgandrade/claude-superskills (mckinsey-strategist) — parallel framework analysis (SWOT, VRIO, 7S, second-order thinking, impact vs effort), executive synthesis, second-order consequence chains"
  - id: abdullah4ai-mckinsey-research
    resource: "https://github.com/Abdullah4AI/mckinsey-research"
    title: "Abdullah4AI/mckinsey-research — 12-prompt parallel research workflow, adaptive stage logic (idea/startup/growth/mature), diamond gates, batch dependency management"
  - id: fzfclee-consulting-skills
    resource: "https://github.com/fzfclee/consulting-skills"
    title: "fzfclee/consulting-skills (issue-tree) — decision-relevant core question, evidence plan template, priority analysis with decision impact, quality gate with disconfirming checks"
  - id: asgard-ai-platform-skills
    resource: "https://github.com/asgard-ai-platform/skills"
    title: "asgard-ai-platform/skills (meta-structured-problem) — IRON LAW (MECE or it's not structured), hypothesis-driven approach steps, 80/20 rule application, gotchas (good enough MECE, hypothesis ≠ confirmation bias, structured ≠ slow, know when to stop)"
  - id: synthesized-practice
    resource: "general industry practice"
    title: "Synthesized from established consulting and strategic analysis practices"
---

# Consulting Problem-Solving Frameworks

The Minto Pyramid Principle ([minto-pyramid-principle.md](minto-pyramid-principle.md))
covers **communication** — how to structure the answer once you have it. This
page covers **problem-solving** — the analytical workflow that produces the
answer in the first place. The two are complementary: the problem-solving
process generates the insight, and the Pyramid Principle communicates it.

In the hiring pipeline, these frameworks matter for **case interviews**
([case-interview.md](case-interview.md)), strategy and product management
roles, and any role where structured decomposition of ambiguous problems is
the core job. They also apply to on-the-job performance: the same
hypothesis-driven discipline that passes a case interview is what makes a
consultant, PM, or strategy operator effective once hired.

## Attribution: What Is and Isn't McKinsey

Several frameworks in this page are commonly associated with McKinsey but
have distinct origins. Accurate attribution matters — misattributing a
framework signals shallow understanding, which hurts credibility in
interviews and on the job.

| Framework | Origin | Attribution |
|-----------|--------|-------------|
| MECE | Barbara Minto, McKinsey, 1960s | Minto's contribution; widely adopted at McKinsey |
| Pyramid Principle | Barbara Minto, McKinsey, 1970s | Minto's communication method |
| Issue Trees | Standard consulting methodology | Practiced at McKinsey, BCG, Bain, and other firms |
| Hypothesis-Driven Problem Solving | Scientific method applied to business | McKinsey popularized the "Day 1 Answer" practice |
| 80/20 Rule (Pareto Principle) | Vilfredo Pareto, 1896 | McKinsey applies it to analysis prioritization |
| McKinsey 7S Framework | Tom Peters & Robert Waterman, McKinsey, 1980s | McKinsey-originated |
| Porter's Five Forces | Michael Porter, Harvard Business School, 1979 | **Not McKinsey** — Porter is HBS faculty |
| SWOT Analysis | Albert Humphrey, Stanford Research Institute, 1960s | **Not McKinsey** — SRI origin |
| BCG Growth-Share Matrix | Boston Consulting Group, 1970s | **Not McKinsey** — BCG-originated, competitor firm |
| VRIO Framework | Jay Barney, 1991 | **Not McKinsey** — academic resource-based view |

The synthesis below integrates these frameworks into a practical
problem-solving workflow. Where a framework is not McKinsey-originated, it is
labeled as such.

## The 7-Step Problem-Solving Process

McKinsey's core problem-solving methodology is a seven-step process that
chains from problem definition through communication. Each step has a
specific output and quality gate.

```
1. DEFINE THE PROBLEM
   └── What exactly are we trying to solve? (specific, measurable)
                    ↓
2. DISAGGREGATE / STRUCTURE
   └── Build an issue tree (MECE decomposition)
                    ↓
3. PRIORITIZE ISSUES
   └── Focus on high-impact, testable branches (80/20)
                    ↓
4. BUILD WORKPLAN & ASSIGN
   └── Who does what analysis by when?
                    ↓
5. CONDUCT ANALYSES
   └── Gather data, test hypotheses
                    ↓
6. SYNTHESIZE FINDINGS
   └── So what? Develop recommendations
                    ↓
7. COMMUNICATE / BUILD BUY-IN
   └── Present using the Pyramid Principle
```

### Step 1: Define the Problem

A well-defined problem is specific, measurable, and decision-relevant. The
problem statement should answer:

- **What** is the undesirable situation? (the current state, R1)
- **What** is the desired state? (the target, R2)
- **Why** does the gap matter? (the business consequence)
- **Who** owns the decision? (the stakeholder who will act)
- **When** is the decision needed? (the deadline)

The Minto page covers problem definition (R1/R2) in detail — see
[minto-pyramid-principle.md](minto-pyramid-principle.md) § Problem Definition.
The key addition here is the **decision-relevance test**: if the problem
statement doesn't map to a decision someone will make, it is a research
question, not a consulting problem. Reframe it.

### Step 2: Disaggregate — Build an Issue Tree

An issue tree decomposes the problem into component issues, MECE at each
level, until each leaf is actionable. See [Issue Trees](#issue-trees) below.

### Step 3: Prioritize — Apply the 80/20 Rule

Not all branches are worth analyzing. Prioritize by impact and feasibility
using the [80/20 scoring model](#the-8020-prioritization-model). The goal is
to focus analysis effort on the 20% of branches that drive 80% of the answer.

### Step 4: Build the Workplan

For each prioritized branch, define:

- **Key question** — what must this analysis answer?
- **Required data** — what evidence is needed?
- **Owner** — who is responsible?
- **Deadline** — when is the analysis due?
- **Decision signal** — what result would confirm or disconfirm the hypothesis?

### Step 5: Conduct Analyses

Gather data and test hypotheses. Each analysis should produce a
confirm/disconfirm/refine verdict on its hypothesis, not just a data dump.

### Step 6: Synthesize Findings

Ask "so what?" at each level. Synthesis is not summarization — it is
extracting the implication. The Minto page covers this as the "so-what pass"
— see [minto-pyramid-principle.md](minto-pyramid-principle.md) § Named
Operations.

### Step 7: Communicate

Present findings using the Pyramid Principle (answer first, then reasons,
then evidence). See [minto-pyramid-principle.md](minto-pyramid-principle.md).

## Issue Trees

An issue tree decomposes a problem into its component parts. The root is the
key question; each level breaks the parent into MECE sub-issues; leaf nodes
are specific enough to analyze or test.

### Choosing the Tree Type

Different problems call for different tree structures. Choosing the wrong
type is a common failure mode.

| Tree type | When to use | Root question shape | Example |
|-----------|-------------|---------------------|---------|
| **Driver tree** | Diagnosing why a metric moved | "Why did X change?" | Why did profit decline 15%? |
| **Process tree** | Finding operational bottlenecks | "Where in the process is the problem?" | Where in the supply chain are delays occurring? |
| **Option tree** | Evaluating strategic choices | "What are our options for X?" | How should we enter the European market? |
| **Hypothesis tree** | Testing a specific theory | "Is X the cause of Y?" | Is customer churn driving the revenue decline? |

### Starter Formulas

Driver trees often start from a formula decomposition:

- **Profit** = Revenue − Cost
- **Revenue** = Price × Volume
- **Volume** = New customers + Expansion − Churn
- **Cost** = Fixed + Variable + Failure cost

Process trees start from the process chain:

- Input quality → Throughput → Output quality → Rework → Cost/time impact

Option trees branch into distinct strategic choices, each compared on:
- Value upside
- Implementation effort
- Execution risk

### Branch Design Rules

1. **Siblings at the same abstraction level** — all children of a node must
   be at the same level of detail. Mixing levels (e.g., a high-level
   category and a specific tactic as siblings) violates level integrity.
2. **Nouns, not action verbs** — branches describe *what* to investigate,
   not *what to do*. "Customer acquisition" not "improve customer
   acquisition." Actions come later, after analysis.
3. **Validate exclusivity before adding children** — before adding a new
   branch, check whether any item could belong to an existing sibling. If
   yes, redefine the branches.
4. **Depth proportional to decision urgency** — a decision needed tomorrow
   needs a shallow tree (2–3 levels). A multi-month engagement can support
   deeper decomposition (4–5 levels). Over-deepening a tree for an urgent
   decision is analysis paralysis.
5. **Limit decomposition depth to 2–3 levels when practical** — deeper trees
   consume disproportionate effort for diminishing analytical return. Four
   layers is a practical warning threshold.

### Issue Tree vs Hypothesis Tree

| Aspect | Issue Tree | Hypothesis Tree |
|--------|-----------|-----------------|
| Starting point | A question | A proposed answer |
| Purpose | Explore all possibilities | Test a specific theory |
| Efficiency | Comprehensive but slower | Faster if the hypothesis is correct |
| Risk | May be slow (boiling the ocean) | May miss alternative explanations |
| When to use | New problem, no prior knowledge | Experience suggests a likely cause |

The two are complementary, not exclusive. A common workflow: build an issue
tree first to understand the problem space, then form a hypothesis and build
a hypothesis tree to test it efficiently.

### MECE Validation Gates

Before presenting or acting on an issue tree, validate it through five gates:

1. **Mutual exclusivity** — can any item belong to more than one branch? If
   yes, the branches overlap and must be redefined.
2. **Collective exhaustiveness** — is anything missing? Check for gaps,
   especially an "Other" bucket that hides incompleteness. A large
   unresolved "Other" bucket signals the decomposition is incomplete.
3. **Level integrity** — are all siblings at the same abstraction level?
   Specifically detect mixing drivers, actions, and outcomes at the same
   level. "Revenue decline" and "launch new product" should not be siblings
   — one is a driver, the other is an action.
4. **Clarity** — would two independent analysts assign the same item to the
   same branch? If not, the branch labels are ambiguous.
5. **Usefulness** — does each branch map to a feasible analysis within the
   decision timeline? A branch with no data path is dead weight.

### Common MECE Structures

When building a tree, these pre-existing structures often provide a MECE
first level:

| Structure | Categories | Best for |
|-----------|-----------|----------|
| Binary | Yes/No, Internal/External, Current/Future | Simple distinctions |
| Process | Input → Process → Output | Workflow analysis |
| Timeline | Past, Present, Future | Trend analysis |
| Stakeholder | Customers, Employees, Shareholders, Partners | Impact analysis |
| Geography | By region, country, city | Market analysis |
| Lifecycle | Acquire, Retain, Grow, Win-back | Customer analysis |
| Formula | Revenue = Price × Volume | Financial decomposition |

### MECE Failure Patterns

- **Large unresolved "Other" buckets** — the decomposition is hiding
  incompleteness behind a catch-all.
- **Deep branches with no data path** — the tree looks thorough but the
  leaves can't be analyzed.
- **Mixing internal and external drivers** at the same level — breaks
  exclusivity because internal and external factors often interact.
- **MECE for MECE's sake** — perfect MECE on a problem that doesn't need it
  wastes time. "Good enough MECE" beats "perfect but took three days."
- **Wrong initial decomposition angle** — the most expensive error. If the
  first cut is wrong, everything below it is wrong. Spend extra time on the
  first level.

## Hypothesis-Driven Problem Solving

Hypothesis-driven problem solving applies the scientific method to business:
state a hypothesis, identify what evidence would confirm or disconfirm it,
gather that specific evidence, and iterate. The alternative — "boiling the
ocean" by gathering all possible data — is slow, expensive, and often
inconclusive.

### The Day 1 Answer

Consultants create a "Day 1 Answer" — their best hypothesis before any
analysis — to focus the investigation from the start:

> "Based on initial information, we believe [hypothesis]. This would require
> [key assumptions to be true]. We will test this by [analysis plan]."

The Day 1 Answer is not a conclusion — it is a starting point that guides
which analyses to run. It is explicitly provisional and must be revised or
rejected if the evidence contradicts it.

### Falsifiable Hypothesis Format

A useful hypothesis must be **falsifiable, directional, and tied to one
measurable outcome**. The recommended format:

> **If X, then Y, because Z.**

- **X** — the proposed cause or intervention
- **Y** — the expected outcome (directional: increase, decrease, change)
- **Z** — the causal mechanism that explains why X leads to Y

Each hypothesis should define:

- **Confirming signal** — what evidence would support it?
- **Disconfirming signal** — what evidence would refute it?
- **Kill threshold** — at what point do we abandon this hypothesis?

### Hypothesis Anti-Patterns

- **Actions disguised as hypotheses** — "We should launch a loyalty
  program" is an action, not a hypothesis. A hypothesis would be "Launching
  a loyalty program will increase order frequency by 15% because frequent
  buyers respond to tiered rewards."
- **Descriptive claims with no causal mechanism** — "Revenue is declining"
  is an observation. A hypothesis needs a *because* clause.
- **Multi-causal claims with no isolatable signal** — "Revenue is declining
  because of competition, pricing, and product quality" is unfalsifiable
  because no single test can confirm or refute it. Break it into separate
  hypotheses, each with its own test.

### Hypothesis-Driven ≠ Confirmation Bias

The hypothesis is a starting point to guide investigation, not a conclusion
to defend. If evidence contradicts it, change the hypothesis. The discipline
is to define the kill criteria *before* testing begins — otherwise, there is
a tendency to reinterpret disconfirming evidence as "almost confirming."

## The 80/20 Prioritization Model

The Pareto Principle (80/20 rule) says that 80% of results come from 20% of
effort. In consulting, this means prioritizing the branches and hypotheses
most likely to drive the answer. The rule is often invoked as a slogan; the
value is in the **scoring model** that makes it operational.

### The Scoring Formula

For each hypothesis or branch, score four dimensions (1–5 each):

| Dimension | Question | Score 1 | Score 5 |
|-----------|----------|---------|---------|
| **Impact** | How much could this change the outcome? | Minimal | Transformational |
| **Confidence** | How likely is our hypothesis to be correct? | Low | High |
| **Effort** | How much work to test this? | Minimal | Extensive |
| **Speed** | How long until we have a result? | Days | Months |

**Priority = (Impact × Confidence) / (Effort × Speed)**

Higher priority = test first.

### Optional Weighting

When dimensions are not equally important, apply weights:

- Impact: 50%
- Confidence: 25%
- Effort: 15%
- Speed: 10%

**Weighted Priority = (Impact × 0.50 + Confidence × 0.25) / (Effort × 0.15 + Speed × 0.10)**

### Testing Rules

- **Test the top hypothesis first** when the decision cycle is short.
- **Run the top two in parallel** only when teams and data paths are
  independent — otherwise, parallel testing creates confounding.
- **Define kill criteria before testing begins** — at what signal do we
  abandon this hypothesis?
- **Document why a hypothesis was killed** — to prevent the team from
  re-investigating the same dead end later.
- **Require fallback plans, owners, and deadlines** — a hypothesis without
  an owner and deadline is a wish, not a test.

## Strategic Analysis Frameworks

These frameworks are tools for specific analytical tasks — industry
analysis, organizational assessment, portfolio planning. They are not a
substitute for the problem-solving process; they are inputs to Steps 2 and 5
(structure and analyze). Choose the framework that fits the question, not
the question that fits the framework.

### Porter's Five Forces (Michael Porter, HBS, 1979)

**Not a McKinsey framework.** Developed by Michael Porter at Harvard
Business School. Analyzes industry structure and competitive intensity to
assess profitability potential.

The five forces:

1. **Threat of new entrants** — high barriers to entry (economies of scale,
   capital requirements, brand loyalty, switching costs, distribution
   access, regulation, proprietary technology) protect incumbents.
2. **Bargaining power of suppliers** — suppliers are powerful when few
   dominate, no substitutes exist, the product is differentiated, switching
   costs are high, or forward integration is possible.
3. **Bargaining power of buyers** — buyers are powerful when few buy in high
   volume, products are standardized, switching costs are low, backward
   integration is possible, or the product is not important to buyer quality.
4. **Threat of substitutes** — substitutes are threatening when the
   price-performance ratio is attractive, switching costs are low, or buyer
   propensity to substitute is high. Substitutes fulfill the same need
   differently — they are not direct competitors.
5. **Industry rivalry** — rivalry is intense when many competitors are of
   similar size, industry growth is slow, fixed costs are high,
   differentiation is low, exit barriers are high, or competitors are
   diverse.

**Scoring**: Rate each force 1–5 (1 = very low, 5 = very high). Higher
scores are worse for industry profitability. The overall score indicates
whether the industry is structurally attractive.

**When to use**: Market entry decisions, industry attractiveness assessment,
competitive positioning strategy.

### McKinsey 7S Framework (Tom Peters & Robert Waterman, 1980s)

Developed by McKinsey consultants Tom Peters and Robert Waterman. Analyzes
organizational effectiveness through seven interconnected elements, with
Shared Values at the center connecting all others.

**Hard elements** (tangible, directly manageable):

- **Strategy** — the plan to achieve competitive advantage
- **Structure** — the organization's reporting hierarchy and coordination
- **Systems** — daily processes, procedures, and information flows

**Soft elements** (intangible, influenced by culture):

- **Shared Values** — core values and beliefs that guide behavior (center)
- **Style** — leadership and management behavior
- **Staff** — the people: capabilities, motivations, recruitment, development
- **Skills** — distinctive capabilities and core competencies

**How to use 7S**:

1. Map the current state for each element
2. Define the desired state for each element
3. Identify gaps between current and desired
4. Analyze alignment between elements (misalignment is the real problem)
5. Develop an action plan to close gaps and improve alignment

The key insight: organizational problems are rarely in a single element —
they are in the **misalignment** between elements. A new strategy with an
old structure will fail regardless of how good the strategy is.

**When to use**: Organizational design, transformation programs, post-merger
integration, diagnosing why a strategy isn't working.

### SWOT Analysis (Albert Humphrey, SRI, 1960s)

**Not a McKinsey framework.** Originated at the Stanford Research Institute.
Evaluates internal strengths/weaknesses and external opportunities/threats.

```
                HELPFUL              HARMFUL
                (to objective)       (to objective)
              ┌─────────────┬─────────────┐
   INTERNAL   │  STRENGTHS  │ WEAKNESSES  │
              ├─────────────┼─────────────┤
   EXTERNAL   │OPPORTUNITIES│   THREATS   │
              └─────────────┴─────────────┘
```

**The TOWS Matrix** converts SWOT from description to strategy:

| | Strengths | Weaknesses |
|---|---|---|
| **Opportunities** | **SO**: Use strengths to capture opportunities | **WO**: Overcome weaknesses by pursuing opportunities |
| **Threats** | **ST**: Use strengths to avoid threats | **WT**: Minimize weaknesses and avoid threats |

**When to use**: Quick situational assessment, strategy workshops,
competitive positioning. SWOT is a starting point, not an end state — it
identifies factors but doesn't prioritize them. Follow with a framework that
does (Five Forces for industry, 7S for organization, 80/20 for priorities).

### BCG Growth-Share Matrix (Boston Consulting Group, 1970s)

**Not a McKinsey framework.** Developed by BCG, a competitor firm. Portfolio
analysis tool for resource allocation across business units or products.

The matrix plots market growth rate (vertical) against relative market share
(horizontal):

- **Stars** — high growth, high share: invest heavily
- **Cash Cows** — low growth, high share: harvest for cash
- **Question Marks** — high growth, low share: invest selectively or divest
- **Dogs** — low growth, low share: divest or harvest

**When to use**: Portfolio management, resource allocation across product
lines or business units. Less relevant for single-product companies.

### VRIO Framework (Jay Barney, 1991)

**Not a McKinsey framework.** Academic resource-based view. Assesses whether
a resource or capability provides sustainable competitive advantage:

- **V**alue — does it enable the firm to exploit opportunities or neutralize
  threats?
- **R**arity — is it possessed by few or no other firms?
- **I**mitability — is it costly for competitors to obtain or develop?
- **O**rganization — is the firm organized to exploit it?

A resource that is Valuable + Rare + Inimitable + Organized provides a
sustained competitive advantage. Missing any dimension degrades the
advantage level.

**When to use**: Competitive advantage assessment, capability audit,
M&A target evaluation.

## Second-Order Thinking

When evaluating recommendations, trace consequences beyond the immediate
effect. For each decision:

- **Immediate consequence** (1st order) — what happens directly?
- **Systemic impact** (2nd/3rd order) — what does the immediate consequence
  cause downstream?

> **Decision**: Cut prices by 20%
> **Immediate consequence**: Revenue per unit drops 20%
> **Systemic impact**: Competitors match → price war → industry margins
> compress → quality declines → customer churn increases
> **Mitigation**: Time-limited promotion with clear exit, paired with cost
> reduction to protect margin

Second-order thinking prevents recommendations that look good on paper but
create cascading problems. It is especially important for strategic
decisions with competitor responses, market dynamics, or behavioral effects.

## Structured Thinking Principles

### Purpose Determines Structure

Structured thinking is not simple classification — it is decomposition and
recombination **in service of a purpose**. The purpose determines the
structure: a profitability diagnosis, a market entry decision, and a
process improvement each require different decomposition angles, even for
the same underlying business.

Before building any structure, clarify:

1. **What decision will this analysis inform?**
2. **What angle of decomposition serves that decision?**
3. **What level of detail does the decision timeline allow?**

### Planar Cuts

A MECE structure is created by making "planar cuts" — single-dimension
partitions that divide the space cleanly. Two-way splits (binary) and
three-way splits can combine to yield quadrants (2×2) and nine-box
structures (3×3). The BCG Matrix is a 2×2 planar cut; the GE-McKinsey
Matrix is a 3×3 extension.

### Structured Thinking vs Systems Thinking

- **Structured thinking** organizes elements — it decomposes and
  recombines static parts.
- **Systems thinking** examines dynamic relationships — feedback loops,
  delays, and nonlinear effects.

Both are valuable. Use structured thinking to decompose the problem and
identify components. Use systems thinking when the components interact
dynamically (e.g., market feedback loops, organizational change dynamics).
An issue tree is a structured-thinking tool; it does not capture feedback
loops or time delays.

### Boundary Conditions — When NOT to Use Structured Frameworks

- **Do not over-structure simple problems.** A two-sentence answer is better
  than a framework applied to a question that doesn't need it.
- **Do not use it for urgent intuitive decisions.** When the decision window
  is minutes and the stakes are moderate, structured decomposition adds
  latency without value.
- **Avoid excessive depth.** Four layers is a practical warning threshold.
  Beyond that, the tree consumes disproportionate effort for diminishing
  return.

## The Complete Workflow

Integrating the frameworks into a single workflow:

```
1. DEFINE  →  Write a specific, measurable, decision-relevant problem
                statement (R1/R2 + decision owner + deadline)

2. STRUCTURE  →  Choose tree type (driver/process/option/hypothesis)
                  Build issue tree with MECE branches
                  Validate through 5 MECE gates

3. PRIORITIZE  →  Score branches with 80/20 model
                  (Impact × Confidence / Effort × Speed)
                  Test top hypothesis first

4. HYPOTHESIZE  →  Form Day 1 Answer
                   Write falsifiable hypotheses (If X then Y because Z)
                   Define confirming/disconfirming signals + kill thresholds

5. ANALYZE  →  Gather evidence for prioritized hypotheses
               Apply strategic frameworks where relevant
               (Five Forces for industry, 7S for org, VRIO for capabilities)
               Trace second-order consequences

6. SYNTHESIZE  →  Ask "so what?" at each level
                  Confirm, refute, or refine each hypothesis
                  Document killed hypotheses and why

7. COMMUNICATE  →  Present using the Pyramid Principle (answer first)
                   Cross-reference: minto-pyramid-principle.md
```

## Applications in the Hiring Pipeline

### Case Interviews

The 7-step process maps directly to the case interview framework
(clarify → structure → analyze → conclude). See
[case-interview.md](case-interview.md) for the interview-specific format.
The additions this page provides:

- **Tree type selection** — knowing when to use a driver tree vs a
  hypothesis tree vs an option tree, rather than defaulting to a
  profitability framework every time.
- **MECE validation gates** — a checklist to validate your structure before
  presenting it to the interviewer, catching level-integrity and
  usefulness failures that interviewers penalize.
- **80/20 scoring** — a systematic way to prioritize which branch to
  analyze first, rather than guessing.
- **Hypothesis format** — the "If X then Y because Z" structure makes your
  hypothesis explicit and testable, which interviewers reward.

### Behavioral Interviews

When describing a past problem-solving experience, the 7-step process
provides a narrative structure: define the problem, describe how you
structured it, explain your prioritization, state your hypothesis, describe
the analysis, share the synthesis, and present the recommendation. This
maps to the STAR method — see
[behavioral-interview-framework.md](behavioral-interview-framework.md).

### Strategy and PM Roles

For strategy, product management, and operations roles, these frameworks
are the core job, not just interview prep. The hypothesis-driven discipline,
issue tree construction, and 80/20 prioritization are daily tools. The
strategic analysis frameworks (Five Forces, 7S, VRIO) appear in strategy
decks, market assessments, and competitive analyses.

### Presentations

When presenting analysis results, use the Pyramid Principle for the
communication structure and the 7-step process for the analytical narrative.
See [presentation-demo-interview.md](presentation-demo-interview.md) and
[minto-pyramid-principle.md](minto-pyramid-principle.md).

## Common Failure Modes

| Failure | What happens | Fix |
|---------|-------------|-----|
| **Framework-first** | Choosing a framework before understanding the problem | Define the problem first, then select the framework that fits |
| **Boiling the ocean** | Analyzing every branch instead of prioritizing | Apply the 80/20 scoring model before starting analysis |
| **Defending the hypothesis** | Treating a Day 1 Answer as a conclusion to protect | Define kill criteria before testing; revise when evidence contradicts |
| **MECE for MECE's sake** | Spending days perfecting structure instead of analyzing | "Good enough MECE" beats "perfect but took three days" |
| **Wrong first cut** | The initial decomposition angle doesn't match the problem | Spend extra time on the first level; it's the most expensive error |
| **Mixing levels** | Siblings at different abstraction levels | Check level integrity (MECE gate 3) before proceeding |
| **No data path** | Deep branches that can't be analyzed | Check usefulness (MECE gate 5) — each branch must map to feasible analysis |
| **Ignoring second-order effects** | Recommendation creates cascading problems | Trace 2nd/3rd order consequences for every strategic recommendation |
| **Structured ≠ slow** | Spending 30 minutes structuring before analyzing | Structure IS the speed — it prevents hours of unfocused analysis |
| **Know when to stop** | Over-analyzing past the point of a confident recommendation | If you have enough evidence to recommend confidently, stop and recommend |

## Cross-References

- [Minto Pyramid Principle](minto-pyramid-principle.md) — the communication
  layer: answer-first structure, SCQA, evidence taxonomy, the 7-step build.
  This page is the problem-solving layer; Minto is the communication layer.
- [Case Interviews](case-interview.md) — the interview format where these
  frameworks are tested under time pressure. The 4-step case framework
  (clarify → structure → analyze → conclude) is the interview version of the
  7-step process.
- [Behavioral Interview Framework](behavioral-interview-framework.md) —
  STAR/PAR/CAR methods for describing past problem-solving experiences.
- [Presentation and Demo Interviews](presentation-demo-interview.md) —
  presenting analysis results with narrative arc and slide design.
- [Strategic Abstraction](strategic-abstraction.md) — matching the
  abstraction level of communication to the audience, relevant when
  presenting consulting-style analysis to executives.
- [Interview Strategy](interview-strategy.md) — when case interviews and
  structured problem-solving assessments appear in the hiring process.
