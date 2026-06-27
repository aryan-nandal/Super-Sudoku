import 'grid.dart';

/// Result of a brute-force solve.
class SolveCount {
  /// Number of solutions found, capped at the requested `limit`.
  final int count;

  /// The first valid solution found, or null if the board is unsolvable.
  final List<int>? solution;

  const SolveCount(this.count, this.solution);
}

/// Counts the solutions of [board] up to [limit] (default 2 — enough to test
/// uniqueness) and returns the first solution found.
///
/// Uses minimum-remaining-values (MRV) cell selection plus per-row/col/box
/// bitmasks, so it short-circuits as soon as the limit is reached. This is the
/// authority for the unique-solution guarantee.
SolveCount countSolutions(List<int> board, {int limit = 2}) {
  final work = List<int>.of(board);
  final rowMask = List<int>.filled(side, 0);
  final colMask = List<int>.filled(side, 0);
  final boxMask = List<int>.filled(side, 0);

  for (var i = 0; i < boardSize; i++) {
    final v = work[i];
    if (v != 0) {
      final bit = 1 << v;
      rowMask[rowOf(i)] |= bit;
      colMask[colOf(i)] |= bit;
      boxMask[boxOf(i)] |= bit;
    }
  }

  var found = 0;
  List<int>? firstSolution;

  // Bitmask of available digits for cell i (bits 1..9 set => available).
  int candidatesFor(int i) {
    final used = rowMask[rowOf(i)] | colMask[colOf(i)] | boxMask[boxOf(i)];
    return (~used) & 0x3FE; // 0x3FE == bits 1..9
  }

  // Returns true to signal "stop searching" (limit reached).
  bool recurse() {
    var best = -1;
    var bestCount = 10;
    var bestMask = 0;
    for (var i = 0; i < boardSize; i++) {
      if (work[i] != 0) continue;
      final mask = candidatesFor(i);
      final c = _popcount(mask);
      if (c == 0) return false; // dead end
      if (c < bestCount) {
        bestCount = c;
        best = i;
        bestMask = mask;
        if (c == 1) break; // can't do better than a forced cell
      }
    }

    if (best == -1) {
      // No empty cells remain: a complete solution.
      found++;
      firstSolution ??= List<int>.of(work);
      return found >= limit;
    }

    final r = rowOf(best), c = colOf(best), b = boxOf(best);
    var m = bestMask;
    while (m != 0) {
      final bit = m & (-m); // lowest set bit
      m ^= bit;
      final d = _bitIndex(bit);

      work[best] = d;
      rowMask[r] |= bit;
      colMask[c] |= bit;
      boxMask[b] |= bit;

      final stop = recurse();

      work[best] = 0;
      rowMask[r] &= ~bit;
      colMask[c] &= ~bit;
      boxMask[b] &= ~bit;

      if (stop) return true;
    }
    return false;
  }

  recurse();
  return SolveCount(found, firstSolution);
}

/// True iff [board] has exactly one solution.
bool hasUniqueSolution(List<int> board) =>
    countSolutions(board, limit: 2).count == 1;

int _popcount(int x) {
  var c = 0;
  while (x != 0) {
    x &= x - 1;
    c++;
  }
  return c;
}

/// The digit (1..9) encoded by a single-bit mask `1 << d`.
int _bitIndex(int bit) {
  var d = 0;
  while (bit > 1) {
    bit >>= 1;
    d++;
  }
  return d;
}
