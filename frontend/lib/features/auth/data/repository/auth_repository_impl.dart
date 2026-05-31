import 'package:injectable/injectable.dart';
import 'package:news_app_clean_architecture/core/errors/exceptions.dart';
import 'package:news_app_clean_architecture/core/errors/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../../domain/domain.dart';
import '../datasources/firebase_auth.dart';

/// Implementation of [AuthRepository] using Firebase Auth as the data source.
///
/// Responsible for:
/// 1. Calling the Firebase data source
/// 2. Catching typed exceptions from the data source
/// 3. Converting exceptions to [Failure] objects
/// 4. Returning [DataState<T>] for remote operations
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final FirebaseAuthDataSource _dataSource;

  @override
  Future<DataState<UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _dataSource.signInWithEmail(
        email: email,
        password: password,
      );
      return DataSuccess(model.toEntity());
    } on AuthException catch (e) {
      return DataFailed(
        AuthFailure(message: e.message, statusCode: e.statusCode),
      );
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final model = await _dataSource.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      return DataSuccess(model.toEntity());
    } on AuthException catch (e) {
      return DataFailed(
        AuthFailure(message: e.message, statusCode: e.statusCode),
      );
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    try {
      final model = await _dataSource.signInWithGoogle();
      return DataSuccess(model.toEntity());
    } on AuthException catch (e) {
      return DataFailed(
        AuthFailure(message: e.message, statusCode: e.statusCode),
      );
    } on ServerException catch (e) {
      return DataFailed(
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const DataSuccess(null);
    } on AuthException catch (e) {
      return DataFailed(
        AuthFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return DataFailed(AuthFailure(message: 'auth.generic', statusCode: null));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final model = _dataSource.getCurrentUser();
    return model?.toEntity();
  }

  @override
  Stream<AuthStatus> watchAuthStatus() {
    return _dataSource.watchAuthState().map((userModel) {
      if (userModel == null) {
        return const Unauthenticated();
      }
      return Authenticated(user: userModel.toEntity());
    });
  }
}
