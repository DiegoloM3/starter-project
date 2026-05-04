import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

class LinkAnonymousWithEmailUseCase
    extends UseCase<DataState<AuthUserEntity>, SignUpParams> {
  final AuthRepository _repository;

  LinkAnonymousWithEmailUseCase(this._repository);

  @override
  Future<DataState<AuthUserEntity>> call({SignUpParams? params}) {
    assert(params != null, 'SignUpParams must not be null');
    return _repository.linkAnonymousWithEmail(params!);
  }
}
