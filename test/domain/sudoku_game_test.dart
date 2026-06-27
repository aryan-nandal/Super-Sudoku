import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/sudoku_game.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  // Canonical puzzle: cell 0 is a given '5'; cells 2 and 3 are empty
  // (solution digits 4 and 6 respectively).
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  SudokuGame freshGame() => SudokuGame(
        solution: parseBoard(solutionStr),
        puzzle: parseBoard(puzzleStr),
      );

  group('construction', () {
    test('marks givens, copies values, starts clean', () {
      final g = freshGame();
      expect(g.given[0], isTrue, reason: 'cell 0 is a clue');
      expect(g.given[2], isFalse, reason: 'cell 2 is empty');
      expect(g.values[0], 5);
      expect(g.values[2], 0);
      expect(g.mistakes, 0);
      expect(g.canUndo, isFalse);
      expect(g.canRedo, isFalse);
      expect(g.isSolved, isFalse);
    });
  });

  group('placing values', () {
    test('correct placement sets value, no mistake, enables undo', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4); // solution[2] == 4
      expect(g.values[2], 4);
      expect(g.mistakes, 0);
      expect(g.isError(2), isFalse);
      expect(g.canUndo, isTrue);
    });

    test('wrong placement counts a mistake and flags an error', () {
      final g = freshGame()
        ..select(3)
        ..inputDigit(9); // solution[3] == 6
      expect(g.values[3], 9);
      expect(g.mistakes, 1);
      expect(g.isError(3), isTrue);
    });

    test('given cells are immutable (input safety)', () {
      final g = freshGame()
        ..select(0)
        ..inputDigit(9);
      expect(g.values[0], 5, reason: 'given cell must not change');
      expect(g.mistakes, 0);
      expect(g.canUndo, isFalse, reason: 'no-op must not push undo history');
    });

    test('re-entering the same digit is a no-op', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4);
      final undoDepthAfterFirst = g.canUndo;
      g.inputDigit(4);
      expect(g.values[2], 4);
      expect(undoDepthAfterFirst, isTrue);
    });
  });

  group('notes', () {
    test('toggle notes on an empty cell without counting mistakes', () {
      final g = freshGame()
        ..select(2)
        ..toggleNotesMode()
        ..inputDigit(5);
      expect(g.notes[2].contains(5), isTrue);
      expect(g.values[2], 0);
      expect(g.mistakes, 0);

      g.inputDigit(5); // toggling the same note removes it
      expect(g.notes[2].contains(5), isFalse);
    });

    test('cannot add notes to a filled cell', () {
      final g = freshGame()
        ..select(3)
        ..inputDigit(6) // fill it
        ..toggleNotesMode()
        ..inputDigit(7);
      expect(g.notes[3], isEmpty);
    });

    test('placing a correct value auto-eliminates it from peer notes', () {
      // Cell 11 shares column 2 with cell 2.
      final g = freshGame()
        ..select(11)
        ..toggleNotesMode()
        ..inputDigit(4) // note 4 in a peer of cell 2
        ..toggleNotesMode()
        ..select(2)
        ..inputDigit(4); // correct placement in cell 2
      expect(g.notes[11].contains(4), isFalse);
    });
  });

  group('erase', () {
    test('clears value and notes of a non-given cell', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4)
        ..erase();
      expect(g.values[2], 0);
      expect(g.notes[2], isEmpty);
    });

    test('erasing a given cell is a no-op', () {
      final g = freshGame()
        ..select(0)
        ..erase();
      expect(g.values[0], 5);
      expect(g.canUndo, isFalse);
    });
  });

  group('undo / redo', () {
    test('undo reverts a placement, redo re-applies it', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4);

      g.undo();
      expect(g.values[2], 0);
      expect(g.canRedo, isTrue);

      g.redo();
      expect(g.values[2], 4);
    });

    test('a new move clears the redo stack', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4);
      g.undo();
      expect(g.canRedo, isTrue);

      g
        ..select(3)
        ..inputDigit(6);
      expect(g.canRedo, isFalse);
    });
  });

  group('duplicate detection', () {
    test('flags two equal values sharing a unit', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(9)
        ..select(3)
        ..inputDigit(9); // cells 2 and 3 share row 0
      expect(g.isDuplicate(2), isTrue);
      expect(g.isDuplicate(3), isTrue);
    });

    test('a unique, correct value is not a duplicate; empty is not', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4); // solution[2]
      expect(g.isDuplicate(2), isFalse);
      expect(g.isDuplicate(5), isFalse); // empty cell
    });
  });

  group('candidatesFor', () {
    test('computes valid candidates for an empty cell', () {
      final g = freshGame();
      final c = g.candidatesFor(2);
      expect(c, contains(4)); // the solution digit must be a candidate
      expect(c, isNot(contains(5))); // 5 is given in the same row
      expect(c, isNot(contains(3))); // 3 is given in the same row
    });

    test('a filled cell has no candidates', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4);
      expect(g.candidatesFor(2), isEmpty);
    });
  });

  group('error rewind guardrail', () {
    test('hasErrors reflects wrong entries; clearErrors removes only those', () {
      final g = freshGame()
        ..select(2)
        ..inputDigit(4) // correct
        ..select(3)
        ..inputDigit(9); // wrong (solution[3] == 6)
      expect(g.hasErrors, isTrue);

      g.clearErrors();
      expect(g.hasErrors, isFalse);
      expect(g.values[3], 0, reason: 'wrong entry cleared');
      expect(g.values[2], 4, reason: 'correct entry kept');
      expect(g.canUndo, isTrue, reason: 'rewind is undoable');
    });
  });

  group('restore', () {
    test('rebuilds givens from puzzle and restores progress on top', () {
      final solution = parseBoard(solutionStr);
      final puzzle = parseBoard(puzzleStr);
      final values = List<int>.of(puzzle)..[2] = 4; // player filled cell 2
      final notes = List<Set<int>>.generate(boardSize, (_) => <int>{});
      notes[11] = {1, 3, 5};

      final g = SudokuGame.restore(
        solution: solution,
        puzzle: puzzle,
        values: values,
        notes: notes,
        mistakes: 3,
      );

      expect(g.given[0], isTrue); // original clue
      expect(g.given[2], isFalse); // was empty in the puzzle
      expect(g.values[2], 4);
      expect(g.notes[11], {1, 3, 5});
      expect(g.mistakes, 3);
    });
  });

  group('completion', () {
    test('isSolved becomes true when the final correct digit is placed', () {
      final solution = parseBoard(solutionStr);
      final nearlyDone = List<int>.of(solution);
      nearlyDone[40] = 0; // leave one cell empty
      final g = SudokuGame(solution: solution, puzzle: nearlyDone);
      expect(g.given[40], isFalse);
      expect(g.isSolved, isFalse);

      g
        ..select(40)
        ..inputDigit(solution[40]);
      expect(g.isSolved, isTrue);
    });

    test('remaining counts missing instances of a digit', () {
      final solution = parseBoard(solutionStr);
      final solved = SudokuGame(solution: solution, puzzle: solution);
      for (var d = 1; d <= 9; d++) {
        expect(solved.remaining(d), 0);
      }
    });
  });
}
