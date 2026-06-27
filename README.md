# Super Sudoku

> The ultimate cognitive gym — a welcoming, ad-free Sudoku built around an honest puzzle engine, a global daily, and a real learning ramp.

A cross-platform Flutter app by **Ninety Nine Labs** (`com.ninetyninelabs`). The
positioning: mass-market on the surface (anyone can pick up the Daily in ten
seconds) with a deep learning ramp and high skill ceiling underneath.

**Monetization:** free global Daily + shareable result card forever, plus a single
**₹9.9 one-time unlock** for depth (unlimited puzzles, unlimited hints, learning
path, deep analytics). **No ads, ever. No subscription.**

---

## Status

| Phase | Theme | State |
|---|---|---|
| **0** | Puzzle engine | ✅ Complete |
| **1** | Lean growth MVP | 🚧 In progress |
| **2** | Identity & progression (learning path, puzzle-rating, leaderboards) | ⏳ Planned |
| **3** | Social depth & variants | ⏳ Planned |

### Done

- **Phase 0 — Puzzle engine** (pure Dart, runs on-device in an isolate)
  - Unique-solution generator (rejects 0- or multi-solution grids)
  - Brute-force solver / uniqueness checker
  - Human-technique logical solver & grader (Naked/Hidden Singles → Locked
    Candidates → Pairs/Triples → X-Wing …) that records the *hardest technique
    required*
  - Honest difficulty banding derived from technique depth, **never** clue count
    (`beginner → easy → medium → hard → expert → master`)
- **Phase 1 — Core board & input UX**
  - 9×9 board with pencil-mark notes, number highlighting, conflict highlighting,
    unlimited undo/redo, mistakes/timer top bar, win flow
  - Off-thread puzzle generation via `compute`, injected for deterministic tests
- **Phase 1 — Global Daily + shareable result card**
  - One puzzle per day, **identical for everyone with no backend** — derived
    deterministically from a per-day seed threaded through the seeded generator
  - Fixed weekly difficulty cadence (easy → hard, capped below `master`)
  - Spoiler-free, one-tap shareable result card (time, mistakes, hints, hardest
    technique reached)

### In progress (branch: `phase1-persistence`)

- **Drift (SQLite) local persistence** — offline-first store for resumable games,
  typed key/value settings, and Daily completion history (the basis for streaks
  and stats).

### Planned for Phase 1

Teaching hints (3-tier nudge → name → walkthrough), streaks with freezes,
post-game analytics, accessibility pass (color-blind-safe cues, font scaling,
reduced motion), ₹9.9 unlock / entitlement gating, and visual polish toward the
glassmorphism/neon direction.

---

## Architecture

Layered, with **dependencies pointing downward only** — a pure-Dart domain that
never imports Flutter or any backend.

```
Presentation   widgets + screens (per feature)
      ↕  watch/read (Riverpod)
Application    Notifiers / controllers (Riverpod)
      ↕  calls
Domain         pure logic: engine, game rules + repository INTERFACES
               (NO Flutter / NO backend)
      ↕  implements
Data           repo impls: Drift local store, Daily service, puzzle gen service
```

Guiding principles:

1. **Domain is pure Dart** — the engine and game rules have zero Flutter/backend
   imports. The durable, testable asset.
2. **Offline-first** — the local store is authoritative; the network is an
   enhancement. Must work in airplane mode.
3. **Feature-first modularity** — each feature owns its UI + state + data.
4. **Thin UI over explicit state** — presentational widgets render state and emit
   intents; no logic lives in widgets.
5. **TDD** — tests precede UI/feature code; only final end-to-end is deferred.

### Tech stack

| Concern | Choice |
|---|---|
| State management | Riverpod v2 (manual providers for now¹) |
| Local persistence | Drift (SQLite) + codegen |
| Engine threading | `compute` (→ dedicated isolate worker later) |
| Backend | Firebase — **deferred to Phase 2**; MVP is local-first |
| Monetization | RevenueCat (store IAP) — Phase 1 later; web stays the free funnel |

¹ `riverpod_generator` is intentionally omitted while its stable release can't
co-resolve with `flutter_riverpod` 3.3 / `riverpod_annotation` 4.x. Providers are
written manually; switching to `@riverpod` later is a drop-in refactor.

---

## Project structure

```
lib/
  core/
    theme/                  app_theme.dart, board_theme.dart (BoardTheme ThemeExtension)
  engine/                   pure puzzle engine
    grid.dart               board representation + index math
    brute_solver.dart       brute-force solver / uniqueness checker
    logical_solver.dart     human-technique solver & grader
    difficulty.dart         honest difficulty banding
    generator.dart          unique-solution generator
    engine.dart             barrel export
  domain/
    sudoku_game.dart        pure game rules + undo/redo
    puzzle_data.dart        isolate-safe DTO
    daily.dart              daily number / seed / difficulty cadence (pure)
  data/
    puzzle_generation_service.dart   compute entry → PuzzleData
    daily_puzzle_service.dart        deterministic daily generation
    db/app_database.dart             Drift schema (settings, game saves, daily completions)
    settings_repository.dart         typed key/value settings
    game_save_repository.dart        resumable-game persistence
    daily_completion_repository.dart daily history
  features/
    game/
      game_controller.dart  Riverpod Notifier (GameState) + generator provider
      board_screen.dart     wires controller ↔ widgets; clock; win dialog
      widgets/              sudoku_board, number_pad, game_top_bar (presentational)
    daily/
      daily_screen.dart
      widgets/daily_result_card.dart
  main.dart                 ProviderScope + themed MaterialApp

bin/engine_demo.dart        standalone CLI demo of the engine
test/                       engine, domain, data, and feature/widget tests
```

> Internal planning docs (`docs/PLAN.md`, `docs/ARCHITECTURE.md`) are kept local
> and gitignored.

---

## Getting started

Requires the Flutter SDK (Dart `^3.11.4`).

```bash
flutter pub get

# Generate Drift code (run after changing the database schema)
dart run build_runner build --delete-conflicting-outputs

flutter run
```

Try the engine standalone, no UI:

```bash
dart run bin/engine_demo.dart
```

## Testing

```bash
flutter test       # ~49 tests across engine, domain, data, and widgets
flutter analyze    # static analysis (kept clean)
```

Testing strategy: plain Dart unit tests for the engine and domain;
`ProviderContainer` + provider overrides for controllers; `flutter_test` widget
tests for presentational widgets, with one screen-level integration test that
overrides the generator for determinism. Full device/E2E tests are deferred.
