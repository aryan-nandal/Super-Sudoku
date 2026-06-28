import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../domain/auth.dart';

/// The current player. Signs in anonymously on first access so the app always
/// has a stable identity (deferred registration) — progress is tied to it and a
/// real account can be linked later without losing anything.
final currentUserProvider = FutureProvider<AppUser>((ref) async {
  final auth = ref.watch(authRepositoryProvider);
  return auth.currentUser ?? await auth.signInAnonymously();
});

/// Account actions (display name, …).
final accountControllerProvider =
    Provider<AccountController>((ref) => AccountController(ref));

class AccountController {
  final Ref _ref;
  AccountController(this._ref);

  /// Sets the player's display name (blank clears it) and mirrors it to the
  /// remote profile so it labels their leaderboard entry.
  Future<void> setDisplayName(String name) async {
    final user = await _ref.read(authRepositoryProvider).updateDisplayName(name);
    final sync = _ref.read(syncServiceProvider);
    if (sync.isRemote) {
      await sync.setProfile(
        user.id,
        displayName: user.displayName ?? 'Guest',
      );
    }
    _ref.invalidate(currentUserProvider);
  }
}
