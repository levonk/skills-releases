---
type: Practice
title: Engineering Blog Patterns
description: Normative patterns for engineering blog posts — the seven canonical patterns (Bug Hunt, Rewrote It in X, How We Built It, Lessons Learned, Thoughts on Trends, Non-Markety Product, Benchmarks) with characteristics, dos, don'ts, and real-world examples. Use to select the right pattern for a topic and to structure the post.
tags: [technical-writing, engineering-blogs, blog-patterns, bug-hunt, rewrite, how-we-built-it, lessons-learned, opinion, benchmarks, product]
date:
  created: "2026-08-27"
  knowledge-basis: "2026-08-27"
  last-used: "2026-08-27"
sources:
  - id: writing-for-developers
    resource: "https://github.com/scynthiadunlop/WritingForDevelopersBook"
    title: "Writing For Developers: Blogs That Get Read by Piotr Sarna and Cynthia Dunlop"
  - id: writethat-blog
    resource: "https://writethatblog.substack.com/"
    title: "Write That Blog — newsletter with writing tips from expert bloggers"
---

# Engineering Blog Patterns

Different types of engineering blog posts have different conventions. A bug
hunt article varies from an opinion piece roasting a hyped technology, which
varies from an article sharing how a team implemented an algorithm. This page
catalogs the seven canonical patterns, each with its purpose, characteristics,
dos, don'ts, and real-world examples.

For the fundamentals of topic selection and compelling post characteristics,
see [Engineering Blog Fundamentals](engineering-blog-fundamentals.md). For the
writing process, see [Blog Writing Process](blog-writing-process.md).

## How to Use This Page

1. Identify the pattern that matches your topic. Most topics fit one pattern
   naturally.
2. Read the pattern's characteristics, dos, and don'ts.
3. Study at least one example post before writing.
4. Follow the pattern's structure, but let your content drive the details. A
   pattern is a scaffold, not a straitjacket.

## Pattern 1: Bug Hunt

The Bug Hunt pattern is the programming world's detective story. It has a main
plot (the bug), side plots (the dead ends), a protagonist (you), and an
antagonist (usually also you, having introduced the bug two weeks ago). It is
captivating, keeps readers in suspense, and ends with a satisfying plot twist
or a tactical cliffhanger.

### Purpose

- **Knowledge dump**: Record the dead ends, red herrings, tools that helped,
  and the old blog post from 2014 that led to the root cause. The future
  debugger (likely you again, two weeks older) saves hours.
- **Global bug awareness**: The bug may not be unique to your project. It may
  stem from a pitfall in your language, a library, or hardware. Your article
  can inspire others to check their setup or motivate the upstream team to
  prevent the same mistake.
- **Bragging**: Tech-world bragging, at the right dosage, is good for you and
  your readers. It is educational, broadens your network, feels good, and
  yields free (hopefully constructive) criticism.

### Characteristics

- Detective-story narrative with suspense and a plot twist
- Includes failed attempts and red herrings, not just the solution
- Deeply technical but accessible to less experienced readers
- The solution is often surprisingly small (one line of code, one config
  change)
- May be long — a 30-minute read is acceptable when the investigation warrants
  it

### Dos

- Include every dead end and red herring — they are the most educational parts
- Show the tools you used, with screenshots or output
- Build tension: let the reader follow the investigation step by step
- Deliver a satisfying resolution — the fix and its impact
- Name the root cause clearly at the end

### Don'ts

- Don't skip straight to the solution without the investigation
- Don't hide the failed attempts to look smarter
- Don't make the post so long that the tension breaks — if it is a 30-minute
  read, structure it with section breaks
- Don't leave the reader without a takeaway — even a cliffhanger needs a
  "what to do next"

### Examples

