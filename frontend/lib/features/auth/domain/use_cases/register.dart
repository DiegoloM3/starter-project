import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/registration_draft.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class RegisterUseCase implements UseCase<DataState<UserEntity>, RegistrationDraftEntity> {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  @override
  Future<DataState<UserEntity>> call({RegistrationDraftEntity? params}) async {
    final draft = params!;
    if (!draft.isValid) return DataFailed(InvalidRegistrationException(draft));
    return _authRepository.register(draft);
  }
}
