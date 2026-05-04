import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';

/// Abstract contract for the auth repository.
///
/// One-shot operations return [DataState<T>] (AV 1.4.3).
/// The watch stream is raw [Stream<AuthUserEntity?>] — failures surface
/// via onError, not as DataState wrappers, matching the existing pattern
/// in daily_news design D2.
///
/// Pure Dart — no Firebase or Flutter imports (AV 2.1.1).
abstract class AuthRepository {
  /// Signs in anonymously. Creates a new anonymous Firebase user if none exists.
  Future<DataState<AuthUserEntity>> signInAnonymously();

  /// Signs in with email and password.
  Future<DataState<AuthUserEntity>> signInWithEmail(SignInParams params);

  /// Creates a new account with email, password, and display name.
  Future<DataState<AuthUserEntity>> signUpWithEmail(SignUpParams params);

  /// Signs in using the Google Sign-In flow.
  Future<DataState<AuthUserEntity>> signInWithGoogle();

  /// Signs out from Firebase (and Google if applicable).
  Future<DataState<void>> signOut();

  /// Sends a password-reset email to the given address.
  Future<DataState<void>> sendPasswordResetEmail(String email);

  /// Continuous stream of auth state changes.
  /// Emits [AuthUserEntity] when a user is signed in, or [null] when signed out.
  Stream<AuthUserEntity?> watchAuthState();

  /// Returns the currently signed-in user, or [null] if none.
  AuthUserEntity? get currentUser;

  /// Validates the locally cached user against the auth server.
  ///
  /// Returns the validated entity if still valid, or `null` if the user has
  /// been deleted/disabled server-side (or no user is cached). On
  /// invalidation, the implementation MUST sign the user out locally so the
  /// bloc can bootstrap a fresh anonymous identity.
  ///
  /// Used by the bloc on cold start to recover from "stale local cache"
  /// scenarios — primarily during development when Firebase data is wiped
  /// from the console while the device retains a cached UID.
  Future<AuthUserEntity?> validateCachedUser();

  /// Links the current anonymous user to an email/password credential.
  ///
  /// On email-already-in-use, signs out the anonymous account and signs in
  /// with the existing credential (anonymous data is not preserved).
  Future<DataState<AuthUserEntity>> linkAnonymousWithEmail(SignUpParams params);

  /// Links the current anonymous user to a Google credential.
  ///
  /// On credential-already-in-use, signs out and signs in with the Google
  /// credential (anonymous data is not preserved).
  Future<DataState<AuthUserEntity>> linkAnonymousWithGoogle();
}
