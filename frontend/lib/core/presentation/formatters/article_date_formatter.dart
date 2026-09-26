/// Formats article and comment dates for presentation.
///
/// Source timestamps remain unchanged in the data and domain layers. This
/// formatter intentionally exposes only the ISO 8601 calendar date to users.
String formatStandardDate(Object? value, {String fallback = ''}) {
  final date = switch (value) {
    DateTime value => value,
    String value => _parseTimestamp(value),
    _ => null,
  };

  if (date == null) return fallback;

  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

DateTime? _parseTimestamp(String value) {
  final trimmed = value.trim();
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return null;

  final calendarMatch =
      RegExp(r'^([+-]?\d{4,})-(\d{2})-(\d{2})').firstMatch(trimmed);
  if (calendarMatch == null) return parsed;

  final year = int.parse(calendarMatch.group(1)!);
  final month = int.parse(calendarMatch.group(2)!);
  final day = int.parse(calendarMatch.group(3)!);
  if (month < 1 || month > 12 || day < 1) return null;

  final daysInMonth = DateTime.utc(year, month + 1, 0).day;
  return day <= daysInMonth ? parsed : null;
}
