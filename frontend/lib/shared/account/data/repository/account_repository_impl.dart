import 'package:news_app_clean_architecture/core/data/data_sources/remote/current_user_data_source.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/account/data/data_sources/remote/account_auth_data_source.dart';
import 'package:news_app_clean_architecture/shared/account/data/data_sources/remote/google_identity_data_source.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';

class AccountRepositoryImpl implements AccountRepository {
  final CurrentUserDataSource _currentUserDataSource;
  final AccountAuthDataSource _accountAuthDataSource;
  final GoogleIdentityDataSource _googleIdentityDataSource;

  AccountRepositoryImpl(
    this._currentUserDataSource,
    this._accountAuthDataSource,
    this._googleIdentityDataSource,
  );

  @override
  Future<DataState<AccountEntity>> getCurrentAccount() {
    return _runThenReadAccount(_currentUserDataSource.ensureSignedIn);
  }

  @override
  Future<DataState<AccountEntity>> connect(SignInMethod method) {
    return _runThenReadAccount(() => _link(method));
  }

  @override
  Future<DataState<AccountEntity>> switchToExistingAccount() {
    return _runThenReadAccount(_accountAuthDataSource.switchToPendingAccount);
  }

  @override
  Future<DataState<AccountEntity>> signOut() {
    return _runThenReadAccount(_signOutAndContinueAsGuest);
  }

  @override
  Future<DataState<void>> reauthenticate(SignInMethod method) async {
    try {
      switch (method) {
        case EmailSignInMethod(:final password):
          await _accountAuthDataSource.reauthenticateWithEmail(password);
        case GoogleSignInMethod():
          final idToken = await _googleIdentityDataSource.requestIdToken();
          await _accountAuthDataSource.reauthenticateWithGoogleIdToken(idToken);
      }
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(e);
    }
  }

  @override
  Future<DataState<AccountEntity>> deleteAccount() {
    return _runThenReadAccount(() async {
      await _accountAuthDataSource.deleteCurrentUser();
      await _googleIdentityDataSource.signOut();
      await _currentUserDataSource.ensureSignedIn();
    });
  }

  @override
  Future<DataState<AccountEntity>> updateDisplayName(String name) {
    return _runThenReadAccount(() => _accountAuthDataSource.updateDisplayName(name));
  }

  Future<void> _link(SignInMethod method) async {
    switch (method) {
      case EmailSignInMethod(:final email, :final password, :final displayName):
        await _accountAuthDataSource.linkWithEmail(
            email: email, password: password, displayName: displayName);
      case GoogleSignInMethod():
        final idToken = await _googleIdentityDataSource.requestIdToken();
        await _accountAuthDataSource.linkWithGoogleIdToken(idToken);
    }
  }

  Future<void> _signOutAndContinueAsGuest() async {
    await _accountAuthDataSource.signOut();
    // Otherwise the next "Continue with Google" silently reuses this account.
    await _googleIdentityDataSource.signOut();
    await _currentUserDataSource.ensureSignedIn();
  }

  Future<DataState<AccountEntity>> _runThenReadAccount(
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return DataSuccess(_accountAuthDataSource.readCurrentAccount().toEntity());
    } catch (e) {
      return DataFailed(e);
    }
  }
}
