import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/domain/daily.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/daily/widgets/daily_result_card.dart';

void main() {
  final result = DailyResult(
    dayNumber: 1,
    date: DateTime.utc(2026, 1, 1),
    difficulty: Difficulty.medium,
    time: const Duration(minutes: 4, seconds: 32),
    mistakes: 1,
    hints: 0,
  );

  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  testWidgets('shows headline, difficulty and time', (tester) async {
    await tester.pumpWidget(
      wrap(DailyResultCard(result: result, onShare: () {})),
    );
    expect(find.textContaining('Daily #1'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('04:32'), findsOneWidget);
  });

  testWidgets('share button fires the callback', (tester) async {
    var shared = false;
    await tester.pumpWidget(
      wrap(DailyResultCard(result: result, onShare: () => shared = true)),
    );
    await tester.tap(find.byKey(const ValueKey('daily_share_button')));
    expect(shared, isTrue);
  });
}
