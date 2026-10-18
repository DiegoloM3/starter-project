import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../exceptions/auth_exceptions.dart';
import '../params/sign_up_params.dart';
import '../repository/auth_repository.dart';

/// New accounts are readers. Only an administrator can promote them to journalists.
class SignUpUseCase implements UseCase<DataState<UserEntity>, SignUpParams> {
  final AuthRepository _authRepository;

  SignUpUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call(SignUpParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(AuthValidationException(errors));
    return _authRepository.signUp(params);
  }
}
