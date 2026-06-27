import '../engine/engine.dart';
import 'puzzle_data.dart';

/// Pure (no Flutter) mutable game state for a single Sudoku puzzle.
///
/// Holds the player's current values, pencil-mark notes, selection, and an
/// undo/redo history. All mutating actions go through methods that enforce the
/// plan's input-safety rules (given cells are immutable, notes never count as
/// mistakes) and snapshot state for undo.
class SudokuGame {
  /// The full, correct solution (used for correctness feedback and hints).
  final List<int> solution;

  /// Whether each cell was a given clue (immutable by the player).
  final List<bool> given;

  /// The player's current value per cell (0 = empty).
  final List<int> values;

  /// Pencil-mark notes per cell.
  final List<Set<int>> notes;

  /// Currently selected cell index, or null.
  int? selected;

  /// When true, digit input edits notes instead of placing a value.
  bool notesMode = false;

  /// When true, placing a value auto-removes that digit from peers' notes.
  bool autoEliminateNotes = true;

  /// Cumulative count of incorrect placements (for stats — never a game-over).
  int mistakes = 0;

  final List<_Snapshot> _undoStack = [];
  final List<_Snapshot> _redoStack = [];

  SudokuGame({required this.solution, required List<int> puzzle})
      : assert(puzzle.length == boardSize),
        assert(solution.length == boardSize),
        given = List<bool>.generate(boardSize, (i) => puzzle[i] != 0),
        values = List<int>.of(puzzle),
        notes = List<Set<int>>.generate(boardSize, (_) => <int>{});

  factory SudokuGame.from(PuzzleData data) =>
      SudokuGame(solution: data.solution, puzzle: data.puzzle);

  /// Rebuild a game from a persisted snapshot: givens come from [puzzle], then
  /// the player's [values], [notes] and [mistakes] are restored on top.
  factory SudokuGame.restore({
    required List<int> solution,
    required List<int> puzzle,
    required List<int> values,
    required List<Set<int>> notes,
    required int mistakes,
  }) {
    final game = SudokuGame(solution: solution, puzzle: puzzle);
    for (var i = 0; i < boardSize; i++) {
      game.values[i] = values[i];
      game.notes[i]
        ..clear()
        ..addAll(notes[i]);
    }
    game.mistakes = mistakes;
    return game;
  }

  // --- Queries used by the UI -------------------------------------------------

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  bool get isSolved {
    for (var i = 0; i < boardSize; i++) {
      if (values[i] != solution[i]) return false;
    }
    return true;
  }

  /// A user-entered value that contradicts the solution.
  bool isError(int i) =>
      values[i] != 0 && !given[i] && values[i] != solution[i];

  /// Whether cell [i] is a peer of cell [of] (shares a row/col/box).
  bool isPeer(int i, int of) => peers[of].contains(i);

  /// How many of [digit] are still missing from the board (placed correctly).
  int remaining(int digit) {
    var placed = 0;
    for (var i = 0; i < boardSize; i++) {
      if (values[i] == digit) placed++;
    }
    return 9 - placed;
  }

  // --- Mutations --------------------------------------------------------------

  void select(int i) => selected = i;

  void toggleNotesMode() => notesMode = !notesMode;

  /// Apply a digit to the selected cell (placing a value, or toggling a note in
  /// notes mode). No-ops safely on given/invalid cells.
  void inputDigit(int digit) {
    final i = selected;
    if (i == null || given[i]) return; // input safety: never edit a given cell

    if (notesMode) {
      if (values[i] != 0) return; // can't note a filled cell
      _recordForUndo();
      if (!notes[i].remove(digit)) notes[i].add(digit);
      return;
    }

    if (values[i] == digit) return; // no-op
    _recordForUndo();
    values[i] = digit;
    notes[i].clear();
    if (digit != solution[i]) {
      mistakes++;
    } else if (autoEliminateNotes) {
      for (final p in peers[i]) {
        notes[p].remove(digit);
      }
    }
  }

  /// Clear the selected cell's value and notes.
  void erase() {
    final i = selected;
    if (i == null || given[i]) return;
    if (values[i] == 0 && notes[i].isEmpty) return;
    _recordForUndo();
    values[i] = 0;
    notes[i].clear();
  }

  void undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_snapshot());
    _restore(_undoStack.removeLast());
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_snapshot());
    _restore(_redoStack.removeLast());
  }

  // --- Undo plumbing ----------------------------------------------------------

  void _recordForUndo() {
    _undoStack.add(_snapshot());
    _redoStack.clear();
  }

  _Snapshot _snapshot() => _Snapshot(
        List<int>.of(values),
        notes.map((s) => Set<int>.of(s)).toList(),
        mistakes,
      );

  void _restore(_Snapshot s) {
    for (var i = 0; i < boardSize; i++) {
      values[i] = s.values[i];
      notes[i]
        ..clear()
        ..addAll(s.notes[i]);
    }
    mistakes = s.mistakes;
  }
}

class _Snapshot {
  final List<int> values;
  final List<Set<int>> notes;
  final int mistakes;
  _Snapshot(this.values, this.notes, this.mistakes);
}
