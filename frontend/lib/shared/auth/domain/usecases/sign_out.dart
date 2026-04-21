import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';

class SignOutUseCase implements UseCase<void, void> {
  final AuthRepository _repository;

  SignOutUseCase(this._repository);

  @override
  Future<void> call({void params}) => _repository.signOut();
}
