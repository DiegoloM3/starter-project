import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';

import '../../../../config/theme/app_themes.dart';

class StatusChangeDialog {
  static Future<bool> showPublishConfirmation(BuildContext context) async {
    return await _showDialog(
          context,
          title: 'Publish Article',
          message:
              'Are you sure you want to publish this article? It will be visible to all users.',
          confirmLabel: 'Publish',
          confirmColor: AppColors.red,
        ) ??
        false;
  }

  static Future<bool> showArchiveConfirmation(BuildContext context) async {
    return await _showDialog(
          context,
          title: 'Archive Article',
          message:
              'Are you sure you want to archive this article? This cannot be undone.',
          confirmLabel: 'Archive',
          confirmColor: AppColors.warning,
        ) ??
        false;
  }

  static Future<bool> showConfirmation(
    BuildContext context, {
    required String targetStatus,
  }) {
    switch (targetStatus) {
      case ArticleStatus.published:
        return showPublishConfirmation(context);
      case ArticleStatus.archived:
        return showArchiveConfirmation(context);
      default:
        return Future.value(false);
    }
  }

  static Future<bool?> _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTypography.serif(fontSize: 18)),
        content: Text(
          message,
          style: AppTypography.sans(fontSize: 13.5, color: AppColors.t2, height: 1.55),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTypography.sans(color: AppColors.t2),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Text(
              confirmLabel,
              style: AppTypography.sans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
