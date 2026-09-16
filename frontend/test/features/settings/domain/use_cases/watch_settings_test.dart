import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';
import 'package:news_app_clean_architecture/features/settings/domain/use_cases/watch_settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  test('re-emits the repository stream', () {
    final repository = MockSettingsRepository();
    const dark = AppSettings(themeMode: AppThemeMode.dark);
    when(() => repository.watchSettings())
        .thenAnswer((_) => Stream.fromIterable([AppSettings.defaults, dark]));

    final stream = WatchSettingsUseCase(repository)(const NoParams());

    expect(stream, emitsInOrder([AppSettings.defaults, dark, emitsDone]));
  });
}
