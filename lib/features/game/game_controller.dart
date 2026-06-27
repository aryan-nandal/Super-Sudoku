import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_completion_repository.dart';
import '../../data/daily_puzzle_service.dart';
import '../../data/game_save_repository.dart';
import '../../data/persistence_providers.dart';
import '../../data/puzzle_generation_service.dart';
import '../../domain/daily.dart';
import '../../domain/puzzle_data.dart';
import '../../domain/sudoku_game.dart';
import '../../engine/engine.dart';

/// Persistence slot id for the free-play game.
const String _freeSlot = 'free';

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

  /// The active hint step, if any (ignored when [hintTier] is 0).
  final HintStep? hintStep;

  /// Hint disclosure level: 0 = none, 1 = nudge, 2 = technique, 3 = exact cell.
  final int hintTier;

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
    this.hintStep,
    this.hintTier = 0,
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
    HintStep? hintStep,
    int? hintTier,
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
      hintStep: hintStep ?? this.hintStep,
      hintTier: hintTier ?? this.hintTier,
    );
  }
}

/// Owns the active [SudokuGame] and orchestrates generation + play actions.
class GameController extends Notifier<GameState> {
  late final PuzzleGenerator _generate;
  late final DailyGenerator _generateDaily;
  late final GameSaveRepository _gameSaves;
  late final DailyCompletionRepository _dailyCompletions;

  @override
  GameState build() {
    _generate = ref.read(puzzleGeneratorProvider);
    _generateDaily = ref.read(dailyGeneratorProvider);
    _gameSaves = ref.read(gameSaveRepositoryProvider);
    _dailyCompletions = ref.read(dailyCompletionRepositoryProvider);
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
    _saveFree();
  }

  /// Resume the saved free-play game if one exists and isn't already solved;
  /// otherwise start a fresh game at [target].
  Future<void> resumeOrNew(Difficulty target) async {
    GameSnapshot? snap;
    try {
      snap = await _gameSaves.load(_freeSlot);
    } catch (_) {
      snap = null; // persistence unavailable (e.g. web without wasm) — start fresh
    }
    if (snap != null && !_snapshotSolved(snap)) {
      final game = SudokuGame.restore(
        solution: snap.solution,
        puzzle: snap.puzzle,
        values: snap.values,
        notes: snap.notes,
        mistakes: snap.mistakes,
      );
      state = GameState(
        game: game,
        difficulty: Difficulty.values[snap.difficultyIndex],
        generating: false,
        solved: false,
        startedAt: DateTime.now().subtract(Duration(seconds: snap.elapsedSeconds)),
        running: true,
      );
    } else {
      await newGame(target);
    }
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

  /// Rewind out of an unsolvable state by clearing wrong entries.
  void clearErrors() => _mutate((g) => g.clearErrors());

  // --- Hints -----------------------------------------------------------------

  /// Request a hint, or escalate the current one to the next disclosure tier.
  /// If no hint exists yet, computes one from the board's *correct* entries.
  /// Leaves [GameState.hintTier] at 0 if no logical step is available.
  void requestHint() {
    final game = state.game;
    if (game == null) return;
    if (state.hintTier > 0) {
      state = state.copyWith(hintTier: (state.hintTier + 1).clamp(1, 3));
      return;
    }
    final step = nextHint(_correctOnlyBoard(game));
    if (step == null) return;
    state = state.copyWith(hintStep: step, hintTier: 1);
  }

  void dismissHint() => state = state.copyWith(hintTier: 0);

  /// Place the current hint's digit (tier-3 "fill it for me").
  void applyHint() {
    final h = state.hintStep;
    if (h == null || state.hintTier == 0) return;
    select(h.cell);
    input(h.digit);
  }

  /// Board containing only givens and correct player entries — the basis for a
  /// meaningful logical hint (player errors are ignored).
  List<int> _correctOnlyBoard(SudokuGame game) => List<int>.generate(
        boardSize,
        (i) =>
            (game.values[i] != 0 && game.values[i] == game.solution[i])
                ? game.values[i]
                : 0,
      );

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
      hintTier: 0, // any board change dismisses the active hint
    );
    _persistAfterMove(justSolved);
  }

  // --- Persistence -----------------------------------------------------------

  void _persistAfterMove(bool justSolved) {
    if (state.isDaily) {
      if (justSolved) _recordDailyCompletion();
    } else if (justSolved) {
      _fireAndForget(_gameSaves.delete(_freeSlot)); // finished — nothing to resume
    } else {
      _saveFree();
    }
  }

  /// Fire-and-forget a persistence write, swallowing failures so a broken
  /// store (e.g. web without wasm) never disrupts play.
  void _fireAndForget(Future<void> future) {
    future.catchError((Object _) {});
  }

  void _saveFree() {
    final game = state.game;
    if (game == null || state.isDaily) return;
    _fireAndForget(_gameSaves.save(
      GameSnapshot(
        id: _freeSlot,
        puzzle: _givensOf(game),
        solution: game.solution,
        values: game.values,
        notes: game.notes,
        mistakes: game.mistakes,
        elapsedSeconds: _elapsedSeconds(),
        difficultyIndex: state.difficulty.index,
      ),
    ));
  }

  void _recordDailyCompletion() {
    final r = dailyResult;
    if (r == null) return;
    _fireAndForget(_dailyCompletions.record(
      DailyCompletionRecord(
        date: dailyDateKey(r.date),
        dayNumber: r.dayNumber,
        difficultyIndex: r.difficulty.index,
        timeSeconds: r.time.inSeconds,
        mistakes: r.mistakes,
        hints: r.hints,
      ),
    ));
  }

  /// Reconstruct the givens-only board from a game (givens are always correct).
  List<int> _givensOf(SudokuGame game) =>
      List<int>.generate(boardSize, (i) => game.given[i] ? game.solution[i] : 0);

  int _elapsedSeconds() {
    final s = state.startedAt;
    if (s == null) return 0;
    final end = state.running ? DateTime.now() : (state.finishedAt ?? s);
    return end.difference(s).inSeconds;
  }

  bool _snapshotSolved(GameSnapshot s) {
    for (var i = 0; i < boardSize; i++) {
      if (s.values[i] != s.solution[i]) return false;
    }
    return true;
  }
}

/// Free-play session.
final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);

/// Daily session — a separate instance so it never clobbers free play.
final dailyGameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);
