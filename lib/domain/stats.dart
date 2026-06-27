/// A minimal solve sample for aggregation (decoupled from storage types).
typedef SolveSample = ({int difficultyIndex, int timeSeconds});

/// Aggregated stats for one difficulty.
class DifficultyStats {
  final int played;
  final int bestSeconds;
  final int averageSeconds;

  const DifficultyStats({
    required this.played,
    required this.bestSeconds,
    required this.averageSeconds,
  });
}

/// Overall stats summary.
class StatsSummary {
  final int totalSolved;
  final Map<int, DifficultyStats> byDifficulty;

  const StatsSummary({required this.totalSolved, required this.byDifficulty});
}

StatsSummary summarizeSolves(Iterable<SolveSample> samples) {
  final grouped = <int, List<int>>{};
  for (final s in samples) {
    grouped.putIfAbsent(s.difficultyIndex, () => []).add(s.timeSeconds);
  }
  final byDifficulty = <int, DifficultyStats>{};
  var total = 0;
  grouped.forEach((difficulty, times) {
    total += times.length;
    final sum = times.fold<int>(0, (a, b) => a + b);
    byDifficulty[difficulty] = DifficultyStats(
      played: times.length,
      bestSeconds: times.reduce((a, b) => a < b ? a : b),
      averageSeconds: (sum / times.length).round(),
    );
  });
  return StatsSummary(totalSolved: total, byDifficulty: byDifficulty);
}

/// Percent faster than [averageSeconds] (positive = faster). Null if no
/// baseline. Used for the "X% faster than your average" post-game line.
int? percentFaster(int timeSeconds, int averageSeconds) {
  if (averageSeconds <= 0) return null;
  return (((averageSeconds - timeSeconds) / averageSeconds) * 100).round();
}
