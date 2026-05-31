import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with a Google account.
class SignInWithGoogle implements UseCase<DataState<UserEntity>, void> {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  @override
  Future<DataState<UserEntity>> call({void params}) {
    return _repository.signInWithGoogle();
  }
}
