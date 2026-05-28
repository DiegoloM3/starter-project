import 'dart:io';

import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/create/create_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/status_change_dialog.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

import '../../../../../config/theme/app_themes.dart';

class ArticlePreviewPage extends StatelessWidget {
  final CreateArticleState articleState;

  const ArticlePreviewPage({Key? key, required this.articleState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildPreviewBanner()),
          SliverToBoxAdapter(child: _buildArticleContent(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => Navigator.pop(context, false),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.07),
            border: Border.all(color: AppColors.red.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Text(
            'PREVIEW',
            style: AppTypography.sans(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.red,
              letterSpacing: 1.8,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (articleState.selectedImagePath != null)
          Image.file(
            File(articleState.selectedImagePath!),
            fit: BoxFit.cover,
          )
        else if (articleState.thumbnailUrl != null &&
            articleState.thumbnailUrl!.isNotEmpty)
          Image.network(
            articleState.thumbnailUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildGradientPlaceholder(),
          )
        else
          _buildGradientPlaceholder(),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x40000000), Colors.transparent],
              stops: [0.0, 0.55],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.6, -0.8),
          end: Alignment(0.6, 0.8),
          colors: [Color(0xFF1E3A5F), Color(0xFF2D6A9F)],
        ),
      ),
    );
  }

  Widget _buildPreviewBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: AppColors.red.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Preview — this article is not yet published',
            style: AppTypography.sans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.red,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            articleState.title.isNotEmpty ? articleState.title : l10n.untitled,
            style: AppTypography.serif(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.t1,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          // Author + meta
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'A',
                  style: AppTypography.sans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.preview,
                    style: AppTypography.sans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.t1,
                    ),
                  ),
                  Text(
                    'Draft · ${articleState.readingTimeMinutes} min read',
                    style: AppTypography.sans(fontSize: 10.5, color: AppColors.t3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Decorative rule
          Row(
            children: [
              const Expanded(child: Divider(height: 1, color: AppColors.border)),
              Container(
                width: 14,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Expanded(child: Divider(height: 1, color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 18),
          // Description (italic standfirst)
          if (articleState.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                articleState.description,
                style: AppTypography.serif(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.italic,
                  color: AppColors.t2,
                  height: 1.65,
                ),
              ),
            ),
          // Content
          Text(
            articleState.content.isNotEmpty
                ? articleState.content
                : l10n.noContentYet,
            style: AppTypography.serif(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: articleState.content.isNotEmpty ? AppColors.t1 : AppColors.t3,
              height: 1.82,
            ),
          ),
          // End ornament
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                '— ◆ —',
                style: AppTypography.serif(
                  fontSize: 18,
                  color: AppColors.t3,
                  letterSpacing: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Publish — primary CTA
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => _onPublish(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  '→  ${l10n.publishArticle}',
                  style: AppTypography.sans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Keep Editing — secondary
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.t2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: AppColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  '← ${l10n.keepEditing}',
                  style: AppTypography.sans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.t2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPublish(BuildContext context) async {
    final confirmed =
        await StatusChangeDialog.showPublishConfirmation(context);
    if (confirmed && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}
