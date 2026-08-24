---
type: Practice
title: Android Image Loading Libraries
description: Coil as the default for Kotlin/Compose projects, Glide for legacy View-based or image-heavy apps, Fresco for memory-intensive feeds, Picasso deprecated. Covers Compose Multiplatform options (Landscapist, Sketch) and the decision rule for choosing between them.
tags: [android, image-loading, coil, glide, fresco, picasso, kotlin, compose, mobile]
date:
  created: "2026-08-21"
  knowledge-basis: "2026-08-21"
  last-used: "2026-08-21"
sources:
  - id: medium-android-image-loading-libraries-2024
    resource: "https://medium.com/intuition/android-image-loading-libraries-glide-picasso-fresco-and-coil-f8a61008aeb9"
    title: "Android Image Loading Libraries: Glide, Picasso, Fresco, and Coil — Sandeep Kella, April 2024"
  - id: coil-kt-github
    resource: "https://github.com/coil-kt/coil"
    title: "Coil (coil-kt/coil) — GitHub repository, v3.5.0 June 2026"
  - id: bumptech-glide-github
    resource: "https://github.com/bumptech/glide"
    title: "Glide (bumptech/glide) — GitHub repository, v5.0.9 July 2026"
  - id: facebook-fresco-github
    resource: "https://github.com/facebook/fresco"
    title: "Fresco (facebook/fresco) — GitHub repository, v3.7.0 June 2026"
  - id: square-picasso-github
    resource: "https://github.com/square/picasso"
    title: "Picasso (square/picasso) — GitHub repository, deprecated"
  - id: android-developers-image-loading
    resource: "https://developer.android.com/develop/ui/compose/images"
    title: "Android Developers — Load images with Coil or Glide (official Compose docs, 2026)"
---


# Android Image Loading Libraries

## Failure Mode

Loading images without a dedicated library on Android leads to OutOfMemoryError
crashes, janky scrolling in lists, duplicated network requests, and manual
bitmap recycling. Choosing the wrong library — or a deprecated one — adds
unnecessary APK size, limits Compose integration, or blocks migration to modern
Kotlin patterns.

## Practice

**Use Coil for new Kotlin/Compose projects. Use Glide for legacy View-based or
image-heavy apps. Use Fresco only for memory-intensive feeds. Do not use
Picasso — it is officially deprecated.**

### Decision Rule

1. **Is this a new Kotlin/Compose project?** → **Coil** (3.x). Kotlin-first,
   coroutine-based, native `AsyncImage` composable, Compose Multiplatform
   support, smallest APK impact.
2. **Is this a legacy View-based app or an image-heavy app (galleries,
   e-commerce grids)?** → **Glide** (5.x). Battle-tested 4-level cache, superior
   cache hit ratio on repeat scrolls, robust GIF/video frame support.
3. **Are you hitting OutOfMemoryError with hundreds of images in an infinite
   feed, or targeting very old devices?** → **Fresco** (3.x). Native memory
   management with bitmap recycling, progressive JPEGs, three-level cache.
4. **Is this a Compose Multiplatform project (shared UI across Android/iOS/
   Desktop)?** → **Landscapist** (pluggable backend) or **Sketch** (KMP-native).
5. **Are you using Picasso?** → **Migrate to Coil.** Square has officially
   deprecated Picasso — no new releases to Maven Central.

### Library Comparison (2026)

| Library | Version | Status | Kotlin/Compose | APK Size | Best For |
|---------|---------|--------|----------------|----------|----------|
| **Coil** | 3.5.0 (Jun 2026) | Active | Kotlin-first, native Compose, KMP | ~2,000 methods | New Kotlin/Compose projects |
| **Glide** | 5.0.9 (Jul 2026) | Active | Java-first, Compose beta | ~3,000+ methods | Legacy View apps, image-heavy grids |
| **Fresco** | 3.7.0 (Jun 2026) | Active (Meta) | Java-first, custom view | Large | Memory-intensive feeds, OOM prevention |
| **Picasso** | 2.8 | **Deprecated** | Java-only, no Compose | Small | Nothing — migrate to Coil |
| **Landscapist** | 2.9.7+ | Active | Compose KMP, pluggable backend | Varies | Compose Multiplatform |
| **Sketch** | 4.6.0 (Mar 2026) | Active | Compose KMP-native | Varies | Pure KMP projects |

### Coil (Default for New Projects)

Coil (Coroutine Image Loader) is the recommended default for Kotlin/Compose
Android projects. It is Kotlin-first, built on Coroutines, and provides native
Compose integration.

