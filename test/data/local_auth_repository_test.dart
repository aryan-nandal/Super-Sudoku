import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/data/db/app_database.dart';
import 'package:super_sudoku/data/local_auth_repository.dart';
import 'package:super_sudoku/data/settings_repository.dart';
import 'package:super_sudoku/domain/auth.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    settings = SettingsRepository(db);
  });
  tearDown(() => db.close());

  test('signs in anonymously with a non-empty id', () async {
    final auth = LocalAuthRepository(settings);
    final user = await auth.signInAnonymously();
    expect(user.isAnonymous, isTrue);
    expect(user.id, isNotEmpty);
    expect(auth.currentUser, user);
  });

  test('issues a stable id that persists across instances', () async {
    final first = await LocalAuthRepository(settings).signInAnonymously();
    // A fresh repo over the same store restores the same identity.
    final second = await LocalAuthRepository(settings).signInAnonymously();
    expect(second.id, first.id);
  });

  test('authStateChanges emits on sign-in and sign-out', () async {
    final auth = LocalAuthRepository(settings);
    final seen = <AppUser?>[];
    final sub = auth.authStateChanges().listen(seen.add);

    final user = await auth.signInAnonymously();
    await auth.signOut();
    await Future<void>.delayed(Duration.zero);

    expect(seen, [user, null]);
    await sub.cancel();
  });

  test('updateDisplayName sets and persists the name (blank clears it)',
      () async {
    final auth = LocalAuthRepository(settings);
    final named = await auth.updateDisplayName('  SudokuFan  ');
    expect(named.displayName, 'SudokuFan');

    // Persisted: a fresh repo over the same store restores the name.
    final restored = await LocalAuthRepository(settings).signInAnonymously();
    expect(restored.displayName, 'SudokuFan');

    final cleared = await auth.updateDisplayName('   ');
    expect(cleared.displayName, isNull);
  });

  test('signOut clears currentUser but keeps the local id', () async {
    final auth = LocalAuthRepository(settings);
    final user = await auth.signInAnonymously();
    await auth.signOut();
    expect(auth.currentUser, isNull);

    final again = await auth.signInAnonymously();
    expect(again.id, user.id, reason: 'progress is not orphaned');
  });
}
