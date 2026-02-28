import '../../../../core/usecase/usecase.dart';
import '../repository/auth_repository.dart';

class SignInParams {
  final String email;
  final String password;

  SignInParams(this.email, this.password);
}

class SignInUseCase implements UseCase<void, SignInParams> {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  @override
  Future<void> call({SignInParams? params}) {
    final p = params!;
    return _authRepository.signInWithEmailAndPassword(
      email: p.email,
      password: p.password,
    );
  }
}

