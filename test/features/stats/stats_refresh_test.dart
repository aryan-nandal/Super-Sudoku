import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/data/daily_completion_repository.dart';
import 'package:super_sudoku/data/game_results_repository.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/features/stats/stats_screen.dart';

import '../../helpers/test_db.dart';

void main() {
  testWidgets('stats update live as results and completions are recorded',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [inMemoryDbOverride],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const StatsScreen(),
        ),
      ),
    );

    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    final results = container.read(gameResultsRepositoryProvider);
    final completions = container.read(dailyCompletionRepositoryProvider);

    Future<void> settle() async {
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await settle();
    expect(find.text('Solved: 0'), findsOneWidget);

    // Recording a solve updates the open Stats screen live (no reopen needed).
    await results.record(const GameResultRecord(
      difficultyIndex: 1, timeSeconds: 120, mistakes: 0, date: '2026-06-28'));
    await settle();
    expect(find.text('Solved: 1'), findsOneWidget);

    await results.record(const GameResultRecord(
      difficultyIndex: 2, timeSeconds: 200, mistakes: 1, date: '2026-06-28'));
    await settle();
    expect(find.text('Solved: 2'), findsOneWidget);

    // A daily completion updates the streak card live too.
    expect(find.text('Current streak'), findsOneWidget);
    await completions.record(DailyCompletionRecord(
      date: dailyDateKey(DateTime.now()),
      dayNumber: 1,
      difficultyIndex: 1,
      timeSeconds: 120,
      mistakes: 0,
    ));
    await settle();
    // Streak becomes 1 (today completed) — the "0/0" card now shows a 1.
    expect(find.text('1'), findsWidgets);

    // Unmount so the ProviderScope disposes (closing the DB + drift streams),
    // then pump to drain drift's coalescing timers so none are left pending.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
