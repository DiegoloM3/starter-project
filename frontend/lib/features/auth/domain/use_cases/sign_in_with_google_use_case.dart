import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/auth/domain/repository/auth_repository.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';

class SignInWithGoogleUseCase implements UseCase<DataState<UserEntity>, NoParams> {
  final AuthRepository _repository;
  SignInWithGoogleUseCase(this._repository);

  @override
  Future<DataState<UserEntity>> call(NoParams params) {
    return _repository.signInWithGoogle();
  }
}
