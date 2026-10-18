import '../../../../core/resources/data_state.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/account_settings_repository.dart';

/// Only the preference is stored: sending push notifications needs a Cloud Function.
class SetNotificationsEnabledUseCase implements UseCase<DataState<void>, bool> {
  final AccountSettingsRepository _accountSettingsRepository;

  SetNotificationsEnabledUseCase(this._accountSettingsRepository);

  @override
  Future<DataState<void>> call(bool isEnabled) => _accountSettingsRepository.setNotificationsEnabled(isEnabled);
}
