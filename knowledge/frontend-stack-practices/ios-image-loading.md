---
type: Practice
title: iOS Image Loading Libraries
description: Kingfisher as the default for Swift/SwiftUI projects, Nuke for performance-critical or memory-constrained apps, SDWebImage for legacy Objective-C codebases. Covers the decision rule and when each library fits.
tags: [ios, swift, swiftui, image-loading, kingfisher, nuke, sdwebimage, mobile]
date:
  created: "2026-08-21"
  knowledge-basis: "2026-08-21"
  last-used: "2026-08-21"
sources:
  - id: kingfisher-github
    resource: "https://github.com/onevcat/Kingfisher"
    title: "Kingfisher (onevcat/Kingfisher) — GitHub repository, v8.10.0 June 2026"
  - id: nuke-github
    resource: "https://github.com/kean/Nuke"
    title: "Nuke (kean/Nuke) — GitHub repository, latest July 2026"
  - id: sdwebimage-github
    resource: "https://github.com/SDWebImage/SDWebImage"
    title: "SDWebImage (SDWebImage/SDWebImage) — GitHub repository, v5.21.7 Feb 2026"
---


# iOS Image Loading Libraries

## Failure Mode

Loading images without a dedicated library on iOS leads to memory spikes, janky
scrolling in `UICollectionView`/`List`, redundant network requests, and manual
`UIImage` cache management. Choosing an Objective-C-era library for a Swift/
SwiftUI project blocks modern async/await patterns and SwiftUI view integration.

## Practice

**Use Kingfisher for new Swift/SwiftUI projects. Use Nuke for performance-
critical or memory-constrained apps. Use SDWebImage only for legacy Objective-C
codebases or when broad platform support (watchOS, tvOS, visionOS) is required.**

### Decision Rule

1. **Is this a new Swift/SwiftUI project?** → **Kingfisher** (8.x). Pure Swift,
   excellent SwiftUI support, most popular, extensive feature set.
2. **Is memory efficiency critical, or do you need fine-grained control?** →
   **Nuke**. Modular architecture, better memory efficiency (72MB vs 118MB in
   tests), optimized for performance.
3. **Is this a legacy Objective-C codebase, or do you need watchOS/tvOS/
   visionOS support?** → **SDWebImage**. Still actively maintained, broad
   platform support, Objective-C native.

### Library Comparison (2026)

| Library | Version | Status | Language | Stars | Best For |
|---------|---------|--------|----------|-------|----------|
| **Kingfisher** | 8.10.0 (Jun 2026) | Active | Pure Swift | 24K | New Swift/SwiftUI projects |
| **Nuke** | Latest (Jul 2026) | Active | Swift | 8.6K | Performance-critical, memory-constrained |
| **SDWebImage** | 5.21.7 (Feb 2026) | Active | Objective-C | 25K | Legacy ObjC, broad platform support |

### Kingfisher (Default for New Projects)

Kingfisher is the most popular pure-Swift image loading library. It provides
excellent SwiftUI support and an extensive feature set.

**Strengths:**
- Pure Swift — no Objective-C baggage
- Excellent SwiftUI support with `KFImage` view
- Multiple cache layers (memory + disk)
- Image processors and filters
- Extensive documentation and community
- Most adopted Swift image library

**Weaknesses:**
- Larger monolithic framework (vs Nuke's modular packages)
- Higher memory usage than Nuke in benchmarks

**Dependency (Swift Package Manager):**
```swift
.package(url: "https://github.com/onevcat/Kingfisher.git", from: "8.10.0")
```

### Nuke (Performance-Critical Apps)

Nuke is a performance-focused image loading library with a modular architecture.
It is the best choice when memory efficiency matters.

**Strengths:**
- Best memory efficiency (72MB vs Kingfisher's 118MB in tests)
- Modular architecture (4 separate packages — use only what you need)
- Optimized for performance with 2x test coverage
- Fine-grained control over caching and loading pipeline

**Weaknesses:**
- Smaller community than Kingfisher (8.6K vs 24K stars)
- More setup required for full-featured usage (modular packages)

**Dependency (Swift Package Manager):**
```swift
.package(url: "https://github.com/kean/Nuke.git", from: "12.0.0")
```

### SDWebImage (Legacy and Broad Platform Support)

SDWebImage is the oldest and most downloaded iOS image loading library. It
remains actively maintained but is Objective-C native.

**Strengths:**
- Most downloaded iOS image library (25K stars)
- Broad platform support: iOS, watchOS, tvOS, visionOS
- Still actively maintained (v5.21.7, Feb 2026)
- Mature and stable

**Weaknesses:**
- Objective-C legacy — not Swift-native
- No first-class SwiftUI support
- Heavier than needed for Swift-only projects

**When to keep SDWebImage:** existing Objective-C codebases, or apps requiring
watchOS/tvOS/visionOS support where Kingfisher or Nuke do not provide adequate
coverage.

## Anti-Patterns

- Choosing SDWebImage for a new pure-Swift project — Kingfisher or Nuke are
  better fits for Swift/SwiftUI.
- Ignoring memory efficiency on image-heavy apps — Nuke's 40% lower memory
  footprint matters in feeds and galleries.
- Rolling a custom image loader — URLSession + manual caching misses edge cases
  (prefetching, progressive decoding, memory pressure handling, cancellation).

## Related Concepts

- [Android Image Loading](android-image-loading.md) — the Android counterpart
  (Coil, Glide, Fresco)
- [Cross-Platform Image Loading](cross-platform-image-loading.md) — Web,
  Flutter, React Native, and Desktop approaches