**Strengths:**
- Kotlin-first design with coroutine-based async API
- Native `AsyncImage` composable — no wrapper needed
- Compose Multiplatform support (Android, iOS, Desktop, Web)
- Smallest APK impact (~2,000 methods vs Glide's 3,000+)
- Modular networking (OkHttp, Ktor 2/3)
- Officially recommended by Android Developers for Kotlin projects

**Weaknesses:**
- Smaller community than Glide (11.8K vs 35K GitHub stars)
- Less mature GIF/video frame support than Glide

**Dependency:**
```kotlin
implementation("io.coil-kt.coil3:coil-compose:3.5.0")
implementation("io.coil-kt.coil3:coil-network-okhttp:3.5.0")
```

### Glide (Legacy and Image-Heavy Apps)

Glide is the most mature and battle-tested Android image loading library (since
2013). It remains the recommended choice for Java projects and image-heavy apps
that benefit from its sophisticated caching.

**Strengths:**
- Most mature ecosystem (35K GitHub stars)
- 4-level caching system (active, memory, disk, resource)
- Superior cache hit ratio on repeat scrolls
- Robust GIF/video frame support out of the box
- Aggressive bitmap pooling (better for low-end devices)
- Officially recommended by Android Developers for Java projects

**Weaknesses:**
- Java-first design — Kotlin extensions are secondary
- Compose integration is **beta** (`1.0.0-beta02`) with known API issues
- Larger APK impact (~3,000+ methods)

**Dependency:**
```kotlin
implementation("com.github.bumptech.glide:glide:5.0.9")
// Compose (beta):
implementation("com.github.bumptech.glide:compose:1.0.0-beta02")
```

### Fresco (Memory-Intensive Apps)

Fresco is Meta's image loading library designed for memory-intensive
applications. It uses native code for advanced memory management and bitmap
recycling.

**Strengths:**
- Advanced memory management with native code
- Three-level caching system
- Progressive JPEG support (gradual loading)
- Bitmap recycling prevents OutOfMemoryError
- 16KB page size support for Android 15

**Weaknesses:**
- Steeper learning curve (custom `SimpleDraweeView` component)
- Java-first design (47% Java, 47% Kotlin)
- Largest library size
- Overkill for most apps

**Dependency:**
```kotlin
implementation("com.facebook.fresco:fresco:3.7.0")
```

### Picasso (Deprecated — Do Not Use)

Square has officially deprecated Picasso. The repository states: "This library
is deprecated. Please use alternatives like Coil for future projects, and start
to migrate existing projects if they rely on Compose UI. Existing versions will
continue to function, but no new work is planned. No more public releases to
Maven Central."

**Action:** Migrate existing Picasso usage to Coil. Only keep Picasso if
maintaining a legacy Java codebase without Compose and no migration budget.

### Compose Multiplatform Options

For projects sharing UI across platforms via Compose Multiplatform:

- **Landscapist** (skydoves/landscapist, v2.9.7+) — pluggable backend that can
  wrap Glide, Coil, or Fresco. Includes built-in animations (crossfade, blur,
  circular reveal) and Baseline Profiles. Used by 100+ apps with 100M+ installs.
- **Sketch** (panpf/sketch, v4.6.0) — designed for Compose Multiplatform from
  day one. Supports GIF, SVG, video thumbnails. Best for pure KMP projects.

### Performance Notes

Performance differences between Coil and Glide are minimal at scale. In
benchmarks (RecyclerView with 500 image cells, mid-tier device):

| Metric | Coil | Glide |
|--------|------|-------|
| Avg decode time | ~14ms | ~11ms |
| Memory churn | Less | More |
| Cache hit ratio (repeat) | Good | Better |
| APK size impact | ~2,000 methods | ~3,000+ methods |

Choose based on architecture fit (Kotlin/Compose vs Java/Views), not raw
benchmark numbers — the difference is negligible in production.

## Anti-Patterns

- Using Picasso for new projects — it is deprecated.
- Choosing Fresco for a simple app — its complexity is only justified for
  memory-intensive feeds or very old device targeting.
- Ignoring Compose integration — if the project uses Jetpack Compose, Coil's
  native `AsyncImage` is significantly smoother than Glide's beta Compose
  wrapper.
- Rolling a custom image loader — the edge cases (bitmap recycling, memory
  pressure, request cancellation, placeholder/crossfade) are already solved by
  every library above.
- Choosing based on GitHub stars alone — Glide has more stars because it is
  older, not because it is better for modern Kotlin/Compose projects.

## Related Concepts

- [iOS Image Loading](ios-image-loading.md) — the iOS counterpart (Kingfisher,
  Nuke, SDWebImage)
- [Cross-Platform Image Loading](cross-platform-image-loading.md) — Web,
  Flutter, React Native, and Desktop approaches
- [Code Style Conventions](code-style-conventions.md) — Kotlin/Compose code
  style when using Coil's `AsyncImage`
