import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  group('nextHint', () {
    test('suggests a correct next placement', () {
      final hint = nextHint(parseBoard(puzzleStr));
      expect(hint, isNotNull);
      final solution = parseBoard(solutionStr);
      // The hinted cell is empty in the puzzle, and the digit is correct.
      expect(parseBoard(puzzleStr)[hint!.cell], 0);
      expect(hint.digit, solution[hint.cell]);
    });

    test('a single remaining cell is a naked single', () {
      final solution = parseBoard(solutionStr);
      final board = List<int>.of(solution)..[40] = 0;
      final hint = nextHint(board);
      expect(hint, isNotNull);
      expect(hint!.cell, 40);
      expect(hint.digit, solution[40]);
      expect(hint.technique, Technique.nakedSingle);
    });

    test('returns null for a solved board', () {
      expect(nextHint(parseBoard(solutionStr)), isNull);
    });

    test('reports a named technique for the step', () {
      final hint = nextHint(parseBoard(puzzleStr));
      expect(Technique.values, contains(hint!.technique));
      expect(hint.technique.label, isNotEmpty);
      expect(hint.technique.tip, isNotEmpty);
    });
  });
}
