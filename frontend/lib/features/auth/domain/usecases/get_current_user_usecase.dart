import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Single operation: returns the currently signed-in user, if any.
class GetCurrentUserUseCase implements UseCase<DataState<UserEntity?>, void> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity?>> call({void params}) async {
    return await _authRepository.getCurrentUser();
  }
}
