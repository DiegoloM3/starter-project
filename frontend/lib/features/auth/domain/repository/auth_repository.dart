import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

