import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/sign_in_with_email_and_password_params.dart';
import 'package:news_app_clean_architecture/features/login/domain/repository/user_repository.dart';

class SignInWithEmailAndPasswordUseCase
    implements UseCase<DataState<void>, SignInWithEmailAndPasswordParams> {
  final UserRepository _userRepository;

  SignInWithEmailAndPasswordUseCase(this._userRepository);

  @override
  Future<DataState<void>> call(SignInWithEmailAndPasswordParams params) async =>
      _userRepository.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );
}
