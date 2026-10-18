import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import 'mock/mock_users.dart';

/// Emits the signed in user, or null when nobody is signed in.
class WatchCurrentUserUseCase implements StreamUseCase<UserEntity?, NoParams> {
  @override
  Stream<UserEntity?> call(NoParams params) => mockSession.watch();
}
