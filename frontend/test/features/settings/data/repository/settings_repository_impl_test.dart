import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';

class MockSettingsLocalDataSource extends Mock implements SettingsLocalDataSource {}

void main() {
  late MockSettingsLocalDataSource localDataSource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    localDataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(localDataSource);
  });

  group('getThemePreference', () {
    test('returns the stored theme', () async {
      when(() => localDataSource.getThemePreference()).thenAnswer((_) async => 'dark');

      final dataState = await repository.getThemePreference();

      expect(dataState.data, const ThemePreferenceEntity(AppTheme.dark));
    });

    test('returns the default theme when none has been stored', () async {
      when(() => localDataSource.getThemePreference()).thenAnswer((_) async => null);

      final dataState = await repository.getThemePreference();

      expect(dataState.data, ThemePreferenceEntity.defaultPreference);
    });

    test('returns the exception of the storage as a failure', () async {
      final error = Exception('Storage unavailable');
      when(() => localDataSource.getThemePreference()).thenThrow(error);

      final dataState = await repository.getThemePreference();

      expect(dataState, isA<DataFailed>());
      expect(dataState.error, error);
    });
  });

  group('saveThemePreference', () {
    test('stores the name of the theme', () async {
      when(() => localDataSource.saveThemePreference(any())).thenAnswer((_) async {});

      final dataState = await repository.saveThemePreference(const ThemePreferenceEntity(AppTheme.light));

      expect(dataState, isA<DataSuccess>());
      verify(() => localDataSource.saveThemePreference('light')).called(1);
    });

    test('returns the exception of the storage as a failure', () async {
      final error = Exception('Storage unavailable');
      when(() => localDataSource.saveThemePreference(any())).thenThrow(error);

      final dataState = await repository.saveThemePreference(const ThemePreferenceEntity(AppTheme.dark));

      expect(dataState, isA<DataFailed>());
      expect(dataState.error, error);
    });
  });
}
