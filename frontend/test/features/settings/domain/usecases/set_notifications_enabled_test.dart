import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/set_notifications_enabled.dart';

import 'notifications_test_data.dart';

void main() {
  test('saves the notifications preference in the repository', () async {
    final repository = MockAccountSettingsRepository();
    when(() => repository.setNotificationsEnabled(false)).thenAnswer((_) async => const DataSuccess(null));

    final result = await SetNotificationsEnabledUseCase(repository).call(false);

    expect(result, isA<DataSuccess>());
    verify(() => repository.setNotificationsEnabled(false)).called(1);
  });
}
