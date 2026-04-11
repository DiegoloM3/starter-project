import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/buttons/fab_button.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/headers/screen_header.dart';

import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        body: SafeArea(
          child: _buildBody(context),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacing16,
              AppDimensions.spacing16,
              AppDimensions.spacing16,
              0,
            ),
            child: ScreenHeader(
              title: l10n.articleTitle,
              onBackPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
            child: Text(
              article!.title!,
              style: AppTypography.sectionTitle
                  .copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppDimensions.spacing14),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimensions.spacing20),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: AppDimensions.iconXs, color: colors.textPlaceholder),
                const SizedBox(width: AppDimensions.spacing6),
                Text(
                  article!.publishedAt!,
                  style: AppTypography.footnote
                      .copyWith(color: colors.textPlaceholder),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacing20),
          Container(
            width: double.maxFinite,
            height: AppDimensions.articleImageHeight,
            color: colors.bgInput,
            child: Image.network(
              article!.urlToImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(Icons.image_outlined,
                    size: AppDimensions.iconHero,
                    color: colors.textPlaceholder),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacing20),
            child: Text(
              '${article!.description ?? ''}\n\n${article!.content ?? ''}',
              style: AppTypography.body.copyWith(
                color: colors.textSecondary,
                height: AppDimensions.lineHeightLoose,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Builder(
      builder: (context) => FabButton(
        icon: Icons.bookmark,
        onPressed: () => _onFloatingActionButtonPressed(context),
      ),
    );
  }

  void _onFloatingActionButtonPressed(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.accentGreen,
        content: Text(
          l10n.articleSavedSuccess,
          style: AppTypography.label.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}
