import 'package:flutter/material.dart';

import '../../../domain/daily.dart';
import '../../../engine/engine.dart';

/// Spoiler-free result card shown after solving the Daily, with a share action.
///
/// Mirrors the shareable text: headline, stats, and a decorative performance
/// grid whose color tier reflects how clean the solve was — never the board.
class DailyResultCard extends StatelessWidget {
  final DailyResult result;
  final VoidCallback onShare;

  /// Percent faster than the player's average (positive = faster), or null.
  final int? fasterThanAveragePercent;

  /// Whether this solve set a new best for the difficulty.
  final bool isNewBest;

  const DailyResultCard({
    super.key,
    required this.result,
    required this.onShare,
    this.fasterThanAveragePercent,
    this.isNewBest = false,
  });

  String? get _analyticsLine {
    if (isNewBest) return '🏆 New best time!';
    final pct = fasterThanAveragePercent;
    if (pct != null && pct > 0) return '⚡ $pct% faster than your average.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Super Sudoku', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            'Daily #${result.dayNumber}',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            _formatDate(result.date),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Chip(
            label: Text(result.difficulty.label),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(
                icon: Icons.timer_outlined,
                value: formatDuration(result.time),
                label: 'Time',
              ),
              _Stat(
                icon: Icons.close_rounded,
                value: '${result.mistakes}',
                label: 'Mistakes',
              ),
              _Stat(
                icon: Icons.lightbulb_outline,
                value: '${result.hints}',
                label: 'Hints',
              ),
            ],
          ),
          if (_analyticsLine != null) ...[
            const SizedBox(height: 12),
            Text(
              _analyticsLine!,
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ],
          const SizedBox(height: 18),
          _PerformanceGrid(mistakes: result.mistakes),
          const SizedBox(height: 22),
          FilledButton.icon(
            key: const ValueKey('daily_share_button'),
            onPressed: onShare,
            icon: const Icon(Icons.ios_share),
            label: const Text('Share result'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleMedium),
        Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _PerformanceGrid extends StatelessWidget {
  final int mistakes;

  const _PerformanceGrid({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    final color = mistakes == 0
        ? const Color(0xFF4CAF50) // green
        : mistakes <= 2
            ? const Color(0xFFFFC107) // amber
            : const Color(0xFFFF9800); // orange
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row = 0; row < 3; row++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col = 0; col < 3; col++)
                Container(
                  margin: const EdgeInsets.all(3),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
