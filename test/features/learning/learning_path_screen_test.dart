import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/domain/learning_path.dart';
import 'package:super_sudoku/features/learning/learning_path_screen.dart';

import '../../helpers/test_db.dart';

void main() {
  testWidgets('shows the path; completing a node unlocks the next (live)',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [inMemoryDbOverride],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LearningPathScreen(),
        ),
      ),
    );

    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await settle();
    expect(find.byKey(const ValueKey('learning_list')), findsOneWidget);

    final first = ValueKey('lesson_${learningPath[0].id}');
    final second = ValueKey('lesson_${learningPath[1].id}');

    // Initially: first node unlocked (play), second locked.
    expect(
      find.descendant(of: find.byKey(first), matching: find.byIcon(Icons.play_circle_fill)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byKey(second), matching: find.byIcon(Icons.lock_outline)),
      findsOneWidget,
    );

    // Completing the first node updates the path live: first done, second unlocks.
    await container
        .read(learningRepositoryProvider)
        .markCompleted(learningPath[0].id);
    await settle();
    expect(
      find.descendant(of: find.byKey(first), matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: find.byKey(second), matching: find.byIcon(Icons.play_circle_fill)),
      findsOneWidget,
    );

    // Drain drift stream timers before teardown.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
