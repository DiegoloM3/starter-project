import '../../../../core/resources/data_state.dart';
import '../repository/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository _repository;
  const SignOutUseCase(this._repository);
  Future<DataState<void>> call() => _repository.signOut();
}
