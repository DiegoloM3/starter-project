import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_theme_preference.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  test('saves the theme preference through the repository', () async {
    final repository = MockSettingsRepository();
    const preference = ThemePreferenceEntity(AppTheme.light);
    when(() => repository.saveThemePreference(preference)).thenAnswer((_) async => const DataSuccess(null));

    final dataState = await SaveThemePreferenceUseCase(repository)(params: preference);

    expect(dataState, isA<DataSuccess>());
    verify(() => repository.saveThemePreference(preference)).called(1);
  });
}
