import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_puzzle_service.dart';
import '../../data/puzzle_generation_service.dart';
import '../../domain/daily.dart';
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

/// Produces the deterministic daily puzzle for a date. Injected for tests.
typedef DailyGenerator = Future<PuzzleData> Function(DateTime date);

/// Default daily generator: deterministic, off-thread.
final dailyGeneratorProvider = Provider<DailyGenerator>(
  (ref) => (date) => compute(
        generateDailyPuzzleData,
        DailyRequest(
          seed: dailySeedFor(date),
          difficultyIndex: dailyDifficultyFor(date).index,
        ),
      ),
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

  /// Whether this session is the global Daily puzzle (vs. free play).
  final bool isDaily;

  /// Calendar date of the daily session; null for free play.
  final DateTime? dailyDate;

  /// 1-based daily number; 0 for free play.
  final int dayNumber;

  const GameState({
    this.game,
    this.difficulty = Difficulty.easy,
    this.generating = false,
    this.solved = false,
    this.startedAt,
    this.finishedAt,
    this.running = false,
    this.isDaily = false,
    this.dailyDate,
    this.dayNumber = 0,
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
    bool? isDaily,
    DateTime? dailyDate,
    int? dayNumber,
  }) {
    return GameState(
      game: game ?? this.game,
      difficulty: difficulty ?? this.difficulty,
      generating: generating ?? this.generating,
      solved: solved ?? this.solved,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      running: running ?? this.running,
      isDaily: isDaily ?? this.isDaily,
      dailyDate: dailyDate ?? this.dailyDate,
      dayNumber: dayNumber ?? this.dayNumber,
    );
  }
}

/// Owns the active [SudokuGame] and orchestrates generation + play actions.
class GameController extends Notifier<GameState> {
  late final PuzzleGenerator _generate;
  late final DailyGenerator _generateDaily;

  @override
  GameState build() {
    _generate = ref.read(puzzleGeneratorProvider);
    _generateDaily = ref.read(dailyGeneratorProvider);
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

  /// Load and start the global Daily puzzle for [date] (deterministic).
  Future<void> startDaily(DateTime date) async {
    state = state.copyWith(generating: true, solved: false, running: false);
    final data = await _generateDaily(date);
    state = GameState(
      game: SudokuGame.from(data),
      difficulty: data.difficulty,
      generating: false,
      solved: false,
      startedAt: DateTime.now(),
      running: true,
      isDaily: true,
      dailyDate: date,
      dayNumber: dailyNumberFor(date),
    );
  }

  /// The daily outcome, available only once a daily session is solved.
  DailyResult? get dailyResult {
    final g = state.game;
    if (!state.isDaily || g == null || !state.solved) return null;
    final start = state.startedAt;
    final end = state.finishedAt;
    final time = (start != null && end != null)
        ? end.difference(start)
        : Duration.zero;
    return DailyResult(
      dayNumber: state.dayNumber,
      date: state.dailyDate ?? DateTime.now(),
      difficulty: state.difficulty,
      time: time,
      mistakes: g.mistakes,
      hints: 0, // hint system not yet implemented
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

/// Free-play session.
final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

/// Daily session — a separate instance so it never clobbers free play.
final dailyGameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);
