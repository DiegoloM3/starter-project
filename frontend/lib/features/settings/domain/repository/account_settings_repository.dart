import '../../../../core/resources/data_state.dart';

/// Preferences of the signed in account, kept on the server so they follow the user to other devices.
abstract class AccountSettingsRepository {
  Future<DataState<bool>> getNotificationsEnabled();

  Future<DataState<void>> setNotificationsEnabled(bool isEnabled);
}
