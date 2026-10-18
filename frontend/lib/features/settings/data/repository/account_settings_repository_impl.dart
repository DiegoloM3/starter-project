import '../../../../core/resources/data_state.dart';
import '../../domain/repository/account_settings_repository.dart';
import '../data_sources/remote/account_settings_remote_data_source.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  final AccountSettingsRemoteDataSource _remoteDataSource;

  AccountSettingsRepositoryImpl(this._remoteDataSource);

  @override
  Future<DataState<bool>> getNotificationsEnabled() => runAsDataState(_remoteDataSource.readNotificationsEnabled);

  @override
  Future<DataState<void>> setNotificationsEnabled(bool isEnabled) {
    return runAsDataState(() => _remoteDataSource.writeNotificationsEnabled(isEnabled));
  }
}
