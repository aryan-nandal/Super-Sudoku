import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../domain/learning_path.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_surface.dart';
import '../game/game_controller.dart';
import '../game/widgets/board_hero.dart';
import '../game/widgets/conflict_banner.dart';
import '../game/widgets/game_top_bar.dart';
import '../game/widgets/hint_banner.dart';
import '../game/widgets/number_pad.dart';
import '../game/widgets/solve_celebration.dart';
import '../game/widgets/sudoku_board.dart';
import '../settings/settings_controller.dart';

/// Teaches one technique, then has the player practice it. Completing it marks
/// the node done and unlocks the next.
class LessonScreen extends ConsumerStatefulWidget {
  final LessonNode node;

  const LessonScreen({super.key, required this.node});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  Timer? _ticker;
  bool _celebrating = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(lessonGameControllerProvider.notifier)
          .startLesson(widget.node.practiceDifficulty);
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Duration _elapsed(GameState state) {
    final start = state.startedAt;
    if (start == null) return Duration.zero;
    final end = state.running ? DateTime.now() : (state.finishedAt ?? start);
    return end.difference(start);
  }

  void _onHint(GameController notifier) {
    notifier.requestHint();
    if (ref.read(lessonGameControllerProvider).hintTier == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hint available right now.')),
      );
    }
  }

  void _onSolved() {
    if (_completed) return;
    _completed = true;
    HapticFeedback.mediumImpact();
    // Mark the lesson done (reactively updates the learning path).
    ref.read(learningRepositoryProvider).markCompleted(widget.node.id);
    final reduced = ref.read(settingsControllerProvider).reducedMotion;
    if (reduced) {
      _showComplete();
    } else {
      setState(() => _celebrating = true);
      Future.delayed(const Duration(milliseconds: 650), () {
        if (mounted) _showComplete();
      });
    }
  }

  void _showComplete() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lesson complete! 🎉'),
        content: Text('You practiced ${widget.node.title}.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // dialog
              Navigator.of(context).pop(); // back to the path
            },
            child: const Text('Back to path'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonGameControllerProvider);
    final notifier = ref.read(lessonGameControllerProvider.notifier);

    ref.listen<GameState>(lessonGameControllerProvider, (prev, next) {
      if (next.solved && (prev?.solved != true)) _onSolved();
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.node.title)),
      extendBodyBehindAppBar: true,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              (state.generating || state.game == null)
                  ? const Center(child: CircularProgressIndicator())
                  : _buildLesson(state, notifier),
              if (_celebrating)
                Positioned.fill(
                  child: SolveCelebration(
                    onDone: () {
                      if (mounted) setState(() => _celebrating = false);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLesson(GameState state, GameController notifier) {
    final game = state.game!;
    final settings = ref.watch(settingsControllerProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: GlassSurface(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(Icons.school_outlined,
                    color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.node.summary)),
              ],
            ),
          ),
        ),
        GameTopBar(
          difficulty: state.difficulty,
          elapsed: _elapsed(state),
          mistakes: game.mistakes,
        ),
        if (game.hasErrors) ConflictBanner(onRewind: notifier.clearErrors),
        if (state.hintTier > 0 && state.hintStep != null)
          HintBanner(
            hint: state.hintStep!,
            tier: state.hintTier,
            onMore: notifier.requestHint,
            onApply: notifier.applyHint,
            onDismiss: notifier.dismissHint,
          ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: AspectRatio(
                aspectRatio: 1,
                child: BoardHero(
                  child: SudokuBoard(
                    game: game,
                    onCellTap: notifier.select,
                    highlightPeers: settings.highlightPeers,
                    highlightDuplicates: settings.highlightDuplicates,
                    autoCandidateNotes: settings.autoCandidateNotes,
                    hintCell: state.hintStep?.cell,
                    hintTier: state.hintTier,
                    colorBlindMode: settings.colorBlindMode,
                    animate: !settings.reducedMotion,
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GlassSurface(
            padding: EdgeInsets.zero,
            child: NumberPad(
              onDigit: (d) {
                HapticFeedback.selectionClick();
                notifier.input(d);
              },
              onErase: notifier.erase,
              onUndo: notifier.undo,
              onRedo: notifier.redo,
              onToggleNotes: notifier.toggleNotesMode,
              onHint: () => _onHint(notifier),
              notesMode: game.notesMode,
              canUndo: game.canUndo,
              canRedo: game.canRedo,
              remaining: [for (var d = 1; d <= 9; d++) game.remaining(d)],
            ),
          ),
        ),
      ],
    );
  }
}
