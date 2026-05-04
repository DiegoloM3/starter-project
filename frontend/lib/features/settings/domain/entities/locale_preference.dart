/// User's locale choice. `system` means follow the device locale; explicit
/// values pin the app to a specific language regardless of the device.
///
/// The mapping between this enum and BCP 47 language codes is centralized
/// here so persistence (data layer) and `MaterialApp.locale` (presentation
/// layer) speak the same alphabet.
enum LocalePreference {
  system,
  english,
  spanish;

  /// Maps a stored language code back to the preference. Unknown codes —
  /// or `null`, which represents "no choice persisted yet" — fall through
  /// to [LocalePreference.system].
  static LocalePreference fromLanguageCode(String? code) {
    return switch (code) {
      'en' => LocalePreference.english,
      'es' => LocalePreference.spanish,
      _ => LocalePreference.system,
    };
  }

  /// BCP 47 code suitable for storage. `null` for [LocalePreference.system]
  /// because "follow device" must NOT be persisted as a fixed code; that
  /// would freeze the choice the day it was made.
  String? get languageCode => switch (this) {
        LocalePreference.system => null,
        LocalePreference.english => 'en',
        LocalePreference.spanish => 'es',
      };
}
