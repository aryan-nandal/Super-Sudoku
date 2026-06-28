import 'dart:async';
import 'dart:math';

import '../domain/auth.dart';
import 'settings_repository.dart';

/// Device-local [AuthRepository]: issues a stable anonymous id persisted in the
/// key/value store, so the same identity (and its progress) survives restarts.
///
/// Swap for a `FirebaseAuthRepository` after `flutterfire configure`; the domain
/// interface and all callers stay unchanged.
class LocalAuthRepository implements AuthRepository {
  static const _userIdKey = 'auth.userId';
  static const _displayNameKey = 'auth.displayName';

  final SettingsRepository _settings;
  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _current;

  LocalAuthRepository(this._settings);

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Future<AppUser> signInAnonymously() async {
    var id = await _settings.getString(_userIdKey);
    if (id == null || id.isEmpty) {
      id = _generateId();
      await _settings.setString(_userIdKey, id);
    }
    final name = await _settings.getString(_displayNameKey);
    final user = AppUser(
      id: id,
      isAnonymous: true,
      displayName: (name != null && name.isNotEmpty) ? name : null,
    );
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> updateDisplayName(String name) async {
    final user = await signInAnonymously();
    final trimmed = name.trim();
    await _settings.setString(_displayNameKey, trimmed);
    final updated = AppUser(
      id: user.id,
      isAnonymous: user.isAnonymous,
      displayName: trimmed.isEmpty ? null : trimmed,
    );
    _current = updated;
    _controller.add(updated);
    return updated;
  }

  @override
  Future<void> signOut() async {
    // Keep the local id so re-signing-in restores the same anonymous progress.
    _current = null;
    _controller.add(null);
  }

  void dispose() => _controller.close();

  static String _generateId() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return 'local_$hex';
  }
}
