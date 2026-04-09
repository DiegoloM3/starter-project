import 'package:news_app_clean_architecture/core/extensions/data_exception_extensions.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/login/data/data_sources/remote/users_service.dart';
import 'package:news_app_clean_architecture/features/login/data/models/user.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/login/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UsersService _usersService;

  const UserRepositoryImpl(this._usersService);

  @override
  Stream<UserEntity?> get loginStream =>
      _usersService.loginStream.map((userModel) => userModel?.toEntity());

  @override
  Future<DataState<void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _usersService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return const DataSuccess(null);
    } on Exception catch (e) {
      return DataFailed(e.exception);
    }
  }

  @override
  Future<DataState<void>> signOut() async {
    try {
      await _usersService.signOut();

      return const DataSuccess(null);
    } on Exception catch (e) {
      return DataFailed(e.exception);
    }
  }

  @override
  Future<DataState<void>> createUser({
    required UserEntity user,
    required String password,
  }) async {
    try {
      final userId = await _usersService.createCredentials(
          email: user.email, password: password);
      await _usersService.createUser(
        UserModel.fromEntity(
          user.copyWith(
            id: userId,
          ),
        ),
      );

      return const DataSuccess(null);
    } on Exception catch (e) {
      return DataFailed(e.exception);
    }
  }
}
