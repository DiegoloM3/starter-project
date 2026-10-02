import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsLocalDataSource {
  /// The stored theme, or `null` when the user has never chosen one.
  Future<String?> getThemePreference();

  Future<void> saveThemePreference(String theme);
}

/// Keeps the settings on the phone. Throws when the local storage cannot be read or written.
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _themePreferenceKey = 'theme_preference';

  final SharedPreferencesAsync _preferences;

  SettingsLocalDataSourceImpl({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  @override
  Future<String?> getThemePreference() => _preferences.getString(_themePreferenceKey);

  @override
  Future<void> saveThemePreference(String theme) => _preferences.setString(_themePreferenceKey, theme);
}
