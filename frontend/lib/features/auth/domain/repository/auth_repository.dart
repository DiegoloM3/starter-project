import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> signInWithGoogle();
  Future<DataState<bool>> signOut();
  Future<DataState<UserEntity>> checkCurrentAuth();
  Future<DataState<bool>> deleteAccount();
}
