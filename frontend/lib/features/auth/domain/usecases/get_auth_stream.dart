import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for streaming authentication state changes.
class GetAuthStream implements StreamUseCase<AuthStatus, void> {
  const GetAuthStream(this._repository);

  final AuthRepository _repository;

  @override
  Stream<AuthStatus> call({void params}) => _repository.watchAuthStatus();
}
