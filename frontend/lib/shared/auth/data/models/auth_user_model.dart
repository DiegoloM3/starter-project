import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUserEntity {
  const AuthUserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    super.emailVerified,
  });

  factory AuthUserModel.fromRawData(Map<String, dynamic> data) {
    return AuthUserModel(
      uid: data['uid'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
    );
  }

  AuthUserEntity toEntity() => AuthUserEntity(
        uid: uid,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        emailVerified: emailVerified,
      );
}
