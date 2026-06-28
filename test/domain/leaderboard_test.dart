import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/leaderboard.dart';
import 'package:super_sudoku/domain/rating.dart';

LeaderboardEntry e(String id, int rating) =>
    LeaderboardEntry(userId: id, displayName: id, rating: rating);

void main() {
  test('rankEntries orders by rating desc with 1-based ranks', () {
    final ranked = rankEntries([e('c', 1100), e('a', 1800), e('b', 1500)]);
    expect(ranked.map((r) => r.entry.userId).toList(), ['a', 'b', 'c']);
    expect(ranked.map((r) => r.rank).toList(), [1, 2, 3]);
  });

  test('ties break deterministically by userId', () {
    final ranked = rankEntries([e('y', 1500), e('x', 1500)]);
    expect(ranked.map((r) => r.entry.userId).toList(), ['x', 'y']);
    expect(ranked.map((r) => r.rank).toList(), [1, 2]);
  });

  test('rankOf finds a user, null when absent', () {
    final entries = [e('a', 1800), e('b', 1500), e('c', 1100)];
    expect(rankOf(entries, 'b'), 2);
    expect(rankOf(entries, 'zzz'), isNull);
  });

  test('entry exposes its tier', () {
    expect(e('a', 2100).tier, RatingTier.master);
    expect(e('b', 900).tier, RatingTier.bronze);
  });
}
