import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/core/utils/format_published_at.dart';

// Pins spec 010 v1.1.0 — the formatter always appends "· HH:mm" in local
// time. Tests compute the expected time suffix dynamically from the same
// ISO input so they remain deterministic regardless of the machine's
// timezone.
void main() {
  final now = DateTime.utc(2026, 4, 8, 12, 0, 0);

  String iso(Duration d) => now.subtract(d).toIso8601String();

  String expectedSuffix(String isoString) =>
      DateFormat('HH:mm').format(DateTime.parse(isoString).toLocal());

  String expected(String label, String isoString) =>
      '$label · ${expectedSuffix(isoString)}';

  group('formatPublishedAt', () {
    group('invalid input', () {
      test('null returns empty string', () {
        expect(formatPublishedAt(null, now: now), '');
      });

      test('empty string returns empty string', () {
        expect(formatPublishedAt('', now: now), '');
      });

      test('garbage returns empty string and does not throw', () {
        expect(formatPublishedAt('not-a-date', now: now), '');
      });
    });

    group('relative branches always include the local time', () {
      test('future timestamp is clamped to "Just now"', () {
        final future = now.add(const Duration(hours: 3)).toIso8601String();
        expect(formatPublishedAt(future, now: now),
            expected('Just now', future));
      });

      test('less than 60 seconds → "Just now"', () {
        final s = iso(const Duration(seconds: 30));
        expect(formatPublishedAt(s, now: now), expected('Just now', s));
      });

      test('1 minute ago is singular', () {
        final s = iso(const Duration(minutes: 1));
        expect(formatPublishedAt(s, now: now), expected('1 minute ago', s));
      });

      test('5 minutes ago is plural', () {
        final s = iso(const Duration(minutes: 5));
        expect(formatPublishedAt(s, now: now), expected('5 minutes ago', s));
      });

      test('59 minutes ago still uses the minutes branch', () {
        final s = iso(const Duration(minutes: 59));
        expect(formatPublishedAt(s, now: now), expected('59 minutes ago', s));
      });

      test('1 hour ago is singular', () {
        final s = iso(const Duration(hours: 1));
        expect(formatPublishedAt(s, now: now), expected('1 hour ago', s));
      });

      test('3 hours ago is plural', () {
        final s = iso(const Duration(hours: 3));
        expect(formatPublishedAt(s, now: now), expected('3 hours ago', s));
      });

      test('24 hours ago → "Yesterday"', () {
        final s = iso(const Duration(hours: 24));
        expect(formatPublishedAt(s, now: now), expected('Yesterday', s));
      });

      test('47 hours ago still "Yesterday"', () {
        final s = iso(const Duration(hours: 47));
        expect(formatPublishedAt(s, now: now), expected('Yesterday', s));
      });

      test('3 days ago', () {
        final s = iso(const Duration(days: 3));
        expect(formatPublishedAt(s, now: now), expected('3 days ago', s));
      });

      test('6 days ago still uses the days branch', () {
        final s = iso(const Duration(days: 6));
        expect(formatPublishedAt(s, now: now), expected('6 days ago', s));
      });
    });

    group('absolute branch also includes the time', () {
      test('7 days ago flips to the absolute format with HH:mm suffix', () {
        final s = iso(const Duration(days: 7));
        final result = formatPublishedAt(s, now: now);
        // Expect "MMM d, y · HH:mm", e.g. "Apr 1, 2026 · 12:00".
        expect(result,
            matches(r'^[A-Z][a-z]+ \d{1,2}, 2026 \u00B7 \d{2}:\d{2}$'));
        expect(result, endsWith('· ${expectedSuffix(s)}'));
      });

      test('30 days ago renders as an absolute date with the time', () {
        final s = iso(const Duration(days: 30));
        final result = formatPublishedAt(s, now: now);
        expect(result,
            matches(r'^[A-Z][a-z]+ \d{1,2}, 2026 \u00B7 \d{2}:\d{2}$'));
        expect(result, endsWith('· ${expectedSuffix(s)}'));
      });
    });

    group('sanity checks on the time suffix format', () {
      test('uses 24h format (no am/pm markers)', () {
        final s = iso(const Duration(hours: 3));
        final result = formatPublishedAt(s, now: now);
        expect(result, isNot(contains('AM')));
        expect(result, isNot(contains('PM')));
        expect(result, isNot(contains('am')));
        expect(result, isNot(contains('pm')));
      });

      test('time suffix is exactly HH:mm zero-padded', () {
        final s = iso(const Duration(hours: 3));
        final result = formatPublishedAt(s, now: now);
        // Extract the suffix and assert HH:mm with exactly two digits each.
        final match = RegExp(r'\u00B7 (\d{2}):(\d{2})$').firstMatch(result);
        expect(match, isNotNull,
            reason: 'expected trailing "· HH:mm" in "$result"');
      });
    });
  });
}
