import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_upload_entity.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/increment_article_views_usecase.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class CommunityArticleDetailScreen extends StatefulWidget {
  final ArticleUploadEntity article;

  const CommunityArticleDetailScreen({Key? key, required this.article})
      : super(key: key);

  @override
  State<CommunityArticleDetailScreen> createState() =>
      _CommunityArticleDetailScreenState();
}

class _CommunityArticleDetailScreenState
    extends State<CommunityArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    final id = widget.article.id;
    if (id != null) {
      sl<IncrementArticleViewsUseCase>()(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMeta(article),
            const SizedBox(height: 16),
            _buildThumbnail(article),
            const SizedBox(height: 20),
            Text(
              article.content,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(ArticleUploadEntity article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          article.title,
          style: const TextStyle(
            fontFamily: 'Butler',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.person_outline,
                size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              article.authorName,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.access_time_outlined,
                size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              '${article.readTime} min read',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.visibility_outlined,
                size: 14, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              '${article.views}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThumbnail(ArticleUploadEntity article) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.network(
        article.thumbnailUrl,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 220,
          color: AppColors.accentLight,
          child: const Icon(Icons.image_outlined,
              size: 48, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
