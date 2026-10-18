import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/data/data_sources/local/settings_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<SettingsLocalDataSource> buildDataSource([Map<String, Object> storedValues = const {}]) async {
    SharedPreferences.setMockInitialValues(storedValues);
    return SettingsLocalDataSource(await SharedPreferences.getInstance());
  }

  test('reads nothing when no appearance was saved', () async {
    final dataSource = await buildDataSource();

    expect(dataSource.readAppearanceId(), isNull);
  });

  test('reads the saved appearance', () async {
    final dataSource = await buildDataSource();

    await dataSource.writeAppearanceId('dark');

    expect(dataSource.readAppearanceId(), 'dark');
  });
}
