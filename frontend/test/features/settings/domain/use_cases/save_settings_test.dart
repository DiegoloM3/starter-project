import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/save_settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('forwards the settings', () async {
    final repository = MockSettingsRepository();
    const dark = AppSettings(themeMode: AppThemeMode.dark);
    when(() => repository.saveSettings(dark)).thenAnswer((_) async => const DataSuccess(null));

    final result = await SaveSettingsUseCase(repository)(dark);

    expect(result.isSuccess, isTrue);
    verify(() => repository.saveSettings(dark)).called(1);
  });
}
