import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';

abstract class UserRepository {
  Future<DataState<void>> createUser(
      {required UserEntity user, required String password});
  Future<DataState<void>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Stream<UserEntity?> get loginStream;
  Future<DataState<void>> signOut();
}
