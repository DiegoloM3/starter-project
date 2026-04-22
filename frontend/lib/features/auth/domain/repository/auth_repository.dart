import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity?> login({required String email, required String password});
  Future<UserEntity?> register({required String email, required String password, String? displayName});
  Future<UserEntity?> signInWithGoogle();
  Future<void> logout();
  Future<void> updateUserProfile({String? displayName, String? bio, String? photoUrl});
  Stream<UserEntity?> get onAuthStateChanged;
  UserEntity? get currentUser;
}
