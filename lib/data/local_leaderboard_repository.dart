import '../domain/leaderboard.dart';

/// Offline stub used when Firebase isn't available — no board, no publishing.
class LocalLeaderboardRepository implements LeaderboardRepository {
  @override
  bool get isRemote => false;

  @override
  Stream<List<LeaderboardEntry>> watchTop({int limit = 50}) =>
      Stream.value(const []);
}
