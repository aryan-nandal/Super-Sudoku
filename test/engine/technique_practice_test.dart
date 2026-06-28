import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  test('collectTechniqueSteps yields positions whose next move features it', () {
    final puzzle = parseBoard(puzzleStr);
    final solution = parseBoard(solutionStr);

    final steps = collectTechniqueSteps(puzzle, Technique.nakedSingle, max: 3);

    expect(steps, isNotEmpty);
    expect(steps.length, lessThanOrEqualTo(3));
    for (final s in steps) {
      // The captured board is a valid mid-solve position.
      expect(s.board[s.step.cell], 0, reason: 'target cell is empty');
      expect(s.step.digit, solution[s.step.cell], reason: 'move is correct');
      expect(s.step.technique, Technique.nakedSingle);
      // The next required move on that board IS this technique step.
      final h = nextHint(s.board);
      expect(h, isNotNull);
      expect(h!.technique, Technique.nakedSingle);
      expect(h.cell, s.step.cell);
      expect(h.digit, s.step.digit);
    }
  });

  test('any captured step genuinely features its technique (no false hits)', () {
    // Whatever technique is requested, every returned position must require it.
    for (final t in Technique.values) {
      final steps = collectTechniqueSteps(parseBoard(puzzleStr), t, max: 2);
      for (final s in steps) {
        expect(nextHint(s.board)!.technique, t);
      }
    }
  });
}
