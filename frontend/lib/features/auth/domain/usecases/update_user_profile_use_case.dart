import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repositories/auth_repository.dart';

class UpdateUserProfileParams {
  final UserEntity user;

  const UpdateUserProfileParams({required this.user});
}

class UpdateUserProfileUseCase
    implements UseCase<DataState<UserEntity>, UpdateUserProfileParams> {
  final AuthRepository _authRepository;

  UpdateUserProfileUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({UpdateUserProfileParams? params}) {
    return _authRepository.updateUserProfile(params!.user);
  }
}
