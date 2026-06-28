import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/auth.dart';

/// Real [SyncService] backed by Cloud Firestore. Each user's data lives at
/// `users/{userId}` (see firestore.rules — a user may only access their own doc).
class FirestoreSyncService implements SyncService {
  final FirebaseFirestore _db;

  FirestoreSyncService([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  @override
  bool get isRemote => true;

  @override
  Future<void> pushSnapshot(String userId, Map<String, Object?> data) =>
      _db.collection('users').doc(userId).set(data, SetOptions(merge: true));

  @override
  Future<Map<String, Object?>?> pullSnapshot(String userId) async {
    final snap = await _db.collection('users').doc(userId).get();
    return snap.data();
  }
}
