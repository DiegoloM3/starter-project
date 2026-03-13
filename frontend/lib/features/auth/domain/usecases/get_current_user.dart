import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Use case for getting the currently authenticated user.
class GetCurrentUserUseCase implements UseCaseNoParams<UserEntity?> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<UserEntity?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
