---
type: Practice
title: STE100-Inspired Simplified Technical English — Detailed Guide
description: Full writing rules (10 rules), approved-words guidance, 3 before/after examples, and the 10-step self-check protocol for STE100-inspired Simplified Technical English. The companion to the core guidelines concept page.
tags: [technical-writing, ste100, simplified-technical-english, documentation, writing-rules, self-check, examples]
date:
  created: "2026-07-26"
  knowledge-basis: "2026-07-26"
  last-used: "2026-07-26"
sources:
  - id: asd-ste100
    resource: "https://www.asd-ste100.org/"
    title: "ASD-STE100 Simplified Technical English specification"
  - id: core-guidelines
    resource: "simplified-technical-english.md"
    title: "Simplified Technical English core guidelines (sibling concept page)"
---

# STE100-Inspired Simplified Technical English — Detailed Guide

This is the progressive-disclosure companion to the
[Simplified Technical English](simplified-technical-english.md) core guidelines
page. The core page carries the gist; this guide carries the depth. Read this
when you need the full writing rules, before/after examples, or the
approved-words reference.

## Background

ASD-STE100 (Aerospace and Defence Industries Association Simplified Technical
English) is a controlled-language standard developed for aerospace maintenance
documentation. It restricts vocabulary and grammar so that technical writing
is unambiguous, translatable by machine translation systems, and easy to read
for non-native speakers.

This guide adopts STE100's *discipline* — short sentences, active voice,
one-word-one-meaning, imperative mood — without its 1000-word approved
vocabulary. Domain terms (Dockerfile, pnpm, devbox, Nx, Ansible) are
permitted when they are the correct technical term. The goal is clarity, not
vocabulary restriction.

## Writing Rules

### Rule 1: One Word, One Meaning

Pick one term for each concept. Use it everywhere in the document.

**Violation:**
> The build copies the file into the image. The container image then starts.
> The docker image runs the entrypoint.

Three terms ("image", "container image", "docker image") name the same thing.

**STE-inspired:**
> The build copies the file into the image. The image then starts. The image
> runs the entrypoint.

Pick "image" once, use it everywhere. Define it on first use if the audience
needs it.

### Rule 2: Short Sentences

Procedural sentences: maximum 20 words.
Descriptive sentences: maximum 25 words.

**Violation (28 words):**
> When the build completes, the resulting image is pushed to the registry by
> the CI pipeline, which then triggers a deployment to the staging environment
> after a manual approval step.

**STE-inspired (split into two sentences, 14 + 13 words):**
> The CI pipeline pushes the image to the registry when the build completes.
> A manual approval step then triggers a deployment to staging.

### Rule 3: Active Voice

The actor does the action. Name the actor.

**Violation:**
> The file is copied by the build. The tests are run. A deployment is triggered.

**STE-inspired:**
> The build copies the file. The pipeline runs the tests. The pipeline triggers
> a deployment.

Passive voice is permitted only when the actor is unknown or irrelevant:
> The file was deleted. (Actor unknown — acceptable in a post-mortem.)

### Rule 4: Imperative Mood for Instructions

Tell the reader what to do. Direct command, no softening.

**Violation:**
> You should run the tests before merging. It would be good to check the lint
> output as well.

**STE-inspired:**
> Run the tests before merging. Check the lint output.

### Rule 5: One Topic per Sentence

One idea per sentence. Split compound sentences.

**Violation:**
> The build copies the file and the test runs and the pipeline deploys.

**STE-inspired:**
> The build copies the file. The test runs. The pipeline deploys.

### Rule 6: Consistent Verb Forms

Use the same verb for the same action. Do not alternate.

**Violation:**
> Run the tests. Execute the tests again. Launch the test suite.

**STE-inspired:**
> Run the tests. Run the tests again. Run the test suite.

Pick "run" once, use it for that action everywhere.

### Rule 7: Approved Modifiers Only

Drop decorative modifiers. Keep informative modifiers.

**Decorative (drop):**
> The build is very fast. The image is extremely small. Just run the command.

**Informative (keep):**
> The build completes in 12 seconds. The image is 18 MB. Run the command.

Informative modifiers carry data. Decorative modifiers carry only emphasis.

### Rule 8: Define Every Acronym on First Use

Write the full term, then the acronym in parentheses. Use the acronym after.

**Violation:**
> Configure CI to run the tests. CD deploys after CI passes.

**STE-inspired:**
> Configure Continuous Integration (CI) to run the tests. Continuous Deployment
> (CD) deploys after CI passes.

### Rule 9: Articles Before Nouns

Use "the" for a specific noun, "a" for one of several. Do not drop articles in
technical prose the way telegraphic style does.

**Violation:**
> Run command. Copy file to directory. Start container.

