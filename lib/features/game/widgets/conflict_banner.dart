import 'package:flutter/material.dart';

/// Shown when the board has wrong entries: offers a one-tap rewind to a valid
/// state (the solvable-state guardrail, instead of a punitive game-over).
class ConflictBanner extends StatelessWidget {
  final VoidCallback onRewind;

  const ConflictBanner({super.key, required this.onRewind});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const ValueKey('conflict_banner'),
      width: double.infinity,
      color: scheme.errorContainer,
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'There’s a conflict on the board.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
          TextButton(
            key: const ValueKey('rewind_button'),
            onPressed: onRewind,
            child: const Text('Clear mistakes'),
          ),
        ],
      ),
    );
  }
}
