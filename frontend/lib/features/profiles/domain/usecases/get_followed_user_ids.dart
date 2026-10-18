import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/profile_repository.dart';

/// Users followed by the signed in user.
class GetFollowedUserIdsUseCase implements UseCase<DataState<List<String>>, NoParams> {
  final ProfileRepository _profileRepository;

  GetFollowedUserIdsUseCase(this._profileRepository);

  @override
  Future<DataState<List<String>>> call(NoParams params) => _profileRepository.getFollowedUserIds();
}
