import 'grid.dart';

/// Human solving techniques, ordered easiest → hardest. The enum order **is**
/// the difficulty order: `index` ranks how hard the technique is.
enum Technique {
  nakedSingle,
  hiddenSingle,
  lockedCandidates,
  nakedPair,
  hiddenPair,
  nakedTriple,
  xWing,
}

extension TechniqueInfo on Technique {
  /// A rough "cognitive cost" weight used to compute a numeric difficulty score.
  int get cost => const {
        Technique.nakedSingle: 1,
        Technique.hiddenSingle: 3,
        Technique.lockedCandidates: 6,
        Technique.nakedPair: 10,
        Technique.hiddenPair: 14,
        Technique.nakedTriple: 18,
        Technique.xWing: 30,
      }[this]!;

  String get label => const {
        Technique.nakedSingle: 'Naked Single',
        Technique.hiddenSingle: 'Hidden Single',
        Technique.lockedCandidates: 'Locked Candidates',
        Technique.nakedPair: 'Naked Pair',
        Technique.hiddenPair: 'Hidden Pair',
        Technique.nakedTriple: 'Naked Triple',
        Technique.xWing: 'X-Wing',
      }[this]!;

  /// One-line teaching tip (used by tier-2 hints).
  String get tip => const {
        Technique.nakedSingle:
            'This cell has only one possible digit left.',
        Technique.hiddenSingle:
            'Only one cell in a row, column, or box can hold this digit.',
        Technique.lockedCandidates:
            'A digit in a box is confined to one line, so it can be removed from that line elsewhere.',
        Technique.nakedPair:
            'Two cells share the same two candidates, freeing those digits from the rest of the unit.',
        Technique.hiddenPair:
            'Two digits can only go in the same two cells of a unit.',
        Technique.nakedTriple:
            'Three cells together use only three candidates.',
        Technique.xWing:
            'A digit forms a rectangle across two lines, eliminating it from the crossing lines.',
      }[this]!;
}

/// The outcome of grading a puzzle by pure logical deduction.
class GradeResult {
  /// Whether the puzzle was fully solved using only the technique ladder.
  final bool solved;

  /// Best-effort filled board (fully solved if [solved], otherwise as far as
  /// logic could get).
  final List<int> solution;

  /// How many times each technique fired.
  final Map<Technique, int> techniqueCounts;

  /// The hardest technique required, or null if no deduction was needed.
  final Technique? hardestTechnique;

  /// Sum of technique costs over every application — a fine-grained difficulty
  /// score for ordering puzzles within a band.
  final int score;

  const GradeResult({
    required this.solved,
    required this.solution,
    required this.techniqueCounts,
    required this.hardestTechnique,
    required this.score,
  });
}

/// Solves [puzzle] using only the human technique ladder and reports which
/// techniques were required. This is the basis for honest difficulty grading
/// and the learning-path's technique tagging.
///
/// The loop always retries from the cheapest technique after any progress, so
/// the recorded "hardest technique" is the genuine ceiling the puzzle demands.
GradeResult grade(List<int> puzzle) {
  final values = List<int>.of(puzzle);
  final candidates = List<Set<int>>.generate(boardSize, (i) {
    if (values[i] != 0) return <int>{};
    final used = <int>{};
    for (final p in peers[i]) {
      if (values[p] != 0) used.add(values[p]);
    }
    return {for (var d = 1; d <= 9; d++) if (!used.contains(d)) d};
  });

  final counts = <Technique, int>{};
  var score = 0;
  Technique? hardest;

  void place(int i, int d) {
    values[i] = d;
    candidates[i].clear();
    for (final p in peers[i]) {
      candidates[p].remove(d);
    }
  }

  bool apply(Technique t) {
    switch (t) {
      case Technique.nakedSingle:
        return _nakedSingle(values, candidates, place);
      case Technique.hiddenSingle:
        return _hiddenSingle(values, candidates, place);
      case Technique.lockedCandidates:
        return _lockedCandidates(values, candidates);
      case Technique.nakedPair:
        return _nakedSubset(values, candidates, 2);
      case Technique.hiddenPair:
        return _hiddenPair(values, candidates);
      case Technique.nakedTriple:
        return _nakedSubset(values, candidates, 3);
      case Technique.xWing:
        return _xWing(values, candidates);
    }
  }

  while (true) {
    // Contradiction: an empty cell with no candidates means this state is dead.
    var dead = false;
    for (var i = 0; i < boardSize; i++) {
      if (values[i] == 0 && candidates[i].isEmpty) {
        dead = true;
        break;
      }
    }
    if (dead) break;

    var progressed = false;
    for (final t in Technique.values) {
      if (apply(t)) {
        counts[t] = (counts[t] ?? 0) + 1;
        score += t.cost;
        if (hardest == null || t.index > hardest.index) hardest = t;
        progressed = true;
        break; // restart from the cheapest technique
      }
    }
    if (!progressed) break;
  }

  final solved = values.every((v) => v != 0) && isConsistent(values);
  return GradeResult(
    solved: solved,
    solution: values,
    techniqueCounts: counts,
    hardestTechnique: hardest,
    score: score,
  );
}

