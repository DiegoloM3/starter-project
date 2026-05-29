import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource(this._firebaseAuth);

  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName);
    // reload() refreshes the cached user so currentUser exposes the new
    // displayName, and (via userChanges below) re-emits the auth user.
    await user.reload();
    return _firebaseAuth.currentUser!;
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  // userChanges() (not authStateChanges()) so profile updates like
  // updateDisplayName after sign-up propagate to the auth state. plain
  // authStateChanges only fires on sign-in/sign-out/token refresh.
  Stream<User?> get authStateChanges => _firebaseAuth.userChanges();

  User? get currentUser => _firebaseAuth.currentUser;
}
