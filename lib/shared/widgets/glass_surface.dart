import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted-glass surface: a translucent, blurred, subtly-bordered container.
/// The glassmorphism building block used for the number pad, banners, etc.
class GlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final BorderRadius borderRadius;

  const GlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.blur = 14,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: isDark ? 0.55 : 0.7),
            borderRadius: borderRadius,
            border: Border.all(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.10 : 0.06),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
