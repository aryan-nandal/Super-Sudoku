import '../engine/engine.dart';

/// The launch epoch — "Daily #1" is the puzzle for this date.
final DateTime _epoch = DateTime.utc(2026, 1, 1);

DateTime _utcDay(DateTime date) => DateTime.utc(date.year, date.month, date.day);

/// 1-based daily number for [date] (days since the launch epoch + 1).
int dailyNumberFor(DateTime date) =>
    _utcDay(date).difference(_epoch).inDays + 1;

/// A stable per-calendar-day seed (yyyymmdd) used to generate the daily puzzle
/// deterministically — identical on every device, no backend required.
int dailySeedFor(DateTime date) =>
    date.year * 10000 + date.month * 100 + date.day;

/// Fixed difficulty cadence by weekday (Mon→Sun). Capped at `hard` so daily
/// generation stays fast and reliable; never `master`.
Difficulty dailyDifficultyFor(DateTime date) {
  const cadence = <Difficulty>[
    Difficulty.easy, // Monday
    Difficulty.easy, // Tuesday
    Difficulty.medium, // Wednesday
    Difficulty.medium, // Thursday
    Difficulty.medium, // Friday
    Difficulty.hard, // Saturday
    Difficulty.hard, // Sunday
  ];
  return cadence[date.weekday - 1];
}

/// The player's outcome on a daily puzzle — the data behind the share card.
class DailyResult {
  final int dayNumber;
  final DateTime date;
  final Difficulty difficulty;
  final Duration time;
  final int mistakes;
  final int hints;

  const DailyResult({
    required this.dayNumber,
    required this.date,
    required this.difficulty,
    required this.time,
    required this.mistakes,
    required this.hints,
  });

  DailyResult copyWith({
    int? dayNumber,
    DateTime? date,
    Difficulty? difficulty,
    Duration? time,
    int? mistakes,
    int? hints,
  }) {
    return DailyResult(
      dayNumber: dayNumber ?? this.dayNumber,
      date: date ?? this.date,
      difficulty: difficulty ?? this.difficulty,
      time: time ?? this.time,
      mistakes: mistakes ?? this.mistakes,
      hints: hints ?? this.hints,
    );
  }
}

/// mm:ss (minutes can exceed 59).
String formatDuration(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Builds the spoiler-free shareable result text (Wordle-style). It conveys the
/// headline stats and a decorative performance grid, but never the solution.
String buildDailyShareText(
  DailyResult result, {
  String url = 'https://supersudoku.app/daily',
}) {
  final grid = _performanceGrid(result.mistakes);
  return 'Super Sudoku Daily #${result.dayNumber}\n'
      '${result.difficulty.label} · ⏱ ${formatDuration(result.time)} · '
      '❌ ${result.mistakes} · 💡 ${result.hints}\n'
      '$grid\n'
      '$url';
}

/// A 3×3 decorative grid whose color tier reflects how clean the solve was.
/// Purely cosmetic — encodes no board information.
String _performanceGrid(int mistakes) {
  final emoji = mistakes == 0
      ? '🟩'
      : mistakes <= 2
          ? '🟨'
          : '🟧';
  final line = emoji * 3;
  return '$line\n$line\n$line';
}
