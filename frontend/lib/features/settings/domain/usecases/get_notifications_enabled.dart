import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/account_settings_repository.dart';

class GetNotificationsEnabledUseCase implements UseCase<DataState<bool>, NoParams> {
  final AccountSettingsRepository _accountSettingsRepository;

  GetNotificationsEnabledUseCase(this._accountSettingsRepository);

  @override
  Future<DataState<bool>> call(NoParams params) => _accountSettingsRepository.getNotificationsEnabled();
}
