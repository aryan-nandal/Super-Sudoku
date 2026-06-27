/// Super Sudoku — Phase 0 puzzle engine.
///
/// Pure Dart (no Flutter imports) so it can run inside a background isolate and
/// be unit-tested directly. Provides:
///   * board representation + index math ([grid.dart])
///   * a brute-force solver / uniqueness checker ([brute_solver.dart])
///   * a human-technique logical solver & grader ([logical_solver.dart])
///   * honest difficulty banding ([difficulty.dart])
///   * a unique-solution puzzle generator ([generator.dart])
library;

export 'brute_solver.dart';
export 'difficulty.dart';
export 'generator.dart';
export 'grid.dart';
export 'logical_solver.dart';
