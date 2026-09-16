import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/credentials.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/models/app_settings_model.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/in_memory_auth_repository.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late InMemoryAuthRepository auth;
  late SettingsRepositoryImpl repository;

  Future<SettingsRepositoryImpl> newRepository() async =>
      SettingsRepositoryImpl(SettingsLocalDataSource(await SharedPreferences.getInstance()), auth);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = InMemoryAuthRepository(latency: Duration.zero);
    await auth.signUpWithEmail(const SignUpParams(displayName: 'Ada', email: 'ada@example.com', password: 'secret123'));
    repository = await newRepository();
  });
  tearDown(() async {
    await repository.dispose();
    await auth.dispose();
  });

  test('starts with the defaults and persists a save for the next read', () async {
    expect(await repository.getSettings(), AppSettings.defaults);

    const changed = AppSettings(themeMode: AppThemeMode.dark, defaultCategory: NewsCategory.health);
    expect((await repository.saveSettings(changed)).isSuccess, isTrue);

    expect(await repository.getSettings(), changed);
    final fresh = await newRepository();
    expect(await fresh.getSettings(), changed);
    await fresh.dispose();
  });

  test('watchSettings emits the current value first, then every save', () async {
    final emitted = <AppSettings>[];
    final sub = repository.watchSettings().listen(emitted.add);
    await flush();
    await repository.saveSettings(const AppSettings(textSize: TextSizePreference.large));
    await flush();
    await sub.cancel();

    expect(emitted, [AppSettings.defaults, const AppSettings(textSize: TextSizePreference.large)]);
  });

  test('each account has its own settings; signing out shows the defaults', () async {
    await repository.saveSettings(const AppSettings(themeMode: AppThemeMode.dark));
    final emitted = <AppSettings>[];
    final sub = repository.watchSettings().listen(emitted.add);
    await flush();

    await auth.signOut();
    await flush();
    expect(await repository.getSettings(), AppSettings.defaults);

    await auth.signInWithGoogle();
    await flush();
    expect(await repository.getSettings(), AppSettings.defaults);
    await repository.saveSettings(const AppSettings(textSize: TextSizePreference.small));

    await auth.signOut();
    await auth.signInWithEmail(const SignInParams(email: 'ada@example.com', password: 'secret123'));
    await flush();
    await sub.cancel();

    expect(await repository.getSettings(), const AppSettings(themeMode: AppThemeMode.dark));
    expect(emitted.last, const AppSettings(themeMode: AppThemeMode.dark));
  });

  test('the model tolerates unknown stored values', () {
    final model = AppSettingsModel.fromRawData({
      AppSettingsModel.keyThemeMode: 'sepia',
      AppSettingsModel.keyTextSize: null,
      AppSettingsModel.keyDefaultCategory: 'nope',
      AppSettingsModel.keySpeechRate: 'fast',
    });

    expect(model.themeMode, AppThemeMode.system);
    expect(model.textSize, TextSizePreference.medium);
    expect(model.defaultCategory, NewsCategory.general);
    expect(model.speechRate, SpeechRatePreference.fast);
    expect(AppSettingsModel.fromEntity(model.toEntity()).toRawData()[AppSettingsModel.keySpeechRate], 'fast');
  });
}
