import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/login/domain/repository/user_repository.dart';

class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  final UserRepository _userRepository;

  SignOutUseCase(this._userRepository);

  @override
  Future<DataState<void>> call(NoParams params) async =>
      _userRepository.signOut();
}
