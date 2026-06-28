import 'db/app_database.dart';

/// Persists which learning-path nodes the player has completed.
///
/// [db] may be null (web without persistence) — then writes no-op and reads
/// return empty.
class LearningRepository {
  final AppDatabase? db;

  LearningRepository(this.db);

  Future<void> markCompleted(String nodeId) async {
    final database = db;
    if (database == null) return;
    await database.into(database.lessonProgress).insertOnConflictUpdate(
          LessonProgressCompanion.insert(
            nodeId: nodeId,
            completedAt: DateTime.now(),
          ),
        );
  }

  /// Live set of completed node ids — re-emits whenever progress changes.
  Stream<Set<String>> watchCompleted() {
    final database = db;
    if (database == null) return Stream.value(const {});
    return database
        .select(database.lessonProgress)
        .watch()
        .map((rows) => rows.map((r) => r.nodeId).toSet());
  }

  Future<Set<String>> completed() async {
    final database = db;
    if (database == null) return const {};
    final rows = await database.select(database.lessonProgress).get();
    return rows.map((r) => r.nodeId).toSet();
  }
}
