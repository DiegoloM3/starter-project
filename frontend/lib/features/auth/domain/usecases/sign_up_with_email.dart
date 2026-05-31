import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for creating a new account with email and password.
class SignUpWithEmail
    implements
        UseCase<
          DataState<UserEntity>,
          ({String email, String password, String displayName})
        > {
  const SignUpWithEmail(this._repository);

  final AuthRepository _repository;

  @override
  Future<DataState<UserEntity>> call({
    ({String displayName, String email, String password})? params,
  }) {
    if (params == null) {
      throw ArgumentError.notNull('params');
    }

    return _repository.signUpWithEmail(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}
