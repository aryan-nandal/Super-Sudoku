import 'package:flutter/material.dart';

import 'board_theme.dart';

/// App-wide Material 3 themes (light + dark) with the board palette attached.
abstract final class AppTheme {
  /// Electric indigo seed — the "tech-forward, intelligent" brand direction.
  static const Color _seed = Color(0xFF5B5BD6);

  static ThemeData light({bool reducedMotion = false}) =>
      _build(Brightness.light, reducedMotion);
  static ThemeData dark({bool reducedMotion = false}) =>
      _build(Brightness.dark, reducedMotion);

  static ThemeData _build(Brightness brightness, bool reducedMotion) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );
    return base.copyWith(
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
