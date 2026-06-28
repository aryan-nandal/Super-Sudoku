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
        boxShadow: isDark
            // Neon glow against the dark backdrop.
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.30),
                  blurRadius: 30,
                  spreadRadius: -6,
                ),
              ]
            // Soft elevation so the white card lifts off the light backdrop.
            : [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.10),
                  blurRadius: 24,
                  spreadRadius: -8,
                ),
              ],
      ),
      child: child,
    );
  }
}
