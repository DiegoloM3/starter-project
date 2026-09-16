import 'package:news_app_clean_architecture/features/settings/data/models/app_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists settings in the platform's key-value store, one set per account:
/// every key is prefixed with the scope (the account id) it belongs to.
class SettingsLocalDataSource {
  final SharedPreferences _preferences;

  SettingsLocalDataSource(this._preferences);

  static const List<String> keys = [
    AppSettingsModel.keyThemeMode,
    AppSettingsModel.keyTextSize,
    AppSettingsModel.keyDefaultCategory,
    AppSettingsModel.keySpeechRate,
  ];

  static String scopedKey(String scope, String key) => '$scope.$key';

  AppSettingsModel read(String scope) {
    return AppSettingsModel.fromRawData({
      for (final key in keys) key: _preferences.getString(scopedKey(scope, key)),
    });
  }

  Future<void> write(String scope, AppSettingsModel model) async {
    for (final entry in model.toRawData().entries) {
      await _preferences.setString(scopedKey(scope, entry.key), entry.value);
    }
  }
}
