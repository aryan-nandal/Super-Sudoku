import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../engine/engine.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/widgets/branded_loader.dart';
import '../../shared/widgets/glass_surface.dart';
import '../settings/settings_controller.dart';
import 'game_controller.dart';
import 'widgets/board_hero.dart';
import 'widgets/conflict_banner.dart';
import 'widgets/game_top_bar.dart';
import 'widgets/hint_banner.dart';
import 'widgets/number_pad.dart';
import 'widgets/solve_celebration.dart';
import 'widgets/sudoku_board.dart';

/// The main play screen: top bar + board + number pad, wired to the controller.
class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  Timer? _ticker;
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    // Start a first game and a once-per-second clock tick.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameControllerProvider.notifier).resumeOrNew(Difficulty.easy);
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
        HapticFeedback.mediumImpact();
        if (ref.read(settingsControllerProvider).reducedMotion) {
          _showWinDialog(next);
        } else {
          setState(() => _celebrating = true);
          Future.delayed(const Duration(milliseconds: 650), () {
            if (mounted) _showWinDialog(next);
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Sudoku'),
        actions: [
          IconButton(
            tooltip: 'Daily puzzle',
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () => context.push('/daily'),
          ),
          IconButton(
            tooltip: 'Learn',
            icon: const Icon(Icons.school_outlined),
            onPressed: () => context.push('/learn'),
          ),
          IconButton(
            tooltip: 'Leaderboard',
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push('/leaderboard'),
          ),
          IconButton(
            tooltip: 'Stats',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push('/stats'),
          ),
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _pickDifficulty,
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackground()),
          SafeArea(
            child: (state.generating || state.game == null)
                ? const BrandedLoader()
                : _buildGame(state, notifier),
          ),
          // On top of everything so the burst is visible over the board.
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
    );
  }

  /// Encouraging post-game analytics line, or null if there's no baseline.
  String? _analyticsLine(GameState state) {
    if (state.isNewBest) return '🏆 New best time!';
    final pct = state.fasterThanAveragePercent;
    if (pct == null) return null;
    if (pct > 0) return '⚡ $pct% faster than your average.';
    if (pct < 0) return 'A bit slower than your average — keep at it!';
    return null;
  }

  void _onHint(GameController notifier) {
    notifier.requestHint();
    if (ref.read(gameControllerProvider).hintTier == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hint available right now.')),
      );
    }
  }

  Widget _buildGame(GameState state, GameController notifier) {
    final game = state.game!;
    final settings = ref.watch(settingsControllerProvider);
    return Column(
      children: [
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
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
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
    final analytics = _analyticsLine(state);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solved! 🎉'),
        content: Text(
          'Difficulty: ${state.difficulty.label}\n'
          'Time: $m:$s\n'
          'Mistakes: ${state.game?.mistakes ?? 0}'
          '${analytics == null ? '' : '\n$analytics'}',
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
