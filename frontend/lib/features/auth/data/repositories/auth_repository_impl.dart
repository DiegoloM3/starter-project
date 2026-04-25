import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/failures/auth_failure.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return DataSuccess(user);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final user = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      return DataSuccess(user);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return DataSuccess(user);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<UserEntity?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return DataSuccess(user);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  @override
  Future<DataState<void>> forgotPassword({required String email}) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email: email);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(_toDataError(e));
    }
  }

  DioError _toDataError(Object e) {
    final failure = e is FirebaseAuthException
        ? AuthFailure(_mapFirebaseAuthCode(e.code))
        : AuthFailure('Something went wrong. Please try again.');
    return DioError(
      requestOptions: RequestOptions(path: ''),
      error: failure,
    );
  }

  String _mapFirebaseAuthCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}
