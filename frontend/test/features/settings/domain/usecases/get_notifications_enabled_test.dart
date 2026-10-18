import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/get_notifications_enabled.dart';

import 'notifications_test_data.dart';

void main() {
  test('gets the notifications preference from the repository', () async {
    final repository = MockAccountSettingsRepository();
    when(() => repository.getNotificationsEnabled()).thenAnswer((_) async => const DataSuccess(false));

    final result = await GetNotificationsEnabledUseCase(repository).call(const NoParams());

    expect(result.data, isFalse);
  });
}
