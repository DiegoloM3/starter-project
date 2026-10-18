import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import 'mock/mock_users.dart';

class SignOutUseCase implements UseCase<DataState<void>, NoParams> {
  @override
  Future<DataState<void>> call(NoParams params) async {
    await Future.delayed(mockNetworkDelay);
    return const DataSuccess(null);
  }
}
