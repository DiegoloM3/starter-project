import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Validates the credentials locally before asking the identity provider.
class SignInWithEmailUseCase
    implements UseCase<DataState<UserEntity>, SignInParams> {
  final AuthRepository _authRepository;

  const SignInWithEmailUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call(SignInParams params) {
    final errors = params.validate();
    if (errors.isNotEmpty) {
      return Future.value(DataFailed(Failure.validation(errors.first.message)));
    }
    return _authRepository.signInWithEmail(params);
  }
}
