---
type: Practice
title: Bevy ECS Conventions
description: Framework exceptions and compile-clean ECS bugs for Bevy crates — system parameters taken by value, the bevy prelude and public component fields are correct, plus the bugs that only panic at runtime (conflicting queries B0001/B0002, deferred Commands, unordered dependent systems, unwrapped single()), and headless App testing.
tags: [rust, bevy, ecs, game-development, framework, testing]
date:
  created: "2026-10-27"
  knowledge-basis: "2026-10-27"
  last-used: "2026-10-27"

sources:
  - id: beautifulrust
    resource: "https://github.com/morganlinton/BeautifulRust"
    title: "BeautifulRust"
---

# Bevy ECS Conventions

## Failure Mode

General Rust advice applied literally to Bevy produces wrong "fixes" —
`&Res<T>` parameters, explicit imports replacing the prelude, split systems
— while the real ECS bugs compile cleanly and panic on the first frame.
Verified against bevy 0.20.0; **check `Cargo.lock` first** — Bevy breaks
its API every release (0.17 renamed events to messages, 0.20 changed
observer generics). Follow the pinned version over this page.

## Practice

Applies when `Cargo.toml` depends on `bevy` or `bevy_ecs`. Exceptions below
replace the general rules **for system functions only** — errors, panics,
naming, tests, and unsafe still apply.

### Conventions to Leave Alone

- **System parameters are by value.** `Res<T>`, `ResMut<T>`, `Query<D, F>`,
  `Single<D, F>`, `Commands`, `Local<T>`, `MessageReader`/`MessageWriter`
  are already borrows Bevy hands the system for one run — do not change
  them to `&Res<T>` or flag needless pass-by-value. Normal borrowing still
  holds inside a system and for helpers it calls (`&Health`, not a `Query`).
- **`use bevy::prelude::*` is correct.** It is Bevy's documented import
  pattern and `wildcard_imports` exempts `prelude` paths. The glob rule
  still applies to your own modules — do not invent an application prelude.
- **Plain-data components may have public fields.** `Health(pub u32)`,
  `Velocity(pub Vec2)` are passive data many systems touch. Keep fields
  private only when they hold an invariant together (a sorted list);
  enforce caps in the system that applies them, not with getters and a
  panicking constructor.
- **Complex queries and many parameters are normal.** Do not split a
  system or wrap queries only to silence `type_complexity` /
  `too_many_arguments` — allow them at crate level (Bevy's own workspace
  does), or derive `SystemParam` when a parameter group is reused and
  deserves a name.

A Bevy crate on the standard `[lints]` table needs these allows so
idiomatic signatures do not warn:

```toml
[lints.rust]
elided_lifetimes_in_paths = "allow"   # write Res<Time>, not Res<'_, Time>

[lints.clippy]
needless_pass_by_value = "allow"      # system parameters are by value
type_complexity = "allow"             # query types; Bevy allows this too
too_many_arguments = "allow"          # systems take many parameters
```

### Bugs That Compile Cleanly

- **Conflicting queries panic (B0001/B0002).** Two parameters that could
  reach the same component mutably panic the first time the system runs —
  `Query<&mut Health, With<Player>>` next to
  `Query<&mut Health, With<Enemy>>` conflicts because one entity could have
  both markers (`Res<T>` + `ResMut<T>` of the same type panics as B0002).
  Make queries disjoint with `Without`, or use `ParamSet` when they truly
  overlap and are used one at a time. Pick the filter matching the game's
  rules, not whichever compiles.
- **`Commands` are deferred.** `spawn`/`insert`/`despawn` apply at the
  next sync point (`ApplyDeferred`). Bevy inserts one automatically between
  systems with an explicit order (`.chain()`, `.before()`, `.after()`)
  when the earlier has `Commands` — without an order, another system can
  run before queued changes apply and see the old world.
- **Order dependent systems.** Systems in one tuple without `.chain()`
  have no order and may run either way per frame. If one reads what another
  writes in the same frame, give them an order: `.chain()` for a pipeline,
  `.after()` for one edge, system sets for groups.
- **Never unwrap queries.** `Query::single()`/`get()` return `Result`;
  `.unwrap()` crashes when the player dies or a second camera spawns. Use
  `Single<D, F>` (skips the system unless exactly one matches) or
  `let Ok(..) = .. else { return };`. A system may return `Result` and use
  `?`, but the default error handler panics — install a quieter one via
  `app.insert_resource(FallbackErrorHandler(warn))`.
- **Commands on a possibly-gone entity.** A command on an entity despawned
  earlier in the frame errors when it applies (default: panic). Guard
  double-despawn (two hits killing one enemy) or use `try_insert` /
  `try_despawn`.
- **Messages are per-reader, once.** A reader running before the writer in
  a frame sees that message next frame — order the reader after its writer
  when same-frame reaction matters.

### Testing Systems

Drive systems through a headless `App` without `DefaultPlugins`; insert
needed resources and advance `Time` by hand for determinism:

```rust
#[test]
fn units_move_by_velocity() {
    let mut app = App::new();
    app.init_resource::<Time>().add_systems(Update, move_units);
    let unit = app.world_mut()
        .spawn((Position(Vec2::ZERO), Velocity(Vec2::X * 10.0))).id();
    app.world_mut().resource_mut::<Time>().advance_by(Duration::from_secs(2));
    app.update();
    assert_eq!(app.world().get::<Position>(unit), Some(&Position(Vec2::X * 20.0)));
}
```

Also add one smoke test that adds the whole plugin and calls `app.update()`
twice — conflicting queries and missing resources only surface when a
system first runs, so per-system tests can all pass while the plugin panics
on frame one.

## Related Concepts

- [Rust Code Review](rust-code-review.md) — the framework check that
  routes a review here
- [Testing Strategy](testing-strategy.md) — general test organization;
  the smoke test is Bevy's addition
- [Rustfmt and Clippy](rustfmt-clippy-config.md) — the `[lints]` table
  this page amends for Bevy crates
- [Import Organization](import-organization.md) — the glob rule the Bevy
  prelude is exempted from
