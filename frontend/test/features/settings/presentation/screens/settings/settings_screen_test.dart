import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/get_theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/theme/app_theme_mode.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/theme/theme_cubit.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/settings/settings_screen.dart';

class MockGetThemePreferenceUseCase extends Mock implements GetThemePreferenceUseCase {}

class MockSaveThemePreferenceUseCase extends Mock implements SaveThemePreferenceUseCase {}

/// User journey "change the theme of the app", with the app drawn by the theme the cubit holds.
void main() {
  late ThemeCubit cubit;

  setUpAll(() => registerFallbackValue(ThemePreferenceEntity.defaultPreference));

  setUp(() {
    final saveThemePreference = MockSaveThemePreferenceUseCase();
    when(() => saveThemePreference(params: any(named: 'params'))).thenAnswer((_) async => const DataSuccess(null));
    cubit = ThemeCubit(MockGetThemePreferenceUseCase(), saveThemePreference);
  });

  tearDown(() => cubit.close());

  Future<void> openSettings(WidgetTester tester) async {
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: BlocBuilder<ThemeCubit, AppTheme>(
        builder: (context, theme) => MaterialApp(
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: theme.themeMode,
          home: const SettingsScreen(),
        ),
      ),
    ));
  }

  Brightness brightnessOfTheScreen(WidgetTester tester) {
    return Theme.of(tester.element(find.byType(SettingsScreen))).brightness;
  }

  testWidgets('offers the light, dark and system themes', (tester) async {
    await openSettings(tester);

    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
  });

  testWidgets('switches the whole app to the dark theme and back', (tester) async {
    await openSettings(tester);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(cubit.state, AppTheme.dark);
    expect(brightnessOfTheScreen(tester), Brightness.dark);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(cubit.state, AppTheme.light);
    expect(brightnessOfTheScreen(tester), Brightness.light);
  });

  testWidgets('each theme brings its own palette', (tester) async {
    await openSettings(tester);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(tester.element(find.byType(SettingsScreen)).palette.background, AppPalette.dark.background);
  });
}
