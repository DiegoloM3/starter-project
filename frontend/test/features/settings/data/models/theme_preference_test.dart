import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/settings/data/models/theme_preference.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';

void main() {
  group('fromRawData', () {
    for (final theme in AppTheme.values) {
      test('reads a stored "${theme.name}" theme', () {
        expect(ThemePreferenceModel.fromRawData(theme.name).theme, theme);
      });
    }

    test('follows the phone when no theme has been stored yet', () {
      expect(ThemePreferenceModel.fromRawData(null).theme, AppTheme.system);
    });

    test('follows the phone when the stored value is unknown', () {
      expect(ThemePreferenceModel.fromRawData('purple').theme, AppTheme.system);
    });
  });

  test('stores the name of the theme', () {
    expect(const ThemePreferenceModel(AppTheme.dark).toRawData(), 'dark');
  });

  test('converts from and to an entity', () {
    const entity = ThemePreferenceEntity(AppTheme.light);

    final model = ThemePreferenceModel.fromEntity(entity);

    expect(model.toEntity(), entity);
    expect(model.toEntity(), isNot(isA<ThemePreferenceModel>()));
  });
}
