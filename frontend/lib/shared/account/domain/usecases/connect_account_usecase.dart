import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_exception.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';

/// Turns the current guest into a permanent account with [SignInMethod].
class ConnectAccountUseCase
    implements UseCase<DataState<AccountEntity>, SignInMethod> {
  final AccountRepository _repository;

  ConnectAccountUseCase(this._repository);

  @override
  Future<DataState<AccountEntity>> call({SignInMethod? params}) {
    if (params == null) {
      return Future.value(const DataFailed<AccountEntity>(
          AccountException(AccountErrorReason.unknown)));
    }
    return _repository.connect(params);
  }
}
