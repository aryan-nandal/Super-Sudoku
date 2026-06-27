import 'package:flutter/material.dart';

import 'board_theme.dart';

/// App-wide Material 3 themes (light + dark) with the board palette attached.
abstract final class AppTheme {
  /// Electric indigo seed — the "tech-forward, intelligent" brand direction.
  static const Color _seed = Color(0xFF5B5BD6);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
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
    );
  }
}
