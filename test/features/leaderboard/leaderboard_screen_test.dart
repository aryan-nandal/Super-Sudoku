import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/domain/leaderboard.dart';
import 'package:super_sudoku/features/leaderboard/leaderboard_screen.dart';

import '../../helpers/test_db.dart';

/// In-memory remote leaderboard for tests.
class _FakeLeaderboard implements LeaderboardRepository {
  final List<LeaderboardEntry> _seed;
  final List<LeaderboardEntry> _added = [];
  final _bump = StreamController<void>.broadcast();

  _FakeLeaderboard(this._seed);

  List<LeaderboardEntry> get _all => [..._seed, ..._added];

  @override
  bool get isRemote => true;

  @override
  Future<void> publish(LeaderboardEntry entry) async {
    _added
      ..removeWhere((e) => e.userId == entry.userId)
      ..add(entry);
    _bump.add(null);
  }

  @override
  Stream<List<LeaderboardEntry>> watchTop({int limit = 50}) async* {
    yield _all;
    await for (final _ in _bump.stream) {
      yield _all;
    }
  }
}

void main() {
  testWidgets('shows the ranked board and highlights the current user',
      (tester) async {
    final fake = _FakeLeaderboard([
      const LeaderboardEntry(userId: 'alice', displayName: 'Alice', rating: 1800),
      const LeaderboardEntry(userId: 'bob', displayName: 'Bob', rating: 1100),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inMemoryDbOverride,
          leaderboardRepositoryProvider.overrideWithValue(fake),
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
    // publishMe added the current (anonymous) player, highlighted as "(You)".
    expect(find.textContaining('(You)'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1)); // drain pending timers
  });
}
