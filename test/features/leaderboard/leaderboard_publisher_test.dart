import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/domain/auth.dart';
import 'package:super_sudoku/domain/leaderboard.dart';
import 'package:super_sudoku/features/leaderboard/leaderboard_controller.dart';

import '../../helpers/test_db.dart';

class _FakeAuth implements AuthRepository {
  static const _me = AppUser(id: 'me', isAnonymous: true, displayName: 'Me');
  @override
  AppUser? get currentUser => _me;
  @override
  Stream<AppUser?> authStateChanges() => Stream.value(_me);
  @override
  Future<AppUser> signInAnonymously() async => _me;
  @override
  Future<AppUser> updateDisplayName(String name) async => _me;
  @override
  Future<void> signOut() async {}
}

class _FakeSync implements SyncService {
  final profiles = <String, String>{};
  @override
  bool get isRemote => true;
  @override
  Future<void> setProfile(String userId, {required String displayName}) async {
    profiles[userId] = displayName;
  }
  @override
  Future<void> recordSolve(String userId,
      {required int difficultyIndex,
      required int timeSeconds,
      required int mistakes}) async {}
}

class _CapturingBoard implements LeaderboardRepository {
  final published = <LeaderboardEntry>[];
  @override
  bool get isRemote => true;
  @override
  Future<void> publish(LeaderboardEntry entry) async => published.add(entry);
  @override
  Stream<List<LeaderboardEntry>> watchTop({int limit = 50}) =>
      Stream.value(const []);
}

void main() {
  test('free mode publishes the client rating + profile name', () async {
    final sync = _FakeSync();
    final board = _CapturingBoard();
    final c = ProviderContainer(overrides: [
      inMemoryDbOverride,
      authRepositoryProvider.overrideWithValue(_FakeAuth()),
      syncServiceProvider.overrideWithValue(sync),
      leaderboardRepositoryProvider.overrideWithValue(board),
    ]);
    addTearDown(c.dispose);

    await c.read(leaderboardPublisherProvider).publishMe();

    // Profile name was set, and the board got a client-computed entry.
    expect(sync.profiles['me'], 'Me');
    expect(board.published, hasLength(1));
    expect(board.published.single.userId, 'me');
    expect(board.published.single.displayName, 'Me');
    expect(board.published.single.rating, greaterThan(0));
  });
}
