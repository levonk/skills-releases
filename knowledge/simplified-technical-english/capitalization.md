---
type: Practice
title: Capitalization and Articles
description: Normative capitalization rules for technical documentation — title-style vs sentence-style headlines, basic capitalization rules (proper nouns, days, months, seasons), and a/an article selection by vowel sound. Applies to all technical prose output.
tags: [technical-writing, ste100, simplified-technical-english, documentation, capitalization, titles, articles, a-an]
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

# Capitalization and Articles

Capitalization signals the structure of a document. Wrong capitalization in
headlines makes the hierarchy unclear. Wrong article selection (a vs an) makes
prose sound wrong to the reader. This page defines the rules for both.

For the core clarity principles, see
[Simplified Technical English](simplified-technical-english.md). For punctuation
rules, see [Punctuation](punctuation.md).

## Titles and Headlines

Use two capitalization styles for headlines, depending on the heading level.

| Heading level | Capitalization style |
|---------------|---------------------|
| Title (H1) and first-level subsections (H2) | Title-style |
| All deeper heading levels (H3, H4, H5, H6) | Sentence-style |

### Title-Style Capitalization

Use title-style capitalization for the document title (H1) and first-level
subsections (H2).

**Rules:**

1. **Always capitalize the first and last word.**
   > A Home to Go Back To

2. **Do not capitalize articles** (a, an, the) unless they are the first word.
   > Linux on the Issue

3. **Do not capitalize short prepositions** (four or fewer letters: on, to, in,
   up, down, of, for) unless the preposition is the first or last word.
   > How to Install Docker

4. **Do not capitalize coordinating conjunctions** (and, but, or, nor, yet, so)
   unless they are the first or last word.
   > Monitoring and Operating a Cluster

5. **Capitalize all other words** — nouns, verbs (including "is" and forms of
   "be"), adverbs (including "very" and "too"), adjectives, and pronouns
   (including "this", "that", "its").
   > Teaching Math Over and Over Again, in Less Time Than Before

6. **Capitalize the second part of a hyphenated compound** if it would be
   capitalized without the hyphen or if it is the last word.
   > Hyper-Converged Infrastructure

7. **Capitalize the first word of UI and API labels** unless they are always
   lowercase (for example, "fdisk").

### Sentence-Style Capitalization

Use sentence-style capitalization for all heading levels deeper than H2 (H3,
H4, H5, H6). Capitalize the first word and lowercase the rest.

**Exceptions:**

- **Proper nouns** are always capitalized. This includes brand names, product
  names, and service names.
- **After a colon**, capitalize the first word.

**Examples:**
> Watch your favorite HD movies, TV shows, and more
> 1 TB of cloud storage
> Choose the cluster size that is right for you
> Network: Setup and configuration

## Basic Capitalization Rules

Beyond headlines, follow these rules in all technical prose:

- **Capitalize the first word of every sentence.**
- **Capitalize proper nouns** — names of cities, countries, companies,
  religions, and political parties.
- **Capitalize days, months, and holidays.** Do not capitalize seasons.
  > Monday, January, Thanksgiving — but: winter, spring, summer, autumn
- **Capitalize nationalities and languages.**
  > English, French, Japanese, American

## A and An

Use "a" before a noun that starts with a consonant **sound**. Use "an" before a
noun that starts with a vowel **sound** (a, e, i, o, u). The rule is about the
sound, not the letter.

**Consonant sound — use "a":**
> a chair, a truck, a castle, a historical document

**Vowel sound — use "an":**
> an apple, an orange, an opera, an hour (silent h)

### Silent H

Use "an" before a word with a silent h.
> an hour, an honest answer

Use "a" before a word with a pronounced h.
> a historical document, a hotel

### Vowel Letters With Consonant Sounds

Use "a" before u and eu when they make a consonant "y" sound (like "you").
> a European, a university, a unit

### Acronyms and Initialisms

The article depends on how the acronym is pronounced, not how the expanded term
is pronounced.

**Pronounced as a word (vowel sound):**
> an MGC (M is pronounced "em" — vowel sound)

**Pronounced as a word (consonant sound):**
> a Media Gateway Controller (M is pronounced as a consonant)

### First vs Subsequent References

Use "an" or "a" the first time you refer to something. Use "the" for subsequent
references to the same thing.

**First reference:**
> An MGC is a Media Gateway Controller.

**Subsequent reference:**
> The MGC controls all activity on the network.

## Quick Self-Check

Before publishing, check capitalization and articles:

- [ ] Do the title (H1) and first-level subsections (H2) use title-style
      capitalization?
- [ ] Do deeper heading levels (H3+) use sentence-style capitalization?
- [ ] Are proper nouns, brand names, and product names capitalized?
- [ ] Are days, months, and holidays capitalized (but not seasons)?
- [ ] Is "a" used before consonant sounds and "an" before vowel sounds?
- [ ] Are silent-h words preceded by "an"?
- [ ] Are acronyms preceded by the article that matches their pronunciation?

## Cross-References

- Core guidelines: [Simplified Technical English](simplified-technical-english.md)
- Full writing rules and self-check: [Detailed Guide](detailed-guide.md)
- Punctuation: [Punctuation](punctuation.md)
- Procedures, lists, and transitions: [Procedures and Lists](procedures-and-lists.md)
- Word choice and consistency: [Word Choice and Consistency](word-choice.md)
- Bundle index: [index.md](index.md)
