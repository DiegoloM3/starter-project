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
        border: Border.all(color: config.borderColor),
      ),
      child: Text(
        config.label.toUpperCase(),
        style: AppTypography.sans(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: config.fg,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static _StatusConfig _configForStatus(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ArticleStatus.draft:
        return _StatusConfig(
          label: l10n.draft,
          fg: AppColors.draftFg,
          bg: AppColors.draftBg,
          borderColor: AppColors.draftBorder,
        );
      case ArticleStatus.published:
        return _StatusConfig(
          label: l10n.published,
          fg: AppColors.publishedFg,
          bg: AppColors.publishedBg,
          borderColor: AppColors.publishedBorder,
        );
      case ArticleStatus.archived:
        return _StatusConfig(
          label: l10n.archived,
          fg: AppColors.archivedFg,
          bg: AppColors.archivedBg,
          borderColor: AppColors.archivedBorder,
        );
      default:
        return _StatusConfig(
          label: status,
          fg: AppColors.archivedFg,
          bg: AppColors.archivedBg,
          borderColor: AppColors.archivedBorder,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color fg;
  final Color bg;
  final Color borderColor;

  const _StatusConfig({
    required this.label,
    required this.fg,
    required this.bg,
    required this.borderColor,
  });
}
