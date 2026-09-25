import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_exception.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/connect_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/delete_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/get_current_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/sign_out_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/switch_to_existing_account_usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/usecases/update_display_name_usecase.dart';

import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final GetCurrentAccountUseCase _getCurrentAccountUseCase;
  final ConnectAccountUseCase _connectAccountUseCase;
  final SwitchToExistingAccountUseCase _switchToExistingAccountUseCase;
  final SignOutUseCase _signOutUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase;
  final UpdateDisplayNameUseCase _updateDisplayNameUseCase;

  AccountCubit(
    this._getCurrentAccountUseCase,
    this._connectAccountUseCase,
    this._switchToExistingAccountUseCase,
    this._signOutUseCase,
    this._deleteAccountUseCase,
    this._updateDisplayNameUseCase,
  ) : super(const AccountState()) {
    unawaited(loadAccount());
  }

  Future<void> loadAccount() async {
    final result = await _getCurrentAccountUseCase();
    if (result is DataSuccess<AccountEntity>) {
      emit(AccountState(account: result.data));
    }
  }

  Future<void> connect(SignInMethod method) {
    return _runAccountAction(
      () => _connectAccountUseCase(params: method),
      onSuccess: AccountActionStatus.connected,
    );
  }

  Future<void> switchToExistingAccount() {
    return _runAccountAction(
      () => _switchToExistingAccountUseCase(),
      onSuccess: AccountActionStatus.switched,
    );
  }

  Future<void> signOut() {
    return _runAccountAction(
      () => _signOutUseCase(),
      onSuccess: AccountActionStatus.signedOut,
    );
  }

  /// [confirmation] proves the user's identity; null for a guest.
  Future<void> deleteAccount(SignInMethod? confirmation) {
    return _runAccountAction(
      () => _deleteAccountUseCase(params: confirmation),
      onSuccess: AccountActionStatus.deleted,
    );
  }

  Future<void> updateDisplayName(String name) {
    return _runAccountAction(
      () => _updateDisplayNameUseCase(params: name),
      onSuccess: AccountActionStatus.nameUpdated,
    );
  }

  void resetActionStatus() {
    emit(AccountState(account: state.account));
  }

  Future<void> _runAccountAction(
    Future<DataState<AccountEntity>> Function() action, {
    required AccountActionStatus onSuccess,
  }) async {
    emit(AccountState(
      account: state.account,
      actionStatus: AccountActionStatus.inProgress,
    ));
    final result = await action();
    if (result is DataSuccess<AccountEntity>) {
      emit(AccountState(account: result.data, actionStatus: onSuccess));
      return;
    }
    emit(_stateForFailure(result.error));
  }

  AccountState _stateForFailure(Object? error) {
    final reason =
        error is AccountException ? error.reason : AccountErrorReason.unknown;
    final status = switch (reason) {
      AccountErrorReason.cancelled => AccountActionStatus.idle,
      AccountErrorReason.existingAccount =>
        AccountActionStatus.existingAccountFound,
      _ => AccountActionStatus.failed,
    };
    return AccountState(
      account: state.account,
      actionStatus: status,
      errorReason: status == AccountActionStatus.failed ? reason : null,
    );
  }
}
