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

/// Publishes the player's standing when the board is opened.
///
/// Free (Spark) model: writes the client-computed rating directly. Blaze model:
/// only sets the profile name — the Cloud Function writes the rating.
final leaderboardPublisherProvider =
    Provider<LeaderboardPublisher>((ref) => LeaderboardPublisher(ref));

class LeaderboardPublisher {
  final Ref _ref;
  LeaderboardPublisher(this._ref);

  Future<void> publishMe() async {
    final sync = _ref.read(syncServiceProvider);
    if (!sync.isRemote) return;
    final user = await _ref.read(currentUserProvider.future);
    final name = user.displayName ?? 'Guest';
    await sync.setProfile(user.id, displayName: name);

    if (!kServerAuthoritativeLeaderboard) {
      final rating =
          _ref.read(playerRatingProvider).value ?? PlayerRating.initial;
      await _ref.read(leaderboardRepositoryProvider).publish(
            LeaderboardEntry(
              userId: user.id,
              displayName: name,
              rating: rating.displayRating,
            ),
          );
    }
  }
}
