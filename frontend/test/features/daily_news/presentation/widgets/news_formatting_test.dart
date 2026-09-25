import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/news_formatting.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_en.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_es.dart';

void main() {
  final now = DateTime.utc(2026, 9, 24, 12);
  String ago(Duration elapsed, {bool spanish = false}) => timeAgo(
        now.subtract(elapsed).toIso8601String(),
        spanish ? AppLocalizationsEs() : AppLocalizationsEn(),
        now: now,
      );

  test('says how long ago a story was published', () {
    expect(ago(const Duration(seconds: 20)), 'Just now');
    expect(ago(const Duration(minutes: 15)), '15 min ago');
    expect(ago(const Duration(hours: 3)), '3 h ago');
    expect(ago(const Duration(days: 1)), 'Yesterday');
    expect(ago(const Duration(days: 4)), '4 days ago');
  });

  test('speaks the chosen language', () {
    expect(ago(const Duration(minutes: 15), spanish: true), 'hace 15 min');
    expect(ago(const Duration(days: 1), spanish: true), 'Ayer');
  });

  test('is empty when the date is missing or broken', () {
    expect(timeAgo(null, AppLocalizationsEn(), now: now), isEmpty);
    expect(timeAgo('not a date', AppLocalizationsEn(), now: now), isEmpty);
  });
}
