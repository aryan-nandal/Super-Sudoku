import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/daily.dart';
import '../../domain/stats.dart';
import '../../engine/engine.dart';
import 'stats_controller.dart';

/// Shows streak, daily quests, and per-difficulty solve stats.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(statsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load stats.\n$e')),
        data: (view) => ListView(
          key: const ValueKey('stats_list'),
          padding: const EdgeInsets.all(16),
          children: [
            _StreakCard(view: view),
            const SizedBox(height: 16),
            Text('Daily quests', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final q in view.quests)
              ListTile(
                dense: true,
                leading: Icon(
                  q.done
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: q.done
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                title: Text(q.title),
              ),
            const SizedBox(height: 16),
            Text('Best & average', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Solved: ${view.summary.totalSolved}'),
            const SizedBox(height: 8),
            for (final entry in _orderedStats(view.summary))
              _DifficultyRow(difficultyIndex: entry.key, stats: entry.value),
          ],
        ),
      ),
    );
  }

  List<MapEntry<int, DifficultyStats>> _orderedStats(StatsSummary s) {
    final entries = s.byDifficulty.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }
}

class _StreakCard extends StatelessWidget {
  final StatsView view;
  const _StreakCard({required this.view});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(label: 'Current streak', value: '${view.streak.current}'),
            _Stat(label: 'Best streak', value: '${view.streak.longest}'),
            Icon(Icons.local_fire_department,
                color: scheme.primary, size: 32),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _DifficultyRow extends StatelessWidget {
  final int difficultyIndex;
  final DifficultyStats stats;
  const _DifficultyRow({required this.difficultyIndex, required this.stats});

  @override
  Widget build(BuildContext context) {
    final label = Difficulty.values[difficultyIndex].label;
    return ListTile(
      dense: true,
      title: Text(label),
      subtitle: Text('Played ${stats.played}'),
      trailing: Text(
        'Best ${formatDuration(Duration(seconds: stats.bestSeconds))} · '
        'Avg ${formatDuration(Duration(seconds: stats.averageSeconds))}',
      ),
    );
  }
}
