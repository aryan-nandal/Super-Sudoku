import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../domain/leaderboard.dart';
import '../../domain/rating.dart';
import '../auth/auth_controller.dart';
import '../profile/rating_controller.dart';

/// Live top entries of the leaderboard (empty when offline/local).
final leaderboardProvider =
    StreamProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  return ref.watch(leaderboardRepositoryProvider).watchTop(limit: 50);
});

/// Publishes the current player's standing to the leaderboard. Called when the
/// board is opened so the player's entry is fresh.
final leaderboardPublisherProvider =
    Provider<LeaderboardPublisher>((ref) => LeaderboardPublisher(ref));

class LeaderboardPublisher {
  final Ref _ref;
  LeaderboardPublisher(this._ref);

  Future<void> publishMe() async {
    final repo = _ref.read(leaderboardRepositoryProvider);
    if (!repo.isRemote) return; // nothing to publish offline
    final user = await _ref.read(currentUserProvider.future);
    final rating =
        _ref.read(playerRatingProvider).value ?? PlayerRating.initial;
    await repo.publish(LeaderboardEntry(
      userId: user.id,
      displayName: user.displayName ?? 'Guest',
      rating: rating.displayRating,
    ));
  }
}
