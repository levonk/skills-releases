---
name: tech-maturity
description: Quantify, audit, and visualize a project's technical maturity using the Tech Maturity rubric from techmaturity.github.io. Supports both interactive and fully automated AI-driven assessments where Claude examines codebases, configuration files, and documentation to score 42 engineering capabilities across 6 dimensions. Use this skill whenever the user asks to assess technical maturity, evaluate engineering practices, audit development processes, score software quality, measure DevOps maturity, analyze code quality practices, review testing coverage, evaluate CI/CD maturity, or wants to understand how mature their technical practices are compared to industry standards.
version: 1.0.0
date:
  created: "2026-06-05"
  updated: "2026-07-02"
  last-used: "2026-07-02"
tags: ["ai/skill", "tech-maturity", "assessment", "engineering-practices", "audit", "devops-maturity"]
see-also:
  - skill: "repository-health-review"
    relationship: "complement"
    description: "Repository health review skill that complements technical maturity assessment"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
---

{{{ include "includes/base-ai-guidance.md" . }}}

# Tech Maturity

Assess and quantify technical maturity across six dimensions: Code, Build & Test, Release, Operations, Security, and Architecture. Use the established rubric from the Tech Maturity project to provide objective, scored evaluations of engineering practices.

## Quick Start

### Interactive Assessment
For manual assessment with guided prompts:

```bash
python scripts/assess_maturity.py /path/to/project --interactive
```

### AI-Driven Automated Assessment
For fully automated AI-driven assessment:

1. Generate an analysis guide:
```bash
python scripts/assess_maturity.py /path/to/project --generate-guide
```

2. [fork] Use the analysis guide to examine the project and score each capability based on evidence

3. Create a JSON file with assessments:
```json
{
  "assessments": {
    "a1": 3,
    "a2": 2,
    "a3": 3,
    ...
  }
}
```

4. Generate the report:
```bash
python scripts/assess_maturity.py /path/to/project --automated assessments.json
```

## Assessment Dimensions

The Tech Maturity rubric evaluates six key areas:

### A. Code
- Code commenting strategy and documentation
- Code management and branching strategy
- Test suite coverage and quality
- Logging and telemetry practices
- Backward/forward compatibility
- Monitoring and alerting
- Quality engineering model
- Code reuse practices
- Availability and resilience testing
- Incremental coding and prototyping
- Feedback and requirements gathering
- Behavior-driven development

### B. Build and Test
- Definition of done completeness
- Code quality metrics
- Security code analysis
- Automated testing
- Continuous integration
- Performance testing and capacity planning
- Configuration file management
- Service consumer tests

### C. Release
- Deployment strategy
- Release automation
- Documentation
- Release communication

### D. Operations
- Incident management
- Monitoring and observability
- Disaster recovery
- Capacity planning
- Change management

### E. Security
- Security policies
- Vulnerability management
- Security testing
- Incident response
- Compliance

### F. Architecture
- System design
- Scalability
- Modularity
- Data management
- Integration patterns

## Scoring System

Each capability is scored on a 1-4 scale:

- **Level 1**: Initial/ad-hoc processes
- **Level 2**: Defined and documented processes
- **Level 3**: Established and standardized processes
- **Level 4**: Optimized and continuously improving

Some capabilities have minimum required levels (specified in the rubric).

## Instructions

The skill supports both interactive and fully automated AI-driven assessment. For the detailed step-by-step process — including the automated assessment workflow, manual assessment steps (Gather Context, Evaluate Capabilities, Generate Report, Analyze Results, Create Improvement Plan), and best practices — see `references/assessment-process.md`.

### Quick Reference

- **Interactive**: `python scripts/assess_maturity.py /path/to/project --interactive`
- **Automated**: Generate guide → examine artifacts → score 42 capabilities → run script → present findings
- **Best practices**: Evidence-based scoring, look for patterns, consider context, document rationale, flag uncertainties

## Examples

### Example 1: AI-Driven Assessment

User: "Assess the technical maturity of my web application project."

