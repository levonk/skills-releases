---
modeline: "vim: set ft=markdown:"
title: "ADR: 3D Modeling Technology Stack Decision"
adr-id: "adr20250203001"
slug: "3d-modeling-technology-stack-decision"
url: "https://github.com/levonk/dotfiles/blob/master/home/current/.chezmoitemplates/config/ai/skills/cad/doc/adr/adr-20250203-001-3d-modeling-technology-stack-decision.md"
synopsis: "Comprehensive analysis and decision framework for selecting appropriate 3D modeling tools based on use case requirements"
author: "https://github.com/levonk"
date-created: "2025-02-03"
date-updated: "2025-02-03"
date-review: "2025-08-03"
date-triggers: ["2025-02-03"]
version: "1.0.0"
status: "accepted"
aliases: []
tags: [doc/architecture/adr, cad/3d-modeling, technology-selection]
supersedes: []
superseded-by: []
related-to: []
scope:
  impact-scope: ["CAD workflows", "3D printing pipelines", "Engineering design processes"]
  excluded-scope: ["2D design tools", "Animation pipelines", "VFX workflows"]
---

# Decision Record: 3D Modeling Technology Stack Decision

---

## Context

The challenge of selecting appropriate 3D modeling tools has become increasingly complex with the proliferation of open-source solutions. Users frequently struggle with understanding whether tools like OpenSCAD and FreeCAD are redundant or serve different purposes. This decision establishes a framework for tool selection based on specific use cases and technical requirements.

### Source Analysis

This decision is based on comprehensive analysis from `3D Modelling.md`, which provides detailed comparisons of five distinct pillars of open-source 3D modeling as of 2025.

## Constraints

- Tools must be open-source (FOSS) to ensure accessibility and long-term sustainability
- Solutions must support both GUI and programmatic workflows where applicable
- Compatibility with standard manufacturing formats (STEP, STL) required for engineering use cases
- Setup complexity must be appropriate for target user skill level

## Decision

Establish a **five-pillar framework** for 3D modeling tool selection, recognizing that each tool serves distinct, non-redundant purposes:

1. **OpenSCAD** - Mathematical, stateless CSG modeling
2. **FreeCAD** - Complete mechanical engineering lifecycle
3. **Blender** - Organic modeling and digital artistry
4. **build123d/CadQuery** - Professional code-driven CAD
5. **Blender123d** - Hybrid precision and artistic workflows

## Rationale

The analysis reveals that these tools are fundamentally different in their mathematical foundations and target use cases:

- **CSG vs B-Rep**: OpenSCAD uses Constructive Solid Geometry (stateless, mathematical) while FreeCAD/build123d use Boundary Representation (surface-aware, engineering-grade)
- **Functional vs Procedural**: OpenSCAD is declarative/functional while Python-based tools are procedural/object-oriented
- **Specialization**: Each tool excels in specific domains - OpenSCAD for parametric parts, FreeCAD for engineering analysis, Blender for organic modeling

## Technical Approach

### Tool Selection Matrix

| Use Case | Recommended Tool | Rationale |
|----------|------------------|-----------|
| **Simple 3D printed brackets** | OpenSCAD | Code stability, instant results, minimal setup |
| **Complex mechanical assemblies** | FreeCAD | Native FEM, CAM, technical drawings |
| **Organic sculptures** | Blender | World-class sculpting and rendering |
| **Professional code-CAD** | build123d | Modern Python API, algorithmic stability |
| **Precision + artistic workflow** | Blender123d | CAD precision in Blender environment |

### Implementation Guidelines

1. **Assess primary use case** - Start with functional requirements
2. **Consider technical constraints** - File formats, precision needs, manufacturing requirements
3. **Evaluate user expertise** - Programming comfort vs GUI preference
4. **Plan for integration** - Multi-tool workflows when necessary

## Affected Components

- **CAD skill development paths** - Training materials must reflect tool-specific strengths
- **Template libraries** - Different paradigms require different template structures
- **Integration scripts** - File format conversion and workflow automation
- **User onboarding** - Clear guidance on tool selection for new users

## Consequences

### Positive

- **Clear decision framework** eliminates tool selection confusion
- **Optimized workflows** by matching tools to appropriate use cases
- **Reduced learning curve** by focusing on relevant tool features
- **Future-proof architecture** accommodating emerging tools like build123d

### Negative

- **Increased complexity** in maintaining expertise across multiple tools
- **Integration overhead** for multi-tool workflows
- **Training requirements** expanded to cover multiple paradigms

### Neutral

- **Storage requirements** for multiple tool installations

- **Documentation maintenance** across different tool ecosystems

## Alternatives Considered

### Single Tool Approach

- **Pros**: Simpler maintenance, unified workflow
- **Cons**: Significant functionality compromises, tool limitations in key areas

### Commercial Software Adoption

- **Pros**: Often more polished, integrated support
- **Cons**: Cost, vendor lock-in, FOSS philosophy misalignment

## Rollout / Migration

1. **Documentation updates** - Update skill descriptions and selection guides
2. **Template organization** - Structure templates by tool paradigm
3. **Training materials** - Create tool-specific learning paths
4. **Integration scripts** - Develop format conversion utilities
5. **Community guidance** - Publish decision matrix for users

## To Investigate

- **Emerging tools** - Monitor new developments in the 3D modeling space
- **Integration patterns** - Best practices for multi-tool workflows
- **Performance benchmarks** - Objective comparisons for specific use cases
- **User experience studies** - Real-world effectiveness of tool recommendations

## Validation

This decision will be evaluated based on:
- **User success rates** in selecting appropriate tools
- **Workflow efficiency** improvements in 3D modeling tasks
- **Community feedback** on tool recommendation accuracy
- **Technology adoption** patterns in the CAD skill ecosystem

## Review Schedule

Review this decision quarterly (every 3 months) or when significant new tools emerge in the 3D modeling landscape.

## Notes

- Current state of tool comparisons belong in the source analysis document
- Implementation details belong in tool-specific skill directories
- User guidance belongs in README and selection matrix documents

## References

- [Source Analysis Document](3D%20Modelling.md)
- [OpenSCAD Official Site](https://openscad.org/)
- [FreeCAD Official Site](https://www.freecad.org/)
- [Blender Official Site](https://www.blender.org/)
- [build123d Repository](https://github.com/gumyr/build123d)
- [CadQuery Repository](https://github.com/CadQuery/cadquery)
- [CAD Sketcher for Blender](https://github.com/hannesdelbeke/cad-sketcher)

<!-- vim: set ft=markdown: -->
