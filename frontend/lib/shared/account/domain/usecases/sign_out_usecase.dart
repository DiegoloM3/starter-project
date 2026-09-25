import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/domain/repository/account_repository.dart';

/// Signs out and continues as a fresh guest, since every screen needs a user.
class SignOutUseCase implements UseCase<DataState<AccountEntity>, void> {
  final AccountRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<DataState<AccountEntity>> call({void params}) {
    return _repository.signOut();
  }
}
