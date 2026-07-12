<!-- Managed by skills-src build pipeline. Do not edit; changes will be overwritten. -->
<!-- Generated from SKILL.md frontmatter + body by `just catalog` -->

# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time

> Category: **tech-maturity** · Status:  · Version: 1.0.0

Quantify, audit, and visualize a project's technical maturity. Supports both interactive and fully automated AI-driven assessments where AI examines codebases, configuration files, and documentation to score 42 engineering capabilities across 6 dimensions. Use this skill whenever the user asks to assess technical maturity, evaluate engineering practices, audit development processes, score software quality, measure DevOps maturity, analyze code quality practices, review testing coverage, evaluate CI/CD maturity, or wants to understand how mature their technical practices are compared to industry standards.

## Metadata

| Field | Value |
|-------|-------|
| Name | `tech-maturity` |
| Category | `tech-maturity` |
| Version | `1.0.0` |
| Status | `` |
| Owner |  |

## Tags
- `ai/skill`
- `tech-maturity`
- `assessment`
- `engineering-practices`
- `audit`
- `devops-maturity`

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

## References

- **Capabilities Rubric**: `references/capabilities.yaml` - The complete maturity assessment rubric with all capability definitions and scoring criteria
- **Rubric Guide**: `references/rubric-guide.md` - Comprehensive guide for interpreting and using the rubric effectively
- **Assessment Process**: `references/assessment-process.md` - Detailed step-by-step assessment workflow (automated and manual)
- **Assessment Script**: `scripts/assess_maturity.py` - Automated tool for conducting assessments and generating reports (supports --interactive, --automated, and --generate-guide modes)
- **Assessment Template**: `assets/assessments-template.json` - Template JSON file for automated assessments with all 42 capability keys
- **Tech Maturity Project**: https://github.com/techmaturity/techmaturity - Source of the assessment framework

## Related Skills
- **repository-health-review** (skill, complement) — Repository health review skill that complements technical maturity assessment
- **base-ai-guidance** (template, base-framework) — Shared framework for creating all AI guidance types

---

- **Full skill**: [`skills/tech-maturity/tech-maturity/SKILL.md`](skills/tech-maturity/tech-maturity/SKILL.md)
- **Install**: `npx skills add levonk/skills-releases`
- **Generated**: 2026-07-12T01:27:53Z
