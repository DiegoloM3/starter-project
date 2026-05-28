import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = _configForStatus(status, context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static _StatusConfig _configForStatus(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ArticleStatus.draft:
        return _StatusConfig(label: l10n.draft, color: Colors.blue);
      case ArticleStatus.published:
        return _StatusConfig(label: l10n.published, color: Colors.green);
      case ArticleStatus.archived:
        return _StatusConfig(label: l10n.archived, color: Colors.grey);
      default:
        return _StatusConfig(label: status, color: Colors.grey);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  const _StatusConfig({required this.label, required this.color});
}
