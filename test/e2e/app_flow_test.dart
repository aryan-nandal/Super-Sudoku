import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/game_controller.dart';
import 'package:super_sudoku/features/settings/settings_screen.dart';
import 'package:super_sudoku/main.dart';

import '../helpers/test_db.dart';

/// End-to-end smoke of the fully-assembled app: boots the real `SuperSudokuApp`
/// and drives the core loop plus navigation, guarding against regressions in how
/// the pieces fit together. Uses an in-memory DB and deterministic puzzles.
///
/// Per-screen behavior (settings toggles, stats data, daily result card) is
/// covered in depth by the feature widget tests; this guards the assembly.
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

  Future<void> bootApp(WidgetTester tester) async {
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
    await tester.pump();
  }

  testWidgets('boots, plays a move, and gives a teaching hint', (tester) async {
    await bootApp(tester);

    // Board is up.
    expect(find.text('Super Sudoku'), findsOneWidget);
    expect(find.byKey(const ValueKey('cell_2')), findsOneWidget);

    // Place a correct digit.
    await tester.tap(find.byKey(const ValueKey('cell_2')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('digit_4'))); // solution[2]
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('cell_2')),
        matching: find.text('4'),
      ),
      findsOneWidget,
    );

    // Teaching hint appears and can be dismissed.
    await tester.tap(find.byKey(const ValueKey('action_hint')));
    await tester.pump();
    expect(find.byKey(const ValueKey('hint_banner')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('hint_dismiss_button')));
    await tester.pump();
    expect(find.byKey(const ValueKey('hint_banner')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1)); // drain drift stream timers
  });

  testWidgets('opens the Settings screen from the board', (tester) async {
    await bootApp(tester);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('setting_auto_candidates')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1)); // drain drift stream timers
  });

  testWidgets('opens the Daily puzzle from the board', (tester) async {
    await bootApp(tester);
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pump(); // push route
    await tester.pump(const Duration(milliseconds: 350)); // finish transition
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50)); // daily generation
    }
    expect(find.textContaining('Daily #'), findsWidgets);
    expect(find.byKey(const ValueKey('cell_2')), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1)); // drain drift stream timers
  });
}
