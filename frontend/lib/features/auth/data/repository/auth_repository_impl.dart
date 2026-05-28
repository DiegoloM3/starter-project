import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<DataState<AuthUserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return DataSuccess(_mapUser(user));
    } on FirebaseAuthException catch (e) {
      return DataFailed(_mapAuthError(e));
    } on FirebaseException catch (e) {
      return DataFailed(AuthException(
        message: e.message ?? 'Authentication failed',
        code: e.code,
      ));
    }
  }

  @override
  Future<DataState<AuthUserEntity>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _dataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return DataSuccess(_mapUser(user));
    } on FirebaseAuthException catch (e) {
      return DataFailed(_mapAuthError(e));
    } on FirebaseException catch (e) {
      return DataFailed(AuthException(
        message: e.message ?? 'Registration failed',
        code: e.code,
      ));
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const DataSuccess(null);
    } on FirebaseException catch (e) {
      return DataFailed(AuthException(
        message: e.message ?? 'Sign out failed',
        code: e.code,
      ));
    }
  }

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return _dataSource.authStateChanges.map(
      (user) => user != null ? _mapUser(user) : null,
    );
  }

  @override
  AuthUserEntity? get currentUser {
    final user = _dataSource.currentUser;
    return user != null ? _mapUser(user) : null;
  }

  AuthUserEntity _mapUser(User user) {
    return AuthUserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }

  AuthException _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthException(
          message: 'No account found with this email',
          code: 'user-not-found',
        );
      case 'wrong-password':
        return const AuthException(
          message: 'Incorrect password',
          code: 'wrong-password',
        );
      case 'invalid-credential':
        return const AuthException(
          message: 'Invalid email or password',
          code: 'invalid-credential',
        );
      case 'email-already-in-use':
        return const AuthException(
          message: 'An account already exists with this email',
          code: 'email-already-in-use',
        );
      case 'weak-password':
        return const AuthException(
          message: 'Password must be at least 6 characters',
          code: 'weak-password',
        );
      case 'invalid-email':
        return const AuthException(
          message: 'Please enter a valid email address',
          code: 'invalid-email',
        );
      case 'too-many-requests':
        return const AuthException(
          message: 'Too many attempts. Please try again later',
          code: 'too-many-requests',
        );
      default:
        return AuthException(
          message: e.message ?? 'Authentication failed',
          code: e.code,
        );
    }
  }
}
