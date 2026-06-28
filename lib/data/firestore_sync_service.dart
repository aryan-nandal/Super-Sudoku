import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/auth.dart';

/// Real [SyncService] backed by Cloud Firestore. The client writes raw solve
/// events to `users/{uid}/solves/{id}` and its display name to `users/{uid}`;
/// a Cloud Function recomputes the authoritative rating and writes the
/// `leaderboard/{uid}` entry (the client cannot write its own rating).
class FirestoreSyncService implements SyncService {
  final FirebaseFirestore _db;

  FirestoreSyncService([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  @override
  bool get isRemote => true;

  @override
  Future<void> setProfile(String userId, {required String displayName}) =>
      _db.collection('users').doc(userId).set(
        {'displayName': displayName},
        SetOptions(merge: true),
      );

  @override
  Future<void> recordSolve(
    String userId, {
    required int difficultyIndex,
    required int timeSeconds,
    required int mistakes,
  }) =>
      _db.collection('users').doc(userId).collection('solves').add({
        'difficultyIndex': difficultyIndex,
        'timeSeconds': timeSeconds,
        'mistakes': mistakes,
        'createdAt': FieldValue.serverTimestamp(),
      });
}
