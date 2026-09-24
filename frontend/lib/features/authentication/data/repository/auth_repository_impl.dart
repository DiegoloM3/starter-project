import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/network_failure.dart';
import 'package:news_app_clean_architecture/core/resources/remote_exception.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_failures.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/remote/firebase_auth_service.dart';

/// Firebase Authentication implementation of [AuthRepository].
///
/// This is where the provider's error codes stop existing: each one is
/// translated into one of the domain's own failures, so nothing above this
/// class has to know which provider is behind it. It never names Firebase
/// either — the service hands it a [RemoteException] (rule 1.2.4).
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  const AuthRepositoryImpl(this._authService);

  @override
  Future<DataState<AppUserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _guard(() async {
      final user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      final registered = user.toEntity();

      // `updateDisplayName` does not necessarily refresh the cached user, and
      // re-reading it is what used to hang, so the name just written wins.
      return displayName.isEmpty
          ? registered
          : registered.copyWith(displayName: displayName);
    });
  }

  @override
  Future<DataState<AppUserEntity>> signIn({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final user = await _authService.signIn(email: email, password: password);

      return user.toEntity();
    });
  }

  @override
  Future<DataState<AppUserEntity>> updateDisplayName(String displayName) {
    return _guard(() async {
      final user = await _authService.updateDisplayName(displayName);

      // The cached user is not refreshed by the write, and reloading it is
      // what used to hang (decision #38), so the name just stored wins.
      return user.toEntity().copyWith(displayName: displayName);
    });
  }

  @override
  Future<DataState<void>> signOut() {
    return _guard(() => _authService.signOut());
  }

  @override
  Future<DataState<AppUserEntity?>> getCurrentUser() {
    return _guard(() async {
      return _authService.currentUser?.toEntity();
    });
  }

  @override
  Future<DataState<void>> requestPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);

      return const DataSuccess(null);
    } on RemoteException catch (error) {
      // An address nobody uses is reported as a success on purpose: the
      // contract promises the app cannot be used to discover who is
      // registered (see AuthRepository.requestPasswordReset).
      if (error.code == _userNotFoundCode) {
        return const DataSuccess(null);
      }

      return DataFailed(_toDomainFailure(error));
    } catch (error) {
      return DataFailed(error);
    }
  }

  /// Runs [operation] and guarantees a [DataState] comes back.
  ///
  /// The broad `catch` is deliberate. Letting anything other than a
  /// [RemoteException] escape does not surface an error, it makes the
  /// caller's `await` never complete: that is what left the sign-up screen
  /// spinning over an account Firebase had already created. A repository owes
  /// its caller an answer, including "something unexpected happened".
  Future<DataState<T>> _guard<T>(Future<T> Function() operation) async {
    try {
      return DataSuccess(await operation());
    } on RemoteException catch (error) {
      return DataFailed(_toDomainFailure(error));
    } catch (error) {
      return DataFailed(error);
    }
  }

  /// Maps the provider's error code onto the failure the domain understands.
  ///
  /// `invalid-credential` is what recent Firebase versions return instead of
  /// `wrong-password`/`user-not-found` when email enumeration protection is
  /// on, which is exactly the distinction [InvalidCredentialsException]
  /// refuses to make.
  Object _toDomainFailure(RemoteException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return const EmailAlreadyRegisteredException();
      case 'invalid-credential':
      case 'wrong-password':
      case _userNotFoundCode:
      case 'invalid-email':
      case 'user-disabled':
        return const InvalidCredentialsException();
      case 'weak-password':
        return const CredentialsValidationException(
          [CredentialsValidationError.passwordTooShort],
        );
      case 'too-many-requests':
        return const TooManyAttemptsException();
      // Reported apart from the generic failure because it is the one the
      // person can do something about: "something went wrong" left somebody
      // in airplane mode with no idea that their connection was the problem.
      case 'network-request-failed':
      case RemoteException.unavailableCode:
        return const NetworkUnavailableException();
      default:
        return error;
    }
  }

  /// The provider's code for an address that has no account.
  static const String _userNotFoundCode = 'user-not-found';
}
