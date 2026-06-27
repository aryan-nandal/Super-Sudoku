import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/game_controller.dart';

void main() {
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';
  const puzzleStr =
      '530070000600195000098000060800060003400803001700020006060000280000419005000080079';

  PuzzleData puzzleFrom(String puzzle, String solution, Difficulty d) =>
      PuzzleData(
        puzzle: parseBoard(puzzle),
        solution: parseBoard(solution),
        difficultyIndex: d.index,
        clues: parseBoard(puzzle).where((v) => v != 0).length,
      );

  /// A container whose generator always returns [data].
  ProviderContainer containerWith(PuzzleData data) {
    final container = ProviderContainer(
      overrides: [
        puzzleGeneratorProvider.overrideWithValue((_) async => data),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('starts with no game and not generating', () {
    final container = containerWith(
      puzzleFrom(puzzleStr, solutionStr, Difficulty.easy),
    );
    final state = container.read(gameControllerProvider);
    expect(state.game, isNull);
    expect(state.generating, isFalse);
    expect(state.solved, isFalse);
  });

  test('newGame loads a playable game', () async {
    final container = containerWith(
      puzzleFrom(puzzleStr, solutionStr, Difficulty.medium),
    );
    await container
        .read(gameControllerProvider.notifier)
        .newGame(Difficulty.medium);

    final state = container.read(gameControllerProvider);
    expect(state.game, isNotNull);
    expect(state.generating, isFalse);
    expect(state.difficulty, Difficulty.medium);
    expect(state.solved, isFalse);
    expect(state.running, isTrue);
  });

  test('input places a value and notifies a new state', () async {
    final container = containerWith(
      puzzleFrom(puzzleStr, solutionStr, Difficulty.easy),
    );
    final notifier = container.read(gameControllerProvider.notifier);
    await notifier.newGame(Difficulty.easy);

    final before = container.read(gameControllerProvider);
    notifier
      ..select(2)
      ..input(4); // solution[2] == 4
    final after = container.read(gameControllerProvider);

    expect(after.game!.values[2], 4);
    expect(identical(before, after), isFalse, reason: 'state must change');
  });

  test('completing the puzzle marks solved and stops the clock', () async {
    final solution = parseBoard(solutionStr);
    final nearlyDone = List<int>.of(solution)..[40] = 0;
    final data = PuzzleData(
      puzzle: nearlyDone,
      solution: solution,
      difficultyIndex: Difficulty.easy.index,
      clues: nearlyDone.where((v) => v != 0).length,
    );
    final container = containerWith(data);
    final notifier = container.read(gameControllerProvider.notifier);
    await notifier.newGame(Difficulty.easy);

    notifier
      ..select(40)
      ..input(solution[40]);

    final state = container.read(gameControllerProvider);
    expect(state.solved, isTrue);
    expect(state.running, isFalse);
  });

  test('undo/redo through the controller', () async {
    final container = containerWith(
      puzzleFrom(puzzleStr, solutionStr, Difficulty.easy),
    );
    final notifier = container.read(gameControllerProvider.notifier);
    await notifier.newGame(Difficulty.easy);

    notifier
      ..select(2)
      ..input(4);
    notifier.undo();
    expect(container.read(gameControllerProvider).game!.values[2], 0);

    notifier.redo();
    expect(container.read(gameControllerProvider).game!.values[2], 4);
  });
}
