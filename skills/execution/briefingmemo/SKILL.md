---
name: briefingmemo
description: >-
  Use when making high-stakes business decisions, strategic choices, partnership
  evaluations, or any decision requiring structured committee deliberation.
  Triggers on requests like 'help me decide', 'strategic decision', 'briefing
  memo', 'committee deliberation', or 'evaluate this decision'. Strategic
  decision-making system using multi-agent committee deliberation that
  transforms strategic questions into well-researched decisions through a
  structured committee process: (1) Create structured brief with required
  sections, (2) Research phase where committee requests additional information,
  (3) Committee deliberation with parallel debate and optional blind peer
  review, (4) CSO final decision memo with one concrete next step, (5)
  Post-decision review by specialized agents. 17-member committee includes
  dedicated Partnership & Opportunities Agent for strategic partnerships,
  government contracts, funding opportunities, and growth synergies, plus an
  Outsider member who catches curse-of-knowledge blind spots. Do NOT trigger
  on fast pressure-tests or "council this" requests (use think-assist instead),
  factual questions with one right answer, pure creation tasks, or
  summary/processing tasks.
version: "1.0.0"
date:
  created: "2026-06-25"
  updated: "2026-07-05"
  last-used: "2026-07-05"
tags:
  - ai/skill
  - decision-making
  - strategic-planning
  - multi-agent
  - committee-deliberation
  - briefing-memo
see-also:
  - skill: think-assist
    relationship: dependency
    description: Thinking-method library consumed by this skill's committee
  - skill: peer-review
    relationship: optional
    description: Blind peer-review round that can be added before the CSO memo
  - skill: ai-guidance-improver
    relationship: complement
    description: For improving guidance file quality
  - template: base-ai-guidance
    relationship: base-framework
    description: Shared framework for creating all AI guidance types
deliberation_protocol: situational-analysis
conflict_resolution: strategic-alignment
leadership_styles:
  - transformational
  - transactional
  - servant
  - autocratic
related_committees:
  - leadership-council
  - management-council
  - executive-strategy-committee
  - legendary-ceos
related_workflows:
  - conflict-resolution/consensus-building
  - conflict-resolution/expert-weighting
  - conflict-resolution/majority-voting
  - think-assist/references/second-order-thinking
  - think-assist/references/systems-thinking
  - think-assist/references/first-principles-thinking
  - think-assist/references/inversion
  - think-assist/references/devils-advocate
  - think-assist/references/scamper
  - think-assist/references/expansionist
  - think-assist/references/outsider
  - think-assist/references/executor
  - general/tasks/task-tracking-ticketr
---

{{{ include "includes/base-ai-guidance.md" . }}}

{{{ include "includes/trigger-guard.md" . }}}

# Briefing to Memo Strategic Decision System

## Overview
This skill implements a deterministic multi-agent decision-making system that transforms strategic questions into well-researched decisions through a structured committee process.

## Related Workflows

This skill integrates with and references the following:

