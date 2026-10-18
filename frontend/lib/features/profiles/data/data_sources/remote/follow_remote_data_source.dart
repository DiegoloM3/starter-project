import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/resources/exceptions.dart';

/// Follows in Firestore, at `follows/{followerId}_{followedId}`. The id makes it impossible
/// to follow the same user twice.
class FollowRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FollowRemoteDataSource(this._firestore, this._auth);

  CollectionReference<Map<String, dynamic>> get _follows => _firestore.collection('follows');

  String get _signedInUserId => _auth.currentUser?.uid ?? (throw const NotSignedInException());

  DocumentReference<Map<String, dynamic>> _followOf(String followedId) {
    return _follows.doc('${_signedInUserId}_$followedId');
  }

  Future<bool> isFollowing(String followedId) async => (await _followOf(followedId).get()).exists;

  Future<void> follow(String followedId) {
    return _followOf(
      followedId,
    ).set({'followerId': _signedInUserId, 'followedId': followedId, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> unfollow(String followedId) => _followOf(followedId).delete();

  /// Counted by the server, without downloading the follows.
  Future<int> countFollowers(String uid) => _count(_follows.where('followedId', isEqualTo: uid));

  Future<int> countFollowing(String uid) => _count(_follows.where('followerId', isEqualTo: uid));

  Future<List<String>> getFollowedUserIds() async {
    final snapshot = await _follows.where('followerId', isEqualTo: _signedInUserId).get();
    return snapshot.docs.map((document) => document.data()['followedId'] as String).toList();
  }

  Future<int> _count(Query<Map<String, dynamic>> query) async => (await query.count().get()).count ?? 0;
}
