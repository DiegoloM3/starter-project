import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:tortutip/features/auth/domain/repository/auth_repository.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<DataState<UserEntity>> signInWithGoogle() async {
    try {
      final user = await _dataSource.signInWithGoogle();
      return DataSuccess(user);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> signOut() async {
    try {
      await _dataSource.signOut();
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> deleteAccount() async {
    try {
      await _dataSource.deleteCurrentUser();
      return const DataSuccess(true);
    } catch (e) {
      return DataFailed(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DataState<UserEntity>> checkCurrentAuth() async {
    try {
      final user = await _dataSource.checkCurrentUser();
      if (user == null) return DataFailed(Exception('No active session'));
      return DataSuccess(user);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }
}
