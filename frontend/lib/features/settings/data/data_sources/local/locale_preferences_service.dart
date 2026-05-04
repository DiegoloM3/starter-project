/// Persists the user's BCP 47 language code across app launches. `null`
/// means the user has not made an explicit choice; the app should follow
/// the device locale.
abstract class LocalePreferencesService {
  Future<String?> getLanguageCode();
  Future<void> setLanguageCode(String? code);
}
