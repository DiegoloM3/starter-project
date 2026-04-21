import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository _repository;

  WatchAuthStateUseCase(this._repository);

  Stream<AuthUserEntity?> call() => _repository.authStateChanges();
}
