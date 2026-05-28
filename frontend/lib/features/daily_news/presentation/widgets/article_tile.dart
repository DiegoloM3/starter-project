import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../config/theme/app_themes.dart';
import '../../domain/entities/article.dart';
import 'reading_time_badge.dart';
import 'status_badge.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity? article;
  final bool isRemovable;
  final bool showStatus;
  final bool showReadingTime;
  final bool showActions;
  final bool showDivider;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;
  final void Function(ArticleEntity article)? onEdit;
  final void Function(ArticleEntity article)? onDelete;

  const ArticleWidget({
    Key? key,
    this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.showStatus = false,
    this.showReadingTime = false,
    this.showActions = false,
    this.showDivider = true,
    this.onRemove,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                const SizedBox(width: 12),
                Expanded(child: _buildContent(context)),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.border),
          ),
      ],
    );
  }

  Widget _buildThumbnail() {
    final imageUrl = article?.thumbnailUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.ink.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.image_outlined, color: AppColors.t3, size: 24),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 70,
          height: 70,
          color: AppColors.ink.withValues(alpha: 0.08),
        ),
        errorWidget: (_, __, ___) => Container(
          width: 70,
          height: 70,
          color: AppColors.ink.withValues(alpha: 0.08),
          child: const Icon(Icons.broken_image_outlined,
              color: AppColors.t3, size: 20),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: status badge + actions
        if (showStatus || showActions) _buildTopRow(context),
        // Title
        Text(
          article?.title ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.serif(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.t1,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 5),
        // Meta row
        _buildMetaRow(context),
      ],
    );
  }

  Widget _buildTopRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: (showStatus && article?.status != null)
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: StatusBadge(status: article!.status!),
                  )
                : const SizedBox.shrink(),
          ),
          if (showActions) ...[
            _buildActionButton(
              icon: Icons.edit_outlined,
              color: AppColors.t2,
              onTap: () {
                if (onEdit != null) onEdit!(article!);
              },
            ),
            _buildActionButton(
              icon: Icons.delete_outline,
              color: AppColors.error.withValues(alpha: 0.6),
              onTap: () {
                if (onDelete != null) onDelete!(article!);
              },
            ),
          ],
          if (isRemovable)
            _buildActionButton(
              icon: Icons.remove_circle_outline,
              color: AppColors.error,
              onTap: () {
                if (onRemove != null) onRemove!(article!);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context) {
    final children = <Widget>[];

    if (showReadingTime && article?.readingTimeMinutes != null) {
      children.add(
        Flexible(child: ReadingTimeBadge(minutes: article!.readingTimeMinutes!)),
      );
    }

    if (article?.publishedAt != null && article!.publishedAt!.isNotEmpty) {
      if (children.isNotEmpty) children.add(_dot());
      children.add(
        Flexible(
          child: Text(
            article!.publishedAt!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              fontSize: 11,
              color: AppColors.t3,
            ),
          ),
        ),
      );
    }

    if (article?.authorName != null && article!.authorName!.isNotEmpty) {
      if (children.isNotEmpty) children.add(_dot());
      children.add(
        Flexible(
          child: Text(
            article!.authorName!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.sans(
              fontSize: 11,
              color: AppColors.t2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Row(children: children);
  }

  Widget _dot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: AppTypography.sans(fontSize: 11, color: AppColors.t3),
      ),
    );
  }

  void _onTap() {
    if (onArticlePressed != null && article != null) {
      onArticlePressed!(article!);
    }
  }
}
