import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/exceptions/auth_exceptions.dart';
import 'package:news_app_clean_architecture/shared/auth/domain/repository/auth_repository.dart';

class UpdateDisplayNameUseCase implements UseCase<AuthUserEntity, String> {
  final AuthRepository _repository;

  UpdateDisplayNameUseCase(this._repository);

  @override
  Future<AuthUserEntity> call({String? params}) {
    final name = params?.trim() ?? '';
    if (name.isEmpty) {
      throw const AuthUnknownException('Name cannot be empty.');
    }
    if (name.length > 80) {
      throw const AuthUnknownException('Name must be 80 characters or fewer.');
    }
    return _repository.updateDisplayName(name);
  }
}
