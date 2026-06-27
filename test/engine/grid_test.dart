import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  group('grid', () {
    test('every cell has exactly 20 peers and excludes itself', () {
      for (var i = 0; i < boardSize; i++) {
        expect(peers[i].length, 20);
        expect(peers[i].contains(i), isFalse);
      }
    });

    test('there are 27 units, each of 9 cells', () {
      expect(allUnits.length, 27);
      for (final u in allUnits) {
        expect(u.length, 9);
      }
    });

    test('parse / serialize round trips (empties canonicalized to ".")', () {
      const s =
          '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
      final board = parseBoard(s);
      expect(board.length, boardSize);
      // boardToString emits '.' for empty cells; re-parsing must yield the
      // same board, and the canonical string uses '.' where the input had '0'.
      expect(parseBoard(boardToString(board)), board);
      expect(boardToString(board), s.replaceAll('0', '.'));
    });

    test('parse rejects malformed input', () {
      expect(() => parseBoard('123'), throwsArgumentError);
    });

    test('isConsistent detects duplicate in a unit', () {
      final board = List<int>.filled(boardSize, 0);
      expect(isConsistent(board), isTrue);
      board[0] = 5;
      board[1] = 5; // same row
      expect(isConsistent(board), isFalse);
    });
  });
}
