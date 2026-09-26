import '../../../../core/resources/data_state.dart';
import '../entities/user_identity.dart';
import '../params/auth_params.dart';
import '../repository/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repository;
  const SignInUseCase(this._repository);
  Future<DataState<UserIdentity>> call(SignInParams params) => _repository.signIn(params);
}
