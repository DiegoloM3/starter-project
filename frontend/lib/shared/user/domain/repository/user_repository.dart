import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<DataState<UserEntity>> getCurrentUser();
  Future<DataState<bool>> updateUserRole(String userId, String role);
  Future<DataState<bool>> selectUserCategories(String userId, List<String> categoryIds);
  Future<DataState<UserEntity>> updateUserProfile(UserEntity user);
  Future<DataState<List<String>>> getUserCategoryIds(String userId);
  Future<DataState<UserEntity>> getUserById(String userId);
  Future<DataState<UserEntity>> recordFeedSwipe(String userId);
}
