import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../domain/leaderboard.dart';
import '../auth/auth_controller.dart';

/// Live top entries of the leaderboard (empty when offline/local).
final leaderboardProvider =
    StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).watchTop(limit: 50);
});

/// Ensures the player's display name is on their profile so the server-computed
/// leaderboard entry is labeled correctly. The rating itself is computed
/// server-side from reported solves — never written by the client.
final leaderboardPublisherProvider =
    Provider<LeaderboardPublisher>((ref) => LeaderboardPublisher(ref));

class LeaderboardPublisher {
  final Ref _ref;
  LeaderboardPublisher(this._ref);

  Future<void> publishMe() async {
    final sync = _ref.read(syncServiceProvider);
    if (!sync.isRemote) return;
    final user = await _ref.read(currentUserProvider.future);
    await sync.setProfile(user.id, displayName: user.displayName ?? 'Guest');
  }
}
