import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> signIn(String email, String password) {
    return _dataSource.signIn(email, password);
  }

  @override
  Future<UserEntity> signUp(
    String email,
    String password,
    String displayName,
  ) {
    return _dataSource.signUp(email, password, displayName);
  }

  @override
  Future<UserEntity> signInAnonymous() {
    return _dataSource.signInAnonymous();
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<UserEntity?> getCurrentUser() {
    return _dataSource.getCurrentUser();
  }
}
