import 'package:flutter/material.dart';

/// Frames the board as the screen's hero: a rounded, neon-bordered, softly
/// glowing, slightly-elevated panel so the grid pops off the background.
class BoardHero extends StatelessWidget {
  final Widget child;

  const BoardHero({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? scheme.surfaceContainerLowest : scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: scheme.primary.withValues(alpha: isDark ? 0.38 : 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: isDark ? 0.30 : 0.14),
            blurRadius: 30,
            spreadRadius: -6,
          ),
        ],
      ),
      child: child,
    );
  }
}
