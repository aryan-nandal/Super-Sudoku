import '../domain/auth.dart';

/// No-op [SyncService] used until a real backend is wired. Keeps the app fully
/// functional offline/local-only; swap for a `FirestoreSyncService` after
/// `flutterfire configure` to enable cross-device sync and leaderboards.
class LocalSyncService implements SyncService {
  @override
  bool get isRemote => false;

  @override
  Future<void> pushSnapshot(String userId, Map<String, Object?> data) async {
    // Intentionally no-op: data already lives in the local Drift store.
  }

  @override
  Future<Map<String, Object?>?> pullSnapshot(String userId) async => null;
}
