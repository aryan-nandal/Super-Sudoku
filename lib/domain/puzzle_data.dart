import '../engine/engine.dart';

/// A puzzle reduced to plain, sendable data so it can cross an isolate boundary
/// (via `compute`) without shipping the richer engine value objects.
class PuzzleData {
  final List<int> puzzle;
  final List<int> solution;
  final int difficultyIndex;
  final int clues;

  const PuzzleData({
    required this.puzzle,
    required this.solution,
    required this.difficultyIndex,
    required this.clues,
  });

  Difficulty get difficulty => Difficulty.values[difficultyIndex];
}
