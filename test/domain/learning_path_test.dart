import 'package:flutter_test/flutter_test.dart';
import 'package:super_sudoku/domain/learning_path.dart';

void main() {
  test('path is non-empty with unique ids and easiest-first order', () {
    expect(learningPath, isNotEmpty);
    final ids = learningPath.map((n) => n.id).toList();
    expect(ids.toSet().length, ids.length, reason: 'ids unique');
    // Difficulty is non-decreasing along the path.
    for (var i = 1; i < learningPath.length; i++) {
      expect(
        learningPath[i].practiceDifficulty.index,
        greaterThanOrEqualTo(learningPath[i - 1].practiceDifficulty.index),
      );
    }
  });

  group('isNodeUnlocked', () {
    test('first node is always unlocked', () {
      expect(isNodeUnlocked(0, const {}), isTrue);
    });

    test('later nodes unlock when the previous is completed', () {
      expect(isNodeUnlocked(1, const {}), isFalse);
      expect(isNodeUnlocked(1, {learningPath[0].id}), isTrue);
    });

    test('out-of-range index is not unlocked', () {
      expect(isNodeUnlocked(learningPath.length, const {}), isFalse);
    });
  });
}
