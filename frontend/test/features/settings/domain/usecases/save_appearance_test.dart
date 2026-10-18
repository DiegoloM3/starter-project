import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/appearance.dart';
import 'package:news_app_clean_architecture/features/settings/domain/repository/settings_repository.dart';
import 'package:news_app_clean_architecture/features/settings/domain/usecases/save_appearance.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  test('saves the appearance in the repository', () async {
    final repository = MockSettingsRepository();
    when(() => repository.saveAppearance(Appearance.dark)).thenAnswer((_) async => const DataSuccess(null));

    final result = await SaveAppearanceUseCase(repository).call(Appearance.dark);

    expect(result, isA<DataSuccess>());
    verify(() => repository.saveAppearance(Appearance.dark)).called(1);
  });
}
