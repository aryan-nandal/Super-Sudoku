import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Typed key/value store for app settings (migration-friendly as settings grow).
@DataClassName('KeyValueEntry')
class KeyValueEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// A resumable in-progress game (one row per slot, e.g. 'free' or 'daily').
@DataClassName('GameSaveRow')
class GameSaves extends Table {
  TextColumn get id => text()();
  TextColumn get puzzle => text()();
  TextColumn get solution => text()();
  TextColumn get cellValues => text()();
  TextColumn get notes => text()();
  IntColumn get mistakes => integer()();
  IntColumn get elapsedSeconds => integer()();
  IntColumn get difficultyIndex => integer()();
  BoolColumn get isDaily => boolean()();
  IntColumn get dayNumber => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Record of a completed Daily (keyed by yyyy-mm-dd) — powers "completed today"
/// and, later, streaks and stats.
@DataClassName('DailyCompletionRow')
class DailyCompletions extends Table {
  TextColumn get date => text()();
  IntColumn get dayNumber => integer()();
  IntColumn get difficultyIndex => integer()();
  IntColumn get timeSeconds => integer()();
  IntColumn get mistakes => integer()();
  IntColumn get hints => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

/// Every solved game (free play and daily) — powers stats & analytics.
@DataClassName('GameResultRow')
class GameResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get difficultyIndex => integer()();
  IntColumn get timeSeconds => integer()();
  IntColumn get mistakes => integer()();
  IntColumn get hints => integer().withDefault(const Constant(0))();
  BoolColumn get isDaily => boolean().withDefault(const Constant(false))();
  TextColumn get date => text()(); // yyyy-mm-dd
}

@DriftDatabase(
  tables: [KeyValueEntries, GameSaves, DailyCompletions, GameResults],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Opens the on-device database for app use. On web this uses the bundled
  /// sqlite3 wasm + drift worker (served from web/); on mobile/desktop the
  /// `web` options are ignored and a native database is used.
  AppDatabase.open()
      : super(
          driftDatabase(
            name: 'super_sudoku',
            web: DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            ),
          ),
        );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(gameResults);
        },
      );
}
