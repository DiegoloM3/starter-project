import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);

  Future<UserEntity> signUp(String email, String password, String displayName);

  Future<UserEntity> signInAnonymous();

  Future<void> signOut();

  Future<UserEntity?> getCurrentUser();
}