/// A single suggested next step for the hint system.
class HintStep {
  /// The technique that justifies the step (the hardest one needed to reach it).
  final Technique technique;

  /// The cell to fill.
  final int cell;

  /// The digit that belongs in [cell].
  final int digit;

  const HintStep({
    required this.technique,
    required this.cell,
    required this.digit,
  });
}

/// Finds the next logical placement from the current [boardValues], applying
/// eliminations as needed to unlock it. Returns null if the board is solved,
/// contradictory, or stuck beyond the supported technique ladder.
///
/// Read-only with respect to the caller's board — it works on internal copies.
HintStep? nextHint(List<int> boardValues) {
  final values = List<int>.of(boardValues);
  final candidates = List<Set<int>>.generate(boardSize, (i) {
    if (values[i] != 0) return <int>{};
    final used = <int>{};
    for (final p in peers[i]) {
      if (values[p] != 0) used.add(values[p]);
    }
    return {for (var d = 1; d <= 9; d++) if (!used.contains(d)) d};
  });

  Technique? hardest;
  while (true) {
    for (var i = 0; i < boardSize; i++) {
      if (values[i] == 0 && candidates[i].isEmpty) return null; // contradiction
    }

    final ns = _findNakedSingle(values, candidates);
    if (ns != null) return _hintResult(Technique.nakedSingle, ns, hardest);

    final hs = _findHiddenSingle(values, candidates);
    if (hs != null) return _hintResult(Technique.hiddenSingle, hs, hardest);

    // No singles available — apply the cheapest elimination to make progress.
    var progressed = false;
    for (final t in const [
      Technique.lockedCandidates,
      Technique.nakedPair,
      Technique.hiddenPair,
      Technique.nakedTriple,
      Technique.xWing,
    ]) {
      if (_applyElimination(t, values, candidates)) {
        if (hardest == null || t.index > hardest.index) hardest = t;
        progressed = true;
        break;
      }
    }
    if (!progressed) return null; // stuck beyond our techniques
  }
}

/// Walks the logical solve path of [puzzle], capturing positions where the next
/// required placement is attributed to [target] (the hardest technique needed
/// to unlock it). Returns up to [max] positions, each as the board state
/// *before* the move plus the move itself — i.e. positions whose next deduction
/// genuinely features that technique. Pure (operates on copies).
List<({List<int> board, HintStep step})> collectTechniqueSteps(
  List<int> puzzle,
  Technique target, {
  int max = 3,
}) {
  final values = List<int>.of(puzzle);
  final out = <({List<int> board, HintStep step})>[];
  var guard = 0;
  while (out.length < max && guard++ < boardSize * 2) {
    final h = nextHint(values);
    if (h == null) break;
    if (h.technique == target) {
      out.add((board: List<int>.of(values), step: h));
    }
    values[h.cell] = h.digit;
  }
  return out;
}

HintStep _hintResult(Technique single, List<int> cellDigit, Technique? hardest) {
  // If an advanced elimination was needed, that's the teaching point.
  final tech =
      (hardest != null && hardest.index > single.index) ? hardest : single;
  return HintStep(technique: tech, cell: cellDigit[0], digit: cellDigit[1]);
}

/// Returns [cell, digit] of a naked single, or null.
List<int>? _findNakedSingle(List<int> values, List<Set<int>> cand) {
  for (var i = 0; i < boardSize; i++) {
    if (values[i] == 0 && cand[i].length == 1) return [i, cand[i].first];
  }
  return null;
}

