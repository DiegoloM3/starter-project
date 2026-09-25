import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/presentation/formatting/relative_time.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations_en.dart';

void main() {
  final now = DateTime(2026, 9, 24, 12);
  String withinADay(Duration elapsed) => relativeTimeOrDate(
        now.subtract(elapsed),
        AppLocalizationsEn(),
        showDateAfter: const Duration(days: 1),
        now: now,
      );

  test('under the cutoff it says how long ago', () {
    expect(withinADay(const Duration(seconds: 30)), 'Just now');
    expect(withinADay(const Duration(minutes: 4)), '4 min ago');
    expect(withinADay(const Duration(hours: 23, minutes: 59)), '23 h ago');
  });

  test('from the cutoff on it gives the real date', () {
    expect(withinADay(const Duration(days: 1)), 'Sep 23, 2026');
    expect(withinADay(const Duration(days: 40)), 'Aug 15, 2026');
  });
}
