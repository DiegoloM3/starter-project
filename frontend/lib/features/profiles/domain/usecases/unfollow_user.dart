import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/profile_repository.dart';

class UnfollowUserUseCase implements UseCase<DataState<void>, String> {
  final ProfileRepository _profileRepository;

  UnfollowUserUseCase(this._profileRepository);

  @override
  Future<DataState<void>> call(String uid) => _profileRepository.unfollow(uid);
}
