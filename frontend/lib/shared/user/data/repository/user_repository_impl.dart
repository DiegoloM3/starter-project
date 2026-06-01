import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/data/data_sources/user_remote_data_source.dart';
import 'package:tortutip/shared/user/data/models/user_model.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/shared/user/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;
  UserRepositoryImpl(this._dataSource);

  @override
  Future<DataState<UserEntity>> getCurrentUser() async {
    try {
      final user = await _dataSource.getCurrentUser();
      return DataSuccess(user);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> updateUserRole(String userId, String role) async {
    try {
      await _dataSource.updateUserRole(userId, role);
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<bool>> selectUserCategories(
      String userId, List<String> categoryIds) async {
    try {
      await _dataSource.selectUserCategories(userId, categoryIds);
      return const DataSuccess(true);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      final model = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        avatarUrl: user.avatarUrl,
        bio: user.bio,
        role: user.role,
        gender: user.gender,
        ageRange: user.ageRange,
        createdAt: user.createdAt,
      );
      final updated = await _dataSource.updateUserProfile(model);
      return DataSuccess(updated);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<List<String>>> getUserCategoryIds(String userId) async {
    try {
      final ids = await _dataSource.getUserCategoryIds(userId);
      return DataSuccess(ids);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> getUserById(String userId) async {
    try {
      final model = await _dataSource.getUserById(userId);
      return DataSuccess(model);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<UserEntity>> recordFeedSwipe(String userId) async {
    try {
      final model = await _dataSource.recordFeedSwipe(userId);
      return DataSuccess(model);
    } on Exception catch (e) {
      return DataFailed(e);
    }
  }
}
