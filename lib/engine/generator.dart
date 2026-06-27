import 'dart:math';

import 'brute_solver.dart';
import 'difficulty.dart';
import 'grid.dart';
import 'logical_solver.dart';

/// A generated puzzle bundled with its solution and grading metadata.
class GeneratedPuzzle {
  final List<int> puzzle;
  final List<int> solution;
  final Difficulty difficulty;
  final GradeResult grade;
  final int clues;

  const GeneratedPuzzle({
    required this.puzzle,
    required this.solution,
    required this.difficulty,
    required this.grade,
    required this.clues,
  });
}

/// Generates a random complete, valid solution grid via randomized backtracking.
List<int> generateSolved(Random rng) {
  final board = List<int>.filled(boardSize, 0);

  bool fill(int pos) {
    if (pos == boardSize) return true;
    if (board[pos] != 0) return fill(pos + 1);
    final digits = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(rng);
    for (final d in digits) {
      if (_canPlace(board, pos, d)) {
        board[pos] = d;
        if (fill(pos + 1)) return true;
        board[pos] = 0;
      }
    }
    return false;
  }

  fill(0);
  return board;
}

bool _canPlace(List<int> board, int i, int d) {
  for (final p in peers[i]) {
    if (board[p] == d) return false;
  }
  return true;
}

/// Generates a puzzle, optionally targeting a difficulty [target].
///
/// Every returned puzzle is guaranteed to have a unique solution. When a target
/// is given we dig holes only while the puzzle stays within the target band, and
/// return the closest match found within [maxAttempts] (exact match returns
/// immediately). With no target, returns the first fully-dug puzzle.
GeneratedPuzzle generatePuzzle({
  Difficulty? target,
  Random? random,
  int maxAttempts = 60,
}) {
  final rng = random ?? Random();
  GeneratedPuzzle? best;
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    final candidate = _digOne(rng, target);
    if (target == null || candidate.difficulty == target) return candidate;
    if (best == null ||
        (candidate.difficulty.index - target.index).abs() <
            (best.difficulty.index - target.index).abs()) {
      best = candidate;
    }
  }
  return best!;
}

GeneratedPuzzle _digOne(Random rng, Difficulty? target) {
  final solution = generateSolved(rng);
  final puzzle = List<int>.of(solution);
  final order = List<int>.generate(boardSize, (i) => i)..shuffle(rng);

  for (final i in order) {
    final backup = puzzle[i];
    if (backup == 0) continue;
    puzzle[i] = 0;

    // Removing a clue must never create a second solution.
    if (!hasUniqueSolution(puzzle)) {
      puzzle[i] = backup;
      continue;
    }

    // When targeting, don't dig past the requested difficulty.
    if (target != null) {
      final g = grade(puzzle);
      if (!g.solved || difficultyFromGrade(g).index > target.index) {
        puzzle[i] = backup;
      }
    }
  }

  final g = grade(puzzle);
  return GeneratedPuzzle(
    puzzle: puzzle,
    solution: solution,
    difficulty: difficultyFromGrade(g),
    grade: g,
    clues: puzzle.where((v) => v != 0).length,
  );
}
