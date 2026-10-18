import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../exceptions/auth_exceptions.dart';
import '../params/sign_in_params.dart';
import '../repository/auth_repository.dart';

class SignInUseCase implements UseCase<DataState<UserEntity>, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call(SignInParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(AuthValidationException(errors));
    return _authRepository.signIn(params);
  }
}
