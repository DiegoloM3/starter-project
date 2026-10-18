import 'package:shared_preferences/shared_preferences.dart';

/// Stores the preferences on the device. Errors of the storage are thrown to the repository.
class SettingsLocalDataSource {
  static const String _appearanceKey = 'appearance';

  final SharedPreferences _preferences;

  SettingsLocalDataSource(this._preferences);

  String? readAppearanceId() => _preferences.getString(_appearanceKey);

  Future<void> writeAppearanceId(String appearanceId) => _preferences.setString(_appearanceKey, appearanceId);
}
