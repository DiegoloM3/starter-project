import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/locale_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferencesServiceImpl implements LocalePreferencesService {
  final SharedPreferences _prefs;

  static const String _kLanguageCodeKey = 'settings.locale.languageCode';

  LocalePreferencesServiceImpl(this._prefs);

  @override
  Future<String?> getLanguageCode() async => _prefs.getString(_kLanguageCodeKey);

  @override
  Future<void> setLanguageCode(String? code) async {
    if (code == null) {
      await _prefs.remove(_kLanguageCodeKey);
    } else {
      await _prefs.setString(_kLanguageCodeKey, code);
    }
  }
}
