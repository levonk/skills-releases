# Directory Update Log

## 2026-08-21 (eleventh revision — Founder Content System concept page)

* **Addition**: Created [founder-content-system.md](founder-content-system.md)
  — The complete methodology for ghostwriting founder social content across
  X, LinkedIn, Instagram, TikTok, YouTube, Facebook, and a blog. Generalized
  from a live founder-ghostwriting engagement (the
  `founder-ghostwriter-setup` skill in `/Users/micro/Downloads/Founder Content
  System/`). Covers: the one-sentence method (facts from verified sources,
  voice from verbatim writing, style by countable checks, corrections
  compound in a ledger), the five-phase pipeline (Phase 0 intake inventory
  with 13 optional inputs, Phase 1 facts layer with context docs + primary
  sources + anchor bank, Phase 2 voice layer with verbatim corpus +
  per-client calibrations, Phase 3 rules layer with persona constraints +
  banned patterns + humanizer, Phase 4 drafting workflow with seven gates
  including isolated drafting and cold adversarial review, Phase 5 feedback
  loop with the ledger), the day-of reactive track for news pegs, the
  universal banned-pattern list (slop lint — core style rules and learned
  universals), platform coverage and per-platform register differences, the
  subagent dependency (isolated drafting and cold adversarial review both
  require parallel agents), and four meta-lessons for why voice guides fail
  and this system works. Cross-references Personal Brand, LinkedIn Profile
  Optimization, Safe Pair of Hands Positioning, Metrics and Quantification,
  Fluff and Buzzword Elimination, and the Minto Pyramid Principle.
* **Inspiration**: Generalized from the `founder-ghostwriter-setup` skill
  (a Claude skill from a live founder-ghostwriting engagement, provided by
  the user at `/Users/micro/Downloads/Founder Content System/`). The
  methodology was codified into this knowledge bundle concept page, and the
  execution layer was built as the `founder-content-system` skill in
  `src/current/skills/content/founder-content-system/`. The skill references
  this bundle page via `includeTree` materialization; the bundle page is the
  single source of truth for the why and what, the skill is the how.
  Additional skills discovered via `pnpm dlx skills find` with keywords
  (post, x, instagram, linkedin, youtube, facebook, tiktok, blog, social,
  media, content, ghostwriter, founder content) informed the platform
  coverage and the per-platform register defaults. Notable finds:
  `samber/cc-skills@linkedin-ghostwriting`, `samber/cc-skills@substack-
  ghostwriting`, `shawnpang/startup-founder-skills@founder-thought-
  leadership`, `aidevgtm/gtm-cofounder@founder-led-content`,
  `langchain-ai/deepagents@social-media`, `anthropics/knowledge-work-
  plugins@content-creation`, `kostja94/marketing-skills@linkedin-posts`,
  `kostja94/marketing-skills@twitter-x-posts`,
  `kostja94/marketing-skills@tiktok-captions`,
  `bradautomates/head-of-content@instagram-research`,
  `bradautomates/head-of-content@tiktok-research`. None replaced the
  engagement-derived methodology — the live engagement's five-phase pipeline
  with isolated drafting and cold adversarial review is the differentiator.
* **Update**: Added the new concept page in a new "Founder Content System"
  section in [index.md](index.md) and [overview.md](overview.md).
* **Bundle total**: Now 51 concept pages covering the full candidate-side
  hiring pipeline plus the founder content execution layer.

## 2026-08-21 (tenth revision — Consulting Problem-Solving Frameworks concept page)

* **Addition**: Created
  [consulting-problem-solving-frameworks.md](consulting-problem-solving-frameworks.md)
  — the McKinsey-style problem-solving toolkit that complements the Minto
  Pyramid Principle's communication layer. Synthesized from established
  consulting methodology and ten open-source AI skill implementations (six
  from `pnpm dlx skills find mckinsey`, `pnpm dlx skills find
  hypothesis-driven`, `pnpm dlx skills find issue-tree`, and `pnpm dlx
  skills find mece`, four from GitHub search). Covers: the 7-step
  problem-solving process (define, disaggregate, prioritize, workplan,
  analyze, synthesize, communicate), hypothesis-driven problem solving with
  Day 1 Answers and falsifiable hypotheses (If X then Y because Z,
  confirming/disconfirming signals, kill thresholds, anti-patterns),
  issue trees (driver, process, option, hypothesis) with starter formulas,
  branch design rules (same abstraction level, nouns not verbs, validate
  exclusivity, depth proportional to urgency, 2–3 level practical limit),
  issue tree vs hypothesis tree comparison, MECE validation gates (mutual
  exclusivity, collective exhaustiveness, level integrity, clarity,
  usefulness), common MECE structures table, MECE failure patterns, the
  80/20 prioritization scoring model (Impact × Confidence / Effort × Speed
  with optional weighting), testing rules (test top first, parallel only
  when independent, kill criteria before testing, document kills),
  strategic analysis frameworks with accurate attribution (Porter's Five
  Forces — Porter/HBS 1979, not McKinsey; McKinsey 7S — Peters & Waterman
  1980s, McKinsey-originated; SWOT — Humphrey/SRI 1960s, not McKinsey; BCG
  Growth-Share Matrix — BCG 1970s, not McKinsey; VRIO — Barney 1991, not
  McKinsey), second-order thinking (1st/2nd/3rd order consequence chains
  with mitigation), structured thinking principles (purpose determines
  structure, planar cuts, structured vs systems thinking, boundary
  conditions), the complete integrated workflow, applications to case
  interviews, behavioral interviews, strategy/PM roles, and presentations,
  and a common failure modes table. Cross-references the Minto Pyramid
  Principle, Case Interviews, Behavioral Interview Framework, Presentation
  and Demo Interviews, Strategic Abstraction, and Interview Strategy
  concept pages.
