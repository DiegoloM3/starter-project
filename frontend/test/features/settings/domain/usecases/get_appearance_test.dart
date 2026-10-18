import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/appearance.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/get_appearance.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  test('gets the appearance from the repository', () async {
    final repository = MockSettingsRepository();
    when(() => repository.getAppearance()).thenAnswer((_) async => const DataSuccess(Appearance.dark));

    final result = await GetAppearanceUseCase(repository).call(const NoParams());

    expect(result.data, Appearance.dark);
  });
}
