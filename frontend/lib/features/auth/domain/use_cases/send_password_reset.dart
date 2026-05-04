import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class SendPasswordResetUseCase extends UseCase<DataState<void>, String> {
  final AuthRepository _repository;

  SendPasswordResetUseCase(this._repository);

  @override
  Future<DataState<void>> call({String? params}) {
    assert(params != null, 'Email must not be null');
    return _repository.sendPasswordResetEmail(params!);
  }
}
