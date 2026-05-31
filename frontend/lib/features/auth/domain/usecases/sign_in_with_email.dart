import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with email and password.
class SignInWithEmail
    implements
        UseCase<DataState<UserEntity>, ({String email, String password})> {
  const SignInWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<DataState<UserEntity>> call({
    ({String email, String password})? params,
  }) {
    if (params == null) {
      throw ArgumentError.notNull('params');
    }

    return _repository.signInWithEmail(
      email: params.email,
      password: params.password,
    );
  }
}
