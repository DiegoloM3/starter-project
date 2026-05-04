import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/firebase_auth_service.dart';

/// Concrete implementation of [FirebaseAuthService] wrapping [FirebaseAuth].
///
/// Maps [FirebaseAuthException] to [AuthException] at this boundary (design D6).
class FirebaseAuthServiceImpl implements FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthServiceImpl(this._firebaseAuth);

  @override
  Future<User> signInAnonymously() async {
    try {
      final credential = await _firebaseAuth.signInAnonymously();
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<User> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<User> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<User> signInWithCredential(AuthCredential credential) async {
    try {
      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<User> updateDisplayName(User user, String displayName) async {
    try {
      await user.updateDisplayName(displayName);
      await user.reload();
      // After reload, _firebaseAuth.currentUser carries the refreshed profile.
      return _firebaseAuth.currentUser ?? user;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<User?> reloadCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      await user.reload();
      // Return the refreshed instance from FirebaseAuth (post-reload).
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (_) {
      // Server reports the user is gone or disabled. Wipe local state so
      // the bloc can bootstrap a fresh anonymous identity.
      await _firebaseAuth.signOut();
      return null;
    }
  }

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  Future<User> linkAnonymousWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(
        message: 'No current user to link',
        code: 'no-current-user',
      );
    }
    try {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      final result = await user.linkWithCredential(credential);
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  @override
  Future<User> linkAnonymousWithGoogleCredential(
    AuthCredential credential,
  ) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException(
        message: 'No current user to link',
        code: 'no-current-user',
      );
    }
    try {
      final result = await user.linkWithCredential(credential);
      return result.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  AuthException _mapException(FirebaseAuthException e) {
    return AuthException(
      message: e.message ?? e.code,
      code: e.code,
      cause: e,
    );
  }
}
