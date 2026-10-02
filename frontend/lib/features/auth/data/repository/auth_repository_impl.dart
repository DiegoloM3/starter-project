import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authDataSource;

  AuthRepositoryImpl(this._authDataSource);

  @override
  Stream<UserEntity?> watchSession() {
    return _authDataSource.watchSession().map((user) => user?.toEntity());
  }

  @override
  Future<DataState<UserEntity>> signIn(String email, String password) async {
    try {
      final user = await _authDataSource.signIn(email, password);
      return DataSuccess(user.toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<UserEntity>> register(RegistrationDraftEntity draft) async {
    try {
      final user = await _authDataSource.register(draft);
      return DataSuccess(user.toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _authDataSource.signOut();
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
