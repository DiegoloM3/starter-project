import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/models/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<DataState<ThemePreferenceEntity>> getThemePreference() async {
    try {
      final storedTheme = await _localDataSource.getThemePreference();
      return DataSuccess(ThemePreferenceModel.fromRawData(storedTheme).toEntity());
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }

  @override
  Future<DataState<void>> saveThemePreference(ThemePreferenceEntity preference) async {
    try {
      await _localDataSource.saveThemePreference(ThemePreferenceModel.fromEntity(preference).toRawData());
      return const DataSuccess(null);
    } on Exception catch (error) {
      return DataFailed(error);
    }
  }
}
