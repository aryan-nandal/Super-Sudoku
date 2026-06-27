import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/daily/daily_screen.dart';
import 'package:super_sudoku/features/game/game_controller.dart';

import '../../helpers/test_db.dart';

void main() {
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  PuzzleData almostSolvedDaily() {
    final solution = parseBoard(solutionStr);
    final puzzle = List<int>.of(solution)..[40] = 0;
    return PuzzleData(
      puzzle: puzzle,
      solution: solution,
      difficultyIndex: Difficulty.medium.index,
      clues: puzzle.where((v) => v != 0).length,
    );
  }

  testWidgets('loads today\'s daily and reveals the result card on solve',
      (tester) async {
    final data = almostSolvedDaily();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryDbOverride,
          dailyGeneratorProvider.overrideWithValue((_) async => data),
        ],
        child: MaterialApp(theme: AppTheme.light(), home: const DailyScreen()),
      ),
    );

    // Let the post-frame startDaily + immediate generation resolve.
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('cell_40')), findsOneWidget);
    expect(find.textContaining('Daily #'), findsWidgets);

    // Solve the single empty cell.
    final solution = parseBoard(solutionStr);
    await tester.tap(find.byKey(const ValueKey('cell_40')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey('digit_${solution[40]}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // sheet animation

    // The shareable result card appears.
    expect(find.byKey(const ValueKey('daily_share_button')), findsOneWidget);

    // Dismiss the sheet (tap the scrim) before unmounting, then unmount to
    // dispose the clock timer cleanly.
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