/// Returns [cell, digit] of a hidden single, or null.
List<int>? _findHiddenSingle(List<int> values, List<Set<int>> cand) {
  for (final unit in allUnits) {
    for (var d = 1; d <= 9; d++) {
      var onlyCell = -1;
      var count = 0;
      var alreadyPlaced = false;
      for (final i in unit) {
        if (values[i] == d) {
          alreadyPlaced = true;
          break;
        }
        if (values[i] == 0 && cand[i].contains(d)) {
          count++;
          onlyCell = i;
        }
      }
      if (!alreadyPlaced && count == 1) return [onlyCell, d];
    }
  }
  return null;
}

bool _applyElimination(
  Technique t,
  List<int> values,
  List<Set<int>> candidates,
) {
  switch (t) {
    case Technique.lockedCandidates:
      return _lockedCandidates(values, candidates);
    case Technique.nakedPair:
      return _nakedSubset(values, candidates, 2);
    case Technique.hiddenPair:
      return _hiddenPair(values, candidates);
    case Technique.nakedTriple:
      return _nakedSubset(values, candidates, 3);
    case Technique.nakedSingle:
    case Technique.hiddenSingle:
    case Technique.xWing:
      return t == Technique.xWing ? _xWing(values, candidates) : false;
  }
}

// ---------------------------------------------------------------------------
// Technique implementations. Each returns true if it changed the board state
// (placed a digit or eliminated at least one candidate).
// ---------------------------------------------------------------------------

bool _nakedSingle(
  List<int> values,
  List<Set<int>> cand,
  void Function(int, int) place,
) {
  for (var i = 0; i < boardSize; i++) {
    if (values[i] == 0 && cand[i].length == 1) {
      place(i, cand[i].first);
      return true;
    }
  }
  return false;
}

bool _hiddenSingle(
  List<int> values,
  List<Set<int>> cand,
  void Function(int, int) place,
) {
  for (final unit in allUnits) {
    for (var d = 1; d <= 9; d++) {
      var onlyCell = -1;
      var count = 0;
      var alreadyPlaced = false;
      for (final i in unit) {
        if (values[i] == d) {
          alreadyPlaced = true;
          break;
        }
        if (values[i] == 0 && cand[i].contains(d)) {
          count++;
          onlyCell = i;
        }
      }
      if (alreadyPlaced) continue;
      if (count == 1) {
        place(onlyCell, d);
        return true;
      }
    }
  }
  return false;
}

bool _lockedCandidates(List<int> values, List<Set<int>> cand) {
  // Pointing: a digit confined to one row/col within a box is eliminated from
  // the rest of that line.
  for (final box in boxUnits) {
    for (var d = 1; d <= 9; d++) {
      final cells = [
        for (final i in box)
          if (values[i] == 0 && cand[i].contains(d)) i,
      ];
      if (cells.isEmpty) continue;
      final boxId = boxOf(cells.first);
      if (cells.map(rowOf).toSet().length == 1) {
        final r = rowOf(cells.first);
        var changed = false;
        for (final i in rowUnits[r]) {
          if (boxOf(i) != boxId && values[i] == 0 && cand[i].remove(d)) {
            changed = true;
          }
        }
        if (changed) return true;
      }
      if (cells.map(colOf).toSet().length == 1) {
        final c = colOf(cells.first);
        var changed = false;
        for (final i in colUnits[c]) {
          if (boxOf(i) != boxId && values[i] == 0 && cand[i].remove(d)) {
            changed = true;
          }
        }
        if (changed) return true;
      }
    }
  }

  // Claiming: a digit confined to one box within a row/col is eliminated from
  // the rest of that box.
  for (final line in [...rowUnits, ...colUnits]) {
    for (var d = 1; d <= 9; d++) {
      final cells = [
        for (final i in line)
          if (values[i] == 0 && cand[i].contains(d)) i,
      ];
      if (cells.isEmpty) continue;
      if (cells.map(boxOf).toSet().length == 1) {
        final b = boxOf(cells.first);
        final lineSet = line.toSet();
        var changed = false;
        for (final i in boxUnits[b]) {
          if (!lineSet.contains(i) && values[i] == 0 && cand[i].remove(d)) {
            changed = true;
          }
        }
        if (changed) return true;
      }
    }
  }
  return false;
}

