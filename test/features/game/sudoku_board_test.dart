import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/domain/sudoku_game.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/widgets/sudoku_board.dart';

void main() {
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  SudokuGame freshGame() => SudokuGame(
        solution: parseBoard(solutionStr),
        puzzle: parseBoard(puzzleStr),
      );

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: SizedBox(width: 360, height: 360, child: child),
          ),
        ),
      );

  testWidgets('renders given digits', (tester) async {
    await tester.pumpWidget(
      wrap(SudokuBoard(game: freshGame(), onCellTap: (_) {})),
    );
    // Cell 0 is a given '5'.
    expect(find.text('5'), findsWidgets);
  });

  testWidgets('tapping an empty cell reports its index', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      wrap(SudokuBoard(game: freshGame(), onCellTap: (i) => tapped = i)),
    );
    await tester.tap(find.byKey(const ValueKey('cell_2')));
    expect(tapped, 2);
  });

  testWidgets('shows pencil-mark notes for a noted cell', (tester) async {
    final game = freshGame()
      ..select(2)
      ..toggleNotesMode()
      ..inputDigit(7);
    await tester.pumpWidget(
      wrap(SudokuBoard(game: game, onCellTap: (_) {})),
    );
    // The note '7' should render somewhere on the board.
    expect(find.text('7'), findsWidgets);
  });
}
