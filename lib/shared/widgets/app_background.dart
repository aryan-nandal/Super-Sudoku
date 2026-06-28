import 'package:flutter/material.dart';

/// A subtle, static brand backdrop: deep base with soft neon glows in the
/// corners. Static (no animation) so it's cheap and reduced-motion safe.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glow = isDark ? 0.22 : 0.10;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(scheme.primary.withValues(alpha: glow), scheme.surface),
            scheme.surface,
            Color.alphaBlend(scheme.tertiary.withValues(alpha: glow), scheme.surface),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
    );
  }
}
