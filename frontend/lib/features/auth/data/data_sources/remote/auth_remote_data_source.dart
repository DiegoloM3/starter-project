import 'package:firebase_auth/firebase_auth.dart';

import '../../../domain/exceptions/auth_exceptions.dart';
import '../../../domain/params/auth_validation.dart';

/// Accounts of Firebase Authentication. It translates its error codes into domain exceptions,
/// so no other layer needs to know them.
class AuthRemoteDataSource {
  final FirebaseAuth _auth;

  AuthRemoteDataSource(this._auth);

  /// Emits the uid of the signed in user, or null when nobody is signed in.
  Stream<String?> watchSignedInUserId() => _auth.authStateChanges().map((user) => user?.uid);

  /// Returns the email as Firebase stored it, which the private account document must match.
  Future<({String uid, String email})> createAccount({required String email, required String password}) {
    return _translateErrors(() async {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user!;
      return (uid: user.uid, email: user.email ?? email);
    });
  }

  Future<String> signIn({required String email, required String password}) {
    return _translateErrors(() async {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user!.uid;
    });
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> deleteSignedInAccount() async => _auth.currentUser?.delete();

  Future<T> _translateErrors<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FirebaseAuthException catch (error) {
      throw _domainExceptionFor(error);
    }
  }

  Exception _domainExceptionFor(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-credential' || 'wrong-password' || 'user-not-found' => const InvalidCredentialsException(),
      'email-already-in-use' => const EmailAlreadyInUseException(),
      'invalid-email' => const AuthValidationException({AuthValidationError.emailInvalid}),
      'weak-password' => const AuthValidationException({AuthValidationError.passwordTooShort}),
      _ => error,
    };
  }
}
