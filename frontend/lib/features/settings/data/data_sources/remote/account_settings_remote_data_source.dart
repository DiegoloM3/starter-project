import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../../core/resources/exceptions.dart';

/// Preferences of the signed in account, at `users/{uid}/private/account`.
class AccountSettingsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AccountSettingsRemoteDataSource(this._firestore, this._auth);

  DocumentReference<Map<String, dynamic>> get _account {
    final uid = _auth.currentUser?.uid ?? (throw const NotSignedInException());
    return _firestore.collection('users').doc(uid).collection('private').doc('account');
  }

  /// Enabled unless the user turned them off.
  Future<bool> readNotificationsEnabled() async {
    final data = (await _account.get()).data();
    return data?['notificationsEnabled'] as bool? ?? true;
  }

  Future<void> writeNotificationsEnabled(bool isEnabled) => _account.update({'notificationsEnabled': isEnabled});
}
