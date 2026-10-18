import '../../../../core/resources/data_state.dart';
import '../../domain/entities/appearance.dart';
import '../../domain/repository/settings_repository.dart';
import '../data_sources/local/settings_local_data_source.dart';

/// The appearance is saved by its id. An enum cannot be extended, so there is no model for it.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<DataState<Appearance>> getAppearance() {
    return runAsDataState(() async => Appearance.fromId(_localDataSource.readAppearanceId()));
  }

  @override
  Future<DataState<void>> saveAppearance(Appearance appearance) {
    return runAsDataState(() => _localDataSource.writeAppearanceId(appearance.id));
  }
}
