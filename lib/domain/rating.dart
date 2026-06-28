import 'dart:math';

import '../engine/engine.dart';

/// A simplified Glicko (Glicko-1) puzzle-skill rating. Each solved puzzle is a
/// "game" against an opponent whose strength is the puzzle's difficulty; the
/// player's [score] in [0,1] reflects how well they solved it (speed +
/// accuracy). Pure Dart, fully deterministic — the rating is *replayed* from the
/// solve history rather than stored, so it can never desync.

const double kDefaultRating = 1200;
const double kDefaultRd = 350;
const double _minRd = 30;
const double _periodC = 24; // RD inflation per game (models uncertainty)
final double _q = ln10 / 400;

/// A player's rating and its deviation (uncertainty, ±RD).
class PlayerRating {
  final double rating;
  final double rd;

  const PlayerRating({required this.rating, required this.rd});

  static const initial = PlayerRating(rating: kDefaultRating, rd: kDefaultRd);

  int get displayRating => rating.round();
}

/// Skill tiers (leagues) by rating band.
enum RatingTier { bronze, silver, gold, platinum, diamond, master }

extension RatingTierInfo on RatingTier {
  String get label => switch (this) {
        RatingTier.bronze => 'Bronze',
        RatingTier.silver => 'Silver',
        RatingTier.gold => 'Gold',
        RatingTier.platinum => 'Platinum',
        RatingTier.diamond => 'Diamond',
        RatingTier.master => 'Master',
      };

  /// Inclusive lower bound of the tier.
  int get floor => switch (this) {
        RatingTier.bronze => 0,
        RatingTier.silver => 1000,
        RatingTier.gold => 1250,
        RatingTier.platinum => 1500,
        RatingTier.diamond => 1750,
        RatingTier.master => 2000,
      };
}

RatingTier tierForRating(num rating) {
  if (rating >= 2000) return RatingTier.master;
  if (rating >= 1750) return RatingTier.diamond;
  if (rating >= 1500) return RatingTier.platinum;
  if (rating >= 1250) return RatingTier.gold;
  if (rating >= 1000) return RatingTier.silver;
  return RatingTier.bronze;
}

/// The "opponent" rating a puzzle of [d] represents.
double opponentRatingFor(Difficulty d) => switch (d) {
      Difficulty.beginner => 800,
      Difficulty.easy => 1000,
      Difficulty.medium => 1300,
      Difficulty.hard => 1600,
      Difficulty.expert => 1900,
      Difficulty.master => 2200,
    };

/// Expected ("par") solve time in seconds for [d] — a clean solve at par scores
/// 0.5 (meets expectation); faster scores higher, slower lower.
int parSecondsFor(Difficulty d) => switch (d) {
      Difficulty.beginner => 150,
      Difficulty.easy => 300,
      Difficulty.medium => 540,
      Difficulty.hard => 900,
      Difficulty.expert => 1500,
      Difficulty.master => 2100,
    };

/// Performance score in [0.05, 0.95]: 0.5 at par with no mistakes, higher when
/// faster, lower when slower or with mistakes.
double performanceScore({
  required Difficulty difficulty,
  required int timeSeconds,
  required int mistakes,
}) {
  final par = parSecondsFor(difficulty).toDouble();
  final time = max(timeSeconds, 1).toDouble();
  final speed = par / (par + time); // 0.5 at par, →1 fast, →0 slow
  final score = speed - 0.06 * mistakes;
  return score.clamp(0.05, 0.95);
}

double _g(double rd) => 1 / sqrt(1 + 3 * _q * _q * rd * rd / (pi * pi));

/// Applies one Glicko game: the player ([current]) vs a puzzle opponent.
PlayerRating updateRating(
  PlayerRating current, {
  required double opponentRating,
  required double opponentRd,
  required double score,
}) {
  // Inflate RD a touch to model uncertainty accrued since the last game.
  final rd = min(sqrt(current.rd * current.rd + _periodC * _periodC), kDefaultRd);

  final gOpp = _g(opponentRd);
  final expected =
      1 / (1 + pow(10, -gOpp * (current.rating - opponentRating) / 400));
  final dInv = _q * _q * gOpp * gOpp * expected * (1 - expected);
  final denom = 1 / (rd * rd) + dInv;

  final newRating = current.rating + (_q / denom) * gOpp * (score - expected);
  final newRd = sqrt(1 / denom).clamp(_minRd, kDefaultRd);
  return PlayerRating(rating: newRating, rd: newRd.toDouble());
}

/// Replays the full solve history into a [PlayerRating]. [results] must be in
/// chronological order.
PlayerRating computeRating(
  Iterable<({int difficultyIndex, int timeSeconds, int mistakes})> results,
) {
  var rating = PlayerRating.initial;
  for (final r in results) {
    if (r.difficultyIndex < 0 || r.difficultyIndex >= Difficulty.values.length) {
      continue;
    }
    final difficulty = Difficulty.values[r.difficultyIndex];
    rating = updateRating(
      rating,
      opponentRating: opponentRatingFor(difficulty),
      opponentRd: 50,
      score: performanceScore(
        difficulty: difficulty,
        timeSeconds: r.timeSeconds,
        mistakes: r.mistakes,
      ),
    );
  }
  return rating;
}
