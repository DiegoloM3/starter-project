import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../config/theme/app_themes.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _configForStatus(status, context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        config.label.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: config.fg, letterSpacing: 1.2),
      ),
    );
  }

  static _StatusConfig _configForStatus(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sem = context.semantic;
    switch (status) {
      case ArticleStatus.draft:
        return _StatusConfig(
          label: l10n.draft,
          fg: sem.draftFg,
          bg: sem.draftBg,
        );
      case ArticleStatus.published:
        return _StatusConfig(
          label: l10n.published,
          fg: sem.publishedFg,
          bg: sem.publishedBg,
        );
      case ArticleStatus.archived:
        return _StatusConfig(
          label: l10n.archived,
          fg: sem.archivedFg,
          bg: sem.archivedBg,
        );
      default:
        return _StatusConfig(
          label: status,
          fg: sem.archivedFg,
          bg: sem.archivedBg,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color fg;
  final Color bg;

  const _StatusConfig({
    required this.label,
    required this.fg,
    required this.bg,
  });
}
