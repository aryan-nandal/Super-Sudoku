// Identity + sync abstraction (pure domain — no Flutter, no Firebase).
//
// The app always has an AppUser: it starts as an anonymous, device-local
// identity (deferred registration). A real Firebase implementation can replace
// the local one later without touching the domain or UI.

/// The current player. Anonymous until they choose to register.
class AppUser {
  final String id;
  final bool isAnonymous;
  final String? displayName;

  const AppUser({
    required this.id,
    required this.isAnonymous,
    this.displayName,
  });

  AppUser copyWith({String? displayName, bool? isAnonymous}) => AppUser(
        id: id,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        displayName: displayName ?? this.displayName,
      );

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.id == id &&
      other.isAnonymous == isAnonymous &&
      other.displayName == displayName;

  @override
  int get hashCode => Object.hash(id, isAnonymous, displayName);
}

/// Authentication seam. The local implementation issues a stable anonymous id;
/// a Firebase implementation will back this with Firebase Auth.
abstract interface class AuthRepository {
  /// The signed-in user, or null before the first sign-in.
  AppUser? get currentUser;

  /// Emits on every sign-in / sign-out.
  Stream<AppUser?> authStateChanges();

  /// Ensures an anonymous identity exists and returns it. Idempotent — repeated
  /// calls return the same stable id so progress is never orphaned.
  Future<AppUser> signInAnonymously();

  Future<void> signOut();
}

/// Cloud-sync seam for mirroring per-user data (progress, stats, results).
///
/// The local implementation is a no-op ([isRemote] == false). A
/// `FirestoreSyncService` will implement this once Firebase is wired.
abstract interface class SyncService {
  /// Whether a real remote backend is connected.
  bool get isRemote;

  /// Push a snapshot of the user's data to the backend.
  Future<void> pushSnapshot(String userId, Map<String, Object?> data);

  /// Pull the user's snapshot from the backend, or null if none/offline.
  Future<Map<String, Object?>?> pullSnapshot(String userId);
}
