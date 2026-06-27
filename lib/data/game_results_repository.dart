import 'package:drift/drift.dart';

import 'db/app_database.dart';

/// A completed game result (plain DTO).
class GameResultRecord {
  final int difficultyIndex;
  final int timeSeconds;
  final int mistakes;
  final int hints;
  final bool isDaily;
  final String date; // yyyy-mm-dd

  const GameResultRecord({
    required this.difficultyIndex,
    required this.timeSeconds,
    required this.mistakes,
    this.hints = 0,
    this.isDaily = false,
    required this.date,
  });
}

/// Stores every solved game; basis for stats and post-game analytics.
///
/// [db] may be null when persistence is unavailable; then record no-ops and
/// queries return empty.
class GameResultsRepository {
  final AppDatabase? db;

  GameResultsRepository(this.db);

  Future<void> record(GameResultRecord r) async {
    final database = db;
    if (database == null) return;
    await database.into(database.gameResults).insert(
          GameResultsCompanion.insert(
            difficultyIndex: r.difficultyIndex,
            timeSeconds: r.timeSeconds,
            mistakes: r.mistakes,
            hints: Value(r.hints),
            isDaily: Value(r.isDaily),
            date: r.date,
          ),
        );
  }

  Future<List<GameResultRecord>> all() async {
    final database = db;
    if (database == null) return [];
    final rows = await database.select(database.gameResults).get();
    return rows.map(_toRecord).toList();
  }

  Future<List<GameResultRecord>> forDifficulty(int difficultyIndex) async {
    final database = db;
    if (database == null) return [];
    final rows = await (database.select(database.gameResults)
          ..where((t) => t.difficultyIndex.equals(difficultyIndex)))
        .get();
    return rows.map(_toRecord).toList();
  }

  GameResultRecord _toRecord(GameResultRow row) => GameResultRecord(
        difficultyIndex: row.difficultyIndex,
        timeSeconds: row.timeSeconds,
        mistakes: row.mistakes,
        hints: row.hints,
        isDaily: row.isDaily,
        date: row.date,
      );
}
