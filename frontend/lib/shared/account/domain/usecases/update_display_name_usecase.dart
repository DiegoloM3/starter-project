import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_exception.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';

/// Sets the account's display name -- shown in Profile and offered as the
/// default byline for a new article. Separate from signing in, so a name
/// set at sign-up can also be changed again any time after.
class UpdateDisplayNameUseCase
    implements UseCase<DataState<AccountEntity>, String> {
  final AccountRepository _repository;

  UpdateDisplayNameUseCase(this._repository);

  @override
  Future<DataState<AccountEntity>> call({String? params}) {
    final name = params?.trim() ?? '';
    if (name.isEmpty) {
      return Future.value(const DataFailed<AccountEntity>(
          AccountException(AccountErrorReason.unknown)));
    }
    return _repository.updateDisplayName(name);
  }
}
