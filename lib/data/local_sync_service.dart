import '../domain/auth.dart';

/// No-op [SyncService] used until a real backend is reachable. The app is fully
/// functional offline; swap for [FirestoreSyncService] when Firebase is up.
class LocalSyncService implements SyncService {
  @override
  bool get isRemote => false;

  @override
  Future<void> setProfile(String userId, {required String displayName}) async {}

  @override
  Future<void> recordSolve(
    String userId, {
    required int difficultyIndex,
    required int timeSeconds,
    required int mistakes,
  }) async {}
}
