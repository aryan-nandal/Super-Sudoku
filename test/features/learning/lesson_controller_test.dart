import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/data/persistence_providers.dart';
import 'package:super_sudoku/domain/learning_path.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/game_controller.dart';
import 'package:super_sudoku/features/learning/lesson_controller.dart';

import '../../helpers/test_db.dart';

void main() {
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  Future<ProviderContainer> started() async {
    final data = PuzzleData(
      puzzle: parseBoard(puzzleStr),
      solution: parseBoard(solutionStr),
      difficultyIndex: Difficulty.easy.index,
      clues: parseBoard(puzzleStr).where((v) => v != 0).length,
    );
    final c = ProviderContainer(overrides: [
      inMemoryDbOverride,
      puzzleGeneratorProvider.overrideWithValue((_) async => data),
    ]);
    addTearDown(c.dispose);
    await c.read(lessonControllerProvider.notifier).start(learningPath.first);
    return c;
  }

  test('start sets a correct first target on step 1', () async {
    final c = await started();
    final s = c.read(lessonControllerProvider);
    expect(s.game, isNotNull);
    expect(s.step, 1);
    expect(s.hintTier, 1);
    expect(s.target, isNotNull);
    final solution = parseBoard(solutionStr);
    expect(s.target!.digit, solution[s.target!.cell]);
  });

  test('a wrong placement nudges and does not advance', () async {
    final c = await started();
    final n = c.read(lessonControllerProvider.notifier);
    final t = c.read(lessonControllerProvider).target!;
    final wrong = t.digit == 1 ? 2 : 1;

    n.select(t.cell);
    n.input(wrong);

    final s = c.read(lessonControllerProvider);
    expect(s.feedback, isNotNull);
    expect(s.game!.values[t.cell], 0, reason: 'wrong digit is not placed');
    expect(s.step, 1);
  });

  test('a correct placement advances to the next step with a fresh target',
      () async {
    final c = await started();
    final n = c.read(lessonControllerProvider.notifier);
    final t = c.read(lessonControllerProvider).target!;

    n.select(t.cell);
    n.input(t.digit);

    final s = c.read(lessonControllerProvider);
    expect(s.game!.values[t.cell], t.digit);
    expect(s.step, 2);
    expect(s.feedback, isNull);
    expect(s.target, isNotNull);
    expect(s.hintTier, 1, reason: 'hint resets each step');
  });

  test('requestHint escalates the tier and clamps at 3', () async {
    final c = await started();
    final n = c.read(lessonControllerProvider.notifier);
    n.requestHint();
    expect(c.read(lessonControllerProvider).hintTier, 2);
    n.requestHint();
    n.requestHint();
    expect(c.read(lessonControllerProvider).hintTier, 3);
  });

  test('completing all steps marks the node done', () async {
    final c = await started();
    final n = c.read(lessonControllerProvider.notifier);

    for (var i = 0; i < kLessonSteps; i++) {
      final t = c.read(lessonControllerProvider).target!;
      n.select(t.cell);
      n.input(t.digit);
    }

    expect(c.read(lessonControllerProvider).completed, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    final done = await c.read(learningRepositoryProvider).completed();
    expect(done, contains(learningPath.first.id));
  });
}
