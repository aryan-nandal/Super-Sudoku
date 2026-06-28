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
