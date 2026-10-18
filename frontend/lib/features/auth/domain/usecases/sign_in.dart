import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../exceptions/auth_exceptions.dart';
import '../params/sign_in_params.dart';
import 'mock/mock_users.dart';

class SignInUseCase implements UseCase<DataState<UserEntity>, SignInParams> {
  @override
  Future<DataState<UserEntity>> call(SignInParams params) async {
    final errors = params.validationErrors;
    if (errors.isNotEmpty) return DataFailed(AuthValidationException(errors));

    await Future.delayed(mockNetworkDelay);
    final user = params.email == mockJournalistEmail ? mockJournalist : mockReader;
    return DataSuccess(user);
  }
}
