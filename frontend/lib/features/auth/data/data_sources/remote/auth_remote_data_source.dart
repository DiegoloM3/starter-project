import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_error.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';

abstract class AuthRemoteDataSource {
  /// The signed-in account every time it changes, starting with the one Firebase kept on the phone.
  Stream<UserModel?> watchSession();

  Future<UserModel> signIn(String email, String password);

  /// Creates the account with the journalist's name, which the security rules check as the author of their articles.
  Future<UserModel> register(RegistrationDraftEntity draft);

  Future<void> signOut();
}

/// Throws an [AuthException] when Firebase Authentication rejects a request.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _auth;

  AuthRemoteDataSourceImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// `userChanges` also reports the name set while registering, not only sign-ins and sign-outs.
  @override
  Stream<UserModel?> watchSession() {
    return _auth.userChanges().map((user) => user == null ? null : _toModel(user));
  }

  @override
  Future<UserModel> signIn(String email, String password) {
    return _translatingErrors(() async {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _toModel(credential.user!);
    });
  }

  @override
  Future<UserModel> register(RegistrationDraftEntity draft) {
    return _translatingErrors(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: draft.email.trim(),
        password: draft.password,
      );
      final user = credential.user!;
      await user.updateDisplayName(draft.name.trim());
      // A new token carries the name, so the security rules accept the journalist's first article.
      await user.getIdToken(true);
      return _toModel(_auth.currentUser!);
    });
  }

  @override
  Future<void> signOut() => _translatingErrors(_auth.signOut);

  UserModel _toModel(User user) {
    return UserModel.fromRawData({'id': user.uid, 'name': user.displayName, 'email': user.email});
  }

  Future<T> _translatingErrors<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_toAuthError(error.code));
    }
  }

  static AuthError _toAuthError(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
      case 'user-disabled':
        return AuthError.wrongEmailOrPassword;
      case 'email-already-in-use':
        return AuthError.emailAlreadyInUse;
      case 'weak-password':
        return AuthError.weakPassword;
      case 'invalid-email':
        return AuthError.invalidEmail;
      case 'too-many-requests':
        return AuthError.tooManyAttempts;
      case 'network-request-failed':
        return AuthError.noConnection;
      default:
        return AuthError.unknown;
    }
  }
}
