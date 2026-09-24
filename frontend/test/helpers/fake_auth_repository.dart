import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/app_user.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/repository/auth_repository.dart';

/// Hand written test double for [AuthRepository], in the same style as
/// [FakeJournalistArticleRepository].
class FakeAuthRepository implements AuthRepository {
  DataState<AppUserEntity>? signUpResult;
  DataState<AppUserEntity>? signInResult;
  DataState<void> signOutResult = const DataSuccess(null);
  DataState<AppUserEntity?> currentUserResult = const DataSuccess(null);
  DataState<void> passwordResetResult = const DataSuccess(null);

  int signUpCallCount = 0;
  int signInCallCount = 0;
  int signOutCallCount = 0;
  int passwordResetCallCount = 0;
  int updateDisplayNameCallCount = 0;

  DataState<AppUserEntity>? updateDisplayNameResult;

  String? lastEmail;
  String? lastPassword;
  String? lastDisplayName;

  static const AppUserEntity anyUser = AppUserEntity(
    id: 'journalist-1',
    email: 'alex@example.com',
    displayName: 'Alex Rivera',
  );

  @override
  Future<DataState<AppUserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    signUpCallCount++;
    lastEmail = email;
    lastPassword = password;
    lastDisplayName = displayName;

    return signUpResult ?? const DataSuccess(anyUser);
  }

  @override
  Future<DataState<AppUserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    signInCallCount++;
    lastEmail = email;
    lastPassword = password;

    return signInResult ?? const DataSuccess(anyUser);
  }

  @override
  Future<DataState<AppUserEntity>> updateDisplayName(String displayName) async {
    updateDisplayNameCallCount++;
    lastDisplayName = displayName;

    return updateDisplayNameResult ??
        DataSuccess(anyUser.copyWith(displayName: displayName));
  }

  @override
  Future<DataState<void>> signOut() async {
    signOutCallCount++;
    return signOutResult;
  }

  @override
  Future<DataState<AppUserEntity?>> getCurrentUser() async {
    return currentUserResult;
  }

  @override
  Future<DataState<void>> requestPasswordReset(String email) async {
    passwordResetCallCount++;
    lastEmail = email;
    return passwordResetResult;
  }
}
