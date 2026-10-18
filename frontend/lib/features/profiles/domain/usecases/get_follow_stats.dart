import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/follow_stats.dart';
import '../repository/profile_repository.dart';

class GetFollowStatsUseCase implements UseCase<DataState<FollowStats>, String> {
  final ProfileRepository _profileRepository;

  GetFollowStatsUseCase(this._profileRepository);

  @override
  Future<DataState<FollowStats>> call(String uid) => _profileRepository.getFollowStats(uid);
}
