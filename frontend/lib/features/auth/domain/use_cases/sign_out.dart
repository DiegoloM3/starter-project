import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class SignOutUseCase implements UseCase<DataState<void>, void> {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  @override
  Future<DataState<void>> call({void params}) => _authRepository.signOut();
}
