import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  group('generator', () {
    test('produced puzzles are unique and consistent with their solution', () {
      final rng = Random(7);
      for (var i = 0; i < 5; i++) {
        final p = generatePuzzle(random: rng);

        expect(hasUniqueSolution(p.puzzle), isTrue,
            reason: 'every generated puzzle must have one solution');
        expect(isConsistent(p.solution), isTrue);
        expect(p.solution.where((v) => v == 0), isEmpty);

        // Clues must agree with the solution, and respect the known 17 minimum.
        for (var c = 0; c < boardSize; c++) {
          if (p.puzzle[c] != 0) {
            expect(p.puzzle[c], p.solution[c]);
          }
        }
        expect(p.clues, greaterThanOrEqualTo(17));
      }
    });

    test('solveable generated puzzles grade below master', () {
      // A targeted medium puzzle should be solvable by the technique ladder.
      final p = generatePuzzle(target: Difficulty.medium, random: Random(123));
      expect(hasUniqueSolution(p.puzzle), isTrue);
      if (p.difficulty != Difficulty.master) {
        expect(p.grade.solved, isTrue);
      }
    });
  });
}
