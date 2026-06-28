import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../domain/leaderboard.dart';
import '../../shared/widgets/app_background.dart';
import '../auth/auth_controller.dart';
import '../profile/widgets/rating_card.dart';
import 'leaderboard_controller.dart';

/// Global tiered leaderboard. Online (Firestore) shows the ranked board with the
/// player highlighted; offline it shows the player's local rating + how to compete.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(leaderboardPublisherProvider).publishMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final remote = ref.watch(leaderboardRepositoryProvider).isRemote;
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: remote ? _buildBoard(context) : _buildOffline(context),
        ),
      ),
    );
  }

  Widget _buildOffline(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const RatingCard(),
        const SizedBox(height: 24),
        Icon(Icons.emoji_events_outlined,
            size: 48, color: Theme.of(context).colorScheme.outline),
        const SizedBox(height: 12),
        Text(
          'Go online to compete',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Connect to the internet to see the global leaderboard and where you '
          'rank. Your rating climbs as you solve.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBoard(BuildContext context) {
    final async = ref.watch(leaderboardProvider);
    final myId = ref.watch(currentUserProvider).value?.id;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Could not load the leaderboard.\n$e')),
      data: (entries) {
        if (entries.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const RatingCard(),
              const SizedBox(height: 24),
              Text('Be the first on the board — solve a puzzle!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          );
        }
        final ranked = rankEntries(entries);
        return ListView.builder(
          key: const ValueKey('leaderboard_list'),
          padding: const EdgeInsets.all(12),
          itemCount: ranked.length,
          itemBuilder: (context, i) =>
              _RankRow(ranked: ranked[i], isMe: ranked[i].entry.userId == myId),
        );
      },
    );
  }
}

class _RankRow extends StatelessWidget {
  final RankedEntry ranked;
  final bool isMe;

  const _RankRow({required this.ranked, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final e = ranked.entry;
    return Container(
      key: ValueKey('lb_${e.userId}'),
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: isMe ? scheme.primary.withValues(alpha: 0.14) : null,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: scheme.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: ListTile(
        leading: SizedBox(
          width: 34,
          child: Text(
            '#${ranked.rank}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        title: Text(
          isMe ? '${e.displayName} (You)' : e.displayName,
          style: TextStyle(
              fontWeight: isMe ? FontWeight.w700 : FontWeight.w500),
        ),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: TierBadge(tier: e.tier),
        ),
        trailing: Text(
          '${e.rating}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
