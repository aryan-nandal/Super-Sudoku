import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/stats.dart';

void main() {
  group('summarizeSolves', () {
    test('aggregates count, best and average per difficulty', () {
      final summary = summarizeSolves(const [
        (difficultyIndex: 1, timeSeconds: 300),
        (difficultyIndex: 1, timeSeconds: 200),
        (difficultyIndex: 2, timeSeconds: 600),
      ]);
      expect(summary.totalSolved, 3);
      expect(summary.byDifficulty[1]!.played, 2);
      expect(summary.byDifficulty[1]!.bestSeconds, 200);
      expect(summary.byDifficulty[1]!.averageSeconds, 250);
      expect(summary.byDifficulty[2]!.played, 1);
    });

    test('empty input yields zero', () {
      expect(summarizeSolves(const []).totalSolved, 0);
    });
  });

  group('percentFaster', () {
    test('positive when faster than average', () {
      expect(percentFaster(200, 250), 20);
    });

    test('negative when slower', () {
      expect(percentFaster(300, 250), -20);
    });

    test('null with no baseline', () {
      expect(percentFaster(200, 0), isNull);
    });
  });
}
