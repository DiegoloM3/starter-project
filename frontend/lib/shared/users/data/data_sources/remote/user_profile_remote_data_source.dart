import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/user.dart';
import '../../models/user_model.dart';

/// Profiles in Firestore: the public `users/{uid}` and the private `users/{uid}/private/account`.
class UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserProfileRemoteDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _profiles => _firestore.collection('users');

  /// Writes both documents at once, so an account never ends up with only one of them.
  Future<void> createProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
  }) {
    final profile = _profiles.doc(uid);
    return (_firestore.batch()
          ..set(profile, {
            'firstName': firstName,
            'lastName': lastName,
            'bio': '',
            'photoURL': null,
            'role': UserRole.reader.id,
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..set(profile.collection('private').doc('account'), {'email': email, 'notificationsEnabled': true}))
        .commit();
  }

  Future<UserModel> getProfile(String uid) async {
    final snapshot = await _profiles.doc(uid).get();
    return UserModel.fromRawData(uid, snapshot.data() ?? const {});
  }

  /// Only the fields that the security rules let the owner change.
  Future<void> updateProfile(
    String uid, {
    required String firstName,
    required String lastName,
    required String bio,
    required String? photoURL,
  }) {
    return _profiles.doc(uid).update({'firstName': firstName, 'lastName': lastName, 'bio': bio, 'photoURL': photoURL});
  }

  /// Emits null while the profile does not exist, for example right after creating the account.
  Stream<UserModel?> watchProfile(String uid) {
    return _profiles.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : UserModel.fromRawData(uid, data);
    });
  }

  /// Deletes the profile and the private data of the user, and the follows they made, in a
  /// single batch. The security rules only let followers delete follows, so the follows of
  /// other users to this user remain.
  Future<void> deleteUserData(String uid) async {
    final profile = _profiles.doc(uid);
    final privateDocuments = await Future.wait([
      profile.collection('private').get(),
      profile.collection('savedArticles').get(),
      profile.collection('history').get(),
      _firestore.collection('follows').where('followerId', isEqualTo: uid).get(),
    ]);
    final batch = _firestore.batch();
    for (final document in privateDocuments.expand((snapshot) => snapshot.docs)) {
      batch.delete(document.reference);
    }
    batch.delete(profile);
    await batch.commit();
  }
}
