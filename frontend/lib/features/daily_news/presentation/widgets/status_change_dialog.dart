import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';

class StatusChangeDialog {
  static Future<bool> showPublishConfirmation(BuildContext context) async {
    return await _showDialog(
          context,
          title: 'Publish Article',
          message:
              'Are you sure you want to publish this article? It will be visible to all users.',
          confirmLabel: 'Publish',
          confirmColor: Colors.green,
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
          confirmColor: Colors.orange,
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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
