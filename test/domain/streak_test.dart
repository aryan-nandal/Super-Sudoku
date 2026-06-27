import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/streak.dart';

void main() {
  final today = DateTime.utc(2026, 6, 28);
  DateTime ago(int n) => today.subtract(Duration(days: n));

  test('no completions means no streak', () {
    final s = computeStreak(const [], today: today);
    expect(s.current, 0);
    expect(s.longest, 0);
  });

  test('three consecutive days ending today', () {
    final s = computeStreak([today, ago(1), ago(2)], today: today, freezeBudget: 0);
    expect(s.current, 3);
    expect(s.longest, 3);
  });

  test('a freeze bridges a single missed day', () {
    final s = computeStreak([today, ago(2)], today: today, freezeBudget: 1);
    expect(s.current, 2, reason: 'gap at day-1 bridged by a freeze');
  });

  test('yesterday-only keeps the streak alive via grace', () {
    final s = computeStreak([ago(1)], today: today, freezeBudget: 1);
    expect(s.current, 1);
  });

  test('too long a gap breaks the current streak', () {
    final s = computeStreak([ago(3)], today: today, freezeBudget: 1);
    expect(s.current, 0);
  });

  test('longest reflects the best historical run', () {
    final s = computeStreak(
      [ago(10), ago(9), ago(8), ago(7), today],
      today: today,
      freezeBudget: 0,
    );
    expect(s.longest, 4);
    expect(s.current, 1);
  });
}
