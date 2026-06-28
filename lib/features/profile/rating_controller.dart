import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../domain/rating.dart';

/// The player's puzzle rating, replayed reactively from the live solve history —
/// it updates the moment a new result is recorded.
final playerRatingProvider =
    Provider.autoDispose<AsyncValue<PlayerRating>>((ref) {
  final resultsAsync = ref.watch(gameResultsStreamProvider);
  if (resultsAsync.hasError) {
    return AsyncError(
        resultsAsync.error!, resultsAsync.stackTrace ?? StackTrace.current);
  }
  final results = resultsAsync.value;
  if (results == null) return const AsyncLoading();

  return AsyncData(
    computeRating(results.map((r) => (
          difficultyIndex: r.difficultyIndex,
          timeSeconds: r.timeSeconds,
          mistakes: r.mistakes,
        ))),
  );
});
