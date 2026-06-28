import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/data/game_results_repository.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/domain/rating.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/profile/rating_controller.dart';

import '../../helpers/test_db.dart';

void main() {
  test('rating starts at default and rises reactively with strong solves',
      () async {
    final c = ProviderContainer(overrides: [inMemoryDbOverride]);
    addTearDown(c.dispose);
    final sub = c.listen(playerRatingProvider, (_, _) {});
    addTearDown(sub.close);

    // Wait for the first (empty) stream emission.
    await c.read(gameResultsStreamProvider.future);
    expect(c.read(playerRatingProvider).value!.rating, kDefaultRating);

    final repo = c.read(gameResultsRepositoryProvider);
    for (var i = 0; i < 6; i++) {
      await repo.record(GameResultRecord(
        difficultyIndex: Difficulty.hard.index,
        timeSeconds: 200, // well under par → strong
        mistakes: 0,
        date: '2026-06-28',
      ));
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final r = c.read(playerRatingProvider).value!;
    expect(r.rating, greaterThan(kDefaultRating));
    expect(r.rd, lessThan(kDefaultRd));
  });
}
