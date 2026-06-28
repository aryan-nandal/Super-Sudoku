import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_completion_repository.dart';
import 'db/app_database.dart';
import 'game_results_repository.dart';
import 'game_save_repository.dart';
import 'settings_repository.dart';

/// The app database, or null when it can't be opened (e.g. web without the
/// sqlite3 wasm assets). A null database makes every repository degrade to a
/// no-persistence mode so the app still runs. Tests override it in-memory.
final appDatabaseProvider = Provider<AppDatabase?>((ref) {
  try {
    final db = AppDatabase.open();
    ref.onDispose(db.close);
    return db;
  } catch (_) {
    return null; // persistence unavailable — keep the app running
  }
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final gameSaveRepositoryProvider = Provider<GameSaveRepository>(
  (ref) => GameSaveRepository(ref.watch(appDatabaseProvider)),
);

final dailyCompletionRepositoryProvider = Provider<DailyCompletionRepository>(
  (ref) => DailyCompletionRepository(ref.watch(appDatabaseProvider)),
);

final gameResultsRepositoryProvider = Provider<GameResultsRepository>(
  (ref) => GameResultsRepository(ref.watch(appDatabaseProvider)),
);

/// Live streams of the tables — re-emit on every DB change. Shared so any
/// feature can stay reactive instead of reading the DB once.
final gameResultsStreamProvider = StreamProvider<List<GameResultRecord>>(
  (ref) => ref.watch(gameResultsRepositoryProvider).watchAll(),
);

final dailyCompletionsStreamProvider =
    StreamProvider<List<DailyCompletionRecord>>(
  (ref) => ref.watch(dailyCompletionRepositoryProvider).watchAll(),
);
