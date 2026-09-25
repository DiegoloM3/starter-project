import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_exception.dart';

enum AccountActionStatus {
  idle,
  inProgress,
  connected,
  existingAccountFound,
  switched,
  signedOut,
  deleted,
  nameUpdated,
  failed,
}

/// [account] and [actionStatus] are separate on purpose: an action in progress
/// or a failed one must not hide who the user is (the account button depends
/// on it).
class AccountState extends Equatable {
  final AccountEntity? account;
  final AccountActionStatus actionStatus;
  final AccountErrorReason? errorReason;

  const AccountState({
    this.account,
    this.actionStatus = AccountActionStatus.idle,
    this.errorReason,
  });

  bool get isGuest => account?.isGuest ?? true;

  bool get isBusy => actionStatus == AccountActionStatus.inProgress;

  @override
  List<Object?> get props => [account, actionStatus, errorReason];
}
