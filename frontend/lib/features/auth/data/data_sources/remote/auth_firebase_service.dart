import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user.model.dart';

/// Firebase Auth data source: sole place touching Firebase Auth for auth.
@injectable
class AuthFirebaseService {
  static final _log = Logger('AuthFirebaseService');

  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;

  /// Watches Firebase Auth state, mapping users to models.
  Stream<UserModel?> get authStateChanges => _firebaseAuth
      .authStateChanges()
      .map((user) => user != null ? _toModel(user) : null);

  /// Returns the currently signed-in user as a model, if any.
  UserModel? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return _toModel(user);
  }

  /// Maps a `firebase_auth` user to a [UserModel] without leaking the
  /// provider type into the model layer (1.2.4).
  UserModel _toModel(fb.User user) {
    return UserModel.fromAuth(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  /// Signs in with [email]/[password]; throws a message on Firebase failure.
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _log.info('signInWithEmailAndPassword → email=$email');
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('User is null after sign in.');
      }
      return _toModel(user);
    } on fb.FirebaseAuthException catch (e) {
      _log.warning(
          'signInWithEmailAndPassword → FirebaseAuthException: ${e.code}', e);
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Creates an account for [email]/[password], setting [displayName] when given.
  Future<UserModel> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _log.info('createUserWithEmailAndPassword → email=$email');
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('User is null after account creation.');
      }

      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
        await user.reload();
      }

      final updatedUser = _firebaseAuth.currentUser ?? user;
      return _toModel(updatedUser);
    } on fb.FirebaseAuthException catch (e) {
      _log.warning(
          'createUserWithEmailAndPassword → FirebaseAuthException: ${e.code}',
          e);
      throw _handleFirebaseAuthException(e);
    }
  }

  /// Signs out the current Firebase user.
  Future<void> signOut() async {
    _log.info('signOut');
    await _firebaseAuth.signOut();
  }

  /// Updates the Firebase Auth display name and photo URL of the current
  /// user so the auth state mirrors the public profile. Returns the fresh
  /// user, or null when nobody is signed in.
  /// Updates display name/photo of the current user; returns the fresh user.
  Future<UserModel?> updateAuthProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    _log.info('updateAuthProfile');
    if (displayName != null) {
      await user.updateDisplayName(displayName.trim());
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }
    await user.reload();
    final updated = _firebaseAuth.currentUser ?? user;
    return _toModel(updated);
  }

  /// Deletes the currently signed-in user, or does nothing when signed out.
  /// Deleting also signs the user out on this device.
  Future<void> deleteCurrentUser() async {
    _log.info('deleteCurrentUser');
    await _firebaseAuth.currentUser?.delete();
  }

  String _handleFirebaseAuthException(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication error occurred (${e.code}).';
    }
  }
}
