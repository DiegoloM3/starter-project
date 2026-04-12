import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/ui_elements/app_icon_button.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/cards/card_news.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/headers/screen_header.dart';

import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../helpers/date_formatter.dart';

class SavedArticles extends HookWidget {
  const SavedArticles({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacing16,
                  AppDimensions.spacing16,
                  AppDimensions.spacing16,
                  0,
                ),
                child: ScreenHeader(
                  title: l10n.savedArticlesTitle,
                  onBackPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: AppDimensions.spacing16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (state is LocalArticlesDone) {
          return _buildArticlesList(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesList(
      BuildContext context, List<ArticleEntity> articles) {
    if (articles.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Center(
        child: Text(
          l10n.noSavedArticles,
          style:
              AppTypography.body.copyWith(color: context.colors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacing16),
      itemCount: articles.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: AppDimensions.spacing16),
      itemBuilder: (context, index) {
        final article = articles[index];
        return CardNews(
          title: article.title ?? '',
          description: article.description,
          date: formatArticleDate(article.publishedAt),
          imageUrl: article.urlToImage,
          onTap: () => _onArticlePressed(context, article),
          trailing: AppIconButton(
            icon: Icons.delete_outline,
            size: AppDimensions.buttonHeight,
            iconColor: AppColors.destructive,
            circular: false,
            onPressed: () => _onRemoveArticle(context, article),
          ),
        );
      },
    );
  }

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    BlocProvider.of<LocalArticleBloc>(context).add(RemoveArticle(article));
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, AppRoutes.articleDetails, arguments: article);
  }
}
