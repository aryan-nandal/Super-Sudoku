// A small CLI to exercise the Phase 0 engine end-to-end.
// Run with: dart run bin/engine_demo.dart
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:super_sudoku/engine/engine.dart';

void main() {
  // Fixed seed so the demo is reproducible.
  final rng = Random(42);

  print('Super Sudoku — Phase 0 engine demo\n');
  print('Generating one puzzle per difficulty band (each verified unique):\n');

  for (final target in [
    Difficulty.beginner,
    Difficulty.easy,
    Difficulty.medium,
    Difficulty.hard,
    Difficulty.expert,
  ]) {
    final p = generatePuzzle(target: target, random: rng);
    final techniques = p.grade.techniqueCounts.entries
        .map((e) => '${e.key.label}×${e.value}')
        .join(', ');

    print('── Target ${target.label} → got ${p.difficulty.label} '
        '(${p.clues} clues, score ${p.grade.score}) ──');
    print(boardToPretty(p.puzzle));
    print('Unique solution : ${hasUniqueSolution(p.puzzle)}');
    print('Solved by logic : ${p.grade.solved}');
    print('Techniques used : ${techniques.isEmpty ? "none" : techniques}');
    print('');
  }
}
