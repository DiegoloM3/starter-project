import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Single operation: signs out the current user.
class LogoutUseCase implements UseCase<DataState<void>, void> {
  final AuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  @override
  Future<DataState<void>> call({void params}) async {
    return await _authRepository.logout();
  }
}
