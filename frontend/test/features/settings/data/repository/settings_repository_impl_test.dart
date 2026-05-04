import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/locale_preferences_service.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';

class _MockService extends Mock implements LocalePreferencesService {}

void main() {
  late _MockService service;
  late SettingsRepositoryImpl repository;

  setUp(() {
    service = _MockService();
    repository = SettingsRepositoryImpl(service);
  });

  group('SettingsRepositoryImpl.getLocalePreference', () {
    test('returns DataSuccess(english) when service returns "en"', () async {
      when(() => service.getLanguageCode()).thenAnswer((_) async => 'en');

      final result = await repository.getLocalePreference();

      expect(result, isA<DataSuccess<LocalePreference>>());
      expect(result.data, LocalePreference.english);
    });

    test('returns DataSuccess(system) when no value is stored', () async {
      when(() => service.getLanguageCode()).thenAnswer((_) async => null);

      final result = await repository.getLocalePreference();

      expect(result, isA<DataSuccess<LocalePreference>>());
      expect(result.data, LocalePreference.system);
    });

    test('wraps an AppException from the service in DataFailed', () async {
      final exception = UnknownException(message: 'boom');
      when(() => service.getLanguageCode()).thenThrow(exception);

      final result = await repository.getLocalePreference();

      expect(result, isA<DataFailed<LocalePreference>>());
      expect(result.error, exception);
    });

    test('wraps a non-AppException in UnknownException', () async {
      when(() => service.getLanguageCode()).thenThrow(StateError('bad'));

      final result = await repository.getLocalePreference();

      expect(result, isA<DataFailed<LocalePreference>>());
      expect(result.error, isA<UnknownException>());
    });
  });

  group('SettingsRepositoryImpl.setLocalePreference', () {
    test('forwards languageCode "es" to the service for spanish', () async {
      when(() => service.setLanguageCode(any())).thenAnswer((_) async {});

      await repository.setLocalePreference(LocalePreference.spanish);

      verify(() => service.setLanguageCode('es')).called(1);
    });

    test('forwards null to the service for system (clears stored value)', () async {
      when(() => service.setLanguageCode(any())).thenAnswer((_) async {});

      await repository.setLocalePreference(LocalePreference.system);

      verify(() => service.setLanguageCode(null)).called(1);
    });

    test('returns DataSuccess on success', () async {
      when(() => service.setLanguageCode(any())).thenAnswer((_) async {});

      final result = await repository.setLocalePreference(LocalePreference.english);

      expect(result, isA<DataSuccess<void>>());
    });

    test('returns DataFailed when the service throws', () async {
      when(() => service.setLanguageCode(any())).thenThrow(StateError('disk full'));

      final result = await repository.setLocalePreference(LocalePreference.english);

      expect(result, isA<DataFailed<void>>());
    });
  });
}
