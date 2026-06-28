import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/leaderboard.dart';

/// Firestore-backed leaderboard. Entries live at `leaderboard/{uid}` —
/// publicly readable, writable only by their owner (see firestore.rules).
///
/// NOTE: the rating is currently client-reported, so it is trust-on-write.
/// Server-side validation (a Cloud Function that recomputes the rating from
/// verified solves) is the anti-cheat follow-up before this is competitive.
class FirebaseLeaderboardRepository implements LeaderboardRepository {
  final FirebaseFirestore _db;

  FirebaseLeaderboardRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('leaderboard');

  @override
  bool get isRemote => true;

  @override
  Stream<List<LeaderboardEntry>> watchTop({int limit = 50}) => _col
      .orderBy('rating', descending: true)
      .limit(limit)
      .snapshots()
      .map((qs) => qs.docs.map(_toEntry).toList());

  LeaderboardEntry _toEntry(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    return LeaderboardEntry(
      userId: doc.id,
      displayName: (m['displayName'] as String?)?.trim().isNotEmpty == true
          ? m['displayName'] as String
          : 'Player',
      rating: (m['rating'] as num?)?.toInt() ?? 1200,
    );
  }
}
