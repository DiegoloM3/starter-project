import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';

/// Signs in to the account that a failed connect attempt found already
/// exists, leaving the current guest (and its articles) behind.
class SwitchToExistingAccountUseCase
    implements UseCase<DataState<AccountEntity>, void> {
  final AccountRepository _repository;

  SwitchToExistingAccountUseCase(this._repository);

  @override
  Future<DataState<AccountEntity>> call({void params}) {
    return _repository.switchToExistingAccount();
  }
}
