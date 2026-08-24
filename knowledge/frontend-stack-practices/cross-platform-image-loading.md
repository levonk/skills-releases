---
type: Practice
title: Cross-Platform Image Loading
description: Image loading and caching for Web (native lazy loading + Next.js Image + sharp), Flutter (cached_network_image_ce), React Native (expo-image), and Desktop (egui_extras, tauri-plugin-redb-cache). Covers the shift from JS libraries to browser standards and framework-native solutions.
tags: [web, flutter, react-native, desktop, image-loading, expo-image, sharp, mobile, cross-platform]
date:
  created: "2026-08-21"
  knowledge-basis: "2026-08-21"
  last-used: "2026-08-21"
sources:
  - id: mdn-loading-lazy
    resource: "https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img#loading"
    title: "MDN — native loading=\"lazy\" attribute (universal browser support)"
  - id: nextjs-image-docs
    resource: "https://nextjs.org/docs/app/api-reference/components/image"
    title: "Next.js Image component documentation (v4, AVIF default)"
  - id: sharp-github
    resource: "https://github.com/lovell/sharp"
    title: "sharp (lovell/sharp) — GitHub repository, v0.35.3 June 2026"
  - id: cached-network-image-ce
    resource: "https://pub.dev/packages/cached_network_image_ce"
    title: "cached_network_image_ce — pub.dev, v4.10.0 July 2026"
  - id: expo-image-docs
    resource: "https://docs.expo.dev/versions/latest/sdk/image/"
    title: "expo-image — Expo SDK documentation (SDK 48-55)"
  - id: tauri-plugin-redb-cache
    resource: "https://github.com/tauri-apps/tauri-plugin-redb-cache"
    title: "tauri-plugin-redb-cache — GitHub repository, v0.1.2"
---


# Cross-Platform Image Loading

## Failure Mode

Each non-native-mobile platform (Web, Flutter, React Native, Desktop) has its
own image loading pitfalls: using deprecated or unmaintained libraries, ignoring
browser-native standards that eliminate the need for a library, or accepting
memory leaks from abandoned community packages.

## Practice

**Use the platform-native or framework-recommended approach. The era of
general-purpose JS image loading libraries is over — browser standards and
framework components have replaced them. For Flutter and React Native, use the
actively-maintained community library, not the abandoned original.**

### Platform Decision Table

| Platform | Recommended | Status | Key Differentiator |
|----------|-------------|--------|-------------------|
| **Web** | Native `loading="lazy"` + `next/image` + `sharp` | Standard | Browser-native, no JS library needed for lazy loading |
| **Flutter** | `cached_network_image_ce` 4.10.0 | Active | 8x faster cache reads than original, pure Dart |
| **React Native** | `expo-image` | Stable | SDWebImage (iOS) + Glide (Android), BlurHash, AVIF |
| **Rust/egui** | `egui_extras` with `all_loaders` | Active | Trait-based loader system with built-in caching |
| **Tauri** | `tauri-plugin-redb-cache` 0.1.2 | Active | Two-tier caching (LRU + Redb), compression |
| **Electron** | Custom copy-to-cache pattern | Pattern | No standard library — use `userData` + opaque IDs |

### Web — Native Standards + Framework Components

The web ecosystem has shifted away from JS image loading libraries to browser
standards and framework-native solutions.

**1. Native lazy loading (`loading="lazy"`):**
- Universal support: Chrome 77+, Firefox 121+, Safari 16.4+
- Zero JavaScript — pure HTML attribute
- Saves 30-60% bytes on long pages
- Use for all below-the-fold images

**2. Next.js Image (`next/image`):**
- AVIF now default format in v4 (20-30% smaller than WebP)
- `remotePatterns` replaces `domains` (breaking config change)
- `priority` deprecated in Next.js 16+ — use `preload` instead
- Automatic responsive sizing, blur placeholders

**3. sharp (server-side processing):**
- v0.35.3 (June 2026), 74M weekly downloads
- Requires Node.js >= 20.9.0 (dropped Node 18 in v0.35.0)
- 4-5x faster than ImageMagick/GraphicsMagick
- Supports AVIF, WebP, HEIF, HDR JPEG with gain maps

