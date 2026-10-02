import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Follows who is signed in. It returns a stream instead of a single result, so it implements
/// [StreamUseCase] rather than [UseCase], whose `call` returns a `Future`.
class WatchSessionUseCase implements StreamUseCase<UserEntity?, void> {
  final AuthRepository _authRepository;

  WatchSessionUseCase(this._authRepository);

  @override
  Stream<UserEntity?> call({void params}) => _authRepository.watchSession();
}
