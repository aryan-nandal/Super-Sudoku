import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/board_theme.dart';
import '../../../domain/sudoku_game.dart';
import '../../../engine/engine.dart';

/// Presentational 9×9 Sudoku board.
///
/// Renders values, notes, and selection/peer/same-value/error highlighting from
/// a [SudokuGame], and reports cell taps via [onCellTap]. No Riverpod — the
/// screen wires it to the controller.
class SudokuBoard extends StatelessWidget {
  final SudokuGame game;
  final void Function(int index) onCellTap;

  /// Highlight cells sharing a unit with the selection.
  final bool highlightPeers;

  /// Tint cells whose value conflicts with a peer (duplicate in a unit).
  final bool highlightDuplicates;

  /// Show computed candidates in empty cells that have no user notes.
  final bool autoCandidateNotes;

  /// The hint target cell to highlight, or null.
  final int? hintCell;

  /// Hint disclosure tier: region highlight for 1–2, exact cell for 3.
  final int hintTier;

  const SudokuBoard({
    super.key,
    required this.game,
    required this.onCellTap,
    this.highlightPeers = true,
    this.highlightDuplicates = true,
    this.autoCandidateNotes = false,
    this.hintCell,
    this.hintTier = 0,
  });

  @override
  Widget build(BuildContext context) {
    final board = BoardTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = math.min(constraints.maxWidth, constraints.maxHeight);
        final cell = extent / side;
        return SizedBox(
          width: extent,
          height: extent,
          child: Stack(
            children: [
              for (var i = 0; i < boardSize; i++)
                Positioned(
                  left: colOf(i) * cell,
                  top: rowOf(i) * cell,
                  width: cell,
                  height: cell,
                  child: _Cell(
                    index: i,
                    game: game,
                    board: board,
                    size: cell,
                    highlightPeers: highlightPeers,
                    highlightDuplicates: highlightDuplicates,
                    autoCandidateNotes: autoCandidateNotes,
                    hintCell: hintCell,
                    hintTier: hintTier,
                    onTap: () => onCellTap(i),
                  ),
                ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GridPainter(
                      thin: board.thinLine,
                      thick: board.thickLine,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  final int index;
  final SudokuGame game;
  final BoardTheme board;
  final double size;
  final bool highlightPeers;
  final bool highlightDuplicates;
  final bool autoCandidateNotes;
  final int? hintCell;
  final int hintTier;
  final VoidCallback onTap;

  const _Cell({
    required this.index,
    required this.game,
    required this.board,
    required this.size,
    required this.highlightPeers,
    required this.highlightDuplicates,
    required this.autoCandidateNotes,
    required this.hintCell,
    required this.hintTier,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final value = game.values[index];
    final selected = game.selected;
    final isSelected = selected == index;
    final isError = game.isError(index);

    final color = _backgroundColor(isSelected, selected, value);

    return GestureDetector(
      key: ValueKey('cell_$index'),
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: _semanticLabel(value),
        selected: isSelected,
        child: Container(
          color: color,
          alignment: Alignment.center,
          child: _content(context, value, isError),
        ),
      ),
    );
  }

  Color _backgroundColor(bool isSelected, int? selected, int value) {
    if (isSelected) return board.selectedCellBackground;
    // Hint highlighting takes priority so the player can find the suggestion.
    if (hintTier > 0 && hintCell != null) {
      if (hintTier >= 3 && index == hintCell) return board.hintCellBackground;
      if (hintTier < 3 && boxOf(index) == boxOf(hintCell!)) {
        return board.hintRegionBackground;
      }
    }
    if (highlightDuplicates && game.isDuplicate(index)) {
      return board.errorCellBackground;
    }
    if (selected != null && selected != index) {
      final selValue = game.values[selected];
      if (value != 0 && selValue == value) return board.sameValueBackground;
      if (highlightPeers && game.isPeer(index, selected)) {
        return board.peerCellBackground;
      }
    }
    return board.cellBackground;
  }

  Widget _content(BuildContext context, int value, bool isError) {
    if (value != 0) {
      final color = isError
          ? board.errorText
          : (game.given[index] ? board.givenText : board.userText);
      return Text(
        '$value',
        style: TextStyle(
          fontSize: size * 0.56,
          fontWeight: game.given[index] ? FontWeight.w700 : FontWeight.w500,
          color: color,
        ),
      );
    }
    if (game.notes[index].isNotEmpty) {
      return _Notes(notes: game.notes[index], size: size, color: board.noteText);
    }
    if (autoCandidateNotes) {
      final candidates = game.candidatesFor(index);
      if (candidates.isNotEmpty) {
        return _Notes(
          notes: candidates,
          size: size,
          color: board.noteText.withValues(alpha: 0.45),
        );
      }
    }
    return const SizedBox.shrink();
  }

  String _semanticLabel(int value) {
    final r = rowOf(index) + 1;
    final c = colOf(index) + 1;
    final where = 'Row $r, column $c';
    if (value != 0) {
      return '$where, ${game.given[index] ? 'given' : 'entered'} $value';
    }
    if (game.notes[index].isNotEmpty) {
      return '$where, notes ${(game.notes[index].toList()..sort()).join(', ')}';
    }
    return '$where, empty';
  }
}

class _Notes extends StatelessWidget {
  final Set<int> notes;
  final double size;
  final Color color;

  const _Notes({required this.notes, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(size * 0.04),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (var col = 0; col < 3; col++)
                    Expanded(
                      child: Center(
                        child: Text(
                          notes.contains(row * 3 + col + 1)
                              ? '${row * 3 + col + 1}'
                              : '',
                          style: TextStyle(
                            fontSize: size * 0.2,
                            color: color,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color thin;
  final Color thick;

  _GridPainter({required this.thin, required this.thick});

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / side;
    for (var i = 0; i <= side; i++) {
      final isBox = i % boxSide == 0;
      final paint = Paint()
        ..color = isBox ? thick : thin
        ..strokeWidth = isBox ? 2.0 : 0.8;
      final d = i * cell;
      canvas.drawLine(Offset(d, 0), Offset(d, size.height), paint);
      canvas.drawLine(Offset(0, d), Offset(size.width, d), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) =>
      old.thin != thin || old.thick != thick;
}
