import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class SignInWithEmailUseCase
    extends UseCase<DataState<AuthUserEntity>, SignInParams> {
  final AuthRepository _repository;

  SignInWithEmailUseCase(this._repository);

  @override
  Future<DataState<AuthUserEntity>> call({SignInParams? params}) {
    assert(params != null, 'SignInParams must not be null');
    return _repository.signInWithEmail(params!);
  }
}
