import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../shared/users/domain/entities/user.dart';
import '../exceptions/profile_exceptions.dart';
import '../params/update_profile_params.dart';
import '../repository/profile_repository.dart';

/// Updates the profile of the signed in user. Articles and comments keep the name they were
/// published with.
class UpdateProfileUseCase implements UseCase<DataState<UserEntity>, UpdateProfileParams> {
  final ProfileRepository _profileRepository;

  UpdateProfileUseCase(this._profileRepository);

  @override
  Future<DataState<UserEntity>> call(UpdateProfileParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(ProfileValidationException(errors));
    return _profileRepository.updateProfile(params);
  }
}
