import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/game_controller.dart';

import '../../helpers/test_db.dart';

void main() {
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  Future<ProviderContainer> startedGame() async {
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
    await c.read(gameControllerProvider.notifier).newGame(Difficulty.easy);
    return c;
  }

  test('requestHint produces a correct, named hint at tier 1', () async {
    final c = await startedGame();
    final notifier = c.read(gameControllerProvider.notifier);
    notifier.requestHint();

    final s = c.read(gameControllerProvider);
    expect(s.hintTier, 1);
    expect(s.hintStep, isNotNull);
    final solution = parseBoard(solutionStr);
    expect(s.hintStep!.digit, solution[s.hintStep!.cell]);
  });

  test('repeated requests escalate the tier and cap at 3', () async {
    final c = await startedGame();
    final notifier = c.read(gameControllerProvider.notifier);
    notifier
      ..requestHint()
      ..requestHint()
      ..requestHint()
      ..requestHint();
    expect(c.read(gameControllerProvider).hintTier, 3);
  });

  test('a board change dismisses the hint', () async {
    final c = await startedGame();
    final notifier = c.read(gameControllerProvider.notifier);
    notifier.requestHint();
    expect(c.read(gameControllerProvider).hintTier, 1);

    notifier
      ..select(2)
      ..input(4);
    expect(c.read(gameControllerProvider).hintTier, 0);
  });

  test('applyHint fills the suggested cell and clears the hint', () async {
    final c = await startedGame();
    final notifier = c.read(gameControllerProvider.notifier);
    notifier.requestHint();
    final hint = c.read(gameControllerProvider).hintStep!;

    notifier.applyHint();
    final s = c.read(gameControllerProvider);
    expect(s.game!.values[hint.cell], hint.digit);
    expect(s.hintTier, 0);
  });
}
