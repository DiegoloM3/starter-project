import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:news_app_clean_architecture/core/models/article_presentation_model.dart';
import 'package:news_app_clean_architecture/core/theme/app_colors.dart';
import 'package:news_app_clean_architecture/core/theme/app_metrics.dart';
import 'package:news_app_clean_architecture/core/theme/app_spacing.dart';
import 'package:news_app_clean_architecture/core/theme/app_typography.dart';
import 'package:news_app_clean_architecture/core/widgets/app_card.dart';
import 'package:news_app_clean_architecture/core/widgets/app_text.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    this.isExpanded = false,
    required this.onTap,
    required this.onReadTap,
    required this.onBookmarkTap,
  });

  final ArticlePresentationModel article;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onReadTap;
  final VoidCallback onBookmarkTap;

  // ── Derived fields ──────────────────────────────────────────────────────

  bool get _hasCategory =>
      article.category != null && article.category!.isNotEmpty;

  String get _date {
    final raw = article.publishedAt;
    if (raw.isEmpty) return '';
    return raw.length >= 10 ? raw.substring(0, 10) : raw;
  }

  String get _readTimeLabel =>
      article.readTime > 0 ? '${article.readTime} min read' : '';

  String? get _imageUrl => article.thumbnailURL;

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: isExpanded ? _buildExpanded() : _buildCollapsed(),
      ),
    );
  }

  // ── Collapsed ───────────────────────────────────────────────────────────

  Widget _buildCollapsed() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppMetrics.h(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasCategory) ...[
                      AppText(
                        article.category!.toUpperCase(),
                        variant: AppTextVariant.labelSmall,
                        color: AppColors.accent,
                      ),
                      SizedBox(height: AppMetrics.h(4)),
                    ],
                    AppText(
                      article.title,
                      variant: AppTextVariant.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppMetrics.h(4)),
                    AppText(
                      article.excerpt,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppMetrics.h(8)),
                    _buildMetaRow(showAvatar: false),
                  ],
                ),
              ),
              SizedBox(width: AppMetrics.w(12)),

              // Right thumbnail
              _buildThumbnail(
                width: 80.r,
                height: 80.r,
                borderRadius: 8.r,
              ),
            ],
          ),
        ),
        const Divider(color: AppColors.border, height: 1),
      ],
    );
  }

  // ── Expanded ────────────────────────────────────────────────────────────

  Widget _buildExpanded() {
    return AppCard(
      variant: AppCardVariant.light,
      padding: EdgeInsets.all(AppMetrics.w(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image with bookmark
          Stack(
            children: [
              _buildThumbnail(
                width: double.infinity,
                height: 200.h,
                borderRadius: 12.r,
              ),
              Positioned(
                top: AppMetrics.h(8),
                right: AppMetrics.w(8),
                child: _buildBookmarkButton(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (_hasCategory) ...[
            AppText(
              article.category!.toUpperCase(),
              variant: AppTextVariant.labelSmall,
              color: AppColors.accent,
            ),
            SizedBox(height: AppMetrics.h(4)),
          ],
          AppText(
            article.title,
            variant: AppTextVariant.headlineMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppMetrics.h(6)),
          AppText(
            article.excerpt,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.md),
          _buildMetaRow(showAvatar: true),
          SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onReadTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Read article →',
                style: AppTypography.labelLarge
                    .copyWith(color: AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────

  Widget _buildMetaRow({required bool showAvatar}) {
    return Row(
      children: [
        if (showAvatar) ...[
          CircleAvatar(
            radius: 12.r,
            backgroundColor: AppColors.surface,
            child: Icon(
              Icons.person,
              size: 14.r,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: AppMetrics.w(6)),
        ],
        Expanded(
          child: Text(
            [article.authorName, _date, _readTimeLabel]
                .where((s) => s.isNotEmpty)
                .join('  ·  '),
            style: AppTypography.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!isExpanded) ...[
          SizedBox(width: AppMetrics.w(8)),
          _buildBookmarkButton(),
        ],
      ],
    );
  }

  Widget _buildBookmarkButton() {
    return GestureDetector(
      onTap: onBookmarkTap,
      child: Container(
        width: 28.r,
        height: 28.r,
        decoration: BoxDecoration(
          color: AppColors.background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.bookmark_border,
          size: 16.r,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildThumbnail({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 24.r, color: AppColors.border),
    );

    if (_imageUrl == null || _imageUrl!.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: _imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      ),
    );
  }
}
