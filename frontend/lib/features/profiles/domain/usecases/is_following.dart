import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/profile_repository.dart';

/// Whether the signed in user follows the given user.
class IsFollowingUseCase implements UseCase<DataState<bool>, String> {
  final ProfileRepository _profileRepository;

  IsFollowingUseCase(this._profileRepository);

  @override
  Future<DataState<bool>> call(String uid) => _profileRepository.isFollowing(uid);
}
