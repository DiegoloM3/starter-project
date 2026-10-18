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

  /// Emits null while the profile does not exist, for example right after creating the account.
  Stream<UserModel?> watchProfile(String uid) {
    return _profiles.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      return data == null ? null : UserModel.fromRawData(uid, data);
    });
  }
}
