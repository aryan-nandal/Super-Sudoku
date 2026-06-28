import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/persistence_providers.dart';
import '../../domain/learning_path.dart';

/// A path node enriched with the player's progress state.
class LessonNodeView {
  final LessonNode node;
  final int index;
  final bool completed;
  final bool unlocked;

  const LessonNodeView({
    required this.node,
    required this.index,
    required this.completed,
    required this.unlocked,
  });
}

/// Reactive learning path: combines the static path with the live completion
/// set so the map updates the moment a lesson is completed.
final learningPathProvider =
    Provider.autoDispose<AsyncValue<List<LessonNodeView>>>((ref) {
  final completedAsync = ref.watch(lessonProgressStreamProvider);
  if (completedAsync.hasError) {
    return AsyncError(completedAsync.error!,
        completedAsync.stackTrace ?? StackTrace.current);
  }
  final completed = completedAsync.value;
  if (completed == null) return const AsyncLoading();

  return AsyncData([
    for (var i = 0; i < learningPath.length; i++)
      LessonNodeView(
        node: learningPath[i],
        index: i,
        completed: completed.contains(learningPath[i].id),
        unlocked: isNodeUnlocked(i, completed),
      ),
  ]);
});
