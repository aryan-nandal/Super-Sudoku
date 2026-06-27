import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_completion_repository.dart';
import '../../data/persistence_providers.dart';
import '../../domain/quests.dart';
import '../../domain/stats.dart';
import '../../domain/streak.dart';
import '../../engine/engine.dart';

/// Everything the Stats screen needs, aggregated.
class StatsView {
  final StreakInfo streak;
  final StatsSummary summary;
  final List<Quest> quests;

  const StatsView({
    required this.streak,
    required this.summary,
    required this.quests,
  });
}

/// Loads results + daily completions and derives streak, stats, and quests.
final statsProvider = FutureProvider<StatsView>((ref) async {
  final results = await ref.watch(gameResultsRepositoryProvider).all();
  final completions = await ref.watch(dailyCompletionRepositoryProvider).all();
  final today = DateTime.now();
  final todayKey = dailyDateKey(today);

  final streak = computeStreak(
    completions.map((c) => DateTime.parse(c.date)),
    today: today,
  );
  final summary = summarizeSolves(
    results.map((r) => (difficultyIndex: r.difficultyIndex, timeSeconds: r.timeSeconds)),
  );
  final quests = todaysQuests(
    results
        .where((r) => r.date == todayKey)
        .map((r) => (difficultyIndex: r.difficultyIndex, mistakes: r.mistakes)),
    dailyDone: completions.any((c) => c.date == todayKey),
    mediumIndex: Difficulty.medium.index,
  );

  return StatsView(streak: streak, summary: summary, quests: quests);
});
