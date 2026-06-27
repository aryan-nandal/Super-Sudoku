import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/router/app_router.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/daily/daily_screen.dart';
import 'package:super_sudoku/features/game/game_controller.dart';
import 'package:super_sudoku/main.dart';

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

  testWidgets('the /daily route deep-links into the Daily screen',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryDbOverride,
          puzzleGeneratorProvider.overrideWithValue((_) async => data),
          dailyGeneratorProvider.overrideWithValue((_) async => data),
        ],
        child: const SuperSudokuApp(),
      ),
    );
    await tester.pump();
    await tester.pump();

    // Simulate opening a shared /daily link.
    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    container.read(appRouterProvider).go('/daily');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(DailyScreen), findsOneWidget);
    expect(find.textContaining('Daily #'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
