import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/daily.dart';
import '../game/game_controller.dart';
import '../game/widgets/game_top_bar.dart';
import '../game/widgets/number_pad.dart';
import '../game/widgets/sudoku_board.dart';
import 'widgets/daily_result_card.dart';

/// Plays the global Daily puzzle (deterministic for today) and shows a
/// spoiler-free, shareable result card on completion.
class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dailyGameControllerProvider.notifier).startDaily(DateTime.now());
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dailyGameControllerProvider);
    final notifier = ref.read(dailyGameControllerProvider.notifier);

    ref.listen<GameState>(dailyGameControllerProvider, (prev, next) {
      if (next.solved && (prev?.solved != true)) {
        _showResult(notifier);
      }
    });

    final title = state.dayNumber > 0 ? 'Daily #${state.dayNumber}' : 'Daily';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: (state.generating || state.game == null)
            ? const Center(child: CircularProgressIndicator())
            : _buildGame(state, notifier),
      ),
    );
  }

  Widget _buildGame(GameState state, GameController notifier) {
    final game = state.game!;
    return Column(
      children: [
        GameTopBar(
          difficulty: state.difficulty,
          elapsed: _elapsed(state),
          mistakes: game.mistakes,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: SudokuBoard(game: game, onCellTap: notifier.select),
              ),
            ),
          ),
        ),
        NumberPad(
          onDigit: notifier.input,
          onErase: notifier.erase,
          onUndo: notifier.undo,
          onRedo: notifier.redo,
          onToggleNotes: notifier.toggleNotesMode,
          notesMode: game.notesMode,
          canUndo: game.canUndo,
          canRedo: game.canRedo,
          remaining: [for (var d = 1; d <= 9; d++) game.remaining(d)],
        ),
      ],
    );
  }

  void _showResult(GameController notifier) {
    final result = notifier.dailyResult;
    if (result == null) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DailyResultCard(
        result: result,
        onShare: () => _share(result),
      ),
    );
  }

  void _share(DailyResult result) {
    SharePlus.instance.share(ShareParams(text: buildDailyShareText(result)));
  }
}
