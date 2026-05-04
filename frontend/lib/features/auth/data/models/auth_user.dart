import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';

/// Data model that wraps a Firebase [User] and maps it to [AuthUserEntity].
///
/// Follows the established pattern from ArticleModel:
///   - Extends the domain entity (AV 1.3.2).
///   - `fromRawData(User)` factory maps the Firebase object (AV 1.3.3).
///   - `toEntity()` returns the pure-domain type.
class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoURL,
    required super.providerId,
    required super.isAnonymous,
  });

  /// Creates an [AuthUserModel] from a Firebase [User].
  ///
  /// [providerId] is derived from [User.providerData]: if the user is
  /// anonymous the value is `'anonymous'`; otherwise it uses the first
  /// provider entry (e.g. `'google.com'` or `'password'`).
  factory AuthUserModel.fromRawData(User firebaseUser) {
    final providerId = firebaseUser.isAnonymous
        ? 'anonymous'
        : (firebaseUser.providerData.isNotEmpty
            ? firebaseUser.providerData.first.providerId
            : 'password');

    return AuthUserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      providerId: providerId,
      isAnonymous: firebaseUser.isAnonymous,
    );
  }

  /// Returns the pure-domain [AuthUserEntity] for this model.
  AuthUserEntity toEntity() {
    return AuthUserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      providerId: providerId,
      isAnonymous: isAnonymous,
    );
  }
}
