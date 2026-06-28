import '../engine/engine.dart';

/// One node in the Duolingo-style learning path: teaches a technique, then has
/// the player practice it on a puzzle of [practiceDifficulty].
class LessonNode {
  final String id;
  final Technique technique;
  final String title;
  final String summary;
  final Difficulty practiceDifficulty;

  const LessonNode({
    required this.id,
    required this.technique,
    required this.title,
    required this.summary,
    required this.practiceDifficulty,
  });
}

/// The ordered learning path, easiest technique first. Each node practices on a
/// puzzle band where that technique is the headline skill.
const List<LessonNode> learningPath = [
  LessonNode(
    id: 'naked_single',
    technique: Technique.nakedSingle,
    title: 'Naked Singles',
    summary:
        'When a cell has only one possible digit left, it must go there. Scan '
        'for cells boxed in by their row, column, and box.',
    practiceDifficulty: Difficulty.beginner,
  ),
  LessonNode(
    id: 'hidden_single',
    technique: Technique.hiddenSingle,
    title: 'Hidden Singles',
    summary:
        'When a digit can only fit in one cell of a row, column, or box, place '
        'it there — even if that cell has other candidates.',
    practiceDifficulty: Difficulty.easy,
  ),
  LessonNode(
    id: 'locked_candidates',
    technique: Technique.lockedCandidates,
    title: 'Locked Candidates',
    summary:
        'If a digit in a box is confined to one row or column, it can be '
        'removed from that line outside the box (and vice versa).',
    practiceDifficulty: Difficulty.medium,
  ),
  LessonNode(
    id: 'naked_pair',
    technique: Technique.nakedPair,
    title: 'Naked Pairs',
    summary:
        'Two cells in a unit sharing the same two candidates lock those digits '
        'to themselves — remove them from the rest of the unit.',
    practiceDifficulty: Difficulty.hard,
  ),
  LessonNode(
    id: 'hidden_pair',
    technique: Technique.hiddenPair,
    title: 'Hidden Pairs',
    summary:
        'Two digits that can only go in the same two cells of a unit clear '
        'every other candidate from those two cells.',
    practiceDifficulty: Difficulty.hard,
  ),
  LessonNode(
    id: 'naked_triple',
    technique: Technique.nakedTriple,
    title: 'Naked Triples',
    summary:
        'Three cells whose candidates together use only three digits lock '
        'those digits — remove them from the rest of the unit.',
    practiceDifficulty: Difficulty.hard,
  ),
  LessonNode(
    id: 'x_wing',
    technique: Technique.xWing,
    title: 'X-Wing',
    summary:
        'When a digit is confined to the same two columns across two rows, it '
        'forms a rectangle — eliminate it from those columns elsewhere.',
    practiceDifficulty: Difficulty.expert,
  ),
];

/// A node is unlocked if it's the first, or the previous node is completed.
bool isNodeUnlocked(int index, Set<String> completedIds) {
  if (index <= 0) return true;
  if (index >= learningPath.length) return false;
  return completedIds.contains(learningPath[index - 1].id);
}
