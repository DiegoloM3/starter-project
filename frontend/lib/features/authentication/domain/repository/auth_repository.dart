import 'package:news_app_clean_architecture/core/resources/data_state.dart';

import '../entities/app_user.dart';

/// Contract for knowing who is using the app.
///
/// The business layer only knows this abstraction: whether identity comes
/// from Firebase Authentication or from anywhere else is the data layer's
/// business.
abstract class AuthRepository {
  /// Registers a new account and leaves it signed in.
  Future<DataState<AppUserEntity>> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs an existing account in.
  Future<DataState<AppUserEntity>> signIn({
    required String email,
    required String password,
  });

  Future<DataState<void>> signOut();

  /// Changes the name readers see on this person's articles.
  ///
  /// Returns the account as it now stands, so whoever asked does not have to
  /// guess what was stored.
  Future<DataState<AppUserEntity>> updateDisplayName(String displayName);

  /// Whoever is signed in right now, or `null` when nobody is.
  ///
  /// Reading the app requires no account, so "nobody" is an ordinary answer
  /// here and not a failure.
  Future<DataState<AppUserEntity?>> getCurrentUser();

  /// Starts a password reset for [email].
  ///
  /// This states the intent, not the mechanism: how the person proves they
  /// own the address is the data layer's decision (today, an email from
  /// Firebase with a single use link).
  ///
  /// Succeeds even when no account uses that address, so that the app cannot
  /// be used to find out who is registered.
  Future<DataState<void>> requestPasswordReset(String email);
}
