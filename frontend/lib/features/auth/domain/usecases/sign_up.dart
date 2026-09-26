import '../../../../core/resources/data_state.dart';
import '../entities/user_identity.dart';
import '../params/auth_params.dart';
import '../repository/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;
  const SignUpUseCase(this._repository);
  Future<DataState<UserIdentity>> call(SignUpParams params) => _repository.signUp(params);
}
