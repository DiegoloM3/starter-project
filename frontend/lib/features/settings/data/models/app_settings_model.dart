import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';
import 'package:news_app_clean_architecture/features/settings/domain/entities/app_settings.dart';

/// Settings as stored on the device (plain strings per key).
class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    super.themeMode,
    super.textSize,
    super.defaultCategory,
    super.speechRate,
  });

  static const String keyThemeMode = 'settings.themeMode';
  static const String keyTextSize = 'settings.textSize';
  static const String keyDefaultCategory = 'settings.defaultCategory';
  static const String keySpeechRate = 'settings.speechRate';

  /// Unknown or missing values fall back to the defaults, so an old install
  /// never breaks on a renamed option.
  factory AppSettingsModel.fromRawData(Map<String, String?> raw) {
    return AppSettingsModel(
      themeMode: _enumByName(AppThemeMode.values, raw[keyThemeMode]) ?? AppThemeMode.system,
      textSize: _enumByName(TextSizePreference.values, raw[keyTextSize]) ?? TextSizePreference.medium,
      defaultCategory: NewsCategory.fromApiValue(raw[keyDefaultCategory]),
      speechRate: _enumByName(SpeechRatePreference.values, raw[keySpeechRate]) ?? SpeechRatePreference.normal,
    );
  }

  factory AppSettingsModel.fromEntity(AppSettings settings) => AppSettingsModel(
        themeMode: settings.themeMode,
        textSize: settings.textSize,
        defaultCategory: settings.defaultCategory,
        speechRate: settings.speechRate,
      );

  Map<String, String> toRawData() => {
        keyThemeMode: themeMode.name,
        keyTextSize: textSize.name,
        keyDefaultCategory: defaultCategory.apiValue,
        keySpeechRate: speechRate.name,
      };

  AppSettings toEntity() => AppSettings(
        themeMode: themeMode,
        textSize: textSize,
        defaultCategory: defaultCategory,
        speechRate: speechRate,
      );

  static T? _enumByName<T extends Enum>(List<T> values, String? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}
