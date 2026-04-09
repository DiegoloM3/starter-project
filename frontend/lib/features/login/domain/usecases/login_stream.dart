import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/login/domain/repository/user_repository.dart';

//! Does not implement UseCase becase we need to return Stream instead of Future<Stream>
class LoginStreamUseCase {
  final UserRepository _userRepository;

  const LoginStreamUseCase(this._userRepository);

  Stream<UserEntity?> call(NoParams params) => _userRepository.loginStream;
}
