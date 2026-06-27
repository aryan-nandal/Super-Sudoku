/// A daily quest and whether today's activity has completed it.
class Quest {
  final String title;
  final bool done;

  const Quest(this.title, {required this.done});
}

/// Minimal per-result info a quest needs.
typedef QuestSample = ({int difficultyIndex, int mistakes});

/// Computes today's quests from today's solves and whether the Daily is done.
/// [mediumIndex] is passed in so this stays decoupled from the engine enum.
List<Quest> todaysQuests(
  Iterable<QuestSample> todaySolves, {
  required bool dailyDone,
  required int mediumIndex,
}) {
  final solves = todaySolves.toList();
  return [
    Quest('Complete today’s Daily', done: dailyDone),
    Quest(
      'Solve a puzzle with no mistakes',
      done: solves.any((r) => r.mistakes == 0),
    ),
    Quest(
      'Solve a Medium or harder puzzle',
      done: solves.any((r) => r.difficultyIndex >= mediumIndex),
    ),
  ];
}
