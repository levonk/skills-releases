---
type: Practice
title: Punctuation for Technical Prose
description: Normative punctuation rules for technical documentation — Oxford commas, comma placement rules, semicolons for independent clauses, hyphens for compound modifiers, em dashes for parenthetical emphasis, slashes for combinations. Applies to all technical prose output.
tags: [technical-writing, ste100, simplified-technical-english, documentation, punctuation, commas, hyphens, em-dashes]
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

# Punctuation for Technical Prose

Punctuation guides the reader through a sentence. In technical prose, wrong
punctuation creates ambiguity. This page defines the punctuation rules that
keep technical documentation clear and consistent.

For the core clarity principles (active voice, short sentences, one topic per
sentence), see [Simplified Technical English](simplified-technical-english.md).
For capitalization and article usage, see
[Capitalization and Articles](capitalization.md).

## Commas

### Use the Oxford Comma

Use the Oxford (serial) comma in lists of three or more items. The Oxford comma
is the comma before the final "and" or "or".

**With Oxford comma (clear):**
> The build copies the file, runs the tests, and pushes the image.

**Without Oxford comma (ambiguous):**
> The build copies the file, runs the tests and pushes the image.

Without the Oxford comma, the reader cannot tell whether "runs the tests and
pushes the image" is one combined step or two separate steps.

### Comma Before Coordinating Conjunctions

Use a comma before a coordinating conjunction (and, but, for, or, nor, so, yet)
that links two independent clauses. An independent clause has its own subject
and verb.

**Two independent clauses (use a comma):**
> The build completes, and the pipeline triggers a deployment.

**One subject, two verbs (no comma):**
> The build completes and triggers a deployment.

### Comma After Introductory Phrases

Use a comma after an introductory phrase or introductory adverb.

**With comma:**
> After the build completes, the pipeline triggers a deployment.
> Finally, run the tests.

### Comma After Sequence Words

Use a comma after sequence words that introduce a sentence (first, next, then,
last, after that).

**With comma:**
> First, run the build.
> Then, run the tests.

### Comma After Dependent Clauses

Use a comma after a dependent clause that starts a sentence (when, after,
although, as, because, before, once, since, while).

**With comma:**
> When the build completes, the pipeline triggers a deployment.

### Comma Between Coordinate Adjectives

Use a comma between two adjectives that modify the same noun.

**With comma:**
> The build is fast, reliable, and idempotent.

## Semicolons

### Join Independent Clauses Without a Conjunction

Use a semicolon to join two independent clauses when you do not use a
coordinating conjunction.

**With semicolon:**
> Select Options; then select Enable fast saves.

**Do not use a comma here.** A comma without a conjunction creates a comma
splice.

### Do Not Use Semicolons in Compound Predicates

Do not use a semicolon between verbs in a compound predicate (two verbs that
share one subject). Use no punctuation.

**No semicolon:**
> The program evaluates the system and then copies the files to the target.

## Hyphens

### Hyphenate Compound Modifiers Before Nouns

Hyphenate two or more words that precede and modify a noun as a unit when
confusion might result without the hyphen.

**Hyphenated:**
> read-only memory, built-in drive, command-line tool

**Not hyphenated (noun form):**
> the Linux command line

Use the hyphenated form when the compound is an adjective ("command-line tool").
Use the two-word form when the compound is a noun ("the command line").

### Hyphenate Participles Used as Adjectives

Hyphenate a compound modifier when one word is a past or present participle (a
verb form ending in -ed or -ing).

**Hyphenated:**
> left-aligned text, well-defined schema, running process

### Hyphenate Number-plus-Noun Modifiers

Hyphenate a modifier that is a number or single letter plus a noun or
participle.

**Hyphenated:**
> two-sided arrow, 5-point star, 64-bit integer

### Hyphenate Abbreviated Compound Nouns

Hyphenate compound nouns when one of the words is abbreviated.

**Hyphenated:**
> e-book, e-commerce, e-bike

**Exception:** Write "email" as one word, not "e-mail".

## Em Dashes

Use an em dash (—) to set off a parenthetical phrase with more emphasis than
parentheses provide. Do not add spaces around an em dash.

**Correct (no spaces around the dash):**
> The configuration—numbers, paths, and flags—is stored in a YAML file.

**Avoid (spaces around the dash):**
> The configuration — numbers, paths, and flags — is stored in a YAML file.

Do not confuse the em dash (—) with the hyphen (-) or the en dash (–). The em
dash is the longest of the three.

## Slashes

### Use Slashes for Combinations

Use a forward slash to imply a combination. Capitalize the word after the slash
if the word before the slash is capitalized.

**Examples:**
> client/server or Client/Server
> TCP/IP

### Do Not Use Slashes for "or"

Do not use a slash as a substitute for "or". Write "or" in prose.

**Avoid:**
> product/service

**Use:**
> product or service

## Quick Self-Check

Before publishing, check punctuation:

- [ ] Does every list of three or more items use the Oxford comma?
- [ ] Does every coordinating conjunction between independent clauses have a
      comma?
- [ ] Does every introductory phrase have a comma after it?
- [ ] Does every sequence word (first, next, then) have a comma after it?
- [ ] Does every dependent clause at the start of a sentence have a comma?
- [ ] Are independent clauses without conjunctions joined by semicolons (not
      commas)?
- [ ] Are compound modifiers before nouns hyphenated?
- [ ] Are em dashes used without spaces?
- [ ] Are slashes used only for combinations, not for "or"?

## Cross-References

- Core guidelines: [Simplified Technical English](simplified-technical-english.md)
- Full writing rules and self-check: [Detailed Guide](detailed-guide.md)
- Capitalization and articles: [Capitalization and Articles](capitalization.md)
- Procedures, lists, and transitions: [Procedures and Lists](procedures-and-lists.md)
- Word choice and consistency: [Word Choice and Consistency](word-choice.md)
- Bundle index: [index.md](index.md)
