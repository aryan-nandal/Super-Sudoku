import 'package:flutter/material.dart';

/// Presentational input controls: digits 1–9 plus undo / notes / erase / redo.
///
/// Pure callbacks, no Riverpod — so it's reusable and easy to test. Large touch
/// targets and a clear notes-mode state are deliberate (plan §2.1 input UX).
class NumberPad extends StatelessWidget {
  final void Function(int digit) onDigit;
  final VoidCallback onErase;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onToggleNotes;
  final VoidCallback onHint;
  final bool notesMode;
  final bool canUndo;
  final bool canRedo;

  /// `remaining[d-1]` = how many of digit `d` are still unplaced.
  final List<int> remaining;

  const NumberPad({
    super.key,
    required this.onDigit,
    required this.onErase,
    required this.onUndo,
    required this.onRedo,
    required this.onToggleNotes,
    required this.onHint,
    required this.notesMode,
    required this.canUndo,
    required this.canRedo,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (var d = 1; d <= 9; d++)
                Expanded(
                  child: _DigitButton(
                    digit: d,
                    remaining: remaining[d - 1],
                    onTap: () => onDigit(d),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionButton(
                actionKey: 'action_hint',
                icon: Icons.lightbulb_outline,
                label: 'Hint',
                onPressed: onHint,
              ),
              _ActionButton(
                actionKey: 'action_undo',
                icon: Icons.undo_rounded,
                label: 'Undo',
                onPressed: canUndo ? onUndo : null,
              ),
              _ActionButton(
                actionKey: 'action_notes',
                icon: notesMode
                    ? Icons.edit_note_rounded
                    : Icons.edit_outlined,
                label: 'Notes',
                highlighted: notesMode,
                onPressed: onToggleNotes,
              ),
              _ActionButton(
                actionKey: 'action_erase',
                icon: Icons.backspace_outlined,
                label: 'Erase',
                onPressed: onErase,
              ),
              _ActionButton(
                actionKey: 'action_redo',
                icon: Icons.redo_rounded,
                label: 'Redo',
                onPressed: canRedo ? onRedo : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DigitButton extends StatelessWidget {
  final int digit;
  final int remaining;
  final VoidCallback onTap;

  const _DigitButton({
    required this.digit,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = remaining > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Digit $digit, $remaining remaining',
        child: InkWell(
          key: ValueKey('digit_$digit'),
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: enabled ? 1 : 0.3,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$digit',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$remaining',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String actionKey;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool highlighted;

  const _ActionButton({
    required this.actionKey,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          key: ValueKey(actionKey),
          onPressed: onPressed,
          isSelected: highlighted,
          icon: Icon(icon),
          style: highlighted
              ? IconButton.styleFrom(
                  backgroundColor: scheme.primary,
                  foregroundColor: scheme.onPrimary,
                )
              : null,
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
