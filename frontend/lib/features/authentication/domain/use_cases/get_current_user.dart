import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/app_user.dart';
import '../repository/auth_repository.dart';

/// Whoever is signed in right now, or `null` when nobody is.
///
/// A null result is the ordinary state of a reader who never made an account,
/// not a failure.
class GetCurrentUserUseCase
    implements UseCase<DataState<AppUserEntity?>, NoParams> {
  final AuthRepository _authRepository;

  const GetCurrentUserUseCase(this._authRepository);

  @override
  Future<DataState<AppUserEntity?>> call(NoParams params) {
    return _authRepository.getCurrentUser();
  }
}
