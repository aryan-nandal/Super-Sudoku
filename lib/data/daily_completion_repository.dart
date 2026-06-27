import 'package:drift/drift.dart';

import 'db/app_database.dart';

/// A completed Daily record (plain DTO).
class DailyCompletionRecord {
  final String date; // yyyy-mm-dd
  final int dayNumber;
  final int difficultyIndex;
  final int timeSeconds;
  final int mistakes;
  final int hints;

  const DailyCompletionRecord({
    required this.date,
    required this.dayNumber,
    required this.difficultyIndex,
    required this.timeSeconds,
    required this.mistakes,
    this.hints = 0,
  });
}

/// yyyy-mm-dd key for a date (UTC day), used to dedupe one completion per day.
String dailyDateKey(DateTime date) {
  final d = DateTime.utc(date.year, date.month, date.day);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

/// Stores Daily completions; powers "completed today" and (later) streaks/stats.
class DailyCompletionRepository {
  final AppDatabase db;

  DailyCompletionRepository(this.db);

  Future<void> record(DailyCompletionRecord r) {
    return db.into(db.dailyCompletions).insertOnConflictUpdate(
          DailyCompletionsCompanion.insert(
            date: r.date,
            dayNumber: r.dayNumber,
            difficultyIndex: r.difficultyIndex,
            timeSeconds: r.timeSeconds,
            mistakes: r.mistakes,
          ),
        );
  }

  Future<DailyCompletionRecord?> forDate(String date) async {
    final row = await (db.select(db.dailyCompletions)
          ..where((t) => t.date.equals(date)))
        .getSingleOrNull();
    if (row == null) return null;
    return _toRecord(row);
  }

  Future<bool> isCompleted(String date) async =>
      (await forDate(date)) != null;

  Future<List<DailyCompletionRecord>> all() async {
    final rows = await (db.select(db.dailyCompletions)
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    return rows.map(_toRecord).toList();
  }

  DailyCompletionRecord _toRecord(DailyCompletionRow row) => DailyCompletionRecord(
        date: row.date,
        dayNumber: row.dayNumber,
        difficultyIndex: row.difficultyIndex,
        timeSeconds: row.timeSeconds,
        mistakes: row.mistakes,
        hints: row.hints,
      );
}