Claude's automated workflow:
1. Generates analysis guide with 42 capability definitions and hints
2. Examines project structure, CI/CD configs, documentation, and code
3. Systematically scores each capability based on evidence found:
   - a1 (Code Commenting): Level 3 - Good docstrings and comments
   - a2 (Code Management): Level 2 - Feature branches but >2 weeks lifetime
   - a3 (Test Suite): Level 2 - Basic unit tests, limited integration tests
   - [continues for all 42 capabilities]
4. Generates assessment JSON with all scores
5. Runs assessment script to calculate dimension scores and compliance
6. Presents maturity report with overall score 2.3/4.0, identifies gaps in testing (a3 requires Level 3), and provides prioritized recommendations

### Example 2: Web Application Assessment

Assess a typical web application project:

1. **Code**: Evaluate Git workflow, code review practices, testing coverage
2. **Build & Test**: Review CI pipeline, automated testing, code quality tools
3. **Release**: Check deployment automation, rollback procedures
4. **Operations**: Assess monitoring, alerting, incident response
5. **Security**: Review security scanning, vulnerability management
6. **Architecture**: Evaluate system design, scalability approaches

### Example 2: Microservices Assessment

For a microservices architecture, pay special attention to:
- Service communication patterns
- Distributed tracing
- Configuration management
- Deployment orchestration
- Inter-service testing
- API documentation

### Example 3: Legacy System Assessment

When assessing legacy systems:
- Note technical debt and constraints
- Focus on incremental improvement opportunities
- Identify quick wins that can build momentum
- Consider modernization pathways

## Assessment Best Practices

- **Be objective**: Base scores on evidence, not intentions
- **Use examples**: Document specific examples for each score
- **Involve the team**: Get input from practitioners, not just observations
- **Consider context**: Account for project size, team size, and business constraints
- **Track changes**: Re-assess periodically to measure improvement
- **Benchmark**: Compare against similar projects when possible

## Common Patterns

### Typical Maturity Progression

Most projects follow this progression:
- Start with Level 1-2 in Code and Build & Test
- Improve Build & Test to Level 3-4 before advancing Release
- Operations and Security often lag behind initial development
- Architecture maturity grows with system complexity

### Red Flags

Watch for these warning signs:
- Level 1 in critical security capabilities
- No minimum level compliance in any dimension
- Large gaps between dimensions (e.g., Level 4 Code but Level 1 Operations)
- No testing or CI/CD in place

### Quick Wins

Common high-impact improvements:
- Set up basic CI/CD pipeline
- Add automated testing
- Implement code review process
- Set up basic monitoring and logging
- Document deployment procedures

## References

- **Capabilities Rubric**: `references/capabilities.yaml` - The complete maturity assessment rubric with all capability definitions and scoring criteria
- **Rubric Guide**: `references/rubric-guide.md` - Comprehensive guide for interpreting and using the rubric effectively
- **Assessment Process**: `references/assessment-process.md` - Detailed step-by-step assessment workflow (automated and manual)
- **Assessment Script**: `scripts/assess_maturity.py` - Automated tool for conducting assessments and generating reports (supports --interactive, --automated, and --generate-guide modes)
- **Assessment Template**: `assets/assessments-template.json` - Template JSON file for automated assessments with all 42 capability keys
- **Tech Maturity Project**: https://github.com/techmaturity/techmaturity - Source of the assessment framework

## Output Formats

The assessment generates several outputs:

1. **JSON Report**: Machine-readable scores and metadata
2. **HTML Report**: Interactive visualizations and detailed analysis
3. **Radar Chart**: Visual representation of maturity across dimensions
4. **Bar Charts**: Score breakdowns by capability
5. **Recommendations**: Prioritized improvement suggestions

## Integration with Development Workflows

Consider integrating maturity assessments into:
- Project onboarding and due diligence
- Quarterly engineering health checks
- Pre-acquisition technical due diligence
- Team retrospective processes
- Architecture review processes
- Compliance audits

## Context Declaration

### File Paths
- Main skill: `config/ai/skills/tech-maturity/SKILL.md`
- Scripts: `scripts/assess_maturity.py`
- References: `references/capabilities.yaml`, `references/rubric-guide.md`, `references/assessment-process.md`
- Assets: `assets/assessments-template.json`

### Related Skills
- repository-health-review (complement)
- base-ai-guidance (base-framework)

### Project Information
- Project: levonk/dotfiles
- Repository: https://github.com/levonk/dotfiles