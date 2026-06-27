import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/daily.dart';
import 'package:super_sudoku/domain/puzzle_data.dart';
import 'package:super_sudoku/engine/engine.dart';
import 'package:super_sudoku/features/game/game_controller.dart';

void main() {
  const solutionStr =
      '534678912672195348198342567859761423426853791713924856961537284287419635345286179';

  /// A near-complete daily: only cell 40 is empty.
  PuzzleData almostSolvedDaily() {
    final solution = parseBoard(solutionStr);
    final puzzle = List<int>.of(solution)..[40] = 0;
    return PuzzleData(
      puzzle: puzzle,
      solution: solution,
      difficultyIndex: Difficulty.medium.index,
      clues: puzzle.where((v) => v != 0).length,
    );
  }

  ProviderContainer containerWith(PuzzleData data) {
    final container = ProviderContainer(
      overrides: [
        dailyGeneratorProvider.overrideWithValue((_) async => data),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('startDaily loads the dated daily session', () async {
    final container = containerWith(almostSolvedDaily());
    final date = DateTime.utc(2026, 1, 11);
    await container.read(dailyGameControllerProvider.notifier).startDaily(date);

    final state = container.read(dailyGameControllerProvider);
    expect(state.isDaily, isTrue);
    expect(state.game, isNotNull);
    expect(state.dayNumber, dailyNumberFor(date)); // 11
    expect(state.difficulty, Difficulty.medium);
    expect(state.running, isTrue);
  });

  test('no dailyResult until solved, then it carries the stats', () async {
    final container = containerWith(almostSolvedDaily());
    final notifier = container.read(dailyGameControllerProvider.notifier);
    final date = DateTime.utc(2026, 1, 11);
    await notifier.startDaily(date);

    expect(notifier.dailyResult, isNull);

    final solution = parseBoard(solutionStr);
    notifier
      ..select(40)
      ..input(solution[40]);

    final result = notifier.dailyResult;
    expect(result, isNotNull);
    expect(result!.dayNumber, 11);
    expect(result.difficulty, Difficulty.medium);
    expect(result.mistakes, 0);
    expect(result.time, greaterThanOrEqualTo(Duration.zero));
  });

  test('daily and free-play controllers are independent', () async {
    final container = containerWith(almostSolvedDaily());
    await container
        .read(dailyGameControllerProvider.notifier)
        .startDaily(DateTime.utc(2026, 1, 11));

    // Free-play controller was never started, so it stays empty.
    final freePlay = container.read(gameControllerProvider);
    expect(freePlay.game, isNull);
    expect(freePlay.isDaily, isFalse);
  });
}
