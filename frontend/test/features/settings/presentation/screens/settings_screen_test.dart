import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/screens/settings_screen.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late SessionHarness session;
  late SettingsHarness settings;

  void createHarnesses() {
    session = SessionHarness();
    settings = SettingsHarness();
    session.signIn(user);
    addTearDown(() async {
      await session.dispose();
      await settings.dispose();
    });
  }

  Future<void> pumpSettings(WidgetTester tester, {Map<String, WidgetBuilder> extra = const {}}) async {
    useScreen(tester, const Size(600, 1600));
    await tester.pump();
    await pumpRoutedApp(
      tester,
      initialLocation: AppRoutes.settings,
      routes: {
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.settingsCategory: (_) => const Text('category picker'),
        ...extra,
      },
      providers: [
        BlocProvider.value(value: session.cubit),
        BlocProvider.value(value: settings.cubit),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the current values and the account email', (tester) async {
    createHarnesses();
    await pumpSettings(tester);

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Top stories'), findsOneWidget);
    expect(find.text('Reading speed'), findsOneWidget);
    expect(find.text('ACCOUNT · ADA@EXAMPLE.COM'), findsOneWidget);
  });

  testWidgets('choosing a theme updates the cubit', (tester) async {
    createHarnesses();
    await pumpSettings(tester);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(settings.cubit.state.settings.themeMode, AppThemeMode.dark);
  });

  testWidgets('the text size slider steps through the sizes', (tester) async {
    createHarnesses();
    await pumpSettings(tester);

    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(3);
    await tester.pumpAndSettle();

    expect(settings.cubit.state.settings.textSize, TextSizePreference.extraLarge);
    expect(find.text('Largest'), findsWidgets);
  });

  testWidgets('feed rows open their pickers', (tester) async {
    createHarnesses();
    await pumpSettings(tester);

    await tester.tap(find.text('Default category'));
    await tester.pumpAndSettle();
    expect(find.text('category picker'), findsOneWidget);
  });

  testWidgets('Sign out calls the session cubit', (tester) async {
    createHarnesses();
    await pumpSettings(tester);

    await tester.ensureVisible(find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    verify(() => session.signOut(any())).called(1);
  });

  testWidgets('a failed account action is announced in a snackbar', (tester) async {
    createHarnesses();
    when(() => session.signOut(any()))
        .thenAnswer((_) async => const DataFailed(Failure.network()));
    await pumpSettings(tester);

    await tester.ensureVisible(find.text('Sign out'));
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('internet connection'), findsOneWidget);
  });

  testWidgets('a rejected settings save is announced too', (tester) async {
    createHarnesses();
    when(() => settings.saveSettings(any()))
        .thenAnswer((_) async => const DataFailed(Failure.unknown()));
    await pumpSettings(tester);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
  });

  testWidgets('About opens the about dialog with the version', (tester) async {
    createHarnesses();
    await pumpSettings(tester);

    await tester.tap(find.textContaining('About Headline News'));
    await tester.pumpAndSettle();

    expect(find.byType(AboutDialog), findsOneWidget);
  });

  testWidgets('choosing a reading speed updates the cubit', (tester) async {
    createHarnesses();
    await pumpSettings(tester);

    await tester.ensureVisible(find.text('Faster'));
    await tester.tap(find.text('Faster'));
    await tester.pumpAndSettle();

    expect(settings.cubit.state.settings.speechRate, SpeechRatePreference.fast);
  });
}