**4. unjs/ipx (image optimization service):**
- v4.0.0-beta.1 (July 2026), ESM-only
- Powered by sharp + svgo
- Security: sanitizes SVG, validates all modifier args
- `maxOutputDimension` prevents memory exhaustion attacks

### Flutter — cached_network_image_ce (Community Edition)

The original `cached_network_image` by Baseflow is effectively unmaintained
since August 2024, with 300+ unresolved issues including critical memory leaks
and scroll performance bugs.

**`cached_network_image_ce` (v4.10.0, July 2026) is the drop-in replacement:**

- Replaced sqflite with `hive_ce` (pure-Dart key-value store, no platform
  channel round-trip)
- Cache read: 16ms → 2ms (8x faster)
- Cache write: 116ms → 29ms (4x faster)
- Cache delete: 55ms → 19ms (2.89x faster)
- 99% API compatible — drop-in replacement
- Full web caching with persistent IndexedDB
- Pluggable eviction: TTL or LRU (original was fixed)

**Dependency:**
```yaml
dependencies:
  cached_network_image_ce: ^4.10.0
```

**Action:** Migrate from `cached_network_image` to `cached_network_image_ce`
immediately if using the original package.

### React Native — expo-image

`expo-image` is the modern standard for React Native image loading, replacing
`react-native-fast-image`.

**Strengths:**
- Native caching: wraps SDWebImage on iOS and Glide on Android (zero config)
- BlurHash and ThumbHash placeholders (28-char BlurHash decodes in <1ms)
- WebP/AVIF support (25-50% smaller than JPEG)
- Smooth transitions — no flickering when sources change
- CSS object-fit model: `contentFit` and `contentPosition` props

**Migration from `react-native-fast-image`:**
- `resizeMode` → `contentFit`
- `source.uri` → `source`
- Mostly search-and-replace

**Dependency:**
```json
"expo-image": "~2.0.0"
```

**Avoid:** React Native's built-in `Image` component (no persistent disk cache
on Android, decodes on JS thread, no cross-fade, no dynamic placeholder).

### Desktop

#### Rust / egui

egui uses a three-layer trait-based loader architecture:
- `BytesLoader` — load raw bytes
- `ImageLoader` — decode bytes to colors
- `TextureLoader` — upload to GPU

Use `egui_extras` with the `all_loaders` feature for default implementations:
```rust
egui_extras::install_image_loaders(&mut cc.egui_ctx);
```

Loaders are expected to cache results (immediate-mode safe). Known issue:
loading WebP/GIF can hang the UI thread — use thread-based loading as
workaround.

#### Tauri

Use `tauri-plugin-redb-cache` (v0.1.2) for HTTP/image caching:
- Two-tier caching: LRU memory + Redb persistent storage
- Automatic compression (Zlib for data >1KB)
- Configurable TTL, memory size, compression threshold
- Cross-platform: Windows, macOS, Linux, Android, iOS

For image viewers, implement custom protocols (`thumb://`, `orig://`) with the
Rust `image` crate and platform-specific decoders for formats like HEIC.

#### Electron

Electron inherits Chromium's image loading with no standard caching library.
Implement a custom copy-to-cache pattern:
- Validate source, copy to `userData` directory
- Serve by opaque ID (not original filename — security)
- Enforce size limits (e.g., 5MB cap per image)
- IPC handlers for import/retrieval
- Monitor temp file growth (can be unbounded without limits)

## Anti-Patterns

- Using `cached_network_image` (original) in Flutter — it is unmaintained with
  critical memory leaks. Use `cached_network_image_ce`.
- Using `react-native-fast-image` for new projects — `expo-image` is the modern
  standard with better features and native-backed caching.
- Installing a JS image lazy-loading library on the web — `loading="lazy"` is
  native and universal.
- Using React Native's built-in `Image` for anything beyond static assets — no
  persistent disk cache on Android.
- Ignoring `maxOutputDimension` in server-side image processing — memory
  exhaustion attacks are real.

## Related Concepts

- [Android Image Loading](android-image-loading.md) — Coil, Glide, Fresco
- [iOS Image Loading](ios-image-loading.md) — Kingfisher, Nuke, SDWebImage
- [Node.js Frontend Setup](nodejs-frontend-setup.md) — web frontend build setup
  that pairs with `next/image` and `sharp`
