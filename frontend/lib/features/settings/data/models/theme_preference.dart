import 'package:news_app_clean_architecture/features/settings/domain/entities/theme_preference.dart';

/// Theme preference as it is kept in the phone's storage: the name of the theme (`light`, `dark`, `system`).
class ThemePreferenceModel extends ThemePreferenceEntity {
  const ThemePreferenceModel(super.theme);

  /// A missing or unknown value falls back to the default preference.
  factory ThemePreferenceModel.fromRawData(String? storedTheme) {
    final theme = AppTheme.values.where((theme) => theme.name == storedTheme).firstOrNull;
    return ThemePreferenceModel(theme ?? ThemePreferenceEntity.defaultPreference.theme);
  }

  factory ThemePreferenceModel.fromEntity(ThemePreferenceEntity entity) {
    return ThemePreferenceModel(entity.theme);
  }

  String toRawData() => theme.name;

  ThemePreferenceEntity toEntity() => ThemePreferenceEntity(theme);
}
