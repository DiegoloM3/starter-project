import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../exceptions/auth_exceptions.dart';
import '../params/auth_validation.dart';
import '../repository/auth_repository.dart';

/// Deleting an account cannot be undone, so the password is asked again to confirm it.
class DeleteAccountUseCase implements UseCase<DataState<void>, String> {
  final AuthRepository _authRepository;

  DeleteAccountUseCase(this._authRepository);

  @override
  Future<DataState<void>> call(String password) async {
    if (password.isEmpty) return const DataFailed(AuthValidationException({AuthValidationError.passwordEmpty}));
    return _authRepository.deleteAccount(password);
  }
}