- **Conflict Resolution**: [Consensus Building](../conflict-resolution/consensus-building.md), [Expert Weighting](../conflict-resolution/expert-weighting.md), [Majority Voting](../conflict-resolution/majority-voting.md)
- **Thinking Methods**: [Second-Order Thinking](../../general/think-assist/references/second-order-thinking.md), [Systems Thinking](../../general/think-assist/references/systems-thinking.md), [First Principles Thinking](../../general/think-assist/references/first-principles-thinking.md), [Inversion](../../general/think-assist/references/inversion.md), [Devil's Advocate](../../general/think-assist/references/devils-advocate.md), [SCAMPER](../../general/think-assist/references/scamper.md), [Expansionist](../../general/think-assist/references/expansionist.md), [Outsider](../../general/think-assist/references/outsider.md), [Executor](../../general/think-assist/references/executor.md) — all from the `think-assist` skill
- **Blind Review (optional)**: [Peer Review Protocol](../../general/peer-review/references/review-protocol.md) — can be added before the CSO memo to strip authority bias from committee debate
- **Task Management**: [Task Tracking with tkr](../general/tasks/task-tracking-ticketr.md), [BriefingMemo tkr Integration](../general/tasks/briefingmemo-tkr-integration.md)

### Integration Pattern
1. **Dynamic Selection**: BriefingMemo dynamically selects appropriate workflows based on decision characteristics
2. **Contextual Application**: Thinking models are chosen based on uncertainty and complexity levels
3. **Escalation Path**: Conflict resolution methods escalate from consensus → expert weighting → majority vote
4. **Bidirectional References**: Each workflow references back to BriefingMemo for decision context

## Process Flow

### Phase 1: Brief Creation
1. **Input**: Strategic question or decision point
2. **Create brief** using `scripts/create_brief.py` with required sections:
   - Situation/Debrief
   - Stakes (what's at risk)
   - Constraints (time, budget, legal, regulatory)
   - Key Questions
   - Context files (business metrics, product overview)

### Phase 2: Research Phase
1. **Determine decision significance** using brief analysis:
   - **Strategic Impact Level** (Critical/High/Medium/Low)
   - **Resource Commitment** ($$$/$$/$)
   - **Stakeholder Breadth** (Enterprise/Division/Team/Individual)
   - **Time Horizon** (Long-term/Medium-term/Short-term)
   - **Reversibility** (Permanent/Difficult/Easy/Reversible)
   - **Uncertainty Level** (High/Medium/Low)

2. **Filter research team based on significance**:
   - **Critical decisions**: Full research team (all analysts + Board consultants)
   - **High impact**: Core team (Data Scientist, Legal Analyst, Risk Analyst, Intelligence Analyst + Board advisors)
   - **Medium impact**: Essential team (Legal Analyst, Risk Analyst, Intelligence Analyst + Board consultants)
   - **Low impact**: Minimal team (Intelligence Analyst only + Board advisor)

3. **Select committee members based on decision type**:
   - **Financial decisions**: Financial/Investment Agent, Risk Management Agent, Compounder
   - **Customer decisions**: Customer/User Advocate, Product Strategist, Culture Agent
   - **Technical decisions**: Operations/Execution Agent, Technical Architect, Innovation/R&D Agent
   - **Strategic decisions**: CSO, Futurist, Moonshot, Contrarian, Partnership & Opportunities Agent
   - **Legal/Regulatory**: Legal/Compliance Agent, Risk Management Agent
   - **Market decisions**: Market Analyst, Customer/User Advocate, Financial/Investment Agent
   - **Partnership/Growth decisions**: Partnership & Opportunities Agent, Financial/Investment Agent, Market Analyst
   - **Organizational decisions**: Board Consultant, Culture Agent, Risk Management Agent, CSO

   *For full committee selection logic, research team filtering, and thinking model application details, see [references/committee-selection.md](references/committee-selection.md).*

4. **Apply specialized thinking models** based on complexity:
   - **High uncertainty**: Second-Order Thinking, Systems Thinking
   - **Complex stakes**: First Principles Thinking, Inversion
   - **Innovation needed**: SCAMPER, Devil's Advocate
   - **Consensus required**: Consensus Building workflow
   - **Expert opinions**: Expert Weighting method

5. **Poll committee members** for information needs using `scripts/poll_research_needs.py`
   - Each committee member identifies specific information gaps
   - Requests are based on their expertise and the brief context
   - Use Devil's Advocate to challenge assumptions and identify blind spots
   - Board consultants provide organizational structure and governance insights

6. [fork] **Research agents gather requested information**:
   - Data Scientist, Market Analyst, Industry Analyst, Legal Analyst, Technical Researcher, Customer Researcher, Risk Analyst, Historical Researcher, Psychological Analyst, Game Theory Analyst, Intelligence Analyst, Partnership Researcher

   *For detailed analyst role descriptions and research request mappings, see [references/analyst-roles.md](references/analyst-roles.md).*

7. **Compile research package** with all gathered information for committee review
   - Each committee member receives the research they requested
   - Plus relevant research from other agents for complete context

## Board Structure

### Board of Directors
The Board provides governance oversight and strategic guidance for organizational decisions:

#### Board Members
- **Chair of the Board** - Leads board meetings and strategic direction
- **Independent Directors** - External expertise and governance oversight
- **Executive Directors** - Internal leadership representation
- **Board Consultants** - Specialized advisors for organizational decisions

#### Board Committees
- **Strategy Committee** - Long-term strategic planning and direction
- **Risk Committee** - Enterprise risk management and compliance oversight
- **Governance Committee** - Corporate governance and policy development
- **Compensation Committee** - Executive compensation and succession planning

### Board Research Team
Specialized researchers supporting Board-level decisions:

#### Board Researchers
- **Organizational Structure Analyst** - Analyzes org design, hierarchy, and reporting relationships
- **Governance Specialist** - Corporate governance best practices and compliance
- **Compensation Analyst** - Executive compensation benchmarks and structures
- **Risk Governance Analyst** - Board-level risk oversight and enterprise risk management
- **Strategy Advisor** - Long-term strategic planning and board-level strategy development

#### Board Research Capabilities
- **Organizational Design Analysis** - Role ID systems, department structures, reporting relationships
- **Governance Framework Assessment** - Board composition, committee structures, governance best practices
- **Strategic Alignment Review** - Organizational structure alignment with strategic objectives
- **Risk Governance Evaluation** - Board-level risk oversight and enterprise risk management
- **Succession Planning** - Leadership development and executive succession strategies

### Board Integration with Briefing Process

#### Board Involvement Triggers
- **Organizational restructuring** decisions
- **Executive leadership changes**
- **Major strategic pivots**
- **Governance structure changes**
- **Risk management framework updates**
- **Compensation structure changes**

#### Board Consultation Process
1. **Board Consultant** participates in committee deliberations for organizational decisions
2. **Board Researchers** provide specialized analysis on organizational structure and governance
3. **Board Review** - Critical decisions reviewed by appropriate Board committee
4. **Board Approval** - Major organizational changes require Board approval
5. **Implementation Oversight** - Board monitors implementation of organizational decisions

### Reference Integration
This skill integrates with the **Organizational Development** skill for:
- Role ID system management and validation
- Organizational structure design and analysis
- Department restructuring and role changes
- Single source of truth maintenance
- Board-level organizational governance

*Reference: `~/p/gh/levonk/dotfiles/home/current/.chezmoitemplates/config/ai/skills/business/org-development/SKILL.md`*

### Phase 3: Committee Deliberation
1. **CSO (Chief of Strategy)** orchestrates deliberation using **situational-analysis** protocol
2. **Apply conflict resolution methods** based on disagreement level:
   - **Minor disagreements**: Consensus Building workflow
     - Position statements from each member
     - Common ground identification
     - Compromise proposals with 80%+ acceptance threshold
   - **Major disagreements**: Expert Weighting method
     - Weight votes by expertise relevance
     - Financial/Investment Agent weighted highest on financial matters
     - Legal/Compliance Agent weighted highest on regulatory matters
     - Customer/User Advocate weighted highest on customer impact
   - **Deadlocked decisions**: Majority Voting with veto power
     - CSO holds tie-breaking veto
     - Simple majority (50%+1) required
     - Must document dissenting opinions
3. **Optional blind peer-review round.** Before the CSO synthesizes, anonymize
   the committee responses and run a blind review round using the
   [peer-review](../../general/peer-review/SKILL.md) skill. This strips
   authority bias — the Financial Agent's opinion gets evaluated on merit, not
   on the title. Each reviewer answers: (1) which response is strongest, (2)
   which has the biggest blind spot, (3) what did all responses miss. The CSO
   receives the de-anonymized bundle plus all reviews. Recommended for
   high-stakes decisions where authority deference is a real risk; skip for
   time-constrained deliberations.
4. **Parallel debate** among committee members with enhanced personas:
   - Financial/Investment Agent: ROI, IRR, financial modeling
   - Legal/Compliance Agent: Regulatory risks, compliance issues
   - Customer/User Advocate: Customer experience impact
   - Market Analyst: Competitive landscape, market sizing
   - Statistician: Data analysis, statistical significance
   - Operations/Execution Agent: Implementation feasibility
   - Culture Agent: Team and company culture impact
   - Futurist: Long-term trends and implications
   - Risk Management Agent: Risk identification and mitigation
   - Innovation/R&D Agent: Technology and innovation implications
   - Compounder: Multi-year compounding advantages
   - Product Strategist: Product-centric decisions
   - Contrarian: Challenges consensus
   - Moonshot: 10x thinking, "what if we're thinking too small?"
   - Outsider: Zero context, fresh eyes — catches curse of knowledge and insider groupthink
   - Technical Architect: Technical feasibility
   - Partnership & Opportunities Agent: Strategic partnerships, growth opportunities, ecosystem expansion
5. **Integrate thinking models** during deliberation:
   - **Second-Order Thinking**: Analyze long-term consequences
   - **Systems Thinking**: Understand interconnected impacts
   - **First Principles**: Break down to fundamental truths
   - **Inversion**: Consider opposite approaches
   - **Devil's Advocate**: Actively challenge consensus
6. **Partnership & Opportunities Agent** specializes in:
   - **Partnership Identification**: Strategic alliance opportunities across industry sectors
   - **Build/Buy Analysis**: Make vs partner vs acquire decision frameworks
   - **Novel Use Cases**: Unconventional applications and market expansions
   - **Charity Strategy**: New charity creation vs collaboration with existing nonprofits
   - **Government Contracts**:
     - Federal opportunities (SAM.gov, Grants.gov, defense contracts)
     - State and local government procurement
     - International government opportunities (UK Crown Commercial, EU procurement, etc.)
     - Contract vehicle eligibility (8(a), HUBZone, SDVOSB, WOSB)
     - GSA Schedule and other contract vehicles
   - **Current Opportunities**:
     - Real-time funding opportunities (VC, PE, angel, strategic investors)
     - Active partnership inquiries and collaboration requests
     - Grant opportunities and RFPs
     - M&A opportunities and strategic acquisitions
     - Joint venture proposals
   - **Cross-Sector Synergy**: Identifying unexpected collaborations and joint ventures
   - **Ecosystem Mapping**: Visualizing partnership networks and value chains
7. **Time constraints**: Default 5 minutes deliberation
8. **Budget constraints**: Default $5 compute budget
9. **Leadership Style Integration**: Each agent embodies a leadership style:
   - Transformational agents inspire and innovate
   - Transactional agents focus on rewards and performance
   - Servant agents prioritize team and stakeholder needs
   - Autocratic agents provide decisive direction when needed

### Phase 4: Decision Memo
1. **CSO creates final memo** with:
   - Decision framework
   - Top recommendations
   - Committee stances (vote count)
   - Resolved and unresolved tensions
   - Next actions
   - Risk assessment
   - **The one thing to do first** — a single concrete next step, not a list. This is the anti-pattern-corrective against producing 10-item action lists. The user can figure out steps 2-10 once they've done step 1. See the [chairman verdict template](../../general/think-assist/references/chairman-verdict-template.md) in think-assist for the rationale.

### Phase 5: Post-Decision Review (Non-influential)
After decision completion, these agents provide perspectives without influencing the decision:
- **Culture Agent**: Cultural implications
- **Philanthropic Agent**: Social impact considerations
- **Environmental Agent**: Environmental impact assessment

## Deterministic Execution

### Fixed Parameters
- Deliberation time: 5 minutes (configurable)
- Compute budget: $5 (configurable)
- Committee composition: 17 members (fixed)
- Decision threshold: Simple majority (default)

### Randomization Control
- Agent response order: Alphabetical by role
- Speaking turns: Round-robin with equal time
- **Conflict Resolution**: Uses **strategic-alignment** method:
   - Context-matching for situational awareness
   - Team-needs-prioritization for stakeholder alignment
   - Strategic-alignment for business objective coherence
   - Principle-weighting for value-based decisions

## Usage Instructions

### Interactive Mode (Recommended)
Launch the TUI interface for full briefing management:
```bash
python3 scripts/manage_briefings.py --tui
```

This provides:
- 📝 Create new briefings with guided input
- ⏳ View and manage pending briefings
- 🔄 Track in-progress deliberations
- ✅ Browse completed decisions
- 🔍 Search through all briefings
- ⚙️ Configure settings

### Starting a Decision
```bash
# Quick start with existing briefing
python3 scripts/start_deliberation.py --brief path/to/brief.md

# With custom parameters
python3 scripts/start_deliberation.py --brief path/to/brief.md --time 10 --budget 10

# Skip research phase
python3 scripts/start_deliberation.py --brief path/to/brief.md --skip-research
```

### Briefing Management
```bash
# List all briefings
python3 scripts/manage_briefings.py --list

# Create new briefing (quick mode)
python3 scripts/manage_briefings.py --create "Strategic Partnership Decision"

# Launch TUI interface
python3 scripts/manage_briefings.py --tui
```

### Creating Brief Template
```bash
scripts/create_brief.py --template --output "new_brief.md"
```

### Customizing Committee
Edit `config/committee.yaml` to adjust:
- Agent roles and personas
- Model assignments (default: Sonnet 4.6 for committee, Opus 4.6 for CSO)
- Expertise file paths
- Interaction patterns

## File Structure
```
briefingmemo/
├── SKILL.md
├── scripts/
│   ├── manage_briefings.py      # TUI briefing management system
│   ├── start_deliberation.py    # Main deliberation orchestrator
│   ├── create_brief.py          # Brief creation template
│   ├── poll_research_needs.py   # Research phase polling
│   ├── gather_research.py        # Research data gathering
│   ├── orchestrate_deliberation.py  # Committee deliberation engine
│   ├── generate_memo.py         # Decision memo generation
│   └── post_decision_review.py  # Post-decision analysis
├── briefings/                    # Active briefings directory
│   ├── briefing_YYYYMMDD_HHMMSS.md
│   └── history/                  # Completed briefings
│       └── completed_YYYYMMDD_HHMMSS_*.md
├── references/
│   ├── brief_template.md
│   ├── committee_roles.md
│   ├── analyst-roles.md          # Detailed analyst role descriptions
│   ├── committee-selection.md    # Committee member selection logic
│   ├── decision_framework.md
│   └── memo_template.md
├── config/
│   ├── committee.yaml
│   ├── deliberation_params.yaml
│   └── agent_personas.yaml
├── outputs/
│   ├── dynamic_sections/         # Generated memo sections
│   └── committee_templates/      # Template references
└── assets/
    ├── memo_templates/
    └── decision_frameworks/
```

## Related Committees
This skill integrates with and references the following committees:
- [Leadership Council](../committees/business/leadership-council.md) - Leadership style integration
- [Management Council](../committees/business/management-council.md) - Team management approaches
- [Executive Strategy Committee](../committees/business/executive/executive-strategy-committee.md) - Strategic alignment
- [Legendary CEOs Council](../committees/legendary-ceos-council.md) - Wisdom synthesis patterns

## Key Principles

1. **Structured Input**: All briefs must follow the template format
2. **Research First**: Committee always has access to relevant data
3. **Parallel Processing**: All agents deliberate simultaneously
4. **Adversarial Design**: Agents have conflicting perspectives to expose all angles
5. **Opportunity-Centric**: Partnership & Opportunities Agent ensures all growth avenues are explored
6. **Post-Decision Review**: Cultural, philanthropic, and environmental impacts assessed after decision

## Error Handling
- Invalid briefs: Auto-reject with specific feedback
- Time/budget exceeded: Graceful termination with partial results
- Agent failures: Continue with available agents, log failures
- Research gaps: Proceed with available information, note gaps

## Output Formats
- **Decision Memo**: Structured markdown with decision rationale
- **Committee Transcript**: Full deliberation log
- **Research Package**: Compiled data and sources
- **Post-Decision Review**: Cultural, social, environmental assessment

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/execution/briefingmemo/SKILL.md`
- Scripts: `scripts/create_brief.py`, `scripts/poll_research_needs.py`
- References: `references/*.md`

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles
