import 'package:intl/intl.dart';

import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// When something happened, the way a reader thinks about it.
///
/// Recent is relative ("3h ago") because that is what says whether it is
/// still current; past a week it becomes a date, because "312h ago" tells
/// nobody anything.
abstract final class RelativeTime {
  static String format(
    AppLocalizations l10n,
    DateTime? moment, {
    DateTime? now,
  }) {
    if (moment == null) {
      return '';
    }

    final elapsed = (now ?? DateTime.now()).difference(moment);

    if (elapsed.isNegative || elapsed.inMinutes < 1) {
      return l10n.justNow;
    }
    if (elapsed.inHours < 1) {
      return l10n.minutesAgo(elapsed.inMinutes);
    }
    if (elapsed.inHours < 24) {
      return l10n.hoursAgo(elapsed.inHours);
    }
    if (elapsed.inDays < 7) {
      return l10n.daysAgo(elapsed.inDays);
    }

    // Past a week the date itself is what a reader wants, formatted in
    // whatever language the app is running in.
    return DateFormat.yMMMd(l10n.localeName).format(moment);
  }

  /// The same, for a date that arrives as text.
  ///
  /// The news API hands `publishedAt` over as a string, so a value that is not
  /// a date is a real case and comes back empty rather than broken.
  static String formatRaw(
    AppLocalizations l10n,
    String? rawMoment, {
    DateTime? now,
  }) {
    if (rawMoment == null || rawMoment.isEmpty) {
      return '';
    }

    final moment = DateTime.tryParse(rawMoment);

    return moment == null ? '' : format(l10n, moment, now: now);
  }
}
