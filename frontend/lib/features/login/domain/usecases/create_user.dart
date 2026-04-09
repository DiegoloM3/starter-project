import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/login/domain/entities/create_user_params.dart';
import 'package:news_app_clean_architecture/features/login/domain/repository/user_repository.dart';

class CreateUserUseCase implements UseCase<DataState<void>, CreateUserParams> {
  final UserRepository _userRepository;

  CreateUserUseCase(this._userRepository);

  @override
  Future<DataState<void>> call(CreateUserParams params) async =>
      _userRepository.createUser(user: params.user, password: params.password);
}
