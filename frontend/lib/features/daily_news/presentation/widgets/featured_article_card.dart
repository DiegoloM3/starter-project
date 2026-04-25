import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/core/constants/colors.dart';
import 'package:news_app_clean_architecture/core/constants/dimensions.dart';
import 'package:news_app_clean_architecture/core/utils/date_formatter.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_avatar.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';

import '../../../../shared/widgets/app_cached_image.dart';

class FeaturedArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final void Function(ArticleEntity article) onArticlePressed;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onArticlePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onArticlePressed(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
        child: Column(
          children: [
            _buildImage(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final double imageHeight = 300;
    return AppCachedImage(
      imageUrl: article.urlToImage ?? '',
      height: imageHeight,
      width: double.infinity,
      borderRadius: BorderRadius.circular(40),
      heroTag: article.heroTag,
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 15,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.titleDark,
            ),
          ),
          const SizedBox(height: 10),
          _buildAuthorRow(),
        ],
      ),
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        ArticleAvatar(
          radius: 12,
          text: article.author ?? 'AU',
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            article.author ?? 'Unknown Author',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.captionText,
            ),
          ),
        ),
        Text(
          DateFormatter.format(article.publishedAt),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.captionText,
          ),
        ),
      ],
    );
  }
}
