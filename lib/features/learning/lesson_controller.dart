import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/learning_repository.dart';
import '../../data/persistence_providers.dart';
import '../../domain/learning_path.dart';
import '../../domain/sudoku_game.dart';
import '../../engine/engine.dart';
import '../game/game_controller.dart'
    show PuzzleGenerator, puzzleGeneratorProvider;

/// How many guided placements make up one lesson.
const int kLessonSteps = 5;

const Object _unset = Object();

/// State for a guided, step-by-step lesson: the player makes a small number of
/// correct placements, each scaffolded by a tiered hint.
class LessonState {
  final SudokuGame? game;
  final List<int> solution;

  /// The suggested next placement (drives the highlight + hint text).
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
      return 'Look at box $box (highlighted). One cell there can be solved — '
          'can you find it?';
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

  @override
  LessonState build() {
    _generate = ref.read(puzzleGeneratorProvider);
    _learning = ref.read(learningRepositoryProvider);
    return const LessonState.initial();
  }

  Future<void> start(LessonNode node) async {
    _nodeId = node.id;
    state = const LessonState(generating: true);
    final data = await _generate(node.practiceDifficulty);
    final game = SudokuGame.from(data);
    state = LessonState(
      game: game,
      solution: data.solution,
      target: nextHint(game.values),
      step: 1,
      totalSteps: kLessonSteps,
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
    if (game == null || state.completed) return;
    final sel = game.selected;
    if (sel == null) {
      state = state.copyWith(feedback: 'Tap a cell first, then choose a number.');
      return;
    }
    if (game.given[sel]) {
      state = state.copyWith(feedback: 'That cell is a clue — pick an empty cell.');
      return;
    }
    if (digit != state.solution[sel]) {
      state = state.copyWith(
        feedback: "Not quite — $digit doesn't go there. "
            'Try the highlighted box, or tap Hint.',
      );
      return;
    }

    // Correct placement.
    game.values[sel] = digit;
    game.selected = null;
    final nextStep = state.step + 1;
    final next = nextHint(game.values);
    if (nextStep > state.totalSteps || next == null) {
      _complete();
      return;
    }
    state = state.copyWith(
      target: next,
      step: nextStep,
      hintTier: 1,
      feedback: null,
    );
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
