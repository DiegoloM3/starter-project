import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/presentation/bloc/settings/settings_cubit.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  late SettingsHarness harness;

  setUp(() => harness = SettingsHarness());
  tearDown(() => harness.dispose());

  test('starts with the defaults and then takes whatever the stream says', () async {
    expect(harness.cubit.state, const SettingsState());

    const stored = AppSettings(themeMode: AppThemeMode.dark, textSize: TextSizePreference.large);
    harness.settings.add(stored);
    await flush();

    expect(harness.cubit.state.settings, stored);
  });

  test('setThemeMode applies at once and persists', () async {
    await harness.cubit.setThemeMode(AppThemeMode.light);

    expect(harness.cubit.state.settings.themeMode, AppThemeMode.light);
    verify(() => harness.saveSettings(
          AppSettings.defaults.copyWith(themeMode: AppThemeMode.light),
        )).called(1);
  });

  test('an unchanged value is not saved again', () async {
    await harness.cubit.setThemeMode(AppThemeMode.system);

    verifyNever(() => harness.saveSettings(any()));
  });

  test('a rejected save rolls back and reports the failure', () async {
    const failure = Failure.unknown();
    when(() => harness.saveSettings(any())).thenAnswer((_) async => const DataFailed(failure));

    final states = <SettingsState>[];
    final subscription = harness.cubit.stream.listen(states.add);
    await harness.cubit.setTextSize(TextSizePreference.large);
    await flush();
    await subscription.cancel();

    expect(states.first.settings.textSize, TextSizePreference.large);
    expect(states.last.settings.textSize, TextSizePreference.medium);
    expect(states.last.saveFailure, failure);
  });

  test('the next successful change clears the reported failure', () async {
    when(() => harness.saveSettings(any()))
        .thenAnswer((_) async => const DataFailed(Failure.unknown()));
    await harness.cubit.setTextSize(TextSizePreference.large);
    when(() => harness.saveSettings(any())).thenAnswer((_) async => const DataSuccess(null));

    await harness.cubit.setTextSize(TextSizePreference.small);

    expect(harness.cubit.state.saveFailure, isNull);
  });

  test('increase and decrease step through the text sizes and clamp', () async {
    await harness.cubit.increaseTextSize();
    expect(harness.cubit.state.settings.textSize, TextSizePreference.large);

    await harness.cubit.increaseTextSize();
    await harness.cubit.increaseTextSize();
    expect(harness.cubit.state.settings.textSize, TextSizePreference.extraLarge);

    await harness.cubit.decreaseTextSize();
    expect(harness.cubit.state.settings.textSize, TextSizePreference.large);
  });

  test('setDefaultCategory and setSpeechRate store the domain values', () async {
    await harness.cubit.setDefaultCategory(NewsCategory.health);
    await harness.cubit.setSpeechRate(SpeechRatePreference.fast);

    expect(harness.cubit.state.settings.defaultCategory, NewsCategory.health);
    expect(harness.cubit.state.settings.speechRate, SpeechRatePreference.fast);
  });
}
