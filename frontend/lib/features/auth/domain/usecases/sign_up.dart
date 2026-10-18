import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../exceptions/auth_exceptions.dart';
import '../params/sign_up_params.dart';
import 'mock/mock_users.dart';

class SignUpUseCase implements UseCase<DataState<UserEntity>, SignUpParams> {
  @override
  Future<DataState<UserEntity>> call(SignUpParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(AuthValidationException(errors));

    await Future.delayed(mockNetworkDelay);
    final user = _buildReader(params);
    mockSession.change(user);
    return DataSuccess(user);
  }

  UserEntity _buildReader(SignUpParams params) {
    return UserEntity(
      uid: 'mock-user-${DateTime.now().microsecondsSinceEpoch}',
      firstName: params.firstName,
      lastName: params.lastName,
      bio: '',
      role: UserRole.reader,
    );
  }
}
