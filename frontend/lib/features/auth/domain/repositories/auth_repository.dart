import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<DataState<UserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<DataState<UserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<DataState<UserEntity>> signInWithGoogle();

  Future<DataState<void>> signOut();

  Future<DataState<UserEntity?>> getCurrentUser();

  Future<DataState<void>> forgotPassword({required String email});
}
