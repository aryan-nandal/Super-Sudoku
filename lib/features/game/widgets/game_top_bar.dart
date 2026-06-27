import 'package:flutter/material.dart';

import '../../../engine/engine.dart';

/// Presentational status row: difficulty, elapsed time, and mistake count.
class GameTopBar extends StatelessWidget {
  final Difficulty difficulty;
  final Duration elapsed;
  final int mistakes;

  const GameTopBar({
    super.key,
    required this.difficulty,
    required this.elapsed,
    required this.mistakes,
  });

  String get _time {
    final m = elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.titleMedium;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Chip(
            label: Text(difficulty.label),
            visualDensity: VisualDensity.compact,
          ),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 18, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(_time, style: labelStyle),
            ],
          ),
          Row(
            children: [
              Icon(Icons.close_rounded, size: 18, color: scheme.error),
              const SizedBox(width: 4),
              Text('$mistakes', style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}
