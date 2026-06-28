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

/// Reactive stats: derives streak, per-difficulty stats, and quests from the
/// live DB streams, so the screen always reflects the latest solves (updates
/// even while open, and on every reopen).
final statsProvider = Provider.autoDispose<AsyncValue<StatsView>>((ref) {
  final resultsAsync = ref.watch(gameResultsStreamProvider);
  final completionsAsync = ref.watch(dailyCompletionsStreamProvider);

  if (resultsAsync.hasError) {
    return AsyncError(
        resultsAsync.error!, resultsAsync.stackTrace ?? StackTrace.current);
  }
  if (completionsAsync.hasError) {
    return AsyncError(completionsAsync.error!,
        completionsAsync.stackTrace ?? StackTrace.current);
  }
  final results = resultsAsync.value;
  final completions = completionsAsync.value;
  if (results == null || completions == null) return const AsyncLoading();

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

  return AsyncData(StatsView(streak: streak, summary: summary, quests: quests));
});
