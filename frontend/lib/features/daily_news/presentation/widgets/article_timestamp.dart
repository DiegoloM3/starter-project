import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/shared/ui/presentation/relative_time.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

/// Shows when an article was published, the way a reader thinks about it.
///
/// Recent news is relative ("3h ago") because that is what tells a reader
/// whether it is still current; anything older than a week is an absolute
/// date, because "312h ago" tells them nothing.
///
/// The News API hands `publishedAt` over as a string, so parsing failures are
/// a real case and are handled by showing nothing rather than a broken date.
class ArticleTimestamp extends StatelessWidget {
  final String? rawDate;
  final TextStyle? style;

  const ArticleTimestamp({super.key, required this.rawDate, this.style});

  @override
  Widget build(BuildContext context) {
    final label = RelativeTime.formatRaw(
      AppLocalizations.of(context),
      rawDate,
    );

    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(label,
        style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
