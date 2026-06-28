import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/domain/auth.dart';
import 'package:super_sudoku/domain/leaderboard.dart';
import 'package:super_sudoku/features/leaderboard/leaderboard_screen.dart';

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

class _FakeBoard implements LeaderboardRepository {
  @override
  bool get isRemote => true;
  @override
  Future<void> publish(LeaderboardEntry entry) async {}
  @override
  Stream<List<LeaderboardEntry>> watchTop({int limit = 50}) => Stream.value(const [
        LeaderboardEntry(userId: 'alice', displayName: 'Alice', rating: 1800),
        LeaderboardEntry(userId: 'me', displayName: 'Me', rating: 1200),
        LeaderboardEntry(userId: 'bob', displayName: 'Bob', rating: 1100),
      ]);
}

void main() {
  testWidgets('shows the ranked board and highlights the current user',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryDbOverride,
          authRepositoryProvider.overrideWithValue(_FakeAuth()),
          leaderboardRepositoryProvider.overrideWithValue(_FakeBoard()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const LeaderboardScreen(),
        ),
      ),
    );

    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byKey(const ValueKey('leaderboard_list')), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    // The current user is highlighted as "(You)".
    expect(find.textContaining('(You)'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
