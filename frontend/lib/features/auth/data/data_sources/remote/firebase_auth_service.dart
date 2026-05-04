import 'package:firebase_auth/firebase_auth.dart';

/// Abstract data source for Firebase Authentication operations.
///
/// Only this file (and its impl) imports `firebase_auth` (AV 1.2.3).
/// Throws [AuthException] on failure — never leaks [FirebaseAuthException].
abstract class FirebaseAuthService {
  /// Signs the user in anonymously.
  Future<User> signInAnonymously();

  /// Signs in with email and password.
  Future<User> signInWithEmail(String email, String password);

  /// Creates a new account with email and password.
  Future<User> signUpWithEmail(String email, String password);

  /// Signs in with an OAuth credential (e.g. Google).
  Future<User> signInWithCredential(AuthCredential credential);

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password-reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Updates the display name on the current Firebase profile and returns
  /// the refreshed [User] (with the new displayName populated).
  ///
  /// Used after sign-up so the FirebaseAuth profile and the Firestore mirror
  /// stay consistent.
  Future<User> updateDisplayName(User user, String displayName);

  /// Returns the currently signed-in [User] or null.
  User? get currentUser;

  /// Validates the locally cached user against the server by calling
  /// `user.reload()`. Returns the refreshed [User] if still valid, or `null`
  /// if the user has been deleted/disabled server-side or no user is cached.
  ///
  /// On invalidation, also performs a local `signOut()` so subsequent calls
  /// to [currentUser] return null.
  Future<User?> reloadCurrentUser();

  /// Continuous stream of auth state changes.
  Stream<User?> authStateChanges();

  /// Links the current anonymous user to an email/password credential.
  ///
  /// Throws [AuthException] on failure. Relevant codes: email-already-in-use,
  /// credential-already-in-use, weak-password, requires-recent-login,
  /// no-current-user.
  Future<User> linkAnonymousWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Links the current anonymous user to a Google credential.
  ///
  /// Throws [AuthException] on failure. Relevant codes: credential-already-in-use,
  /// no-current-user.
  Future<User> linkAnonymousWithGoogleCredential(AuthCredential credential);
}
