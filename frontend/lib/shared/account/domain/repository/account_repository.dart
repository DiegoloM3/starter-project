import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';

abstract class AccountRepository {
  Future<DataState<AccountEntity>> getCurrentAccount();

  Future<DataState<AccountEntity>> connect(SignInMethod method);

  Future<DataState<AccountEntity>> switchToExistingAccount();

  Future<DataState<AccountEntity>> signOut();

  /// Signs in again with [method], to prove it's really the account's owner.
  Future<DataState<void>> reauthenticate(SignInMethod method);

  /// Deletes the account itself and continues as a new guest.
  Future<DataState<AccountEntity>> deleteAccount();

  /// Sets the account's name -- shown in Profile and offered as a new
  /// article's byline. Independent of [connect] so it can be changed any
  /// time afterward, not just set once at sign-up.
  Future<DataState<AccountEntity>> updateDisplayName(String name);
}
