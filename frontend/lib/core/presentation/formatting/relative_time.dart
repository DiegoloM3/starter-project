import 'package:intl/intl.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

/// "Just now", "15 min ago", "3 h ago", "Yesterday", "4 days ago" -- or the
/// plain date once [moment] is more than [showDateAfter] old. [now] is only
/// there for tests.
String relativeTimeOrDate(
  DateTime moment,
  AppLocalizations l10n, {
  required Duration showDateAfter,
  DateTime? now,
}) {
  final elapsed = (now ?? DateTime.now()).difference(moment);
  if (elapsed >= showDateAfter) {
    return DateFormat.yMMMd().format(moment.toLocal());
  }
  if (elapsed.inMinutes < 1) return l10n.justNow;
  if (elapsed.inHours < 1) return l10n.minutesAgo(elapsed.inMinutes);
  if (elapsed.inDays < 1) return l10n.hoursAgo(elapsed.inHours);
  return l10n.daysAgo(elapsed.inDays);
}
