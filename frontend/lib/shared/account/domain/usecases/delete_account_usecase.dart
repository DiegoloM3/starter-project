import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_content_repository.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';

/// Deletes the current account and everything it created, then continues as
/// a new guest. The [SignInMethod] confirms the user's identity first
/// (Firebase only deletes accounts that signed in recently); guests pass none.
///
/// The order matters: identity first, so nothing is deleted if that fails;
/// content before the account, because deleting content needs the account.
class DeleteAccountUseCase
    implements UseCase<DataState<AccountEntity>, SignInMethod?> {
  final AccountRepository _accountRepository;
  final AccountContentRepository _contentRepository;

  DeleteAccountUseCase(this._accountRepository, this._contentRepository);

  @override
  Future<DataState<AccountEntity>> call({SignInMethod? params}) async {
    if (params != null) {
      final confirmed = await _accountRepository.reauthenticate(params);
      if (confirmed is DataFailed) return DataFailed(confirmed.error!);
    }
    final contentDeleted = await _contentRepository.deleteAllContent();
    if (contentDeleted is DataFailed) return DataFailed(contentDeleted.error!);
    return _accountRepository.deleteAccount();
  }
}
