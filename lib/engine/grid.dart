// Core Sudoku board constants and index math.
//
// A board is a flat `List<int>` of length 81. Index `i` maps to row `i ~/ 9`
// and column `i % 9`. A value of `0` means empty; `1..9` is a filled digit.
// All lookup tables (units, peers) are precomputed once at startup.

const int boardSize = 81;
const int side = 9;
const int boxSide = 3;

int rowOf(int i) => i ~/ side;
int colOf(int i) => i % side;
int boxOf(int i) => (rowOf(i) ~/ boxSide) * boxSide + (colOf(i) ~/ boxSide);

/// The 9 rows, each a list of 9 cell indices.
final List<List<int>> rowUnits = List.generate(
  side,
  (r) => List.generate(side, (c) => r * side + c),
);

/// The 9 columns.
final List<List<int>> colUnits = List.generate(
  side,
  (c) => List.generate(side, (r) => r * side + c),
);

/// The 9 boxes.
final List<List<int>> boxUnits = List.generate(side, (b) {
  final baseRow = (b ~/ boxSide) * boxSide;
  final baseCol = (b % boxSide) * boxSide;
  final cells = <int>[];
  for (var dr = 0; dr < boxSide; dr++) {
    for (var dc = 0; dc < boxSide; dc++) {
      cells.add((baseRow + dr) * side + (baseCol + dc));
    }
  }
  return cells;
});

/// All 27 units (9 rows + 9 columns + 9 boxes).
final List<List<int>> allUnits = [...rowUnits, ...colUnits, ...boxUnits];

/// For each cell, the list of its 20 peers (same row, column, or box).
final List<List<int>> peers = List.generate(boardSize, (i) {
  final set = <int>{}
    ..addAll(rowUnits[rowOf(i)])
    ..addAll(colUnits[colOf(i)])
    ..addAll(boxUnits[boxOf(i)])
    ..remove(i);
  return set.toList(growable: false);
});

/// Parse an 81-character string ('.' or '0' for empty) into a board.
List<int> parseBoard(String s) {
  final cleaned = s.replaceAll(RegExp(r'\s'), '');
  if (cleaned.length != boardSize) {
    throw ArgumentError(
      'Board string must have $boardSize cells, got ${cleaned.length}',
    );
  }
  return List<int>.generate(boardSize, (i) {
    final ch = cleaned[i];
    if (ch == '.' || ch == '0') return 0;
    final d = int.tryParse(ch);
    if (d == null || d < 1 || d > 9) {
      throw ArgumentError('Invalid character "$ch" at index $i');
    }
    return d;
  });
}

/// Serialize a board to an 81-character string using '.' for empty cells.
String boardToString(List<int> board) {
  final sb = StringBuffer();
  for (final v in board) {
    sb.write(v == 0 ? '.' : v.toString());
  }
  return sb.toString();
}

/// Render a board as a human-readable 9x9 grid (for debugging / the CLI demo).
String boardToPretty(List<int> board) {
  final sb = StringBuffer();
  for (var r = 0; r < side; r++) {
    if (r % boxSide == 0 && r != 0) sb.writeln('------+-------+------');
    for (var c = 0; c < side; c++) {
      if (c % boxSide == 0 && c != 0) sb.write('| ');
      final v = board[r * side + c];
      sb.write(v == 0 ? '. ' : '$v ');
    }
    sb.writeln();
  }
  return sb.toString();
}

/// True if `board` has no duplicate digit in any unit (ignoring empty cells).
bool isConsistent(List<int> board) {
  for (final unit in allUnits) {
    final seen = <int>{};
    for (final i in unit) {
      final v = board[i];
      if (v == 0) continue;
      if (!seen.add(v)) return false;
    }
  }
  return true;
}
