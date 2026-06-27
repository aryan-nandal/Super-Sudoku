import 'package:drift/drift.dart';

import '../engine/engine.dart';
import 'db/app_database.dart';

/// Plain snapshot of a resumable game (engine-agnostic persistence DTO).
class GameSnapshot {
  final String id;
  final List<int> puzzle;
  final List<int> solution;
  final List<int> values;
  final List<Set<int>> notes;
  final int mistakes;
  final int elapsedSeconds;
  final int difficultyIndex;
  final bool isDaily;
  final int dayNumber;

  const GameSnapshot({
    required this.id,
    required this.puzzle,
    required this.solution,
    required this.values,
    required this.notes,
    required this.mistakes,
    required this.elapsedSeconds,
    required this.difficultyIndex,
    this.isDaily = false,
    this.dayNumber = 0,
  });
}

/// Persists and restores in-progress games (one row per slot id).
///
/// [db] may be null when persistence is unavailable; then saves/deletes no-op
/// and load returns null.
class GameSaveRepository {
  final AppDatabase? db;

  GameSaveRepository(this.db);

  Future<void> save(GameSnapshot s) async {
    final database = db;
    if (database == null) return;
    await database.into(database.gameSaves).insertOnConflictUpdate(
          GameSavesCompanion.insert(
            id: s.id,
            puzzle: boardToString(s.puzzle),
            solution: boardToString(s.solution),
            cellValues: boardToString(s.values),
            notes: _encodeNotes(s.notes),
            mistakes: s.mistakes,
            elapsedSeconds: s.elapsedSeconds,
            difficultyIndex: s.difficultyIndex,
            isDaily: s.isDaily,
            dayNumber: Value(s.dayNumber),
            updatedAt: DateTime.now(),
          ),
        );
  }

  Future<GameSnapshot?> load(String id) async {
    final database = db;
    if (database == null) return null;
    final row = await (database.select(database.gameSaves)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return GameSnapshot(
      id: row.id,
      puzzle: parseBoard(row.puzzle),
      solution: parseBoard(row.solution),
      values: parseBoard(row.cellValues),
      notes: _decodeNotes(row.notes),
      mistakes: row.mistakes,
      elapsedSeconds: row.elapsedSeconds,
      difficultyIndex: row.difficultyIndex,
      isDaily: row.isDaily,
      dayNumber: row.dayNumber,
    );
  }

  Future<void> delete(String id) async {
    final database = db;
    if (database == null) return;
    await (database.delete(database.gameSaves)..where((t) => t.id.equals(id)))
        .go();
  }

  /// Notes are encoded as 81 comma-separated fields; each field is the sorted
  /// digits of that cell (empty field == no notes). e.g. "135,,7,...".
  static String _encodeNotes(List<Set<int>> notes) {
    return notes
        .map((s) => (s.toList()..sort()).join())
        .join(',');
  }

  static List<Set<int>> _decodeNotes(String encoded) {
    final fields = encoded.split(',');
    return List<Set<int>>.generate(boardSize, (i) {
      if (i >= fields.length || fields[i].isEmpty) return <int>{};
      return fields[i].split('').map(int.parse).toSet();
    });
  }
}
