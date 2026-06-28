import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/learning_repository.dart';
import '../../data/persistence_providers.dart';
import '../../domain/learning_path.dart';
import '../../domain/puzzle_data.dart';
import '../../domain/sudoku_game.dart';
import '../../engine/engine.dart';
import '../game/game_controller.dart'
    show PuzzleGenerator, puzzleGeneratorProvider;

/// How many curated practice positions make up one lesson.
const int kLessonSteps = 3;

/// Cap on puzzle generations while hunting for positions of the target
/// technique (rarer techniques may not appear in every generated puzzle).
const int _kMaxAttempts = 16;

const Object _unset = Object();

/// One curated position: a board where the next required move features the
/// lesson's technique, plus that move and the puzzle's solution.
class _Practice {
  final List<int> board;
  final List<int> solution;
  final HintStep step;

  const _Practice({
    required this.board,
    required this.solution,
    required this.step,
  });
}

/// State for a guided, step-by-step lesson: the player works through a few
/// positions that each genuinely require the technique, scaffolded by a tiered
/// hint.
class LessonState {
  final SudokuGame? game;
  final List<int> solution;

  /// The move to make this step (drives the highlight + hint text).
  final HintStep? target;

  final int step;
  final int totalSteps;

  /// 1 = which region to look at, 2 = which number & why, 3 = exact cell+number.
  final int hintTier;

  final bool generating;
  final bool completed;

  /// Transient nudge after a wrong tap (null when clear).
  final String? feedback;

  const LessonState({
    this.game,
    this.solution = const [],
    this.target,
    this.step = 1,
    this.totalSteps = kLessonSteps,
    this.hintTier = 1,
    this.generating = false,
    this.completed = false,
    this.feedback,
  });

  const LessonState.initial() : this();

  LessonState copyWith({
    SudokuGame? game,
    List<int>? solution,
    HintStep? target,
    int? step,
    int? totalSteps,
    int? hintTier,
    bool? generating,
    bool? completed,
    Object? feedback = _unset,
  }) {
    return LessonState(
      game: game ?? this.game,
      solution: solution ?? this.solution,
      target: target ?? this.target,
      step: step ?? this.step,
      totalSteps: totalSteps ?? this.totalSteps,
      hintTier: hintTier ?? this.hintTier,
      generating: generating ?? this.generating,
      completed: completed ?? this.completed,
      feedback: feedback == _unset ? this.feedback : feedback as String?,
    );
  }
}

/// Beginner-facing instruction for the current step, escalating with [tier]:
/// where to look → which number & why → the exact cell + number.
String lessonInstruction(HintStep target, int tier) {
  final row = rowOf(target.cell) + 1;
  final col = colOf(target.cell) + 1;
  final box = boxOf(target.cell) + 1;
  switch (tier) {
    case 1:
      return 'Look at box $box (highlighted). One cell there can be solved with '
          'this technique — can you find it?';
    case 2:
      return '${target.technique.label}: ${target.technique.tip} '
          'Look for where ${target.digit} must go.';
    default:
      return 'Place ${target.digit} in the highlighted cell '
          '(row $row, column $col).';
  }
}

class LessonController extends Notifier<LessonState> {
  late final PuzzleGenerator _generate;
  late final LearningRepository _learning;

  String? _nodeId;
  List<_Practice> _practices = const [];
  int _index = 0;

  @override
  LessonState build() {
    _generate = ref.read(puzzleGeneratorProvider);
    _learning = ref.read(learningRepositoryProvider);
    return const LessonState.initial();
  }

  Future<void> start(LessonNode node) async {
    _nodeId = node.id;
    _index = 0;
    state = const LessonState(generating: true);

    final practices = <_Practice>[];
    var attempts = 0;
    while (practices.length < kLessonSteps && attempts < _kMaxAttempts) {
      attempts++;
      final data = await _generate(node.practiceDifficulty);
      final steps = collectTechniqueSteps(
        data.puzzle,
        node.technique,
        max: kLessonSteps - practices.length,
      );
      for (final s in steps) {
        practices.add(_Practice(
          board: s.board,
          solution: data.solution,
          step: s.step,
        ));
      }
    }

    // Fallback: if the technique never surfaced, practice the next move on a
    // band puzzle so the lesson is still playable.
    if (practices.isEmpty) {
      final data = await _generate(node.practiceDifficulty);
      final h = nextHint(data.puzzle);
      if (h != null) {
        practices.add(_Practice(
          board: data.puzzle,
          solution: data.solution,
          step: h,
        ));
      }
    }

    _practices = practices;
    state = practices.isEmpty
        ? const LessonState(generating: false)
        : _stateForCurrent();
  }

  LessonState _stateForCurrent() {
    final p = _practices[_index];
    final game = SudokuGame.from(PuzzleData(
      puzzle: p.board,
      solution: p.solution,
      difficultyIndex: 0,
      clues: p.board.where((v) => v != 0).length,
    ));
    return LessonState(
      game: game,
      solution: p.solution,
      target: p.step,
      step: _index + 1,
      totalSteps: _practices.length,
      hintTier: 1,
    );
  }

  void select(int i) {
    final game = state.game;
    if (game == null || state.completed) return;
    game.select(i);
    state = state.copyWith(feedback: null);
  }

  void input(int digit) {
    final game = state.game;
    final target = state.target;
    if (game == null || target == null || state.completed) return;
    final sel = game.selected;
    if (sel == null) {
      state = state.copyWith(feedback: 'Tap a cell first, then choose a number.');
      return;
    }

    if (sel == target.cell && digit == target.digit) {
      // The technique move — advance to the next position (or finish).
      game.values[sel] = digit;
      _index++;
      if (_index >= _practices.length) {
        _complete();
        return;
      }
      state = _stateForCurrent();
      return;
    }

    if (digit == state.solution[sel]) {
      state = state.copyWith(
        feedback: 'Good digit — but this lesson is about '
            '${target.technique.label.toLowerCase()}. Try the highlighted box.',
      );
    } else {
      state = state.copyWith(
        feedback: "Not quite — $digit doesn't go there. "
            'Try the highlighted box, or tap Hint.',
      );
    }
  }

  /// Escalate the hint: region → number+reason → exact cell.
  void requestHint() {
    if (state.completed) return;
    state = state.copyWith(
      hintTier: (state.hintTier + 1).clamp(1, 3),
      feedback: null,
    );
  }

  void _complete() {
    final id = _nodeId;
    if (id != null) _learning.markCompleted(id);
    state = state.copyWith(completed: true, feedback: null);
  }
}

final lessonControllerProvider =
    NotifierProvider<LessonController, LessonState>(LessonController.new);
