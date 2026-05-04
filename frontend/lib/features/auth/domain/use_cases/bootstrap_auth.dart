import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// One-shot bootstrap of the auth state, intended to be called from `main()`
/// **once per app lifecycle**, after `Firebase.initializeApp()` and DI setup.
///
/// Centralising the bootstrap here (instead of inside [AuthBloc]) is the
/// canonical FlutterFire pattern:
///   - `main()` runs exactly once, so `signInAnonymously()` cannot fire
///     multiple times due to widget rebuilds spawning duplicate bloc events.
///   - The bloc is reduced to an observer of `authStateChanges` — it emits
///     state, but does not own bootstrap.
///   - Auto-anonymous works in three scenarios:
///       1. Fresh install — no cached user, sign in anon.
///       2. Cached user is server-side stale (deleted/disabled) —
///          [AuthRepository.validateCachedUser] signs out locally and we
///          fall through to anon.
///       3. Cached user is still valid — we leave it alone.
///
/// Failures (Anonymous provider disabled, network errors) are swallowed
/// here on purpose: the app continues to boot into [AuthUnauthenticated]
/// and the user can still navigate to `/login` to sign in explicitly.
class BootstrapAuthUseCase implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  BootstrapAuthUseCase(this._repository);

  @override
  Future<void> call({NoParams? params}) async {
    final validated = await _repository.validateCachedUser();
    if (validated == null) {
      await _repository.signInAnonymously();
    }
  }
}
