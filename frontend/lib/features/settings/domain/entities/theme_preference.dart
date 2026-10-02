import 'package:news_app_clean_architecture/core/util/value_equality.dart';

enum AppTheme { light, dark, system }

/// Theme chosen by the user in Settings.
class ThemePreferenceEntity with ValueEquality {
  /// Until the user chooses one, the app follows the phone's theme.
  static const ThemePreferenceEntity defaultPreference = ThemePreferenceEntity(AppTheme.system);

  final AppTheme theme;

  const ThemePreferenceEntity(this.theme);

  @override
  List<Object?> get props => [theme];
}
