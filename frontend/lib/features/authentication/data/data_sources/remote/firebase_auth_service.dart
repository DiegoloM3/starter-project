import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

import '../../models/app_user_model.dart';

/// The only class in the app that talks to Firebase Authentication.
///
/// Nothing of the SDK leaves this class. Accounts leave as [AppUserModel] and
/// errors as [RemoteException] carrying Firebase's own code, so the repository
/// above can translate a failure without importing Firebase (rule 1.2.4).
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  const FirebaseAuthService(this._firebaseAuth);

  /// Whoever is signed in, or null. Reading it touches no network, so unlike
  /// every method below it has no failure to translate.
  AppUserModel? get currentUser {
    final user = _firebaseAuth.currentUser;

    return user == null ? null : _modelOf(user);
  }

  /// Creates the account and sets its display name.
  ///
  /// It deliberately does not call `User.reload()` afterwards: reloading has
  /// been seen to never complete on Android, which left the sign-up screen
  /// spinning forever over an account that had in fact been created. The
  /// caller already knows the name it asked for, so re-reading it buys
  /// nothing.
  Future<AppUserModel> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _translatingErrors(() async {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw StateError('Firebase created an account but returned no user.');
      }

      if (displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      return _modelOf(user);
    });
  }

  Future<AppUserModel> signIn({
    required String email,
    required String password,
  }) {
    return _translatingErrors(() async {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _modelOf(credential.user!);
    });
  }

  Future<void> signOut() {
    return _translatingErrors(() => _firebaseAuth.signOut());
  }

  /// Writes a new display name onto the signed in account.
  Future<AppUserModel> updateDisplayName(String displayName) {
    return _translatingErrors(() async {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw StateError('Nobody is signed in.');
      }

      await user.updateDisplayName(displayName);

      return _modelOf(user);
    });
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _translatingErrors(
      () => _firebaseAuth.sendPasswordResetEmail(email: email),
    );
  }

  /// Runs [operation] under a deadline and rewrites Firebase's exception as
  /// the data layer's own, so that the SDK's types stop at this class.
  ///
  /// The deadline is here for the same reason it is on Firestore: a call that
  /// never answers leaves the sign-in button spinning with nothing to tell
  /// the person, and "we could not reach the server" is an answer.
  Future<T> _translatingErrors<T>(Future<T> Function() operation) async {
    try {
      return await operation().timeout(kFirestoreTimeout);
    } on TimeoutException catch (error) {
      throw RemoteException(
        RemoteException.unavailableCode,
        message: 'Firebase Authentication did not answer in time.',
        cause: error,
      );
    } on FirebaseAuthException catch (error) {
      throw RemoteException(
        error.code,
        message: error.message,
        cause: error,
      );
    }
  }

  /// The three fields the app reads off an account, as plain Dart.
  static AppUserModel _modelOf(User user) {
    return AppUserModel.fromRawData(<String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
    });
  }
}