**STE-inspired:**
> Run the command. Copy the file to the directory. Start the container.

### Rule 10: Sequential Steps as Numbered Lists

When steps must run in order, use a numbered list. One action per step.

**STE-inspired:**
> 1. Run the build.
> 2. Run the tests.
> 3. Push the image.

When steps can run in any order, use a bulleted list.

## Approved-Words Guidance

STE100 publishes a controlled vocabulary of approximately 1000 approved words.
This guide does not adopt that list — domain terms are permitted. Instead,
follow these principles:

- **Prefer the simple verb.** Use "start" not "initiate", "end" not "terminate",
  "show" not "display", "use" not "utilize", "begin" not "commence".
- **Prefer the concrete noun.** Use "file" not "artifact" when you mean a file.
  Use "command" not "directive" when you mean a command.
- **Avoid phrasal verbs when a single verb exists.** Use "remove" not "take
  out", "install" not "put in", "continue" not "go on".
- **Keep domain terms as-is.** Dockerfile, pnpm, devbox, Nx, Ansible, Kubernetes,
  Helm, Terraform — these are the correct terms. Do not paraphrase them.

## Before/After Examples

### Example 1: A Failure Mode Description

**Before (32 words, passive, decorative modifier):**
> The container image is unfortunately built without a health check, which
> means that orchestrators are unable to detect when the service has become
> unresponsive and will continue to route traffic to it.

**After (two sentences, 13 + 14 words, active, no decoration):**
> The image has no health check. The orchestrator cannot detect an unresponsive
> service and continues to route traffic to it.

### Example 2: A Procedural Instruction

**Before (24 words, passive, non-imperative):**
> It should be noted that the Dockerfile should be linted with hadolint prior
> to the image being built in order to catch issues early.

**After (10 words, active, imperative):**
> Lint the Dockerfile with hadolint before you build the image.

### Example 3: A Concept Definition

**Before (38 words, one sentence, mixed voice):**
> A multi-stage build is a Dockerfile pattern where the build is performed in
> one stage and the resulting artifact is copied into a final stage which
> contains only the runtime dependencies, resulting in a smaller image and
> reduced attack surface.

**After (three sentences, 11 + 13 + 9 words, active):**
> A multi-stage build splits the Dockerfile into stages. The first stage builds
> the artifact. The final stage copies the artifact and the runtime dependencies
> only. The result is a smaller image with a smaller attack surface.

## The Full Self-Check Protocol

Run this protocol on every piece of technical prose before publishing.

1. **Sentence length.** Read each sentence. Count the words. Procedural: under
   20. Descriptive: under 25. Split any sentence that exceeds the limit.

2. **Voice.** Find every passive construction ("is X-ed", "was X-ed", "are
   X-ed"). Rewrite as active unless the actor is genuinely unknown.

3. **Mood.** Find every instruction. Confirm it is imperative ("Run", "Add",
   "Remove"). Rewrite any softened instruction ("You should...", "It would be
   good to...").

4. **Terminology.** List every technical term in the document. Confirm each
   term has one and only one form. Pick a canonical form and replace variants.

5. **Acronyms.** Find every acronym. Confirm each is defined on first use.
   Add the definition if missing.

6. **Modifiers.** Find every adjective and adverb. Drop decorative ones
   ("very", "extremely", "simply", "just", "easily"). Keep informative ones
   ("non-root", "read-only", "idempotent", "atomic").

7. **Topics.** Find every sentence with "and" or "while" joining two clauses.
   Confirm the clauses are one topic. Split if they are two topics.

8. **Articles.** Find every bare noun in instructions ("Run command", "Copy
   file"). Add the article ("Run the command", "Copy the file").

9. **Sequential steps.** Find every ordered procedure. Confirm it is a
   numbered list with one action per step.

10. **Verb consistency.** List every verb used for each action. Confirm one
    verb per action. Replace variants with the canonical verb.

## When to Relax the Rules

These guidelines are strict for technical documentation meant to be executed
precisely. Relax them when:

- **Synthesis and overview prose** can use slightly longer sentences (under 30
  words) when the connection between ideas is the point.
- **Change logs** are append-only records, not instructions. They keep their
  existing terse style.
- **Quotations from upstream sources** keep the source's wording. Do not
  rewrite a quoted sentence into STE.
- **Code comments** follow the code's conventions, not these guidelines. Code
  comments are read alongside the code, not as standalone documentation.

## Cross-References

- Core guidelines: [Simplified Technical English](simplified-technical-english.md) (sibling concept page in this bundle)
- Build-time include (gist): `includes/ste100-simplified-technical-english.md.tmpl` (inlined into skills and other bundles at build time)
- Bundle index: [index.md](index.md)
- Upstream standard: ASD-STE100 Simplified Technical English,
  <https://www.asd-ste100.org/>
