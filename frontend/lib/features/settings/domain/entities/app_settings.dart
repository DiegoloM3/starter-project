import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_category.dart';

/// Theme preference, independent of Flutter's `ThemeMode` so the domain stays
/// free of framework types.
enum AppThemeMode { system, light, dark }

/// Reading text size. [factor] multiplies the base text scale so that the
/// 17sp body renders at 16 / 17 / 19 / 21 sp.
enum TextSizePreference {
  small(16 / 17, 'Small'),
  medium(1.0, 'Default'),
  large(19 / 17, 'Large'),
  extraLarge(21 / 17, 'Largest');

  final double factor;
  final String label;

  const TextSizePreference(this.factor, this.label);

  TextSizePreference get smaller =>
      index == 0 ? this : TextSizePreference.values[index - 1];

  TextSizePreference get larger => index == TextSizePreference.values.length - 1
      ? this
      : TextSizePreference.values[index + 1];
}

/// Reading-aloud pace, as a multiplier of the device's normal speed.
enum SpeechRatePreference {
  slow(0.8, 'Slower'),
  normal(1.0, 'Normal'),
  fast(1.2, 'Faster');

  final double multiplier;
  final String label;

  const SpeechRatePreference(this.multiplier, this.label);
}

/// User preferences that persist on the device.
class AppSettings extends Equatable {
  final AppThemeMode themeMode;
  final TextSizePreference textSize;
  final NewsCategory defaultCategory;
  final SpeechRatePreference speechRate;

  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.textSize = TextSizePreference.medium,
    this.defaultCategory = NewsCategory.general,
    this.speechRate = SpeechRatePreference.normal,
  });

  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    AppThemeMode? themeMode,
    TextSizePreference? textSize,
    NewsCategory? defaultCategory,
    SpeechRatePreference? speechRate,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      textSize: textSize ?? this.textSize,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      speechRate: speechRate ?? this.speechRate,
    );
  }

  @override
  List<Object?> get props => [themeMode, textSize, defaultCategory, speechRate];
}
