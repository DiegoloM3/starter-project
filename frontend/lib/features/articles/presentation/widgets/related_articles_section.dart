import 'package:flutter/material.dart';
import 'package:tortutip/config/theme/app_colors.dart';
import 'package:tortutip/config/theme/app_spacing.dart';
import 'package:tortutip/config/theme/app_typography.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/presentation/widgets/related_article_card.dart';
import 'package:tortutip/l10n/app_localizations.dart';

class RelatedArticlesSection extends StatelessWidget {
  final List<ArticleEntity> articles;
  final void Function(String articleId) onArticleTap;

  const RelatedArticlesSection({
    super.key,
    required this.articles,
    required this.onArticleTap,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).articleDetailRelated,
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: articles.length > 4 ? 4 : articles.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, index) => RelatedArticleCard(
            article: articles[index],
            onTap: () => onArticleTap(articles[index].id),
          ),
        ),
      ],
    );
  }
}
