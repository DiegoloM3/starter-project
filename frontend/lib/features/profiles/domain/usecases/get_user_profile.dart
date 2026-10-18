import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../repository/profile_repository.dart';

class GetUserProfileUseCase implements UseCase<DataState<UserEntity>, String> {
  final ProfileRepository _profileRepository;

  GetUserProfileUseCase(this._profileRepository);

  @override
  Future<DataState<UserEntity>> call(String uid) => _profileRepository.getProfile(uid);
}
