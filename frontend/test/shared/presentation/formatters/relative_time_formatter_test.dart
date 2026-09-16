import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/relative_time_formatter.dart';

void main() {
  final now = DateTime(2026, 9, 15, 9, 41);

  group('ago', () {
    test('scales from minutes to weeks', () {
      expect(RelativeTimeFormatter.ago(now, now: now), 'just now');
      expect(RelativeTimeFormatter.ago(now.subtract(const Duration(minutes: 5)), now: now), '5 min ago');
      expect(RelativeTimeFormatter.ago(now.subtract(const Duration(hours: 2)), now: now), '2 h ago');
      expect(RelativeTimeFormatter.ago(now.subtract(const Duration(days: 3)), now: now), '3 d ago');
      expect(RelativeTimeFormatter.ago(now.subtract(const Duration(days: 15)), now: now), '2 w ago');
    });

    test('older than a month shows the date, the future says scheduled', () {
      expect(RelativeTimeFormatter.ago(DateTime(2026, 7, 1), now: now), '1 Jul 2026');
      expect(RelativeTimeFormatter.ago(now.add(const Duration(hours: 1)), now: now), 'scheduled');
    });
  });

  group('published', () {
    test('writes full words and singular forms', () {
      expect(RelativeTimeFormatter.published(now, now: now), 'Published just now');
      expect(RelativeTimeFormatter.published(now.subtract(const Duration(minutes: 1)), now: now), 'Published 1 minute ago');
      expect(RelativeTimeFormatter.published(now.subtract(const Duration(hours: 2)), now: now), 'Published 2 hours ago');
      expect(RelativeTimeFormatter.published(now.subtract(const Duration(days: 1)), now: now), 'Published 1 day ago');
      expect(RelativeTimeFormatter.published(DateTime(2026, 8, 1), now: now), 'Published 1 Aug 2026');
    });

    test('a future date reads as scheduled with the time', () {
      expect(
        RelativeTimeFormatter.published(DateTime(2026, 9, 18, 8, 30), now: now),
        'Scheduled for 18 Sep, 08:30',
      );
    });
  });

  test('longDate spells the weekday and month', () {
    expect(RelativeTimeFormatter.longDate(now), 'Tuesday, 15 September');
  });

  test('publishDateValue prefixes "Now" within a minute of now', () {
    expect(RelativeTimeFormatter.publishDateValue(now, now: now), 'Now · 15 Sep, 9:41');
    expect(
      RelativeTimeFormatter.publishDateValue(DateTime(2026, 9, 18, 8, 30), now: now),
      '18 Sep, 8:30',
    );
  });

  test('greeting changes with the hour', () {
    expect(RelativeTimeFormatter.greeting(DateTime(2026, 9, 15, 8)), 'Good morning');
    expect(RelativeTimeFormatter.greeting(DateTime(2026, 9, 15, 13)), 'Good afternoon');
    expect(RelativeTimeFormatter.greeting(DateTime(2026, 9, 15, 20)), 'Good evening');
  });
}
