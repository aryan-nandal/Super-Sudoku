import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/features/stats/stats_screen.dart';

import '../../helpers/test_db.dart';

void main() {
  testWidgets('renders streak, quests and totals (empty state)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [inMemoryDbOverride],
        child: MaterialApp(theme: AppTheme.light(), home: const StatsScreen()),
      ),
    );
    // Let the async stats load resolve.
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('stats_list')), findsOneWidget);
    expect(find.text('Daily quests'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Solved: 0'), findsOneWidget);
    // Three quests, all incomplete with no activity.
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));

    // Dispose the scope (closes DB + drift streams) and drain coalescing timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
