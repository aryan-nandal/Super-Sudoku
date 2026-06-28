import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'board_theme.dart';

/// App-wide Material 3 themes (light + dark) with the board palette,
/// neon-accented colors, and geometric typography.
abstract final class AppTheme {
  // Brand accents — electric indigo with cyan/purple neon.
  static const Color _primary = Color(0xFF6C63FF);
  static const Color _cyan = Color(0xFF22D3EE);
  static const Color _purple = Color(0xFFB36BFF);

  /// Deep, slightly-blue near-black for the dark "cognitive gym" surface.
  static const Color _darkSurface = Color(0xFF0E1116);

  static ThemeData light({bool reducedMotion = false}) =>
      _build(Brightness.light, reducedMotion);
  static ThemeData dark({bool reducedMotion = false}) =>
      _build(Brightness.dark, reducedMotion);

  static ThemeData _build(Brightness brightness, bool reducedMotion) {
    final isDark = brightness == Brightness.dark;
    var scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: brightness,
    ).copyWith(
      secondary: _cyan,
      tertiary: _purple,
    );
    if (isDark) {
      scheme = scheme.copyWith(
        surface: _darkSurface,
        surfaceContainerLowest: const Color(0xFF0B0E12),
        surfaceContainerLow: const Color(0xFF141922),
        surfaceContainer: const Color(0xFF181E29),
        surfaceContainerHigh: const Color(0xFF1E2533),
        surfaceContainerHighest: const Color(0xFF242C3D),
      );
    }

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scheme.surface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[BoardTheme.fromScheme(scheme)],
      pageTransitionsTheme: reducedMotion
          ? const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _NoTransitionsBuilder(),
                TargetPlatform.iOS: _NoTransitionsBuilder(),
                TargetPlatform.macOS: _NoTransitionsBuilder(),
              },
            )
          : null,
    );
  }
}

/// Page route transition that does nothing — used when "reduce motion" is on.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}
