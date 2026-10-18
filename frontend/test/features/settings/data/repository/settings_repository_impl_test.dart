import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:news_app_clean_architecture/features/settings/data/repository/settings_repository_impl.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/appearance.dart';

class MockSettingsLocalDataSource extends Mock implements SettingsLocalDataSource {}

void main() {
  late MockSettingsLocalDataSource dataSource;
  late SettingsRepositoryImpl repository;

  setUp(() {
    dataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(dataSource);
  });

  test('returns the saved appearance', () async {
    when(() => dataSource.readAppearanceId()).thenReturn('dark');

    final result = await repository.getAppearance();

    expect(result.data, Appearance.dark);
  });

  test('returns the light appearance when none was saved', () async {
    when(() => dataSource.readAppearanceId()).thenReturn(null);

    final result = await repository.getAppearance();

    expect(result.data, Appearance.light);
  });

  test('saves the id of the appearance', () async {
    when(() => dataSource.writeAppearanceId('dark')).thenAnswer((_) async {});

    final result = await repository.saveAppearance(Appearance.dark);

    expect(result, isA<DataSuccess>());
    verify(() => dataSource.writeAppearanceId('dark')).called(1);
  });

  test('fails when the storage throws', () async {
    final error = Exception('storage unavailable');
    when(() => dataSource.writeAppearanceId(any())).thenThrow(error);

    final result = await repository.saveAppearance(Appearance.dark);

    expect(result.error, error);
  });
}