/// Naked pair (size 2) and naked triple (size 3): a group of `size` cells in a
/// unit whose candidates union to exactly `size` digits lets those digits be
/// removed from the rest of the unit.
bool _nakedSubset(List<int> values, List<Set<int>> cand, int size) {
  for (final unit in allUnits) {
    final emptyCells = [
      for (final i in unit)
        if (values[i] == 0) i,
    ];
    final cells = [
      for (final i in emptyCells)
        if (cand[i].length >= 2 && cand[i].length <= size) i,
    ];
    for (final combo in _combinations(cells, size)) {
      final union = <int>{};
      for (final i in combo) {
        union.addAll(cand[i]);
      }
      if (union.length != size) continue;
      var changed = false;
      for (final i in emptyCells) {
        if (combo.contains(i)) continue;
        for (final d in union) {
          if (cand[i].remove(d)) changed = true;
        }
      }
      if (changed) return true;
    }
  }
  return false;
}

/// Hidden pair: two digits that can only appear in the same two cells of a unit
/// let all other candidates be removed from those two cells.
bool _hiddenPair(List<int> values, List<Set<int>> cand) {
  for (final unit in allUnits) {
    final pos = <int, List<int>>{};
    for (var d = 1; d <= 9; d++) {
      final cells = [
        for (final i in unit)
          if (values[i] == 0 && cand[i].contains(d)) i,
      ];
      if (cells.isNotEmpty) pos[d] = cells;
    }
    final digits = pos.keys.toList();
    for (var a = 0; a < digits.length; a++) {
      for (var b = a + 1; b < digits.length; b++) {
        final d1 = digits[a], d2 = digits[b];
        final c1 = pos[d1]!, c2 = pos[d2]!;
        if (c1.length == 2 && c2.length == 2 && _sameCells(c1, c2)) {
          var changed = false;
          for (final i in c1) {
            final before = cand[i].length;
            cand[i].removeWhere((d) => d != d1 && d != d2);
            if (cand[i].length != before) changed = true;
          }
          if (changed) return true;
        }
      }
    }
  }
  return false;
}

/// X-Wing: for a digit, two rows where it is confined to the same two columns
/// (or vice versa) let it be eliminated from those columns in all other rows.
bool _xWing(List<int> values, List<Set<int>> cand) {
  for (var d = 1; d <= 9; d++) {
    // Row-based.
    final rowCols = <int, List<int>>{};
    for (var r = 0; r < side; r++) {
      final cols = [
        for (final i in rowUnits[r])
          if (values[i] == 0 && cand[i].contains(d)) colOf(i),
      ];
      if (cols.length == 2) rowCols[r] = cols;
    }
    final rows = rowCols.keys.toList();
    for (var a = 0; a < rows.length; a++) {
      for (var b = a + 1; b < rows.length; b++) {
        final r1 = rows[a], r2 = rows[b];
        if (!_sameCells(rowCols[r1]!, rowCols[r2]!)) continue;
        final c1 = rowCols[r1]![0], c2 = rowCols[r1]![1];
        var changed = false;
        for (var r = 0; r < side; r++) {
          if (r == r1 || r == r2) continue;
          for (final c in [c1, c2]) {
            final i = r * side + c;
            if (values[i] == 0 && cand[i].remove(d)) changed = true;
          }
        }
        if (changed) return true;
      }
    }

    // Column-based.
    final colRows = <int, List<int>>{};
    for (var c = 0; c < side; c++) {
      final rws = [
        for (final i in colUnits[c])
          if (values[i] == 0 && cand[i].contains(d)) rowOf(i),
      ];
      if (rws.length == 2) colRows[c] = rws;
    }
    final cols = colRows.keys.toList();
    for (var a = 0; a < cols.length; a++) {
      for (var b = a + 1; b < cols.length; b++) {
        final cc1 = cols[a], cc2 = cols[b];
        if (!_sameCells(colRows[cc1]!, colRows[cc2]!)) continue;
        final r1 = colRows[cc1]![0], r2 = colRows[cc1]![1];
        var changed = false;
        for (var c = 0; c < side; c++) {
          if (c == cc1 || c == cc2) continue;
          for (final r in [r1, r2]) {
            final i = r * side + c;
            if (values[i] == 0 && cand[i].remove(d)) changed = true;
          }
        }
        if (changed) return true;
      }
    }
  }
  return false;
}

bool _sameCells(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  final sb = b.toSet();
  for (final x in a) {
    if (!sb.contains(x)) return false;
  }
  return true;
}

List<List<int>> _combinations(List<int> items, int k) {
  final result = <List<int>>[];
  void go(int start, List<int> acc) {
    if (acc.length == k) {
      result.add(List.of(acc));
      return;
    }
    for (var i = start; i < items.length; i++) {
      acc.add(items[i]);
      go(i + 1, acc);
      acc.removeLast();
    }
  }

  go(0, <int>[]);
  return result;
}
