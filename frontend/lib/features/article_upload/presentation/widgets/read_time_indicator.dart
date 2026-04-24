import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_upload_entity.dart';

class ReadTimeIndicator extends StatelessWidget {
  final String content;

  const ReadTimeIndicator({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final wordCount = trimmed.split(RegExp(r'\s+')).length;
    final readTime = ArticleUploadEntity.calculateReadTime(trimmed);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$wordCount words · $readTime min read',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}
