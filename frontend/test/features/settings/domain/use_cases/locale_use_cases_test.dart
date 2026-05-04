import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_locale_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/set_locale_preference.dart';

class _MockRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockRepository repository;

  setUpAll(() {
    registerFallbackValue(LocalePreference.system);
  });

  setUp(() {
    repository = _MockRepository();
  });

  group('GetLocalePreferenceUseCase', () {
    test('delegates to repository.getLocalePreference and returns its result', () async {
      const expected = DataSuccess(LocalePreference.spanish);
      when(() => repository.getLocalePreference()).thenAnswer((_) async => expected);

      final useCase = GetLocalePreferenceUseCase(repository);
      final result = await useCase.call(params: const NoParams());

      expect(result, expected);
      verify(() => repository.getLocalePreference()).called(1);
    });
  });

  group('SetLocalePreferenceUseCase', () {
    test('forwards the preference to the repository', () async {
      when(() => repository.setLocalePreference(any()))
          .thenAnswer((_) async => const DataSuccess(null));

      final useCase = SetLocalePreferenceUseCase(repository);
      await useCase.call(params: LocalePreference.english);

      verify(() => repository.setLocalePreference(LocalePreference.english))
          .called(1);
    });

    test('throws an assertion error when params is null', () {
      final useCase = SetLocalePreferenceUseCase(repository);
      expect(() => useCase.call(), throwsA(isA<AssertionError>()));
    });
  });
}
