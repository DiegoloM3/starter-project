import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class SignInWithGoogleUseCase
    extends UseCase<DataState<AuthUserEntity>, NoParams> {
  final AuthRepository _repository;

  SignInWithGoogleUseCase(this._repository);

  @override
  Future<DataState<AuthUserEntity>> call({NoParams? params}) {
    return _repository.signInWithGoogle();
  }
}
