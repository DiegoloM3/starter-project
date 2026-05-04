import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class SignOutUseCase extends UseCase<DataState<void>, NoParams> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<DataState<void>> call({NoParams? params}) {
    return _repository.signOut();
  }
}
