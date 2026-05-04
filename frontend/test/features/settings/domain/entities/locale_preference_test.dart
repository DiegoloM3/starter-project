import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';

void main() {
  group('LocalePreference.fromLanguageCode', () {
    test('returns english for "en"', () {
      expect(LocalePreference.fromLanguageCode('en'), LocalePreference.english);
    });

    test('returns spanish for "es"', () {
      expect(LocalePreference.fromLanguageCode('es'), LocalePreference.spanish);
    });

    test('returns system for null (no preference persisted)', () {
      expect(LocalePreference.fromLanguageCode(null), LocalePreference.system);
    });

    test('returns system for unsupported language codes', () {
      expect(LocalePreference.fromLanguageCode('fr'), LocalePreference.system);
      expect(LocalePreference.fromLanguageCode(''), LocalePreference.system);
    });
  });

  group('LocalePreference.languageCode', () {
    test('english → "en"', () {
      expect(LocalePreference.english.languageCode, 'en');
    });

    test('spanish → "es"', () {
      expect(LocalePreference.spanish.languageCode, 'es');
    });

    test('system → null so the persistence layer can clear the stored key', () {
      expect(LocalePreference.system.languageCode, isNull);
    });
  });
}
