import 'rating.dart';

/// One player's public leaderboard standing.
class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int rating;

  const LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.rating,
  });

  RatingTier get tier => tierForRating(rating);
}

/// An entry with its 1-based position.
class RankedEntry {
  final int rank;
  final LeaderboardEntry entry;

  const RankedEntry({required this.rank, required this.entry});
}

/// Sorts entries by rating (desc) and assigns 1-based ranks. Stable on ties by
/// userId so ordering is deterministic.
List<RankedEntry> rankEntries(List<LeaderboardEntry> entries) {
  final sorted = [...entries]..sort((a, b) {
      final byRating = b.rating.compareTo(a.rating);
      return byRating != 0 ? byRating : a.userId.compareTo(b.userId);
    });
  return [
    for (var i = 0; i < sorted.length; i++)
      RankedEntry(rank: i + 1, entry: sorted[i]),
  ];
}

/// The 1-based rank of [userId], or null if absent.
int? rankOf(List<LeaderboardEntry> entries, String userId) {
  for (final r in rankEntries(entries)) {
    if (r.entry.userId == userId) return r.rank;
  }
  return null;
}

/// Reads (and, in free/client-trusted mode, writes) the leaderboard. The local
/// implementation is offline ([isRemote] == false).
abstract interface class LeaderboardRepository {
  /// Whether this is a real online board (vs. the offline local stub).
  bool get isRemote;

  /// Publish/refresh the current player's entry. Used in the free (Spark) trust
  /// model; under the Blaze model the server writes entries instead and this is
  /// blocked by rules.
  Future<void> publish(LeaderboardEntry entry);

  /// Live top-[limit] entries, highest rating first.
  Stream<List<LeaderboardEntry>> watchTop({int limit});
}
