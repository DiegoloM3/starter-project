import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_theme_preference.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  test('returns the theme preference from the repository', () async {
    final repository = MockSettingsRepository();
    when(() => repository.getThemePreference())
        .thenAnswer((_) async => const DataSuccess(ThemePreferenceEntity(AppTheme.dark)));

    final dataState = await GetThemePreferenceUseCase(repository)();

    expect(dataState.data, const ThemePreferenceEntity(AppTheme.dark));
  });

  test('the default preference follows the phone', () {
    expect(ThemePreferenceEntity.defaultPreference.theme, AppTheme.system);
  });
}
