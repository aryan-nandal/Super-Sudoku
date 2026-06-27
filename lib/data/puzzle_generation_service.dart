import '../domain/puzzle_data.dart';
import '../engine/engine.dart';

/// Top-level entry point suitable for `compute()` — generates a puzzle of the
/// requested difficulty off the UI thread. Takes/returns only simple data so it
/// is safe to send across an isolate boundary.
PuzzleData generatePuzzleData(int difficultyIndex) {
  final target = Difficulty.values[difficultyIndex];
  final generated = generatePuzzle(target: target);
  return PuzzleData(
    puzzle: generated.puzzle,
    solution: generated.solution,
    difficultyIndex: generated.difficulty.index,
    clues: generated.clues,
  );
}
