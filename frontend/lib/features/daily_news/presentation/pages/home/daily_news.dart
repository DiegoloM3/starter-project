import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/theme_extensions.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/buttons/fab_button.dart';
import 'package:news_app_clean_architecture/shared/design_system/presentation/widgets/cards/card_news.dart';

import '../../../domain/entities/article.dart';

class DailyNews extends StatelessWidget {
  const DailyNews({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPage();
  }

  PreferredSizeWidget _buildAppbar(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      title: Text(l10n.dailyNewsTitle,
          style: TextStyle(color: colors.textPrimary)),
      actions: [
        GestureDetector(
          onTap: () => _onShowSavedArticlesViewTapped(context),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimensions.spacing14),
            child: Icon(Icons.bookmark, color: colors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildPage() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: const Center(child: CupertinoActivityIndicator()),
          );
        }
        if (state is RemoteArticlesError) {
          return Scaffold(
            appBar: _buildAppbar(context),
            body: const Center(child: Icon(Icons.refresh)),
          );
        }
        if (state is RemoteArticlesDone) {
          return _buildArticlesPage(context, state.articles!);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildArticlesPage(
      BuildContext context, List<ArticleEntity> articles) {
    return Scaffold(
      appBar: _buildAppbar(context),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        itemCount: articles.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.spacing16),
        itemBuilder: (context, index) {
          final article = articles[index];
          return CardNews(
            title: article.title ?? '',
            description: article.description,
            date: article.publishedAt ?? '',
            imageUrl: article.urlToImage,
            onTap: () => _onArticlePressed(context, article),
          );
        },
      ),
      floatingActionButton: FabButton(
        onPressed: () {
          // TODO: REPLACE ROUTE WITH YOUR "ADD ARTICLE" PAGE
        },
      ),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowSavedArticlesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/SavedArticles');
  }
}
