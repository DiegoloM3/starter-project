import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class GetAuthStateChangesUseCase {
  final AuthRepository _repository;

  GetAuthStateChangesUseCase(this._repository);

  Stream<AuthUserEntity?> call() => _repository.authStateChanges;
}
