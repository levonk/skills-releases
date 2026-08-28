---
type: Practice
title: Word Choice and Consistency
description: Normative word-choice rules for technical documentation — avoid slang/jargon/idioms, use contractions correctly, avoid lazy abbreviations, prefer "for example"/"that is" over e.g./i.e., acronym usage nuances, US/UK English consistency, gender-neutral pronouns, and tested examples. Applies to all technical prose output.
tags: [technical-writing, ste100, simplified-technical-english, documentation, word-choice, contractions, abbreviations, acronyms, gender-neutral, examples]
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

# Word Choice and Consistency

Word choice determines whether the reader understands the text on the first
read. Technical documentation serves non-native speakers, distracted operators,
and AI agents that must execute steps precisely. Wrong word choices create
ambiguity. This page defines the rules for choosing words and keeping them
consistent.

For the core clarity principles (one-word-one-meaning, consistent verb forms,
approved modifiers), see [Simplified Technical English](simplified-technical-english.md).
For procedure and list formatting, see
[Procedures and Lists](procedures-and-lists.md).

## Avoid Slang, Jargon, and Idioms

Do not use slang, jargon, or idioms when a more familiar term exists. Most
technical audiences include non-native English speakers. Idioms do not
translate.

**Avoid:**
> Use the glyph to represent the symbol.

**Use:**
> Use the symbol to represent the value.

## Contractions

Common contractions are acceptable in technical prose:
- it's, you're, that's, don't

**Do not use contractions with nouns.** A contraction that joins a verb to a
noun creates ambiguity and sounds unprofessional.

**Avoid:**
> Docker's the leading container platform.

**Use:**
> Docker is the leading container platform.

## Abbreviations

### Avoid Lazy Abbreviations

Avoid abbreviations that save a few characters at the cost of clarity.

**Avoid:**
> approx. — write "about" or "approximately"

### Avoid "etc."

The abbreviation "etc." is often misused. Do not use "etc." after "such as" or
"including" — the qualifier already signals an incomplete list.

**Avoid (redundant):**
> He eats lots of fruit, such as apples, oranges, bananas, etc.

**Use:**
> He eats lots of fruit, such as apples, oranges, and bananas.

If you must use "etc.", use it with a colon and no "such as":
> He eats lots of fruit: apples, oranges, bananas, etc.

## e.g. and i.e.

Prefer the full English words over the Latin abbreviations.

- Write "for example" instead of "e.g."
- Write "that is" or "in other words" instead of "i.e."

Most readers do not know what "e.g." and "i.e." mean. If you must use them,
include the comma at the end:
- "e.g.," — "for example"
- "i.e.," — "that is" / "in other words"

Alternative words for exemplification: as an illustration, especially,
including, in detail, in other words, in particular, for example, for instance,
namely, specifically, such as, to demonstrate, to illustrate.

## Acronym Usage

### Define on First Use

Write the full term, then the acronym in parentheses. Use the acronym after.

> Kernel Samepage Merging (KSM)

See [Simplified Technical English](simplified-technical-english.md) Rule 8 for
the core principle.

### Do Not Define an Acronym Used Only Once

If an acronym appears only once in a document, do not introduce it. Write the
full term and skip the acronym. Defining an acronym that never appears again
adds noise.

### Commonly Known Acronyms

Some acronyms are universally known. Do not define them:
- USB, HTML, URL, FAQ

Use judgment based on the audience. When in doubt, define the acronym.

## Consistency: Introduce Synonyms on First Use

Pick one term for each concept and use it everywhere. On first use, introduce
other common terms in parentheses. This helps readers who search for a
different term.

**Example:**
> A USB flash drive (USB stick) is the recommended installation medium.

After the first use, use only "USB flash drive". Do not alternate between
"USB flash drive", "USB stick", and "thumb drive" in the same document.

See [Simplified Technical English](simplified-technical-english.md) Rule 1 for
the core one-word-one-meaning principle.

## US or UK English

Pick one English variant and use it consistently. Most technical documentation
uses US English.

**US English:**
> center, color, behavior

**UK English:**
> centre, colour, behaviour

Do not mix variants in the same document. If you write "color" in section 1, do
not write "colour" in section 2.

## Gender-Neutral Pronouns

Use gender-neutral pronouns: they, them, their. Do not use "he or she" or "his
or her" — these are verbose and exclude non-binary readers.

If a sentence feels awkward with a gender-neutral pronoun, restructure it. Omit
the pronoun or switch to the second person imperative.

**Avoid:**
> Each user must configure his or her settings.

**Use:**
> Each user must configure their settings.

**Or (second person imperative):**
> Configure your settings.

## Examples

Examples must be clear, correct, and tested.

Do not publish an untested example. A wrong example is worse than no example. A
reader who follows a broken example loses trust in the entire document.

**Before publishing an example:**
- Run the code or commands yourself.
- Confirm the output matches what the example shows.
- Confirm the example works on a clean environment, not just your machine.

If you cannot test an example, remove it. Write "no example available" rather
than publishing an untested one.

## Quick Self-Check

Before publishing, check word choice:

- [ ] Have you replaced slang, jargon, and idioms with familiar terms?
- [ ] Are contractions used only with pronouns (not nouns)?
- [ ] Have you removed lazy abbreviations (approx., etc.)?
- [ ] Have you replaced e.g./i.e. with "for example"/"that is"?
- [ ] Is every acronym defined on first use (or commonly known like USB/HTML)?
- [ ] Are acronyms used only once left undefined (full term only)?
- [ ] Are synonyms introduced on first use, then the canonical term used after?
- [ ] Is the English variant (US or UK) consistent throughout?
- [ ] Are pronouns gender-neutral (they/them/their)?
- [ ] Is every example tested and correct?

## Cross-References

- Core guidelines: [Simplified Technical English](simplified-technical-english.md)
- Full writing rules and self-check: [Detailed Guide](detailed-guide.md)
- Punctuation: [Punctuation](punctuation.md)
- Capitalization and articles: [Capitalization and Articles](capitalization.md)
- Procedures, lists, and transitions: [Procedures and Lists](procedures-and-lists.md)
- Bundle index: [index.md](index.md)
