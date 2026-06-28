import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../domain/auth.dart';

/// Real [AuthRepository] backed by Firebase Auth (anonymous sign-in).
/// Selected when Firebase initialized successfully; otherwise the app uses
/// [LocalAuthRepository].
class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth;

  FirebaseAuthRepository([fb.FirebaseAuth? auth])
      : _auth = auth ?? fb.FirebaseAuth.instance;

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  Future<AppUser> signInAnonymously() async {
    final existing = _auth.currentUser;
    if (existing != null) return _map(existing)!;
    final cred = await _auth.signInAnonymously();
    return _map(cred.user)!;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  AppUser? _map(fb.User? u) => u == null
      ? null
      : AppUser(
          id: u.uid,
          isAnonymous: u.isAnonymous,
          displayName: u.displayName,
        );
}
