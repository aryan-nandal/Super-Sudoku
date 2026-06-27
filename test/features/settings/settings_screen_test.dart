import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/features/settings/settings_controller.dart';
import 'package:super_sudoku/features/settings/settings_screen.dart';

import '../../helpers/test_db.dart';

void main() {
  testWidgets('renders toggles and flips a setting', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [inMemoryDbOverride],
        child: MaterialApp(theme: AppTheme.light(), home: const SettingsScreen()),
      ),
    );
    await tester.pump(); // initial settings load

    final autoCandidates = find.byKey(const ValueKey('setting_auto_candidates'));
    expect(autoCandidates, findsOneWidget);
    expect(tester.widget<SwitchListTile>(autoCandidates).value, isFalse);

    await tester.tap(autoCandidates);
    await tester.pump();

    expect(tester.widget<SwitchListTile>(autoCandidates).value, isTrue);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(container.read(settingsControllerProvider).autoCandidateNotes, isTrue);
  });
}
