import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for retrieving the currently authenticated user.
class GetCurrentUser implements UseCase<UserEntity?, void> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<UserEntity?> call({void params}) {
    return _repository.getCurrentUser();
  }
}
