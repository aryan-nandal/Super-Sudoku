import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/rating.dart';
import 'package:super_sudoku/engine/engine.dart';

void main() {
  group('tiers', () {
    test('map rating bands to tiers', () {
      expect(tierForRating(800), RatingTier.bronze);
      expect(tierForRating(1100), RatingTier.silver);
      expect(tierForRating(1300), RatingTier.gold);
      expect(tierForRating(1600), RatingTier.platinum);
      expect(tierForRating(1800), RatingTier.diamond);
      expect(tierForRating(2100), RatingTier.master);
    });
  });

  group('performanceScore', () {
    test('clean solve at par scores ~0.5', () {
      final s = performanceScore(
        difficulty: Difficulty.medium,
        timeSeconds: parSecondsFor(Difficulty.medium),
        mistakes: 0,
      );
      expect(s, closeTo(0.5, 0.02));
    });

    test('faster scores higher, slower + mistakes scores lower', () {
      final fast = performanceScore(
          difficulty: Difficulty.medium, timeSeconds: 120, mistakes: 0);
      final slow = performanceScore(
          difficulty: Difficulty.medium, timeSeconds: 2000, mistakes: 3);
      expect(fast, greaterThan(0.5));
      expect(slow, lessThan(0.5));
      expect(slow, greaterThanOrEqualTo(0.05));
      expect(fast, lessThanOrEqualTo(0.95));
    });
  });

  group('updateRating', () {
    test('a strong win against a tough puzzle raises the rating', () {
      const start = PlayerRating(rating: 1200, rd: 200);
      final after = updateRating(start,
          opponentRating: 1600, opponentRd: 50, score: 0.9);
      expect(after.rating, greaterThan(start.rating));
      expect(after.rd, lessThan(start.rd), reason: 'uncertainty shrinks');
    });

    test('a poor result against an easy puzzle lowers the rating', () {
      const start = PlayerRating(rating: 1200, rd: 200);
      final after = updateRating(start,
          opponentRating: 900, opponentRd: 50, score: 0.1);
      expect(after.rating, lessThan(start.rating));
    });
  });

  group('computeRating (replay)', () {
    test('starts at the default and is deterministic', () {
      expect(computeRating(const []).rating, kDefaultRating);

      final results = [
        (difficultyIndex: Difficulty.medium.index, timeSeconds: 300, mistakes: 0),
        (difficultyIndex: Difficulty.hard.index, timeSeconds: 600, mistakes: 0),
        (difficultyIndex: Difficulty.expert.index, timeSeconds: 900, mistakes: 0),
      ];
      final a = computeRating(results);
      final b = computeRating(results);
      expect(a.rating, b.rating);
      expect(a.rd, b.rd);
    });

    test('consistently strong solves climb above the default', () {
      final results = List.generate(
        20,
        (_) => (
          difficultyIndex: Difficulty.hard.index,
          timeSeconds: 300, // well under par → strong
          mistakes: 0,
        ),
      );
      final r = computeRating(results);
      expect(r.rating, greaterThan(kDefaultRating));
      expect(r.rd, lessThan(kDefaultRd), reason: 'more games → more certainty');
    });

    test('ignores out-of-range difficulty indices', () {
      final r = computeRating([
        (difficultyIndex: 99, timeSeconds: 100, mistakes: 0),
      ]);
      expect(r.rating, kDefaultRating);
    });
  });
}
