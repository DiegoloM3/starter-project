import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';

abstract class SettingsRepository {
  Future<DataState<LocalePreference>> getLocalePreference();
  Future<DataState<void>> setLocalePreference(LocalePreference preference);
}
