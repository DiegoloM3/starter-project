import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Ends the session. What the account kept on the device (bookmarks, draft,
/// settings) stays under its own id, ready for when it signs in again.
class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  final AuthRepository _authRepository;

  const SignOutUseCase(this._authRepository);

  @override
  Future<DataState<void>> call(NoParams params) => _authRepository.signOut();
}
