import 'package:intl/intl.dart';

// Renders an ISO 8601 timestamp as a user-friendly publish label.
//
// Strategy: relative time for the first week ("Just now",
// "5 minutes ago", "Yesterday", "3 days ago"), then fall back to an
// absolute date ("Apr 7, 2026") because relative time loses meaning
// beyond that horizon. The **publish time** is always appended as
// `· HH:mm` in the device's local timezone so the user can see exactly
// when the article went live regardless of the relative bucket.
//
// Examples:
//   Just now · 14:30
//   3 hours ago · 11:30
//   Yesterday · 16:39
//   3 days ago · 09:12
//   Apr 1, 2026 · 09:12
//
// `now` is injectable so tests can assert without depending on wall-clock
// time. Production callers omit it and get `DateTime.now()`.
//
// Inputs that cannot be parsed (null, empty, garbage) return `""` instead
// of throwing — every call site renders the result directly in a `Text`
// widget and must tolerate the empty case.
String formatPublishedAt(String? iso, {DateTime? now}) {
  if (iso == null || iso.isEmpty) return '';
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return '';

  final current = now ?? DateTime.now();
  final diff = current.difference(parsed);
  final timeSuffix = DateFormat('HH:mm').format(parsed.toLocal());

  String withTime(String label) => '$label · $timeSuffix';

  // Clamp future timestamps (server/client clock skew) to "Just now".
  if (diff.isNegative) return withTime('Just now');

  if (diff.inSeconds < 60) return withTime('Just now');

  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return withTime(m == 1 ? '1 minute ago' : '$m minutes ago');
  }

  if (diff.inHours < 24) {
    final h = diff.inHours;
    return withTime(h == 1 ? '1 hour ago' : '$h hours ago');
  }

  if (diff.inDays < 2) return withTime('Yesterday');

  if (diff.inDays < 7) return withTime('${diff.inDays} days ago');

  return withTime(DateFormat('MMM d, y').format(parsed.toLocal()));
}
