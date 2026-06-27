import 'package:flutter/material.dart';

import '../../../engine/engine.dart';

/// Teaching hint banner with three escalating tiers (nudge → technique →
/// exact cell). Teaches the technique rather than just revealing the answer.
class HintBanner extends StatelessWidget {
  final HintStep hint;
  final int tier;
  final VoidCallback onMore;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  const HintBanner({
    super.key,
    required this.hint,
    required this.tier,
    required this.onMore,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('hint_banner'),
      width: double.infinity,
      color: scheme.secondaryContainer,
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb, color: scheme.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _message(),
                  style: TextStyle(color: scheme.onSecondaryContainer),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (tier < 3)
                      TextButton(
                        key: const ValueKey('hint_more_button'),
                        onPressed: onMore,
                        child: const Text('Show more'),
                      ),
                    if (tier >= 3)
                      TextButton(
                        key: const ValueKey('hint_apply_button'),
                        onPressed: onApply,
                        child: const Text('Place it'),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            key: const ValueKey('hint_dismiss_button'),
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }

  String _message() {
    switch (tier) {
      case 1:
        return 'There’s a move you can make. Tap “Show more” for the technique.';
      case 2:
        return '${hint.technique.label}: ${hint.technique.tip}';
      default:
        final r = rowOf(hint.cell) + 1;
        final c = colOf(hint.cell) + 1;
        return 'Place ${hint.digit} at row $r, column $c '
            '(${hint.technique.label}).';
    }
  }
}
