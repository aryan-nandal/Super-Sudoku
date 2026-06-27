import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/features/game/widgets/number_pad.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: child),
      );

  NumberPad build({
    void Function(int)? onDigit,
    VoidCallback? onErase,
    VoidCallback? onUndo,
    VoidCallback? onRedo,
    VoidCallback? onToggleNotes,
    bool notesMode = false,
    bool canUndo = true,
    bool canRedo = true,
    List<int>? remaining,
  }) {
    return NumberPad(
      onDigit: onDigit ?? (_) {},
      onErase: onErase ?? () {},
      onUndo: onUndo ?? () {},
      onRedo: onRedo ?? () {},
      onToggleNotes: onToggleNotes ?? () {},
      notesMode: notesMode,
      canUndo: canUndo,
      canRedo: canRedo,
      remaining: remaining ?? List<int>.filled(9, 5),
    );
  }

  testWidgets('tapping a digit reports that digit', (tester) async {
    int? tapped;
    await tester.pumpWidget(wrap(build(onDigit: (d) => tapped = d)));
    await tester.tap(find.byKey(const ValueKey('digit_3')));
    expect(tapped, 3);
  });

  testWidgets('a fully-placed digit is disabled', (tester) async {
    var tapped = false;
    final remaining = List<int>.filled(9, 5)..[4] = 0; // digit 5 is done
    await tester.pumpWidget(
      wrap(build(onDigit: (_) => tapped = true, remaining: remaining)),
    );
    await tester.tap(find.byKey(const ValueKey('digit_5')), warnIfMissed: false);
    expect(tapped, isFalse);
  });

  testWidgets('undo is disabled when canUndo is false', (tester) async {
    var undone = false;
    await tester.pumpWidget(
      wrap(build(onUndo: () => undone = true, canUndo: false)),
    );
    await tester.tap(find.byKey(const ValueKey('action_undo')),
        warnIfMissed: false);
    expect(undone, isFalse);
  });

  testWidgets('notes and erase actions fire', (tester) async {
    var notesToggled = false;
    var erased = false;
    await tester.pumpWidget(wrap(build(
      onToggleNotes: () => notesToggled = true,
      onErase: () => erased = true,
    )));
    await tester.tap(find.byKey(const ValueKey('action_notes')));
    await tester.tap(find.byKey(const ValueKey('action_erase')));
    expect(notesToggled, isTrue);
    expect(erased, isTrue);
  });
}
