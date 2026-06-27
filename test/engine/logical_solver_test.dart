import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  const puzzle =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solution =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  group('logical solver / grader', () {
    test('solves the canonical puzzle by logic and matches brute solution', () {
      final g = grade(parseBoard(puzzle));
      expect(g.solved, isTrue);
      expect(boardToString(g.solution), solution);
      expect(g.hardestTechnique, isNotNull);
      expect(g.score, greaterThan(0));
    });

    test('a board of only naked singles grades as Beginner', () {
      // Full solution with a single empty cell => only a naked single needed.
      final board = parseBoard(solution);
      board[40] = 0;
      final g = grade(board);
      expect(g.solved, isTrue);
      expect(g.hardestTechnique, Technique.nakedSingle);
      expect(difficultyFromGrade(g), Difficulty.beginner);
    });

    test('difficulty band is always a valid enum value', () {
      final g = grade(parseBoard(puzzle));
      expect(Difficulty.values, contains(difficultyFromGrade(g)));
    });
  });
}
