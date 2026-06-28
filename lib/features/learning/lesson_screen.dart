import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/learning_path.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/glass_surface.dart';
import '../game/widgets/board_hero.dart';
import '../game/widgets/number_pad.dart';
import '../game/widgets/solve_celebration.dart';
import '../game/widgets/sudoku_board.dart';
import '../settings/settings_controller.dart';
import 'lesson_controller.dart';

/// A guided, beginner-friendly lesson: teach the technique, then walk the player
/// through a few scaffolded placements with tiered hints.
class LessonScreen extends ConsumerStatefulWidget {
  final LessonNode node;

  const LessonScreen({super.key, required this.node});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  bool _celebrating = false;
  bool _handledComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lessonControllerProvider.notifier).start(widget.node);
    });
  }

  void _onComplete() {
    if (_handledComplete) return;
    _handledComplete = true;
    HapticFeedback.mediumImpact();
    if (ref.read(settingsControllerProvider).reducedMotion) {
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
        content: Text(
          'Great work — you practiced ${widget.node.title.toLowerCase()}.',
        ),
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
    final state = ref.watch(lessonControllerProvider);
    final notifier = ref.read(lessonControllerProvider.notifier);

    ref.listen<LessonState>(lessonControllerProvider, (prev, next) {
      if (next.completed && (prev?.completed != true)) _onComplete();
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

  Widget _buildLesson(LessonState state, LessonController notifier) {
    final game = state.game!;
    final settings = ref.watch(settingsControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final target = state.target;

    return Column(
      children: [
        // Teaching intro.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: GlassSurface(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.school_outlined, color: scheme.secondary),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.node.summary)),
              ],
            ),
          ),
        ),
        // Step progress + scaffolded instruction + feedback.
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: GlassSurface(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step ${state.step.clamp(1, state.totalSteps)} of ${state.totalSteps}',
                  style: TextStyle(
                    color: scheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  target == null
                      ? 'Find the next cell you can solve.'
                      : lessonInstruction(target, state.hintTier),
                  key: const ValueKey('lesson_instruction'),
                ),
                if (state.feedback != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    state.feedback!,
                    key: const ValueKey('lesson_feedback'),
                    style: TextStyle(color: scheme.error, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
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
                    hintCell: target?.cell,
                    hintTier: target == null ? 0 : state.hintTier,
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
              onErase: () {},
              onUndo: () {},
              onRedo: () {},
              onToggleNotes: () {},
              onHint: notifier.requestHint,
              notesMode: false,
              canUndo: false,
              canRedo: false,
              remaining: [for (var d = 1; d <= 9; d++) game.remaining(d)],
            ),
          ),
        ),
      ],
    );
  }
}
