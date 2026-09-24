import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/app_user.dart';
import '../entities/auth_failures.dart';
import '../params/update_display_name_params.dart';
import '../repository/auth_repository.dart';

/// Changes the name a journalist publishes under.
///
/// It was only ever settable at sign-up, which left the byline on every
/// article somebody had written stuck with whatever they typed that day.
class UpdateDisplayNameUseCase
    implements UseCase<DataState<AppUserEntity>, UpdateDisplayNameParams> {
  final AuthRepository _authRepository;

  const UpdateDisplayNameUseCase(this._authRepository);

  @override
  Future<DataState<AppUserEntity>> call(UpdateDisplayNameParams params) async {
    final validationErrors = params.validate();

    if (validationErrors.isNotEmpty) {
      return DataFailed(CredentialsValidationException(validationErrors));
    }

    return _authRepository.updateDisplayName(params.displayName.trim());
  }
}
