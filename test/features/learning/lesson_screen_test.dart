import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/domain/learning_path.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/game_controller.dart';
import 'package:super_sudoku/features/learning/lesson_controller.dart';
import 'package:super_sudoku/features/learning/lesson_screen.dart';

import '../../helpers/test_db.dart';

void main() {
  testWidgets('guided lesson renders step + instruction and advances',
      (tester) async {
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryDbOverride,
          puzzleGeneratorProvider.overrideWithValue((_) async => data),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: LessonScreen(node: learningPath.first),
        ),
      ),
    );

    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await settle();
    expect(find.textContaining('Step 1 of'), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson_instruction')), findsOneWidget);

    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    // This lesson should have more than one position to show live advance.
    expect(container.read(lessonControllerProvider).totalSteps,
        greaterThanOrEqualTo(2));

    // Make the technique move → the step advances live.
    final n = container.read(lessonControllerProvider.notifier);
    final t = container.read(lessonControllerProvider).target!;
    n.select(t.cell);
    n.input(t.digit);
    await settle();

    expect(find.textContaining('Step 2 of'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
