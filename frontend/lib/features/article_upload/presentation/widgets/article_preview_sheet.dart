import 'dart:io';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_upload_entity.dart';
import 'package:news_app_clean_architecture/shared/widgets/view_count_badge.dart';

class ArticlePreviewSheet extends StatefulWidget {
  final String title;
  final String content;
  final String? localThumbnailPath;
  final List<String> tags;
  final int viewCount;
  final VoidCallback onEdit;
  final VoidCallback onPublish;

  const ArticlePreviewSheet({
    Key? key,
    required this.title,
    required this.content,
    this.localThumbnailPath,
    required this.tags,
    this.viewCount = 0,
    required this.onEdit,
    required this.onPublish,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    String? localThumbnailPath,
    required List<String> tags,
    int viewCount = 0,
    required VoidCallback onEdit,
    required VoidCallback onPublish,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ArticlePreviewSheet(
        title: title,
        content: content,
        localThumbnailPath: localThumbnailPath,
        tags: tags,
        viewCount: viewCount,
        onEdit: onEdit,
        onPublish: onPublish,
      ),
    );
  }

  @override
  State<ArticlePreviewSheet> createState() => _ArticlePreviewSheetState();
}

class _ArticlePreviewSheetState extends State<ArticlePreviewSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _titleAnim;
  late final Animation<double> _metaAnim;
  late final Animation<double> _contentAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _titleAnim = _staggered(0.0, 0.45);
    _metaAnim = _staggered(0.2, 0.65);
    _contentAnim = _staggered(0.4, 1.0);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _staggered(double start, double end) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  children: [
                    if (widget.localThumbnailPath != null) _buildThumbnail(),
                    const SizedBox(height: AppSpacing.lg),
                    FadeTransition(opacity: _titleAnim, child: _buildTitle()),
                    const SizedBox(height: AppSpacing.sm),
                    FadeTransition(opacity: _metaAnim, child: _buildMeta()),
                    const SizedBox(height: AppSpacing.lg),
                    if (widget.tags.isNotEmpty)
                      FadeTransition(opacity: _metaAnim, child: _buildTags()),
                    if (widget.tags.isNotEmpty) const SizedBox(height: AppSpacing.lg),
                    FadeTransition(opacity: _contentAnim, child: _buildContent()),
                    const SizedBox(height: AppSpacing.xxxl),
                    _buildActions(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Image.file(
        File(widget.localThumbnailPath!),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.title.isEmpty ? 'Untitled' : widget.title,
      style: AppTextStyles.headline,
    );
  }

  Widget _buildMeta() {
    final readTime = ArticleUploadEntity.calculateReadTime(widget.content);
    final wordCount = widget.content.trim().isEmpty
        ? 0
        : widget.content.trim().split(RegExp(r'\s+')).length;

    return Row(
      children: [
        const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text('$wordCount words · $readTime min read', style: AppTextStyles.caption),
        if (widget.viewCount > 0) ...[
          const SizedBox(width: AppSpacing.md),
          ViewCountBadge(count: widget.viewCount),
        ],
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: widget.tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: Text('#$tag', style: AppTextStyles.tag),
            ),
          )
          .toList(),
    );
  }

  Widget _buildContent() {
    return Text(widget.content, style: AppTextStyles.body);
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onEdit();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.surfaceBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Edit'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPublish();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: const Text(
              'Publish Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
