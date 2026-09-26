import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/presentation/formatters/article_date_formatter.dart';

void main() {
  test('formats a full ISO timestamp as an ISO calendar date', () {
    expect(formatStandardDate('2026-09-23T08:00:00Z'), '2026-09-23');
  });

  test('keeps a date-only value in the standard calendar format', () {
    expect(formatStandardDate('2026-09-23'), '2026-09-23');
  });

  test('formats DateTime values as an ISO calendar date', () {
    expect(formatStandardDate(DateTime(2026, 9, 23, 8)), '2026-09-23');
  });

  test('returns the fallback for null, empty, and invalid values', () {
    expect(formatStandardDate(null), '');
    expect(formatStandardDate(''), '');
    expect(formatStandardDate('not-a-date'), '');
    expect(formatStandardDate('2026-02-30T08:00:00Z'), '');
    expect(
      formatStandardDate('not-a-date', fallback: 'Date unavailable'),
      'Date unavailable',
    );
  });
}
