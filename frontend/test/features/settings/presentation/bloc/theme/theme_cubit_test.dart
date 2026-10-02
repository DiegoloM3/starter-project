import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/theme/app_theme_mode.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/theme/theme_cubit.dart';

class MockGetThemePreferenceUseCase extends Mock implements GetThemePreferenceUseCase {}

class MockSaveThemePreferenceUseCase extends Mock implements SaveThemePreferenceUseCase {}

void main() {
  late MockGetThemePreferenceUseCase getThemePreference;
  late MockSaveThemePreferenceUseCase saveThemePreference;
  late ThemeCubit cubit;

  setUpAll(() => registerFallbackValue(ThemePreferenceEntity.defaultPreference));

  setUp(() {
    getThemePreference = MockGetThemePreferenceUseCase();
    saveThemePreference = MockSaveThemePreferenceUseCase();
    cubit = ThemeCubit(getThemePreference, saveThemePreference);
    when(() => saveThemePreference(params: any(named: 'params'))).thenAnswer((_) async => const DataSuccess(null));
  });

  tearDown(() => cubit.close());

  test('follows the phone until the saved preference is loaded', () {
    expect(cubit.state, AppTheme.system);
  });

  test('shows the saved theme once it is loaded', () async {
    when(() => getThemePreference())
        .thenAnswer((_) async => const DataSuccess(ThemePreferenceEntity(AppTheme.dark)));

    await cubit.loadTheme();

    expect(cubit.state, AppTheme.dark);
  });

  test('keeps following the phone when the saved preference cannot be read', () async {
    when(() => getThemePreference()).thenAnswer((_) async => DataFailed(Exception('Storage unavailable')));

    await cubit.loadTheme();

    expect(cubit.state, AppTheme.system);
  });

  test('shows the chosen theme and saves it', () async {
    await cubit.selectTheme(AppTheme.light);

    expect(cubit.state, AppTheme.light);
    verify(() => saveThemePreference(params: const ThemePreferenceEntity(AppTheme.light))).called(1);
  });

  test('maps every theme to how Flutter shows it', () {
    expect(AppTheme.light.themeMode, ThemeMode.light);
    expect(AppTheme.dark.themeMode, ThemeMode.dark);
    expect(AppTheme.system.themeMode, ThemeMode.system);
  });
}
