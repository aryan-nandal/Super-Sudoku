import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/daily.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  group('daily numbering & seed', () {
    test('day number counts from the launch epoch (2026-01-01 == #1)', () {
      expect(dailyNumberFor(DateTime.utc(2026, 1, 1)), 1);
      expect(dailyNumberFor(DateTime.utc(2026, 1, 11)), 11);
    });

    test('numbering ignores time-of-day', () {
      expect(
        dailyNumberFor(DateTime.utc(2026, 3, 14, 23, 59)),
        dailyNumberFor(DateTime.utc(2026, 3, 14, 0, 1)),
      );
    });

    test('seed is stable per calendar day and differs across days', () {
      expect(dailySeedFor(DateTime.utc(2026, 5, 20)),
          dailySeedFor(DateTime.utc(2026, 5, 20, 12)));
      expect(dailySeedFor(DateTime.utc(2026, 5, 20)),
          isNot(dailySeedFor(DateTime.utc(2026, 5, 21))));
    });
  });

  group('difficulty cadence', () {
    test('maps weekday to a fixed, non-master difficulty', () {
      // 2026-01-01 is a Thursday; 2026-01-03 is a Saturday.
      expect(dailyDifficultyFor(DateTime.utc(2026, 1, 1)), Difficulty.medium);
      expect(dailyDifficultyFor(DateTime.utc(2026, 1, 3)), Difficulty.hard);
      for (var d = 1; d <= 7; d++) {
        final day = DateTime.utc(2026, 1, d);
        expect(dailyDifficultyFor(day), isNot(Difficulty.master));
      }
    });
  });

  group('share text', () {
    final result = DailyResult(
      dayNumber: 1,
      date: DateTime.utc(2026, 1, 1),
      difficulty: Difficulty.medium,
      time: const Duration(minutes: 4, seconds: 32),
      mistakes: 1,
      hints: 0,
    );

    test('formats duration as mm:ss', () {
      expect(formatDuration(const Duration(minutes: 4, seconds: 32)), '04:32');
      expect(formatDuration(const Duration(seconds: 9)), '00:09');
    });

    test('is spoiler-free and includes the headline stats', () {
      final text = buildDailyShareText(result);
      expect(text, contains('Super Sudoku Daily #1'));
      expect(text, contains('Medium'));
      expect(text, contains('04:32'));
      expect(text, contains('1')); // mistakes
      expect(text, contains('supersudoku.app'));
      // No raw board digits leak: it must not contain a 9-in-a-row digit string.
      expect(RegExp(r'\d{9}').hasMatch(text), isFalse);
    });

    test('emoji grid reflects a flawless solve differently from a sloppy one',
        () {
      final clean = buildDailyShareText(result.copyWith(mistakes: 0));
      final sloppy = buildDailyShareText(result.copyWith(mistakes: 5));
      expect(clean, contains('🟩'));
      expect(clean, isNot(equals(sloppy)));
    });
  });
}
