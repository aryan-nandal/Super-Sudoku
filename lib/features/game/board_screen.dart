import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../engine/engine.dart';
import 'game_controller.dart';
import 'widgets/game_top_bar.dart';
import 'widgets/number_pad.dart';
import 'widgets/sudoku_board.dart';

/// The main play screen: top bar + board + number pad, wired to the controller.
class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Start a first game and a once-per-second clock tick.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider.notifier).newGame(Difficulty.easy);
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
    final state = ref.watch(gameControllerProvider);
    final notifier = ref.read(gameControllerProvider.notifier);

    ref.listen<GameState>(gameControllerProvider, (prev, next) {
      if (next.solved && (prev?.solved != true)) {
        _showWinDialog(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Sudoku'),
        actions: [
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _pickDifficulty,
          ),
        ],
      ),
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

  void _pickDifficulty() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('New game', style: TextStyle(fontSize: 18)),
            ),
            for (final d in Difficulty.values)
              if (d != Difficulty.master)
                ListTile(
                  title: Text(d.label),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(gameControllerProvider.notifier).newGame(d);
                  },
                ),
          ],
        ),
      ),
    );
  }

  void _showWinDialog(GameState state) {
    final elapsed = _elapsed(state);
    final m = elapsed.inMinutes.toString().padLeft(2, '0');
    final s = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solved! 🎉'),
        content: Text(
          'Difficulty: ${state.difficulty.label}\n'
          'Time: $m:$s\n'
          'Mistakes: ${state.game?.mistakes ?? 0}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickDifficulty();
            },
            child: const Text('New game'),
          ),
        ],
      ),
    );
  }
}
