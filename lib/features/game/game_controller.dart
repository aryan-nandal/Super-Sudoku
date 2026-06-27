import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/puzzle_generation_service.dart';
import '../../domain/puzzle_data.dart';
import '../../domain/sudoku_game.dart';
import '../../engine/engine.dart';

/// Produces a puzzle for a difficulty. Injected so tests can supply a
/// deterministic fake instead of running the real generator in an isolate.
typedef PuzzleGenerator = Future<PuzzleData> Function(Difficulty difficulty);

/// Default generator: runs the engine off the UI thread via [compute].
final puzzleGeneratorProvider = Provider<PuzzleGenerator>(
  (ref) => (difficulty) => compute(generatePuzzleData, difficulty.index),
);

/// Immutable snapshot of the play screen's state. The [game] itself is mutated
/// in place; every controller action emits a fresh [GameState] so Riverpod
/// notifies listeners.
@immutable
class GameState {
  final SudokuGame? game;
  final Difficulty difficulty;
  final bool generating;
  final bool solved;

  /// When the current game began (for the play timer); null before first game.
  final DateTime? startedAt;

  /// When the game was solved (freezes the clock); null while unsolved.
  final DateTime? finishedAt;

  /// Whether the clock is running (false once solved or while generating).
  final bool running;

  const GameState({
    this.game,
    this.difficulty = Difficulty.easy,
    this.generating = false,
    this.solved = false,
    this.startedAt,
    this.finishedAt,
    this.running = false,
  });

  const GameState.initial() : this();

  GameState copyWith({
    SudokuGame? game,
    Difficulty? difficulty,
    bool? generating,
    bool? solved,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool? running,
  }) {
    return GameState(
      game: game ?? this.game,
      difficulty: difficulty ?? this.difficulty,
      generating: generating ?? this.generating,
      solved: solved ?? this.solved,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      running: running ?? this.running,
    );
  }
}

/// Owns the active [SudokuGame] and orchestrates generation + play actions.
class GameController extends Notifier<GameState> {
  late final PuzzleGenerator _generate;

  @override
  GameState build() {
    _generate = ref.read(puzzleGeneratorProvider);
    return const GameState.initial();
  }

  Future<void> newGame(Difficulty target) async {
    state = state.copyWith(generating: true, solved: false, running: false);
    final data = await _generate(target);
    state = GameState(
      game: SudokuGame.from(data),
      difficulty: data.difficulty,
      generating: false,
      solved: false,
      startedAt: DateTime.now(),
      running: true,
    );
  }

  void select(int index) => _mutate((g) => g.select(index));

  void input(int digit) => _mutate((g) => g.inputDigit(digit));

  void erase() => _mutate((g) => g.erase());

  void toggleNotesMode() => _mutate((g) => g.toggleNotesMode());

  void undo() => _mutate((g) => g.undo());

  void redo() => _mutate((g) => g.redo());

  /// Applies [action] to the current game, then emits a refreshed state,
  /// flipping to solved (and stopping the clock) when the board is complete.
  void _mutate(void Function(SudokuGame game) action) {
    final game = state.game;
    if (game == null) return;
    action(game);
    final justSolved = game.isSolved;
    state = state.copyWith(
      solved: justSolved,
      running: state.running && !justSolved,
      finishedAt: justSolved ? DateTime.now() : null,
    );
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);
