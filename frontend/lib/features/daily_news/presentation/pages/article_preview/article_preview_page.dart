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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildPreviewBanner(context)),
          SliverToBoxAdapter(child: _buildArticleContent(context)),
          const SliverToBoxAdapter(child: SizedBox(height: 140)),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: cs.surface,
      leading: IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: () => Navigator.pop(context, false),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.md),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: AppSpacing.xs),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.07),
            border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Text(
            'PREVIEW',
            style: tt.labelSmall?.copyWith(color: cs.primary),
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

  Widget _buildPreviewBanner(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.04),
        border: Border(
          bottom: BorderSide(color: cs.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Preview — this article is not yet published',
            style: tt.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            articleState.title.isNotEmpty ? articleState.title : l10n.untitled,
            style: tt.headlineMedium?.copyWith(
              fontSize: 24,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // Author + meta
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'A',
                  style: tt.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.preview,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Draft · ${articleState.readingTimeMinutes} min read',
                    style: tt.labelMedium?.copyWith(
                      color: cs.outlineVariant,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Decorative rule
          Row(
            children: [
              Expanded(child: Divider(height: 1, color: cs.outline)),
              Container(
                width: 14,
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ),
              Expanded(child: Divider(height: 1, color: cs.outline)),
            ],
          ),
          const SizedBox(height: 18),
          // Description (italic standfirst)
          if (articleState.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Text(
                articleState.description,
                style: tt.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                  height: 1.65,
                ),
              ),
            ),
          // Content
          Text(
            articleState.content.isNotEmpty
                ? articleState.content
                : l10n.noContentYet,
            style: tt.bodyLarge?.copyWith(
              color: articleState.content.isNotEmpty
                  ? cs.onSurface
                  : cs.outlineVariant,
            ),
          ),
          // End ornament
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Text(
                '— ◆ —',
                style: tt.headlineSmall?.copyWith(
                  color: cs.outlineVariant,
                  fontWeight: FontWeight.w700,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.md, AppSpacing.gutter, AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline)),
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
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  '→  ${l10n.publishArticle}',
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
                  foregroundColor: cs.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  side: BorderSide(color: cs.outline, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  '← ${l10n.keepEditing}',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
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
