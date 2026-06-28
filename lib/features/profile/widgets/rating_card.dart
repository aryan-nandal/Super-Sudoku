import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/rating.dart';
import '../rating_controller.dart';

/// Tier brand colors (also used by the leaderboard).
Color tierColor(RatingTier tier) => switch (tier) {
      RatingTier.bronze => const Color(0xFFB87333),
      RatingTier.silver => const Color(0xFFB0BEC5),
      RatingTier.gold => const Color(0xFFFFC107),
      RatingTier.platinum => const Color(0xFF22D3EE),
      RatingTier.diamond => const Color(0xFF6C63FF),
      RatingTier.master => const Color(0xFFB36BFF),
    };

/// A small colored tier chip.
class TierBadge extends StatelessWidget {
  final RatingTier tier;
  const TierBadge({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final color = tierColor(tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            tier.label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Shows the player's puzzle rating, tier, confidence, and progress to the next
/// tier. Reactive — updates as new puzzles are solved.
class RatingCard extends ConsumerWidget {
  const RatingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(playerRatingProvider);
    return async.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (r) {
        final tier = tierForRating(r.rating);
        final tiers = RatingTier.values;
        final next = tier.index + 1 < tiers.length ? tiers[tier.index + 1] : null;
        final progress = next == null
            ? 1.0
            : ((r.rating - tier.floor) / (next.floor - tier.floor))
                .clamp(0.0, 1.0);

        return Card(
          key: const ValueKey('rating_card'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${r.displayRating}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Puzzle rating · ±${r.rd.round()}',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                    const Spacer(),
                    TierBadge(tier: tier),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    color: tierColor(tier),
                    backgroundColor: tierColor(tier).withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  next == null
                      ? 'Top tier reached'
                      : '${(next.floor - r.rating).clamp(0, 9999).round()} to ${next.label}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