- **"Hunting a NUMA Performance Bug"** by Michal Chojnowski, ScyllaDB Blog
  (https://www.scylladb.com/2021/09/28/hunting-a-numa-performance-bug/) — The
  pinnacle of the pattern. Deeply technical but simple to follow. The solution
  is one line of code. The casual expertise (editing executable binaries as
  text) makes it an enjoyable read.
- **"Why Is My Rust Build So Slow?"** by Amos Wenger, fasterthanli.me
  (https://fasterthanli.me/articles/why-is-my-rust-build-so-slow) — A long,
  encyclopedic post profiling the Rust compiler. Features the author's alter
  ego "Cool Bear" for humor. The conclusion is unconventional: honest advice
  instead of a surprise fix.
- **"How a Single Line of Code Made a 24-core Server Slower Than a Laptop"**
  by Piotr Kołaczkowski
  (https://pkolaczk.github.io/server-slower-than-a-laptop/) — A clickbaity but
  elegant title. Sneakily educational, digressing on CPU cache timings. The
  fix (minimizing shared state between processor units) follows naturally from
  the analysis.
- **"ZFS Is Mysteriously Eating My CPU"** by Brendan Gregg
  (https://www.brendangregg.com/blog/2021-09-06/zfs-is-mysteriously-eating-my-cpu.html)
  — Concise (three-minute read) but packed with knowledge. Shows that you do
  not need thousands of words to squeeze in technical detail. The author's
  personal brand (flame graph inventor) adds credibility.

## Pattern 2: Rewrote It in X

The Rewrote It in X pattern covers migrating or rewriting an application,
service, or system in a new programming language, library, or framework.

### Purpose

Share the why, how, and what happened of a technology change so other
engineers can judge whether a similar rewrite is worth it. Demonstrate
engineering judgment, surface hard-won lessons, and give the reader enough
data to make their own decision.

### Characteristics

- Clear before/after technology comparison with a concrete problem
- Quantified results: cost, latency, throughput, memory, CPU, startup time
- Honest discussion of pitfalls, false starts, and things that did not improve
- Defensible selection process for the new stack (why X, and why not Y or Z)
- Description of the rewrite strategy: black-box reimplementation, incremental
  port, side-by-side validation, or big-bang
- Takeaways about whether the rewrite was worth it and under what conditions

### Dos

- Start with the real driver — the business or operational cost the old stack
  was imposing
- Include numbers and methodology — "faster" is not enough; show how you
  measured
- Be honest about downsides: learning curves, ecosystem gaps, productivity
  dips, and bugs
- Explain the alternatives you considered and rejected
- Describe validation — how you verified correctness or prevented regressions
- Close with practical guidance for readers considering the same move

### Don'ts

- Don't turn it into language or framework evangelism
- Don't hide the rough parts or present marketing fluff
- Don't rewrite something just to have a blog post
- Don't omit the real reason for the change
- Don't rely on shallow benchmarks or one-off anecdotes

### Examples

- **"Counter Service: How we rewrote it in Rust"** by Grab Engineering
  (https://engineering.grab.com/counter-service-how-we-rewrote-it-in-rust) —
  Grab rewrote a high-QPS Go microservice in Rust, treating the old service as
  a black box. Reports roughly 70% infrastructure savings. Honest about
  Rust's learning curve and the fact that idiomatic Go does not translate
  directly to idiomatic Rust.
- **"The Appwrite CLI is now written in Go"** by Appwrite
  (https://appwrite.io/blog/post/rewriting-the-appwrite-cli-in-go) — Replaced
  a 6.9 MB Node bundle with a 14 MB Go binary. Starts from measurements (CLI
  start time and push memory), justifies why Go beat Rust for this I/O-bound
  workload, and keeps the external command surface unchanged.
- **"Rewriting a Python Moderation Service in Go: From 3GB to 50MB"** by
  Anthony G. Tellez
  (https://anthonygtellez.com/blog/2026-01-15-rewriting-python-service-go-performance)
  — Striking before/after numbers: 3 GB memory and 30-60s startup in Python
  versus 20-50 MB and under 100ms in Go. Honest about what Go made easier and
  harder (goroutines, the thin Go ML ecosystem).

## Pattern 3: How We Built It

The How We Built It pattern recounts the design and construction of an
impressive or technically challenging engineering achievement — a system, tool,
or feature built under demanding constraints.

### Purpose

Create a public knowledge base of how hard engineering problems are solved.
Showcase architecture and non-obvious design decisions. Inspire and educate
other engineers. This is the "show your work" pattern.

### Characteristics

- Clearly defined, impressive problem or achievement
- High-level architecture plus the why behind non-obvious choices
- Concrete constraints: scale, latency, cost, uptime, team size, deadlines
- Technical depth: diagrams, data models, algorithms, code snippets,
  infrastructure details
- Honest discussion of trade-offs, pivots, and dead ends
- Measurable impact on users or the business

### Dos

- Start with the problem and why it matters — make the stakes clear
- Show the architecture, not just the tools — diagrams and data flows help
- Explain the non-obvious decisions — why this design over an easier
  alternative
- Include real outcomes: latency, scale, cost, uptime, user impact
- Tell the story of pivots and failures — they are often the most useful part
- Keep it focused on one achievement

### Don'ts

- Don't write it as a marketing brochure or product pitch
- Don't dump an unstructured chronological log
- Don't skip the problem and jump straight to the solution
- Don't hide the engineering struggle
- Don't over-hype claims without data
- Don't make the post so generic it could apply to any company

### Examples

- **"How we built Pingora, the proxy that connects Cloudflare to the
  Internet"** by Cloudflare
  (https://blog.cloudflare.com/how-we-built-pingora-the-proxy-that-connects-cloudflare-to-the-internet)
  — An in-house Rust HTTP proxy serving over a trillion requests per day,
  replacing NGINX. Covers why Rust, why they wrote their own HTTP library
  instead of using hyper, and the programmable request-lifecycle API.
- **"How Discord Stores Trillions of Messages"** by Discord
  (https://discord.com/blog/how-discord-stores-trillions-of-messages/) —
  Discord's database journey from MongoDB to Cassandra to ScyllaDB. Concrete
  scale numbers, hot partitions, garbage collection pain, and a clear
  problem-experiment-solution arc.
- **"How We Built AI-Powered Search in Figma"** by Figma
  (https://www.figma.com/blog/how-we-built-ai-search-in-figma/) — An
  autocomplete hackathon prototype pivoted into a visual/semantic AI search
  feature. Explains user research, the product reasoning behind visual search,
  and the infrastructure.

## Pattern 4: Lessons Learned

The Lessons Learned pattern distills hard-won conclusions from a real
technical challenge, postmortem, or retrospective. It narrates what happened,
why it went wrong (or right), and what the team now knows that they wish they
had known earlier.

### Purpose

- Transfer first-hand experience so readers can avoid the same mistakes
- Build trust and credibility by showing vulnerability and intellectual
  honesty
- Turn failures and near-misses into reusable institutional knowledge

### Characteristics

- Starts from a concrete, specific problem or incident
- Provides enough technical context that peers can follow the diagnosis
- Extracts explicit, named, or numbered lessons — not just a story
- Includes what the team is changing as a result
- Honest about mistakes, trade-offs, and lingering uncertainty
- Mixes narrative with enough technical detail to be useful

### Dos

- Ground the post in a real project, outage, or decision
- Include a clear timeline and root cause
- Number or label the lessons
- Tie every lesson to a concrete action or process change
- Give credit to collaborators and explain the organizational follow-up
- Write at a technical level appropriate for the intended readers

### Don'ts

- Don't offer vague platitudes like "we should have tested more" without
  specifics
- Don't sanitize the narrative to protect reputations
- Don't omit the actual technical cause or dump raw logs without
  interpretation
- Don't bury the lessons inside a purely heroic war story
- Don't turn a postmortem into a marketing pitch
- Don't ignore unresolved follow-up work

### Examples

- **"Post mortem on the Cloudflare Control Plane and Analytics Outage"** by
  Matthew Prince, Cloudflare
  (https://blog.cloudflare.com/post-mortem-on-cloudflare-control-plane-and-analytics-outage/)
  — Begins with an honest apology, walks through the cascading failure of a
  core data center dependency, and lists concrete follow-up changes.
- **"You've Got (Too Much) Mail: Behind the Scenes of the 3/25/26 Voice
  Outage"** by Discord
  (https://discord.com/blog/behind-the-scenes-of-the-3-25-26-voice-outage) —
  Traces a small Kubernetes admission webhook change through to a cascading
  voice outage, then explains the exact remediation steps. A blameless,
  chain-of-failure postmortem.
- **"Building a general-purpose accessibility agent — and what we learned in
  the process"** by GitHub
  (https://github.blog/ai-and-ml/github-copilot/building-a-general-purpose-accessibility-agent-and-what-we-learned-in-the-process/)
  — Frames an AI/ML experiment around explicit "what we learned" takeaways:
  scope control, the importance of a curated issue corpus, and augmenting
  rather than replacing human reviewers.

## Pattern 5: Thoughts on Trends

The Thoughts on Trends pattern covers highly opinionated essays that react to,
critique, or stake a position on an industry trend, technology, or hot topic.
The author's point of view is the central feature.

### Purpose

- Cut through hype and help engineers evaluate a trend
- Provoke discussion and sometimes shift conventional wisdom
- Establish the author as a credible voice by taking a stand
- Influence how teams and companies approach a new technology or practice

### Characteristics

- Opens with a clear, often provocative thesis
- Uses a strong, first-person voice
- References current tools, events, or debates
- Willing to be contrarian or to challenge the consensus
- Backs opinions with real experience, data, or telling examples
- Explains the practical "so what" for working engineers
- Attracts strong reactions and discussion

### Dos

- Have a single, specific opinion rather than a vague "X is interesting"
  observation
- Ground the argument in real engineering or operational experience
- Acknowledge counterarguments and trade-offs
- Explain what the trend means for day-to-day practitioners
- Use a memorable, assertive headline
- Accept that some readers will disagree

### Don'ts

- Don't be contrarian only for clicks
- Don't rant without a coherent point or recommendation
- Don't ignore the real trade-offs of the technology you are criticizing
- Don't generalize from one personal anecdote to the whole industry
- Don't misrepresent the technology or straw-man opponents
- Don't confuse a trend opinion piece with a product advertisement

### Examples

- **"Promoting AI agents"** by DHH
  (https://world.hey.com/dhh/promoting-ai-agents-3ee04945) — Argues that AI
  coding agents have crossed a threshold from assistants to autonomous
  contributors, while carefully separating current professional utility from
  "vibe coding" hype. A personal, well-bounded trend take.
- **"Generative AI is not going to build your engineering team for you"** by
  Charity Majors (https://charity.wtf/p/generative-ai-is-not-going-to-build-your-engineering-team-for-you)
  — Pushes back on the idea that junior engineering work is being automated
  away, emphasizing that the hard parts of software are operating,
  understanding, and governing code. A polemic grounded in decades of
  operations experience.
- **"Don't fall into the anti-AI hype"** by antirez
  (https://antirez.com/news/158) — Argues against letting personal preferences
  for hand-written, minimal code blind engineers to the fact that AI will
  reshape programming. A nuanced, contrarian trend piece from a respected
  systems programmer.

## Pattern 6: Non-Markety Product Perspectives

The Non-Markety Product Perspectives pattern embeds a product inside a
genuinely intriguing and educational technical article. The product is not the
star — it appears naturally as part of the engineering story. Readers walk
away with useful technical knowledge even if they never adopt the product.

### Purpose

- Build trust and awareness by teaching first and selling second
- Let the product demonstrate its value through the problems it helps solve,
  not through feature lists or claims
- Create word-of-mouth momentum because the post is interesting on its own
  merits

### Characteristics

- The post is technical — it explains a real system, algorithm, or
  engineering problem in depth
- Behind-the-scenes — reveals how something was actually built or how an
  unusual challenge was handled
- Product mentions are subliminal — the product shows up as the natural
  setting or implementation detail, not as a pitch
- Gives the reader transferable knowledge (data structures, architecture
  trade-offs, debugging techniques)
- Uses first-person narrative, code, diagrams, and concrete numbers

### Dos

- Lead with an interesting technical problem or question
- Make the product a supporting character, not the hero
- Include real code, architecture diagrams, and honest trade-offs
- Mention the product only when it is the natural answer to the problem being
  discussed
- Show what the reader can learn regardless of whether they use your product
- Be transparent about limitations and alternative approaches

### Don'ts

- Don't write a press release or feature-launch announcement dressed up as a
  blog post
- Don't use marketing superlatives ("industry-leading", "revolutionary",
  "best-in-class")
- Don't force the product into every paragraph
- Don't hide the product so completely that the post has no clear connection to
  your work
- Don't bash competitors to make your product look better

### Examples

- **"How we made global routing faster with Bloom filters"** by Vercel
  (https://vercel.com/blog/how-we-made-global-routing-faster-with-bloom-filters)
  — Teaches Bloom filters from a real production problem. Vercel's global
  routing is the backdrop; the lesson is about replacing JSON path lookups
  with a probabilistic data structure, cutting memory and improving TTFB by
  10%.
- **"Tracing Discord's Elixir Systems (Without Melting Everything)"** by
  Discord (https://discord.com/blog/tracing-discords-elixir-systems-without-melting-everything)
  — An educational deep dive into OpenTelemetry, message-passing, and a
  custom transport layer. Discord is the setting, not the pitch.
- **"The infrastructure behind AI search in Figma"** by Figma
  (https://www.figma.com/blog/the-infrastructure-behind-ai-search-in-figma/)
  — Generating and indexing billions of multimodal embeddings using CLIP,
  SageMaker, DynamoDB, and OpenSearch while keeping costs down. The product
  is the context; the reader learns how to build large-scale semantic search.

## Pattern 7: Benchmarks and Test Results

The Benchmarks and Test Results pattern publishes the results of performance
tests or benchmarks. These can compare a product to competitors, compare
infrastructure options, or measure an independent technology.

### Purpose

- Provide objective, numeric evidence for engineering or product decisions
- Demonstrate the performance characteristics of a product or approach
- Serve as a community service by sharing reproducible measurements
- Be transparent about what was tested and how, so readers can judge for
  themselves

### Characteristics

- Numeric and visual — tables, graphs, percentiles, throughput and latency
  figures
- Methodology-first — the author explains setup, hardware, workloads, and
  limitations because benchmarks are easily distrusted
- Clear test harness, dataset, machine types, concurrency, and warm-up
- Results tied to realistic workloads, not just micro-benchmarks
- Explains the why behind the numbers (architecture, bottlenecks, tuning)
- Often includes links to reproducible code or raw data

### Dos

- Share full test setup: hardware, versions, dataset, load generator, and
  configuration
- Run multiple iterations and report variance and percentiles, not just
  best-case throughput
- Use open-loop or realistic workload shapes when possible
- Show the code or scripts so others can reproduce the results
- Be explicit about what you are measuring and what you are not
- Call out your own product's weaknesses and the competitor's strengths
- Explain the engineering reason for any significant difference

### Don'ts

- Don't cherry-pick a single metric that flatters your product
- Don't use synthetic micro-benchmarks that do not resemble real workloads
- Don't hide the test configuration, instance sizing, or tuning
- Don't omit tail latency, error rates, or resource usage
- Don't claim "X times faster" without defining the workload and conditions
- Don't benchmark your product on better hardware than the competition
- Don't treat a benchmark score as a conclusion — it is an observation under
  specific conditions

### Examples

- **"Benchmarking Edge Network Performance"** by Cloudflare
  (https://blog.cloudflare.com/benchmarking-edge-network-performance/) —
  Compares five major CDN providers using real RUM data from end-user
  browsers. Publishes p95 TCP connection time, TTFB, and TTLB. Names cases
  where Cloudflare is not first. A textbook benchmark post.
- **"Scaling Performance Comparison: ScyllaDB Tablets vs Cassandra vNodes"**
  by ScyllaDB (https://www.scylladb.com/2026/01/13/scaling-performance-comparison-vs-cassandra/)
  — Tests scale-out under live traffic with caches warm and topology changes
  in progress. Reports throughput, latency, and scaling time with hardware
  and configuration in an appendix.
- **"How Turso made connections to SQLite databases 575x faster"** by Turso
  (https://turso.tech/blog/how-turso-made-connections-faster) — Starts with a
  concrete benchmark (opening a connection to a 10,000-table SQLite database)
  and shows the reduction from 23ms to 40 microseconds. Explains the
  engineering (sharing parsed schemas with copy-on-write Arcs) and links to
  the benchmark code.

## Choosing a Pattern

| If your topic is... | Use this pattern |
|---------------------|------------------|
| A bug you hunted and fixed | Bug Hunt |
| A rewrite or migration to a new stack | Rewrote It in X |
| A system or feature you built | How We Built It |
| A postmortem or retrospective | Lessons Learned |
| An opinion on a technology or trend | Thoughts on Trends |
| A technical story that naturally involves your product | Non-Markety Product |
| Performance measurements or comparisons | Benchmarks and Test Results |

Some topics fit multiple patterns. A rewrite that started as a bug hunt can
blend both. A lessons-learned post about a benchmark gone wrong can blend
Lessons Learned with Benchmarks. Pick the dominant pattern and let the others
inform subsections.

## Quick Self-Check

Before writing, check:

- [ ] Have you identified the dominant pattern for your topic?
- [ ] Have you read at least one example post in that pattern?
- [ ] Does your outline follow the pattern's natural structure?
- [ ] Are you following the pattern's dos?
- [ ] Are you avoiding the pattern's don'ts?

## Cross-References

- Fundamentals and topic selection: [Engineering Blog Fundamentals](engineering-blog-fundamentals.md)
- Writing process: [Blog Writing Process](blog-writing-process.md)
- Promotion and expansion: [Blog Promotion and Expansion](blog-promotion-and-expansion.md)
- Core prose clarity rules: [Simplified Technical English](simplified-technical-english.md)
- Full writing rules and self-check: [Detailed Guide](detailed-guide.md)
- Bundle index: [index.md](index.md)
