import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/shared/auth/data/models/auth_user_model.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;

  FirebaseAuthDataSource(this._auth);

  Stream<AuthUserModel?> authStateChanges() =>
      _auth.userChanges().map((u) => u == null ? null : _toModel(u));

  AuthUserModel? get currentUserSnapshot {
    final u = _auth.currentUser;
    return u == null ? null : _toModel(u);
  }

  Future<AuthUserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toModel(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<AuthUserModel> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _toModel(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<AuthUserModel> updateDisplayName(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthUnknownException('Not signed in.');
      await user.updateDisplayName(displayName);
      await user.reload();
      return _toModel(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw const AuthUnknownException('Not signed in.');
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  Future<AuthUserModel> updatePhotoUrl(String url) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw const AuthUnknownException('Not signed in.');
      await user.updatePhotoURL(url);
      await user.reload();
      return _toModel(_auth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw _mapException(e);
    }
  }

  AuthUserModel _toModel(User user) => AuthUserModel.fromRawData({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'emailVerified': user.emailVerified,
      });

  AuthException _mapException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'invalid-email':
        return const InvalidEmailException();
      default:
        return AuthUnknownException(e.message ?? e.code);
    }
  }
}
