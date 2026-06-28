import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/features/auth/auth_controller.dart';

import '../../helpers/test_db.dart';

void main() {
  test('currentUserProvider signs in anonymously on first read', () async {
    final c = ProviderContainer(overrides: [inMemoryDbOverride]);
    addTearDown(c.dispose);

    final user = await c.read(currentUserProvider.future);
    expect(user.isAnonymous, isTrue);
    expect(user.id, isNotEmpty);

    // The repository now reports the same current user.
    expect(c.read(authRepositoryProvider).currentUser!.id, user.id);
  });
}
