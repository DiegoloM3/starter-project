import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCase<DataState<UserEntity?>, void> {
  final AuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity?>> call({void params}) {
    return _authRepository.getCurrentUser();
  }
}
