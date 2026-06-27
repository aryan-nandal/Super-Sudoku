import 'dart:math';

import '../domain/puzzle_data.dart';
import '../engine/engine.dart';

/// Request for a deterministic daily puzzle. Plain data so it can cross an
/// isolate boundary via `compute`.
class DailyRequest {
  /// Stable per-day seed (see `dailySeedFor`).
  final int seed;

  /// Target difficulty index (see `dailyDifficultyFor`).
  final int difficultyIndex;

  const DailyRequest({required this.seed, required this.difficultyIndex});
}

/// Generates the daily puzzle deterministically from [req].
///
/// Because the engine threads a seeded [Random] through generation, the same
/// seed yields a byte-identical puzzle on every device — a true global daily
/// with no backend. Suitable for `compute()`.
PuzzleData generateDailyPuzzleData(DailyRequest req) {
  final target = Difficulty.values[req.difficultyIndex];
  final generated = generatePuzzle(target: target, random: Random(req.seed));
  return PuzzleData(
    puzzle: generated.puzzle,
    solution: generated.solution,
    difficultyIndex: generated.difficulty.index,
    clues: generated.clues,
  );
}
