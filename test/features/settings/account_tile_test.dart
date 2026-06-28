import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/core/theme/app_theme.dart';
import 'package:super_sudoku/features/auth/auth_controller.dart';
import 'package:super_sudoku/features/settings/settings_screen.dart';

import '../../helpers/test_db.dart';

void main() {
  testWidgets('account tile edits and persists the display name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [inMemoryDbOverride],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SettingsScreen(),
        ),
      ),
    );

    Future<void> settle() async {
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await settle();
    expect(find.text('Playing as Guest'), findsOneWidget);

    // Open the editor, type a name, save.
    await tester.tap(find.byKey(const ValueKey('account_tile')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('name_field')), 'Aryan');
    await tester.tap(find.byKey(const ValueKey('name_save')));
    await settle();

    // The tile now shows the chosen name.
    expect(find.text('Aryan'), findsOneWidget);
    expect(find.text('Playing as Guest'), findsNothing);

    final container =
        ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
    final user = await container.read(currentUserProvider.future);
    expect(user.displayName, 'Aryan');
  });
}
