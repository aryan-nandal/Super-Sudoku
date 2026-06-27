import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/features/settings/settings_controller.dart';

import '../../helpers/test_db.dart';

void main() {
  ProviderContainer makeContainer() {
    final c = ProviderContainer(overrides: [inMemoryDbOverride]);
    addTearDown(c.dispose);
    return c;
  }

  test('exposes sensible defaults', () async {
    final c = makeContainer();
    final notifier = c.read(settingsControllerProvider.notifier);
    await notifier.reload();
    final s = c.read(settingsControllerProvider);
    expect(s.autoCandidateNotes, isFalse);
    expect(s.highlightDuplicates, isTrue);
    expect(s.highlightPeers, isTrue);
    expect(s.colorBlindMode, isFalse);
    expect(s.reducedMotion, isFalse);
    expect(s.textScale, 1.0);
  });

  test('persists accessibility settings across a reload', () async {
    final c = makeContainer();
    final notifier = c.read(settingsControllerProvider.notifier);
    await notifier.reload();

    await notifier.setColorBlindMode(true);
    await notifier.setReducedMotion(true);
    await notifier.setTextScale(1.4);

    await notifier.reload();
    final s = c.read(settingsControllerProvider);
    expect(s.colorBlindMode, isTrue);
    expect(s.reducedMotion, isTrue);
    expect(s.textScale, 1.4);
  });

  test('updates state and persists across a reload', () async {
    final c = makeContainer();
    final notifier = c.read(settingsControllerProvider.notifier);
    await notifier.reload();

    await notifier.setAutoCandidateNotes(true);
    await notifier.setHighlightPeers(false);
    expect(c.read(settingsControllerProvider).autoCandidateNotes, isTrue);
    expect(c.read(settingsControllerProvider).highlightPeers, isFalse);

    await notifier.reload(); // re-read from the same DB
    final s = c.read(settingsControllerProvider);
    expect(s.autoCandidateNotes, isTrue);
    expect(s.highlightPeers, isFalse);
  });
}
