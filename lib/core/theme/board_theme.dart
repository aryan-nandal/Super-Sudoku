import 'package:flutter/material.dart';

/// Board-specific colors, exposed as a [ThemeExtension] so widgets read them
/// from the active [ThemeData] (works across light/dark and future themes).
///
/// Highlights are deliberately distinguished by *intensity* as well as hue, and
/// errors are reinforced with bold text — a step toward not encoding state by
/// color alone (full color-blind audit is a later task).
@immutable
class BoardTheme extends ThemeExtension<BoardTheme> {
  final Color cellBackground;
  final Color givenText;
  final Color userText;
  final Color errorText;
  final Color errorCellBackground;
  final Color selectedCellBackground;
  final Color peerCellBackground;
  final Color sameValueBackground;
  final Color noteText;
  final Color thinLine;
  final Color thickLine;

  const BoardTheme({
    required this.cellBackground,
    required this.givenText,
    required this.userText,
    required this.errorText,
    required this.errorCellBackground,
    required this.selectedCellBackground,
    required this.peerCellBackground,
    required this.sameValueBackground,
    required this.noteText,
    required this.thinLine,
    required this.thickLine,
  });

  /// Derive a board palette from a Material [ColorScheme].
  factory BoardTheme.fromScheme(ColorScheme scheme) {
    return BoardTheme(
      cellBackground: scheme.surface,
      givenText: scheme.onSurface,
      userText: scheme.primary,
      errorText: scheme.error,
      errorCellBackground: scheme.error.withValues(alpha: 0.14),
      selectedCellBackground: scheme.primary.withValues(alpha: 0.28),
      peerCellBackground: scheme.primary.withValues(alpha: 0.07),
      sameValueBackground: scheme.primary.withValues(alpha: 0.16),
      noteText: scheme.onSurfaceVariant,
      thinLine: scheme.outlineVariant,
      thickLine: scheme.outline,
    );
  }

  @override
  BoardTheme copyWith({
    Color? cellBackground,
    Color? givenText,
    Color? userText,
    Color? errorText,
    Color? errorCellBackground,
    Color? selectedCellBackground,
    Color? peerCellBackground,
    Color? sameValueBackground,
    Color? noteText,
    Color? thinLine,
    Color? thickLine,
  }) {
    return BoardTheme(
      cellBackground: cellBackground ?? this.cellBackground,
      givenText: givenText ?? this.givenText,
      userText: userText ?? this.userText,
      errorText: errorText ?? this.errorText,
      errorCellBackground: errorCellBackground ?? this.errorCellBackground,
      selectedCellBackground:
          selectedCellBackground ?? this.selectedCellBackground,
      peerCellBackground: peerCellBackground ?? this.peerCellBackground,
      sameValueBackground: sameValueBackground ?? this.sameValueBackground,
      noteText: noteText ?? this.noteText,
      thinLine: thinLine ?? this.thinLine,
      thickLine: thickLine ?? this.thickLine,
    );
  }

  @override
  BoardTheme lerp(ThemeExtension<BoardTheme>? other, double t) {
    if (other is! BoardTheme) return this;
    return BoardTheme(
      cellBackground: Color.lerp(cellBackground, other.cellBackground, t)!,
      givenText: Color.lerp(givenText, other.givenText, t)!,
      userText: Color.lerp(userText, other.userText, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      errorCellBackground:
          Color.lerp(errorCellBackground, other.errorCellBackground, t)!,
      selectedCellBackground:
          Color.lerp(selectedCellBackground, other.selectedCellBackground, t)!,
      peerCellBackground:
          Color.lerp(peerCellBackground, other.peerCellBackground, t)!,
      sameValueBackground:
          Color.lerp(sameValueBackground, other.sameValueBackground, t)!,
      noteText: Color.lerp(noteText, other.noteText, t)!,
      thinLine: Color.lerp(thinLine, other.thinLine, t)!,
      thickLine: Color.lerp(thickLine, other.thickLine, t)!,
    );
  }

  /// Convenience lookup from a [BuildContext].
  static BoardTheme of(BuildContext context) =>
      Theme.of(context).extension<BoardTheme>()!;
}
