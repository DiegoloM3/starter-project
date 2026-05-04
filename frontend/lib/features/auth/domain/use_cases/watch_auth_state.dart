import 'package:news_app_clean_architecture/core/usecase/stream_usecase.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Use case that subscribes to the continuous auth state stream.
///
/// Extends [StreamUseCase] to keep future/stream taxonomy clean (design D3, CG6).
class WatchAuthStateUseCase extends StreamUseCase<AuthUserEntity?, NoParams> {
  final AuthRepository _repository;

  WatchAuthStateUseCase(this._repository);

  @override
  Stream<AuthUserEntity?> call({NoParams? params}) {
    return _repository.watchAuthState();
  }
}