* **Inspiration**: Synthesized from established consulting methodology and
  ten open-source AI skill repositories, each contributing unique gems:
  - [fleurytian/awesome-claude-skills](https://github.com/fleurytian/awesome-claude-skills)
    (mckinsey-consultant) — staged problem-solving workflow, problem
    boundary definition, issue tree construction, hypothesis formation,
    dummy page design, page dependency types
  - [santos-sanz/lifeskills](https://github.com/santos-sanz/lifeskills)
    (consulting-hypothesis-driven-80-20) — falsifiable hypothesis format
    (If X then Y because Z), confirming/disconfirming signals, kill
    thresholds, 80/20 scoring model (Impact × Confidence / Effort ×
    Speed), optional weighting, parallel testing rules, kill documentation
  - [santos-sanz/lifeskills](https://github.com/santos-sanz/lifeskills)
    (consulting-issue-tree-mece) — tree type selection
    (driver/process/option/hypothesis), starter formulas, branch design
    rules, MECE validation gates (5 gates), failure patterns
  - [uxderrick/mece-skill](https://github.com/uxderrick/mece-skill) — MECE
    validation and decomposition modes, numeric scoring model, self-test
    before presenting, domain-aware validation, boundary definition,
    decomposition depth limits
  - [kangarooking/cognitive-dividend-skill](https://github.com/kangarooking/cognitive-dividend-skill)
    (structured-thinking) — purpose determines structure, planar cuts,
    two-way/three-way splits, structured thinking vs systems thinking,
    boundary conditions, failure modes
  - [yoichiojima-2/consultant](https://github.com/yoichiojima-2/consultant)
    — MECE common structures table, issue tree examples, hypothesis tree
    vs issue tree comparison, McKinsey 7-step problem solving process, Day
    1 Answer, Porter's Five Forces, McKinsey 7S, SWOT, BCG Matrix
  - [ericgandrade/claude-superskills](https://github.com/ericgandrade/claude-superskills)
    (mckinsey-strategist) — parallel framework analysis (SWOT, VRIO, 7S,
    second-order thinking, impact vs effort), executive synthesis,
    second-order consequence chains
  - [Abdullah4AI/mckinsey-research](https://github.com/Abdullah4AI/mckinsey-research)
    — 12-prompt parallel research workflow, adaptive stage logic
    (idea/startup/growth/mature), diamond gates, batch dependency
    management
  - [fzfclee/consulting-skills](https://github.com/fzfclee/consulting-skills)
    (issue-tree) — decision-relevant core question, evidence plan
    template, priority analysis with decision impact, quality gate with
    disconfirming checks
  - [asgard-ai-platform/skills](https://github.com/asgard-ai-platform/skills)
    (meta-structured-problem) — IRON LAW (MECE or it's not structured),
    hypothesis-driven approach steps, 80/20 rule application, gotchas
    (good enough MECE, hypothesis ≠ confirmation bias, structured ≠ slow,
    know when to stop)
* **Update**: Added the new concept page to the "Interview & Hiring Process"
  section in [index.md](index.md) and [overview.md](overview.md), placed
  after the Minto Pyramid Principle entry to reflect the complementary
  relationship (Minto = communication layer, this page = problem-solving
  layer).

## 2026-08-21 (ninth revision — Minto Pyramid Principle concept page, expanded)

* **Addition**: Created [minto-pyramid-principle.md](minto-pyramid-principle.md)
  — Barbara Minto's Pyramid Principle for structured communication, synthesized
  from the original framework and eleven open-source AI skill implementations
  (six from GitHub search, five from `pnpm dlx skills find minto` and
  `pnpm dlx skills find pyramid`).
  Covers: the Gate (when NOT to use pyramid), BLUF vs Minto distinction, one
  pyramid per document, the brutal Level 1 test, three logic rules, MECE with
  the duplication test, SCQA with audience dosing, anti-patterns, SCR + Minto
  combined, burying the ask, evidence taxonomy (stat/named example/named
  person/concrete anecdote) and strength classification (STRONG/WEAK/MISSING),
  numbers over adjectives, evidence + implication + risk triple, the
  mechanics-vs-reasons test, ask-before-drafting, problem definition (R1/R2),
  seven common reader positions, common question shapes, diagnostic frameworks,
  logic trees, issue analysis (yes-or-no questions), the 7-step build process,
  multiple pyramid configuration with bridge questions, structural constraints
  (max 4 levels/4 children), don't-force-pyramid-onto-bad-reasoning, restructure
  don't summarise, validation with scoring rubric (5 axes, 0–10), the 9-failure
  catalogue, epistemic discipline and the confidence contract
  (High/Medium/Low/Unverified), tiered renderers (Tier A/B/C with the Tier C
  override), depth levels (Compact/Standard/Deep), named operations (buried-lede
  test, reason audit, so-what pass, email version), the "invent nothing" rule,
  the closing contract (decision/owner/date/next action), one governing question,
  action ideas must state end products, news is not thinking, risks/next-steps
  as closing section, hedging dissolves the claim, red flags in a draft, and
  applications to interview answers, presentations, case interviews, written
  communication, and salary negotiation throughout the hiring pipeline.
  Cross-references the Behavioral Interview Framework, Case Interviews,
  Presentation and Demo Interviews, Strategic Abstraction, Bullet Autonomy
  Principle, Metrics and Quantification, Safe Pair of Hands Positioning,
  Recruiter Outreach, Conciseness and Length, Fluff and Buzzword Elimination,
  and Technical Interview Preparation concept pages.
* **Inspiration**: Synthesized from Barbara Minto's *The Pyramid Principle*
  (2009 revised edition) and eleven open-source AI skill repositories, each
  contributing unique gems:
  - [smplx-c/minto-skill](https://github.com/smplx-c/minto-skill) — three
    logic rules, 7-step build, validation checks, epistemic discipline, tiered
    renderers (Tier A/B/C), depth levels, "never fabricate to fill a structure"
  - [welltraum/minto](https://github.com/welltraum/minto) — dose-the-Situation
    by audience, kind-comes-first table, mechanics-vs-reasons test, duplication
    test, 9-failure catalogue, scoring rubric, SCQA anti-patterns, chaining
    protocol
  - [millwright-labs/minto-pyramid-skill](https://github.com/millwright-labs/minto-pyramid-skill)
    — the Gate (when NOT to use pyramid), offer-rather-than-act, do-not-force-
    three, invent-nothing rule, when-not-to-use-it, red flags in a draft,
    hedging dissolves the claim, risks/next-steps as closing section
  - [damianof/minto-skill](https://github.com/damianof/minto-skill) — brutal
    Level 1 test (contestable, not a topic), 4-type evidence taxonomy, evidence
    strength classification (STRONG/WEAK/MISSING), principle piece vs case
    study piece, the subject test for openers
  - [ProfEullerBarros/minto-pyramid-principle](https://github.com/ProfEullerBarros/minto-pyramid-principle)
    — problem definition framework (R1/R2), diagnostic frameworks, logic trees,
    visual reflection, deduction vs induction choice at the Key Line
  - [tyroneross/pyramid-principle](https://github.com/tyroneross/pyramid-principle)
    — source-integrity layer, confidence contract (High/Medium/Low/Unverified),
    carry key terms parent→child, given-to-new information flow, grammatical
    parallelism, direct writing contract (specific actor + active verb +
    specific outcome)
  - [patrick204nqh/skills](https://github.com/patrick204nqh/skills) — BLUF vs
    Minto distinction ("BLUF is the lede; Minto is the whole pyramid"), one
    pyramid per doc, numbers over adjectives, restructure don't summarise,
    don't force pyramid onto bad reasoning, present options under a recommended
    one
  - [geb-algebra/writer-skill](https://github.com/geb-algebra/writer-skill) —
    multiple pyramid configuration with bridge questions, max 4 levels/4
    children constraints, don't use body-defined terms in introduction,
    final-draft information density
  - [that-in-rust/agent-room-of-requirements](https://github.com/that-in-rust/agent-room-of-requirements)
    — action ideas must state end products, seven common reader positions,
    issue analysis (yes-or-no questions), storyboarding workflow, common
    question shapes, news is not thinking, distinguish levels of action
  - [refoundai/lenny-skills](https://github.com/refoundai/lenny-skills) —
    SCR + Minto combined (SCR wraps, Minto structures the Resolution),
    burying the ask, ignoring the Situation, shared non-controversial facts
  - [santos-sanz/lifeskills](https://github.com/santos-sanz/lifeskills) —
    evidence + implication + risk triple, closing contract
    (decision/owner/date/next action), one governing question / reject
    multi-question drift, ask-before-drafting questions, output contract
* **Update**: Added the new concept page to the "Interview & Hiring Process"
  section in [index.md](index.md) and [overview.md](overview.md).

## 2026-08-02 (eighth revision — comprehensive gap fill: 27 new concept pages)

* **Audit**: Conducted a systematic gap audit of the bundle against the full
  candidate-side hiring pipeline. Identified 27 missing concepts across 8
  categories: interview formats, post-interview/offers, job search strategy,
  resume writing, career lifecycle, wellbeing/brand, and platform/positioning.
* **Addition**: Created 27 new concept pages via 6 parallel subagents:

  **Interview Formats (5):**
  - [technical-interview-preparation.md](technical-interview-preparation.md)
    — Coding interviews (live, whiteboard, IDE), system design (4-step
    framework), take-home assignments, think-out-loud protocol, LeetCode
    patterns, failure modes, stuck recovery
  - [behavioral-interview-framework.md](behavioral-interview-framework.md)
    — STAR/PAR/CAR methods, lead-with-result variant, 7-theme story bank
    (leadership, conflict, failure, ambiguity, influence, delivery, growth),
    common mistakes
  - [panel-group-interview.md](panel-group-interview.md) — Reading the room
    (decision-maker, skeptic, silent), redirect technique, managing dominant
    vs quiet panelists, breadth-over-depth calibration
  - [case-interview.md](case-interview.md) — Consulting-style cases: 4-step
    framework, MECE principle, case types (market sizing, profitability,
    M&A, market entry), math under pressure, cases outside consulting
  - [presentation-demo-interview.md](presentation-demo-interview.md) —
    Audience analysis, narrative arc, slide design, Q&A protocol,
    show-don't-tell for demos, common failure modes

  **Post-Interview & Offers (5):**
  - [interview-follow-up.md](interview-follow-up.md) — Thank you notes
    (timing, format, content), follow-up cadence, "no response is a
    response" principle
  - [offer-evaluation.md](offer-evaluation.md) — Total comp: base, equity
    (RSUs/ISOs/NSOs, vesting, cliffs, exercise windows, acceleration),
    bonuses, benefits, intangibles, offer comparison matrix, red flags
  - [counter-offer-dynamics.md](counter-offer-dynamics.md) — Statistics on
    counter-offer failure, why they rarely work, when one might make sense,
    handling script, burned bridge risk
  - [reference-management.md](reference-management.md) — Who to list, how to
    prepare them, what they'll be asked, "references available upon request"
    debate, coaching without scripting
  - [background-check-preparation.md](background-check-preparation.md) — Check
    types, disqualifiers, pre-emption, timelines, FCRA rights

  **Job Search Strategy (4):**
  - [job-search-strategy.md](job-search-strategy.md) — Funnel math, 70-20-10
    rule, tracking systems, pipeline concept, weekly cadence, stuck-stage
    diagnosis
  - [networking-relationship-building.md](networking-relationship-building.md)
    — Informational interviews, weak ties (Granovetter), give-before-you-ask,
    dormant tie reactivation, referral right/wrong way
  - [achievement-mining.md](achievement-mining.md) — Calendar archaeology,
    email/PM search, performance reviews, before/after framing, quarterly
    accomplishment inventory
  - [job-board-strategy.md](job-board-strategy.md) — Board landscape,
    easy-apply trap, referral-first principle, application timing

  **Resume Writing (4):**
  - [resume-format-selection.md](resume-format-selection.md) — Chronological
    vs functional vs hybrid, why functional triggers suspicion, stealth
    chronological technique
  - [section-selection.md](section-selection.md) — What to include/omit by
    seniority, optional sections, ordering conventions, skills section debate
  - [quantifying-leadership.md](quantifying-leadership.md) — Mentorship,
    culture-building, engineering excellence, org design, influence without
    authority metrics
  - [portfolio-work-samples.md](portfolio-work-samples.md) — GitHub repos,
    case studies, design/writing portfolios, portfolio-as-proof, maintenance

  **Career Lifecycle (5):**
  - [career-transition.md](career-transition.md) — Bridge strategy,
    credibility building, narrative pivot, transferable skills, stepping
    stone approach
  - [rejection-recovery.md](rejection-recovery.md) — Emotional dimension,
    asking for feedback, "no" as data (pattern diagnosis by stage), when to
    reapply
  - [resignation-offboarding.md](resignation-offboarding.md) — Resignation
    conversation, notice periods, exit interview, knowledge transfer,
    preserving relationships
  - [severance-negotiation.md](severance-negotiation.md) — What's negotiable,
    separation agreement, OWBPA timelines, when to involve a lawyer
  - [promotion-internal-mobility.md](promotion-internal-mobility.md) —
    Sponsorship vs mentorship, visibility, promotion case, internal transfer,
    the "stale" problem

  **Wellbeing & Brand (4):**
  - [burnout-job-search-fatigue.md](burnout-job-search-fatigue.md) — Search
    fatigue signs, search sprint approach, maintaining momentum, identity
    diversification, when to seek professional help
  - [personal-brand.md](personal-brand.md) — Speaking, writing, open
    source/community channels, give-before-you-ask, niche authority, when
    brand accelerates search
  - [remote-work-positioning.md](remote-work-positioning.md) — Remote-ready
    signals, remote interview, async communication, remote-first vs
    remote-friendly, red flags
  - [recruiter-outreach.md](recruiter-outreach.md) — Outbound contact: who
    to target, outreach message, follow-up cadence, recruiter network

* **Update: index.md**: Restructured into 11 sections (Resume System
  Architecture, Resume Content & Writing, Resume Structure & Scannability,
  Positioning & Strategy, Job Search Strategy, ATS & Platform Reality,
  Interview & Hiring Process, Offer & Negotiation, Career Lifecycle
  Management, Age Bias & Overqualification, Content Exclusion). Added all
  27 new concept pages with descriptions.
* **Update: overview.md**: Added all 27 new concepts to the synthesis
  sections, with new subsections for Job Search Strategy, Offer &
  Negotiation, and Career Lifecycle Management.
* **Bundle total**: Now 49 concept pages covering the full candidate-side
  hiring pipeline from resume architecture through severance negotiation.

## 2026-08-02 (seventh revision — pattern abstraction from candidate-specific specs)

* **Addition**: Created 9 new concept pages, abstracted from patterns
  documented candidate-specifically in the resume system AGENTS.md and
  STYLE-GUIDE.md but applicable to any job seeker:
  - [resume-architecture-and-lineage.md](resume-architecture-and-lineage.md)
    — Multi-tier resume system (archive → working resume → tailored
    variants), root-first lineage rule, single-use exception, extraction
    markers, YAML-primary model. The biggest missing concept — about the
    *system* of managing resume variants, not individual bullets.
  - [job-description-tailoring-workflow.md](job-description-tailoring-
    workflow.md) — 5-step process for tailoring a resume to a specific JD:
    ingest, gap analysis, mutate, verify ATS compatibility, output package.
    Distinct from application-strategy (which is about which jobs to target).
  - [chronological-accuracy-and-name-changes.md](chronological-accuracy-and-
    name-changes.md) — Time-appropriate names in archives, modern names in
    current documents, recognizability exception for rebranded employers,
    consistent date format, no unexplained gaps.
  - [award-and-recognition-framing.md](award-and-recognition-framing.md) —
    Three-part rule for internal awards: name in quotes, one-phrase
    explanation, link to business outcome. External vs internal award
    treatment.
  - [bullet-autonomy-principle.md](bullet-autonomy-principle.md) — Every
    bullet must stand alone with action, object, outcome. The sub-point trap.
    The action-object-outcome test. When to merge vs split.
  - [collaboration-framing.md](collaboration-framing.md) — Lead with
    strategic impact of collaboration, not participation. Three collaboration
    types (cross-functional, vendor, enterprise). The committee trap.
  - [credibility-section-for-senior-careers.md](credibility-section-for-
    senior-careers.md) — Condensing pre-2012 or early-career roles into a
    single narrative paragraph with metrics but no dates or role titles.
    Retains credibility signal without age signal. Distinct from age-bias-
    coded-language (what to remove) because this is about what to retain.
  - [application-funnel-stages.md](application-funnel-stages.md) — S0-S5
    funnel with measurable conversion objectives per stage. Stage-by-stage
    optimization. The optimization trade-off (never sacrifice S4 for S1).
    Context-specific variant selection.
  - [answer-sheet-terminology-guide.md](answer-sheet-terminology-guide.md)
    — Companion document explaining jargon, internal terms, and acronyms for
    reviewers. Living documentation. Not a resume artifact.
* **Update: linkedin-profile-optimization.md**: Expanded with 5 new sections
  from AGENTS.md §13 — Headline Strategy (formula, length, keyword load),
  About/Summary Section (5-part structure, tone, length), Experience Entries
  (narrative format, media attachments), Skills & Endorsements (pinned
  skills, search volume over precision, remove legacy), and Featured Section
  (highest-visibility content, recommended items). Updated frontmatter
  description and knowledge-basis date.
* **Update: index.md**: Added new "Resume System Architecture" section with
  4 concepts (Resume Architecture, Application Funnel Stages, JD Tailoring
  Workflow, Answer Sheet). Added 5 new concepts to existing sections: Bullet
  Autonomy, Award Framing, Collaboration Framing (Resume Content);
  Credibility Section (Resume Structure); Chronological Accuracy
  (Positioning). Updated LinkedIn description to reflect expanded content.
* **Update: overview.md**: Added new "Resume System Architecture" subsection
  to the concepts synthesis. Added 5 new concepts to existing subsections.
  Updated LinkedIn description. Updated frontmatter description, tags, and
  knowledge-basis date.
* **Source**: Internal observation — patterns documented candidate-
  specifically in the resume system AGENTS.md (§1-2, §4.6, §5.1, §8-11, §13,
  §14) and STYLE-GUIDE.md (§5.1-5.6) were identified as general practices
  applicable to any job seeker and abstracted into reusable concept pages.
  The bundle now covers the full system lifecycle: architecture → content →
  structure → positioning → platform → interview → negotiation, plus the
  cross-cutting concerns of age bias and content exclusion.

## 2026-08-02 (sixth revision — strategic abstraction & technology-outcome framing)

* **Addition**: Created 2 new concept pages:
  - [strategic-abstraction.md](strategic-abstraction.md) — Why the
    abstraction level of every bullet must match the seniority of the target
    role. Defines four altitudes (implementation, team, org, enterprise),
    the narrow-callout trap (singling out one technology when the actual
    impact was a broader pattern of organizational change), how to elevate
    altitude (identify pattern → list instances → name business outcome →
    scope the impact), when to stay at low altitude (IC roles, technical
    credibility sections, genuinely narrow achievements), and the altitude
    variety balance test by target role. Cross-references Ownership Verbs,
    Technology-Outcome Framing, Safe Pair of Hands, and Metrics.
  - [technology-outcome-framing.md](technology-outcome-framing.md) — Why
    every technology reference must be framed as a means to a business end.
    The Early-Adopter Trap: "early in its lifecycle" framing signals
    buzzword-chasing, recklessness, and fashion-following rather than
    strategic judgment. The two failures (technology as achievement,
    novelty as qualification). The three-part reframe structure (problem →
    technology as solution → outcome). The motivation test and the "so
    what" test. When technology can lead (ATS keyword matching). Age-signal
    overlap with "early" qualifiers. Cross-references Strategic Abstraction,
    Fluff Elimination, Ownership Verbs, Age Bias, and Safe Pair of Hands.
* **Update: index.md**: Added both new concept pages under the "Resume
  Content & Writing" section with descriptions.
* **Update: overview.md**: Added both new concepts to the Resume Content
  synthesis subsection.
* **Source**: Internal observation from a resume review — the "Evangelized
  Kubernetes" callout was judged insufficient at executive altitude, and
  "early in its lifecycle" was judged to signal technology-for-technology's-
  sake. Both observations generalized into reusable concepts.

## 2026-08-01 (fifth revision — standard interview questions)

* **Addition**: Created 1 new concept page:
  - [standard-interview-questions.md](standard-interview-questions.md) —
    Frameworks and generic fallback answers for the predictable questions
    nearly every interview asks. Covers the opening ("how are you"), the
    departure reason (pull factor over push factor), the employment gap,
    "why our company" (specificity requirement), the 5-year plan, the
    overqualified challenge (Value Multiplier Reframe), the
    underqualified challenge (transferable skills + ramp plan), management
    style, being-managed style, communication style, and a quick-reference
    table for other standard questions (tell me about yourself, greatest
    weakness/strength, why should we hire you, salary expectations,
    failure, conflict, motivation, interviewing elsewhere). Each question
    has a best-answer framework, a generic fallback, and a "what not to
    say" list. Closes with the Fallback Principle: forward-looking,
    role-relevant, red-flag-free, concrete enough to be credible.
* **Update: standard-interview-questions.md**: Added §11 "What questions
  do you have for me?" — the audience-aware question. Broken out by who
  is asking: recruiter screening call (process and role-fit questions),
  subordinate (psychological safety, management style, what to preserve
  vs. fix), peer (collaboration, decision-making, cross-team friction),
  manager (gaps, success definition, biggest challenge), and skip-manager
  (strategic altitude, business impact, funding and prioritization). Each
  audience gets best questions, a generic fallback, and "what not to ask."
  Includes a cross-audience safe question, a closing question, and the
  meta-strategy (always have questions, match to audience, ask one that
  emerged from the conversation, don't ask what the website answers, close
  forward-looking). Updated the quick-reference table entry and the
  frontmatter description to reference the new section.
* **Update: standard-interview-questions.md**: Added §12 "What concerns
  do you have about this role?" — the mirror image of §11, audience-aware
  by who can address the concern. Broken out by: recruiter (timeline,
  level, compensation band), subordinate (team buy-in, what's been tried),
  peer (cross-team friction, prioritization, tech debt), manager
  (resources, biggest risk, management style fit), and skip-manager
  (strategic priorities, funding trajectory). Includes the meta-strategy
  (always have one concern, frame as curiosity not complaint, match to
  audience, raise dealbreakers with recruiter privately), a cross-audience
  safe concern, and when to raise a real concern.
* **Update: standard-interview-questions.md**: Expanded the quick-reference
  table with 10 previously missing questions: "walk me through your
  resume," "what are you looking for in your next role," "what would you
  do in your first 30/60/90 days," "when can you start," "what do you do
  outside of work" / hobbies (cross-linked to Content Exclusion), "how do
  you stay current with technology," "what would your previous boss /
  direct reports say about you," "describe your ideal work environment,"
  "how do you handle stress / pressure," and "why did you choose this
  career path." Each gets a best-answer framework and a generic fallback.
* **Update: standard-interview-questions.md**: Added a full question
  index summary table cross-linking all 12 full sections and 21
  quick-reference questions, with an "audience-specific?" column marking
  only §11 and §12 as audience-specific (other-directed), and a
  "cross-reference" column linking to related concept pages. Closes with
  a rationale for why only §11 and §12 need the audience treatment.
* **Update: index.md**: Added the new concept page under the "Interview &
  Hiring Process" section, with updated description mentioning the
  audience-aware question.
* **Update: overview.md**: Added the new concept page to the Interview &
  Hiring Process synthesis (with updated description), and added it as a
  companion reference for the screening-call and interview pipeline stages.

## 2026-08-01 (fourth revision — content exclusion)

* **Addition**: Created 1 new concept page:
  - [content-exclusion-and-disclosure-prevention.md](content-exclusion-and-disclosure-prevention.md)
    — What must never appear in a resume or professional document:
    protected-class information (race, religion, gender, age, disability,
    marital status, national origin), controversial topics (politics,
    firearms, alcohol/tobacco, cannabis), personal/private information (SSN,
    full address, financial info), unprofessional content (email addresses,
    social media, hobbies), negative content (employer criticism, salary
    disputes), the disclosure audit checklist, and the "forward to a
    stranger" test.
* **Update: index.md**: Added new "Content Exclusion & Disclosure
  Prevention" section listing the concept page.
* **Update: overview.md**: Added new "Content Exclusion & Disclosure
  Prevention" subsection in the concepts synthesis.

## 2026-07-31 (third revision — source audit)

* **Source audit**: Conducted a systematic audit of all 10 source video
  notes in the 2ndbrain vault. Three subagents investigated: (1) the 2
  source files previously marked "out of scope," (2) the 5 ingested source
  files for missed content, and (3) the corrected 8 Secrets video for
  resume-relevant content.
* **Addition**: Created 1 new concept page:
  - [application-strategy.md](application-strategy.md) — Targeted
    applications outperform mass-applying, the cover letter question, and
    the quality-over-volume workflow (from Don Georgiovich)
* **Update: interview-strategy.md**: Added 5 new sections from "6 Secrets
  Hiring Managers Won't Tell You" — the benchmark candidate (fair process
  trap), the silver medalist strategy, managerial desperation increases
  risk aversion, the 5-minute decision (confirmation bias), and culture
  fit as bias shield (with tone mirroring tactic).
* **Update: recruiter-communication.md**: Added a major new section
  "Information Boundaries" from "The One Thing You Should Never Tell a
  Recruiter" — the full desk agency model, the interview lead trap, the
  confessional booth trap, 3 deflection scripts, what to never share, and
  communication best practices.
* **Update: ats-reality-vs-myths.md**: Added 4 new sections from the
  corrected 8 Secrets video — the OFCCP 100% qualification rule, why
  "instant" rejections happen, Workday's multi-column parsing failure, and
  the no-headshot-in-the-US rule.
* **Update: visual-scanning-patterns.md**: Added 3 new sections —
  "Communicate value, not a to-do list" (8 Secrets), first-page layout
  strategy with font specs (Don Georgiovich), and the 5-second first
  impression audit (Beat the ATS).
* **Update: fluff-and-buzzword-elimination.md**: Added 2 new sections —
  "Typos: The Silent Offer Killer" with the Google hiring manager anecdote
  (8 Secrets), and "The Objective Statement Debate" presenting both the
  mainstream (remove) and contrarian (keep, one line) views. Added the
  Google search audit technique to the Audit Method section.
* **Update: safe-pair-of-hands-positioning.md**: Added 2 new sections —
  the transferable skills translation framework (Ex Google Recruiter) and
  the Builder Trap / Fluff Strategy anti-patterns (Ex Google Recruiter).
* **Update: value-multiplier-reframe.md**: Added 2 new fears to the
  managerial fear list — team insecurity and room to grow (from "6 Secrets
  Hiring Managers Won't Tell You").
* **Update: index.md, overview.md**: Updated to reflect the new
  application-strategy.md page and the expanded descriptions of
  interview-strategy, recruiter-communication, and safe-pair-of-hands.

## 2026-07-31 (second revision)

* **Rename**: `resume-writing-best-practices` → `career-advancement-practices`.
  The original name was too narrow — the source videos cover the full
  candidate-side hiring pipeline (resume, ATS, interview, salary negotiation,
  recruiter communication), and several existing concept pages already
  contained interview strategy sections. Splitting into separate resume and
  interview bundles would force artificial boundaries on cross-cutting
  concepts (positioning, age-bias, recruiter psychology). The new name
  also leaves room to grow into promotion and internal mobility without
  another rename.
* **Addition**: Authored 3 new concept pages from the corrected
  "8 Secrets Recruiters Won't Tell You" video (Farah Sharghi,
  `iybdUPYXPEw`):
  - [interview-strategy.md](interview-strategy.md) — Team composition
    determines hiring, the fast-track scenario, OE/OA recruiter metrics,
    cultural fit (Googliness), and asking the right questions
  - [salary-negotiation.md](salary-negotiation.md) — Salary bands, sign-on
    bonuses as an alternative, the ramp-up-time justification, and scripts
    for the salary expectations question
  - [recruiter-communication.md](recruiter-communication.md) — Recruiters
    as professional matchmakers, the intake meeting pattern matching, and
    optimizing for recruiter discovery
* **Update**: Rewrote [overview.md](overview.md) to cover the full hiring
  pipeline (candidate perspective) with a pipeline-stage table mapping each
  stage to its gatekeeper, time budget, key signal, and concept page.
* **Update**: Rewrote [index.md](index.md) with the new bundle name and
  the 3 new concept pages under a new "Interview & Hiring Process" section.

## 2026-07-31 (initial)

* **Initialization**: Created the `resume-writing-best-practices` knowledge
  bundle to give evidence-backed resume writing practices a canonical,
  publicly-reachable home on `skills-releases`. Previously this knowledge
  existed only as individual YouTube video notes in a personal 2ndbrain
  vault, which were not reusable by other projects or consumers.
* **Creation**: Authored 13 concept pages:
  - [metrics-and-quantification.md](metrics-and-quantification.md) — X-Y-Z formula, 5+ metrics rule, quantifying hard-to-measure work
  - [conciseness-and-length.md](conciseness-and-length.md) — 475–600 word sweet spot, page-count by career stage, 3 best accomplishments rule
  - [visual-scanning-patterns.md](visual-scanning-patterns.md) — F-shaped scan, 7.4-second window, fold test
  - [fluff-and-buzzword-elimination.md](fluff-and-buzzword-elimination.md) — terms to purge, pronoun removal, adverb-to-evidence replacement
  - [ownership-verbs.md](ownership-verbs.md) — first word = seniority signal, verb lists to use/avoid
  - [keyword-engineering.md](keyword-engineering.md) — soft-skills gap, natural embedding, word cloud method, keyword mirroring
  - [safe-pair-of-hands-positioning.md](safe-pair-of-hands-positioning.md) — safety over brilliance, three pillars of results, explaining risk on the page
  - [proving-ground-principle.md](proving-ground-principle.md) — last 5–7 years as primary signal, weighting by recency, trimming older roles
  - [evidence-over-experience.md](evidence-over-experience.md) — entry-level strategy, strategic volunteering, personal projects as case studies
  - [ats-reality-vs-myths.md](ats-reality-vs-myths.md) — ATS as database not terminator, 5 myths debunked, knockout questions, human-first framework
  - [linkedin-profile-optimization.md](linkedin-profile-optimization.md) — bare profile decreases callbacks, headshot/banner, consistency rules, content strategy
  - [title-gap-bridging.md](title-gap-bridging.md) — parenthetical clarifiers, dot-connector summaries, functional titles
  - [age-bias-coded-language.md](age-bias-coded-language.md) — dog-whistle phrases, managerial fears, curation over hiding
  - [value-multiplier-reframe.md](value-multiplier-reframe.md) — repositioning overqualification as ROI, three reframe pillars, interview strategy
* **Creation**: Established [overview.md](overview.md) synthesis and this
  [index.md](index.md) directory listing.
* **Sources**: Synthesized from 6 YouTube video notes in the 2ndbrain vault
  covering recruiter interviews (Farah Sharghi, ex-Google recruiter), the
  Austin Belcak 125,484-resume study, eye-tracking studies (The Ladders), and
  age-bias navigation guidance.
