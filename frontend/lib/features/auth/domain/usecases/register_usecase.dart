import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/user_profile_repository.dart';

/// Registration input required by [RegisterUseCase].
class RegisterParams {
  final String email;
  final String password;
  final String? displayName;

  const RegisterParams({
    required this.email,
    required this.password,
    this.displayName,
  });
}

/// Single operation: registers a user then creates their public profile.
class RegisterUseCase
    implements UseCase<DataState<UserEntity>, RegisterParams> {
  static final _log = Logger('RegisterUseCase');

  final AuthRepository _authRepository;
  final UserProfileRepository _userProfileRepository;

  RegisterUseCase(this._authRepository, this._userProfileRepository);

  @override
  Future<DataState<UserEntity>> call({RegisterParams? params}) async {
    if (params == null) {
      return const DataGenericFailed('Missing register parameters');
    }
    final authResult = await _authRepository.register(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
    if (authResult is! DataSuccess || authResult.data == null) {
      return authResult;
    }

    // Firebase Auth and Firestore share no transaction, so compensate:
    // when the profile write fails, delete the freshly created auth user
    // instead of leaving an orphan login behind.
    final user = authResult.data!;
    final profileResult = await _userProfileRepository.createUserProfile(
      UserProfileEntity(
        id: user.id,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
      ),
    );
    if (profileResult is DataSuccess) {
      return DataSuccess(user);
    }

    _log.warning('register → profile write failed, rolling back auth user');
    await _authRepository.deleteCurrentUser();
    return DataGenericFailed(
      profileResult.errorMessage ??
          profileResult.error?.toString() ??
          'Could not create your profile.',
    );
  }
}
