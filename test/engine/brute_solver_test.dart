import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  const puzzle =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solution =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  group('brute solver', () {
    test('canonical puzzle has a single, correct solution', () {
      final board = parseBoard(puzzle);
      final result = countSolutions(board, limit: 2);
      expect(result.count, 1);
      expect(boardToString(result.solution!), solution);
      expect(hasUniqueSolution(board), isTrue);
    });

    test('empty board is not unique (caps at the limit)', () {
      final board = List<int>.filled(boardSize, 0);
      expect(countSolutions(board, limit: 2).count, 2);
      expect(hasUniqueSolution(board), isFalse);
    });

    test('returned solution is consistent and complete', () {
      final result = countSolutions(parseBoard(puzzle));
      expect(result.solution, isNotNull);
      expect(result.solution!.where((v) => v == 0), isEmpty);
      expect(isConsistent(result.solution!), isTrue);
    });
  });
}
