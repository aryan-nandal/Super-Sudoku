import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/board_screen.dart';
import 'package:super_sudoku/features/game/game_controller.dart';

import '../../helpers/test_db.dart';

void main() {
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  final data = PuzzleData(
    puzzle: parseBoard(puzzleStr),
    solution: parseBoard(solutionStr),
    difficultyIndex: Difficulty.easy.index,
    clues: parseBoard(puzzleStr).where((v) => v != 0).length,
  );

  testWidgets('loads a game, then selects a cell and places a digit',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryDbOverride,
          puzzleGeneratorProvider.overrideWithValue((_) async => data),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const BoardScreen()),
      ),
    );

    // Let the post-frame newGame run and the (immediate) generation resolve.
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('cell_2')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cell_2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('digit_4')));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cell_2')),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );

    // Unmount to dispose the clock timer cleanly.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
