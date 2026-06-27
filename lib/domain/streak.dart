/// Streak summary: current run and all-time best.
class StreakInfo {
  final int current;
  final int longest;

  const StreakInfo({required this.current, required this.longest});
}

DateTime _day(DateTime x) => DateTime.utc(x.year, x.month, x.day);

/// Computes streaks from the set of completed days.
///
/// [freezeBudget] is the number of missed days that may be bridged in the
/// *current* streak (the "freeze"/grace mechanic) — including a missed today.
/// The longest streak is the longest unbroken run, never less than the current.
StreakInfo computeStreak(
  Iterable<DateTime> completedDays, {
  required DateTime today,
  int freezeBudget = 1,
}) {
  final days = completedDays.map(_day).toSet();
  if (days.isEmpty) return const StreakInfo(current: 0, longest: 0);

  // Longest unbroken run anywhere in the history.
  var longest = 0;
  for (final day in days) {
    if (days.contains(day.subtract(const Duration(days: 1)))) continue; // not a run start
    var len = 1;
    var cur = day;
    while (days.contains(cur.add(const Duration(days: 1)))) {
      cur = cur.add(const Duration(days: 1));
      len++;
    }
    if (len > longest) longest = len;
  }

  // Current run: walk back from today, spending freezes to bridge gaps.
  var current = 0;
  var freezes = freezeBudget;
  var cursor = _day(today);
  while (true) {
    if (days.contains(cursor)) {
      current++;
      cursor = cursor.subtract(const Duration(days: 1));
    } else if (freezes > 0) {
      freezes--;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return StreakInfo(current: current, longest: longest > current ? longest : current);
}
