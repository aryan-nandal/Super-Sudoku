import 'logical_solver.dart';

/// Honest difficulty bands, derived from the hardest technique a puzzle
/// genuinely requires — never from clue count.
enum Difficulty { beginner, easy, medium, hard, expert, master }

extension DifficultyLabel on Difficulty {
  String get label => name[0].toUpperCase() + name.substring(1);
}

/// Maps a [GradeResult] to a difficulty band.
///
/// `master` means the puzzle could not be solved by the current technique
/// ladder (it needs techniques beyond X-Wing — chains, etc.). That is reported
/// honestly rather than mislabeled, which is exactly the integrity gap serious
/// solvers complain about in existing apps.
Difficulty difficultyFromGrade(GradeResult g) {
  if (!g.solved || g.hardestTechnique == null) return Difficulty.master;
  switch (g.hardestTechnique!) {
    case Technique.nakedSingle:
      return Difficulty.beginner;
    case Technique.hiddenSingle:
      return Difficulty.easy;
    case Technique.lockedCandidates:
      return Difficulty.medium;
    case Technique.nakedPair:
    case Technique.hiddenPair:
    case Technique.nakedTriple:
      return Difficulty.hard;
    case Technique.xWing:
      return Difficulty.expert;
  }
}
