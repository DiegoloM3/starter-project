import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:news_app_clean_architecture/core/session/auth_session.dart';

/// Firebase-backed auth session.
///
/// Implements the read-only [AuthSession] port plus the command surface
/// (`signIn`, `signUp`, `signOut`) used by `AuthCubit`. Both responsibilities
/// share one wrapper because they both wrap the same `FirebaseAuth.instance`,
/// and splitting them would force callers to coordinate two GetIt bindings.
class FirebaseAuthSession implements AuthSession {
  FirebaseAuthSession(this._auth);

  final fb.FirebaseAuth _auth;

  @override
  AuthUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AuthUser?> get changes => _auth.authStateChanges().map(_toAppUser);

  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _toAppUser(cred.user)!;
  }

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = cred.user!;
    if (name.isNotEmpty) {
      await user.updateDisplayName(name);
      await user.reload();
    }
    return _toAppUser(_auth.currentUser)!;
  }

  Future<void> signOut() => _auth.signOut();

  AuthUser? _toAppUser(fb.User? u) {
    if (u == null) return null;
    final fallback = u.email ?? 'User';
    final name = (u.displayName == null || u.displayName!.isEmpty)
        ? fallback
        : u.displayName!;
    return AuthUser(id: u.uid, name: name);
  }
}
