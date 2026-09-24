import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../repository/auth_repository.dart';

/// Ends the current session. Reading the app keeps working afterwards.
class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;

  const SignOutUseCase(this._authRepository);

  @override
  Future<DataState<void>> call(NoParams params) {
    return _authRepository.signOut();
  }
}
