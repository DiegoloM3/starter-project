import 'package:intl/intl.dart';

/// Human-friendly time phrases for article metadata.
abstract final class RelativeTimeFormatter {
  /// "just now", "5 min ago", "2 h ago", "3 d ago", "1 w ago", "15 Sep 2026".
  static String ago(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = reference.difference(date);

    if (difference.isNegative) return 'scheduled';
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} h ago';
    if (difference.inDays < 7) return '${difference.inDays} d ago';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7} w ago';
    return DateFormat('d MMM yyyy').format(date.toLocal());
  }

  /// "Published 2 hours ago", used in the Reader.
  static String published(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final difference = reference.difference(date);

    if (difference.isNegative) {
      return 'Scheduled for ${DateFormat('d MMM, HH:mm').format(date.toLocal())}';
    }
    if (difference.inMinutes < 1) return 'Published just now';
    if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'Published $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'Published $hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Published $days ${days == 1 ? 'day' : 'days'} ago';
    }
    return 'Published ${DateFormat('d MMM yyyy').format(date.toLocal())}';
  }

  /// "Monday, 15 September" for the Home header.
  static String longDate(DateTime date) => DateFormat('EEEE, d MMMM').format(date);

  /// "Now · 15 Sep, 9:41" style value for the publish-date row.
  static String publishDateValue(DateTime date, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    final formatted = DateFormat('d MMM, H:mm').format(date.toLocal());
    final isNow = reference.difference(date).abs() < const Duration(minutes: 1);
    return isNow ? 'Now · $formatted' : formatted;
  }

  /// "Good morning" / "Good afternoon" / "Good evening" by local hour.
  static String greeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}
