import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';

abstract class SettingsRepository {
  Future<DataState<ThemePreferenceEntity>> getThemePreference();

  Future<DataState<void>> saveThemePreference(ThemePreferenceEntity preference);
}
