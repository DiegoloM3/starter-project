import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing out the current user.
class SignOut implements UseCase<DataState<void>, void> {
  const SignOut(this._repository);

  final AuthRepository _repository;

  @override
  Future<DataState<void>> call({void params}) {
    return _repository.signOut();
  }
}
