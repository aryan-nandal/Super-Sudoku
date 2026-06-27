import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/quests.dart';

void main() {
  test('all incomplete with no activity', () {
    final quests = todaysQuests(const [], dailyDone: false, mediumIndex: 2);
    expect(quests, hasLength(3));
    expect(quests.every((q) => !q.done), isTrue);
  });

  test('marks quests done based on today\'s solves', () {
    final quests = todaysQuests(
      const [
        (difficultyIndex: 3, mistakes: 0), // hard, clean
      ],
      dailyDone: true,
      mediumIndex: 2,
    );
    expect(quests[0].done, isTrue); // daily
    expect(quests[1].done, isTrue); // no mistakes
    expect(quests[2].done, isTrue); // medium-or-harder
  });

  test('a sloppy easy solve completes none of the conditional quests', () {
    final quests = todaysQuests(
      const [(difficultyIndex: 0, mistakes: 3)],
      dailyDone: false,
      mediumIndex: 2,
    );
    expect(quests.every((q) => !q.done), isTrue);
  });
}
