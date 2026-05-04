import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/locale_preferences_service_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LocalePreferencesServiceImpl service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    service = LocalePreferencesServiceImpl(prefs);
  });

  group('LocalePreferencesServiceImpl', () {
    test('getLanguageCode returns null when no value has been stored', () async {
      expect(await service.getLanguageCode(), isNull);
    });

    test('setLanguageCode persists a string and getLanguageCode reads it back', () async {
      await service.setLanguageCode('es');
      expect(await service.getLanguageCode(), 'es');
    });

    test('setLanguageCode(null) clears the stored value', () async {
      await service.setLanguageCode('en');
      expect(await service.getLanguageCode(), 'en');

      await service.setLanguageCode(null);
      expect(await service.getLanguageCode(), isNull);
    });

    test('overwrites an existing value', () async {
      await service.setLanguageCode('en');
      await service.setLanguageCode('es');
      expect(await service.getLanguageCode(), 'es');
    });
  });
}
