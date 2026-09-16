import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Creates an account after validating the form locally.
class SignUpWithEmailUseCase
    implements UseCase<DataState<UserEntity>, SignUpParams> {
  final AuthRepository _authRepository;

  const SignUpWithEmailUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call(SignUpParams params) {
    final errors = params.validate();
    if (errors.isNotEmpty) {
      return Future.value(DataFailed(Failure.validation(errors.first.message)));
    }
    return _authRepository.signUpWithEmail(params);
  }
}
