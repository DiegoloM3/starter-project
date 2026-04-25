import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class MockAuthRepositoryImpl implements AuthRepository {
  UserEntity? _currentUser;

  @override
  Future<UserEntity> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserEntity(
      uid: 'mock-uid-123',
      displayName: 'Mock User',
      email: email,
      isAnonymous: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserEntity(
      uid: 'mock-uid-456',
      displayName: displayName,
      email: email,
      isAnonymous: false,
    );
    return _currentUser!;
  }

  @override
  Future<UserEntity> signInAnonymous() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = const UserEntity(
      uid: 'mock-anonymous-789',
      displayName: 'Guest',
      isAnonymous: true,
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return _currentUser;
  }
}
