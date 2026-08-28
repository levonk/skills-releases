---
type: Practice
title: Procedures, Lists, and Transitions
description: Normative rules for procedural instructions and lists in technical documentation — front-load important information, write introductory sentences, format single-step and multi-step procedures, choose bullet vs numbered lists, structure list items, and use transitions to connect ideas. Applies to all technical prose output.
tags: [technical-writing, ste100, simplified-technical-english, documentation, procedures, lists, transitions, instructions]
date:
  created: "2026-08-26"
  knowledge-basis: "2026-08-26"
  last-used: "2026-08-26"
sources:
  - id: proxmox-twsg
    resource: "https://pve.proxmox.com/wiki/Technical_Writing_Style_Guide"
    title: "Proxmox VE Technical Writing Style Guide"
  - id: asd-ste100
    resource: "https://www.asd-ste100.org/"
    title: "ASD-STE100 Simplified Technical English specification"
---

# Procedures, Lists, and Transitions

Procedures and lists are the most-read parts of technical documentation. Readers
scan them, skip to them, and execute them. Wrong procedure formatting causes
errors. This page defines the rules for writing procedures, formatting lists,
and using transitions to connect ideas.

For the core clarity principles (imperative mood, active voice, short
sentences), see [Simplified Technical English](simplified-technical-english.md).
For punctuation within lists, see [Punctuation](punctuation.md).

## Front-Load Important Information

Put the important information at the beginning of the sentence. State the
purpose of an action before the action itself. This lets the reader skip the
instruction if the purpose does not apply.

**Avoid (purpose after action):**
> Click Delete if you want to delete the entire document.

**Use (purpose before action):**
> To delete the entire document, click Delete.

**Avoid (purpose after action):**
> To enable quick integration with third-party tools, the platform offers a
> REST API.

**Use (purpose before action):**
> The platform offers a REST API to enable quick integration with third-party
> tools.

## Procedures

A procedure is a sequence of numbered steps for accomplishing a task.

### Procedure Format

- **Add a heading** so readers find the instructions quickly. Use the same
  phrasing style for all procedure headings in a document (for example,
  "Closing the Program", "Starting the Service").
- **Make each step specify one action.** Each step must answer "What do I do
  next?" with one meaningful action.
- **Use parallel structure** across all steps in a procedure.
- **Use the imperative verb form** (tell the reader what to do). See
  [Simplified Technical English](simplified-technical-english.md) Rule 4.

### Introductory Sentence

Introduce a procedure with an introductory sentence that provides context. Do
not repeat the heading.

**Example:**
> To configure the network, follow these steps:

### Single-Step Procedures

Use a bullet for a procedure with only one step. Do not use a numbered list for
a single step.

**Example:**
> **Closing the Program**
> - To close the program, choose Exit on the File menu.

### Numbered Procedures

Use a numbered list for procedures with two or more steps. Label sub-steps with
lowercase letters. Label sub-sub-steps with lowercase Roman numerals.

**Example:**
> 1. First, configure the network, as follows:
>    a. Set the IP address.
>    b. Set the subnet mask. There is no third part.
>       i. Confirm the prefix length.
>       ii. Save the configuration.
> 2. Next, restart the network service.

### Combine Related Actions Into One Step

If the user must press Enter or confirm an action after a step, include that
instruction as part of the same step. Do not split a single interaction across
two steps.

**Avoid (split interaction):**
> 1. Click the search box, then type the query.
> 2. Press Enter.

**Use (combined step):**
> 1. Click the search box, then type the query and press Enter.

### State Purpose Before Action in Steps

Within a procedure step, state the purpose before the action (same principle as
front-loading).

**Avoid:**
> Click File > New > Document to start a new document.

**Use:**
> To start a new document, click File > New > Document.

## Lists

Lists make prose concise. Use them to pull items out of a paragraph for
clarity.

### When to Create a List

- **Three or more items in running text** — pull them out of the paragraph and
  format them as a list.
- **Options with no required order** — use a bullet list.
- **Items the reader must perform or read in order** — use a numbered list.
- **Keep lists simple and short.** If a list grows past 10 items, consider
  splitting it into sub-lists or a table.

### List Item Structure

- **Term and definition** — boldface the term, plain text the definition.
  > **USB flash drive** — the recommended installation medium.
- **Link and description** — put the link first, indent the description
  underneath.
  > [Documentation](https://example.com/docs)
  >   — User-facing guides and references.

### Consistency Within a List

Keep the style consistent within a single list. Do not mix full sentences with
fragments.

**Full sentences (with punctuation):**
> - The build copies the file into the image.
> - The image runs the entrypoint.
> - The pipeline pushes the image to the registry.

**Fragments (without end punctuation):**
> - Copy the file into the image
> - Run the entrypoint
> - Push the image to the registry

Do not mix the two styles in one list. Either all items end with a period, or
none do.

## Transitions

Transitions are words or phrases that connect one idea to the next. Use
transitions to clarify the relationships between ideas. Sometimes adding "for
example" or "in other words" at the start of a sentence improves the flow.

### Transition Categories

| Purpose | Transition words |
|---------|-----------------|
| Add to a previous point | and, or, nor, furthermore, also, moreover, in addition, first, second |
| Illustrate or expand a point | for instance, for example, similarly, likewise |
| Summarize or emphasize | therefore, thus, so, hence, consequently, in other words, in short, in conclusion |
| Qualify or restrict | frequently, occasionally, in general, specifically, in particular, usually |
| Shift to a different point or signal contradiction | but, however, yet, on the contrary |
| Make a concession | although, though, whereas |
| Connect an explanation to a statement | because, as, since, for |
| Qualify a general idea | if, provided, in case, unless, when |

### Transitions for Procedures

In procedural text, use sequence transitions to signal the order of steps.

> first, second, third, then, next, after, before, subsequently, prior to,
> previously, simultaneously, following, later, earlier, as soon as, until,
> once

Do not overuse transitions. If the numbered list already signals order, the
transition word is redundant. Use transitions in prose between steps, not
inside numbered steps that already have numbers.

## Quick Self-Check

Before publishing, check procedures and lists:

- [ ] Does every procedure step state the purpose before the action?
- [ ] Does every procedure have a heading?
- [ ] Are single-step procedures formatted as bullets, not numbered lists?
- [ ] Are sub-steps labeled with lowercase letters and sub-sub-steps with Roman
      numerals?
- [ ] Are related actions (like pressing Enter) combined into one step?
- [ ] Are bullet lists used for unordered items and numbered lists for ordered
      items?
- [ ] Is the style consistent within each list (all sentences or all fragments)?
- [ ] Do term-and-definition list items bold the term?
- [ ] Are transitions used to clarify relationships between ideas (not
      redundantly inside numbered steps)?

## Cross-References

- Core guidelines: [Simplified Technical English](simplified-technical-english.md)
- Full writing rules and self-check: [Detailed Guide](detailed-guide.md)
- Punctuation: [Punctuation](punctuation.md)
- Capitalization and articles: [Capitalization and Articles](capitalization.md)
- Word choice and consistency: [Word Choice and Consistency](word-choice.md)
- Bundle index: [index.md](index.md)
