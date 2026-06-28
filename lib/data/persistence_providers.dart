import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auth.dart';
import '../domain/leaderboard.dart';
import 'daily_completion_repository.dart';
import 'db/app_database.dart';
import 'firebase_auth_repository.dart';
import 'firebase_leaderboard_repository.dart';
import 'firestore_sync_service.dart';
import 'game_results_repository.dart';
import 'game_save_repository.dart';
import 'learning_repository.dart';
import 'local_auth_repository.dart';
import 'local_leaderboard_repository.dart';
import 'local_sync_service.dart';
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

final learningRepositoryProvider = Provider<LearningRepository>(
  (ref) => LearningRepository(ref.watch(appDatabaseProvider)),
);

/// Live set of completed lesson-node ids.
final lessonProgressStreamProvider = StreamProvider<Set<String>>(
  (ref) => ref.watch(learningRepositoryProvider).watchCompleted(),
);

/// Whether Firebase initialized successfully. Overridden in `main()` after
/// `Firebase.initializeApp`; defaults to false so tests use the local impls.
final firebaseReadyProvider = Provider<bool>((ref) => false);

/// Leaderboard trust model.
///
/// - `false` (default — Firebase **Spark / free** plan): the client computes and
///   publishes its own rating; Firestore rules validate it (range/length). No
///   Cloud Functions needed, so it runs entirely on the free tier.
/// - `true` (Firebase **Blaze** plan): the client only reports solve events +
///   profile; a deployed Cloud Function computes the authoritative rating and
///   writes the leaderboard. Flip this on AFTER `firebase deploy --only
///   functions` and switching the leaderboard rule to `write:false`.
const bool kServerAuthoritativeLeaderboard = false;

/// Identity seam — Firebase Auth when available, else local anonymous.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(firebaseReadyProvider)) return FirebaseAuthRepository();
  final repo = LocalAuthRepository(ref.watch(settingsRepositoryProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

/// Cloud-sync seam — Firestore when available, else a no-op local impl.
final syncServiceProvider = Provider<SyncService>((ref) =>
    ref.watch(firebaseReadyProvider)
        ? FirestoreSyncService()
        : LocalSyncService());

/// Leaderboard seam — Firestore when available, else an offline local stub.
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) =>
    ref.watch(firebaseReadyProvider)
        ? FirebaseLeaderboardRepository()
        : LocalLeaderboardRepository());
