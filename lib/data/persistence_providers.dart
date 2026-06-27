import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'daily_completion_repository.dart';
import 'db/app_database.dart';
import 'game_results_repository.dart';
import 'game_save_repository.dart';
import 'settings_repository.dart';

/// The app database. Overridden in `main` with [AppDatabase.open]; tests
/// override it with an in-memory database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
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
