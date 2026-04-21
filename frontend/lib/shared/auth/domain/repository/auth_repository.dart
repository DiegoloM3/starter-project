import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/auth_credentials.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/password_change.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/usecases/params/profile_photo.dart';

abstract class AuthRepository {
  Stream<AuthUserEntity?> authStateChanges();

  AuthUserEntity? get currentUser;

  Future<AuthUserEntity> signIn(AuthCredentials credentials);

  Future<AuthUserEntity> signUp(AuthCredentials credentials);

  Future<void> signOut();

  Future<AuthUserEntity> updateDisplayName(String displayName);

  Future<void> updatePassword(PasswordChange change);

  Future<AuthUserEntity> updateProfilePhoto(ProfilePhoto photo);
}
