import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

/// Device-local user preferences.
abstract interface class SettingsRepository {
  /// Emits the stored settings, starting with the present value, and again
  /// after every save.
  Stream<AppSettings> watchSettings();

  /// Stored settings, or [AppSettings.defaults] when nothing was saved yet.
  Future<AppSettings> getSettings();

  Future<DataState<void>> saveSettings(AppSettings settings);
}
