import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/error_keys.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';

import '../models/user_model.dart';

/// Data source handling all Firebase Authentication interactions.
@lazySingleton
class FirebaseAuthDataSource {
  const FirebaseAuthDataSource({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _auth = firebaseAuth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Signs in with email and password.
  ///
  /// Throws [AuthException] on authentication failure.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseError(e);
    }
  }

  /// Creates a new account and persists user profile to Firestore.
  ///
  /// Throws [AuthException] on authentication failure.
  /// Throws [ServerException] on Firestore failure.
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();
      final user = _auth.currentUser!;

      final model = UserModel.fromFirebaseUser(user);

      try {
        await _createUserProfile(model);
      } on FirebaseException catch (e) {
        // User is authenticated but profile creation failed
        throw ServerException(
          message: ServerErrorKeys.profileCreationFailed,
          statusCode: e.code.hashCode,
        );
      }

      return model;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebaseError(e);
    }
  }

  /// Signs in with Google credentials.
  ///
  /// Throws [AuthException] if user cancels or authentication fails.
  /// Uses google_sign_in v7 API
  Future<UserModel> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    final GoogleSignInAccount account;
    try {
      account = await googleSignIn.authenticate(scopeHint: ['email']);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException.userCancelled();
      }
      // Convert other Google sign-in errors to AuthException
      throw AuthException(message: e.toString(), statusCode: e.code.hashCode);
    }
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final authResult = await _auth.signInWithCredential(credential);
    final model = UserModel.fromFirebaseUser(authResult.user!);

    try {
      await _createUserProfile(model);
    } on FirebaseException catch (e) {
      // User is authenticated but profile creation failed
      // This is a server-side error, convert to ServerException
      throw ServerException(
        message: ServerErrorKeys.profileCreationFailed,
        statusCode: e.code.hashCode,
      );
    }

    return model;
  }

  /// Signs out the current user from all providers.
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), GoogleSignIn.instance.signOut()]);
  }

  /// Returns the currently authenticated user, or null.
  UserModel? getCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user);
  }

  /// Streams auth state changes as [UserModel?].
  Stream<UserModel?> watchAuthState() {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user);
    });
  }

  /// Creates a user profile document in Firestore if it doesn't exist.
  Future<void> _createUserProfile(UserModel user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(user.toFirestore());
    }
  }
}
