import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/data/daily_puzzle_service.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  group('daily puzzle generation', () {
    test('is deterministic for the same seed (the global-daily guarantee)', () {
      final req = DailyRequest(
        seed: 20260101,
        difficultyIndex: Difficulty.medium.index,
      );
      final a = generateDailyPuzzleData(req);
      final b = generateDailyPuzzleData(req);
      expect(boardToString(a.puzzle), boardToString(b.puzzle));
      expect(boardToString(a.solution), boardToString(b.solution));
    });

    test('different seeds produce different puzzles', () {
      final a = generateDailyPuzzleData(
        DailyRequest(seed: 20260101, difficultyIndex: Difficulty.medium.index),
      );
      final b = generateDailyPuzzleData(
        DailyRequest(seed: 20260102, difficultyIndex: Difficulty.medium.index),
      );
      expect(boardToString(a.puzzle), isNot(boardToString(b.puzzle)));
    });

    test('produces a valid, uniquely-solvable puzzle', () {
      final p = generateDailyPuzzleData(
        DailyRequest(seed: 20260103, difficultyIndex: Difficulty.hard.index),
      );
      expect(hasUniqueSolution(p.puzzle), isTrue);
      expect(isConsistent(p.solution), isTrue);
      expect(p.solution.where((v) => v == 0), isEmpty);
    });
  });
}
